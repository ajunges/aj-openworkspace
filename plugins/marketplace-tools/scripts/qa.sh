#!/usr/bin/env bash
# marketplace-tools qa.sh — diagnóstico de saúde do marketplace local
# Uso: bash scripts/qa.sh
# Invocado pelo slash command /marketplace-tools:marketplace-qa
#
# Detecta inconsistências causadas pelos bugs conhecidos do Claude Code:
#   - #13799 cache não invalidado quando marketplace atualiza
#   - #14061 /plugin update não invalida cache
#   - #46081 claude plugin update usa marketplace cache stale

set -Eeuo pipefail
# -E: traps ERR propagam em funções e subshells
# -e: aborta ao primeiro erro não tratado (evita relatório falso-limpo quando algo falha)
# -u: variável indefinida = erro
# -o pipefail: pipe retorna o exit do primeiro comando que falhar (senão esconde erros do meio)
trap 'echo "ERRO em qa.sh linha $LINENO: $BASH_COMMAND" >&2' ERR

# PATH hardening — script roda em processo bash dedicado, env é o do sistema
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# --- Sanity check ---
test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
for cmd in jq git find awk; do
  command -v "$cmd" >/dev/null || { echo "ERRO: $cmd não instalado."; exit 1; }
done
test -f "$HOME/.claude/plugins/installed_plugins.json"  || { echo "ERRO: installed_plugins.json ausente."; exit 1; }
test -f "$HOME/.claude/plugins/known_marketplaces.json" || { echo "ERRO: known_marketplaces.json ausente."; exit 1; }

# --- Paths e vars principais ---
MKT_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
CLONE_PATH="$HOME/.claude/plugins/marketplaces/$MKT_NAME"
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"
SETTINGS="$HOME/.claude/settings.json"
MKT_JSON=".claude-plugin/marketplace.json"
FINDINGS=$(mktemp) || { echo "ERRO: mktemp falhou"; exit 1; }
TMPDIR_QA=$(mktemp -d) || { echo "ERRO: mktemp -d falhou"; exit 1; }
trap 'rm -rf "$TMPDIR_QA"' EXIT

echo "=== Marketplace QA: $MKT_NAME ==="

# ---------------- 3.1 Clone behind remote ----------------
if [ -d "$CLONE_PATH" ]; then
  if git -C "$CLONE_PATH" fetch origin --quiet 2>/dev/null; then
    LOCAL_HEAD=$(git -C "$CLONE_PATH" rev-parse HEAD)
    TRACKING=$(git -C "$CLONE_PATH" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "origin/main")
    REMOTE_HEAD=$(git -C "$CLONE_PATH" rev-parse "$TRACKING" 2>/dev/null || echo "")
    if [ -n "$REMOTE_HEAD" ] && [ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]; then
      BEHIND=$(git -C "$CLONE_PATH" rev-list --count "$LOCAL_HEAD..$REMOTE_HEAD" 2>/dev/null || echo "?")
      echo "MEDIUM|3.1|*|clone-behind-remote: $BEHIND commits atrás de $TRACKING|yes" >> "$FINDINGS"
    fi
  else
    echo "LOW|3.1|*|fetch-failed: não consegui fetch em $CLONE_PATH (offline ou auth?)|no" >> "$FINDINGS"
  fi
else
  echo "HIGH|3.1|*|marketplace-clone-missing: $CLONE_PATH não existe|no" >> "$FINDINGS"
fi

# ---------------- 3.2 Dangling installPath ----------------
jq -r '.plugins | to_entries[] | "\(.key)\t\(.value[0].installPath)"' "$INSTALLED" > "$TMPDIR_QA/paths.tsv"
while IFS=$'\t' read -r name path; do
  [ -z "$path" ] && continue
  if [ ! -d "$path" ]; then
    echo "HIGH|3.2|$name|dangling-path: $path não existe|yes" >> "$FINDINGS"
  fi
done < "$TMPDIR_QA/paths.tsv"

# ---------------- 3.3 SHA drift (Level 3 com commits afetando) ----------------
if [ -d "$CLONE_PATH" ]; then
  CLONE_HEAD=$(git -C "$CLONE_PATH" rev-parse HEAD)
  jq -r --arg m "$MKT_NAME" '.plugins | to_entries[] | select(.key | endswith("@\($m)")) | "\(.key)\t\(.value[0].gitCommitSha)"' "$INSTALLED" > "$TMPDIR_QA/sha.tsv"
  while IFS=$'\t' read -r name sha; do
    [ "$sha" = "$CLONE_HEAD" ] && continue
    plugin_name="${name%@*}"
    source_type=$(jq -r --arg n "$plugin_name" '.plugins[] | select(.name == $n) | .source | type' "$MKT_JSON")
    [ "$source_type" != "string" ] && continue   # só Level 3
    plugin_path=$(jq -r --arg n "$plugin_name" '.plugins[] | select(.name == $n) | .source' "$MKT_JSON")
    affects=$(git -C "$CLONE_PATH" log --oneline "$sha..$CLONE_HEAD" -- "$plugin_path" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$affects" -gt 0 ]; then
      echo "MEDIUM|3.3|$name|sha-drift: ${sha:0:12} vs ${CLONE_HEAD:0:12} ($affects commits afetando $plugin_path)|yes" >> "$FINDINGS"
    fi
  done < "$TMPDIR_QA/sha.tsv"
fi

# ---------------- 3.4 Version drift (marketplace.json vs installed) ----------------
jq -r --arg m "$MKT_NAME" '.plugins[] | select(.source | type == "string") | "\(.name)\t\(.version // "none")"' "$MKT_JSON" > "$TMPDIR_QA/vers.tsv"
while IFS=$'\t' read -r name mkt_ver; do
  installed_ver=$(jq -r --arg k "$name@$MKT_NAME" '.plugins[$k][0].version // "none"' "$INSTALLED")
  if [ "$installed_ver" != "none" ] && [ "$mkt_ver" != "$installed_ver" ]; then
    echo "MEDIUM|3.4|$name|version-drift: marketplace=$mkt_ver installed=$installed_ver|yes" >> "$FINDINGS"
  fi
done < "$TMPDIR_QA/vers.tsv"

# ---------------- 3.5 Enabled but not installed ----------------
if [ -f "$SETTINGS" ]; then
  jq -r '.enabledPlugins // {} | keys[]' "$SETTINGS" > "$TMPDIR_QA/enabled.txt"
  while read -r key; do
    if ! jq -e --arg k "$key" '.plugins[$k]' "$INSTALLED" >/dev/null 2>&1; then
      echo "HIGH|3.5|$key|enabled-not-installed: presente em settings mas sem entry em installed_plugins|no" >> "$FINDINGS"
    fi
  done < "$TMPDIR_QA/enabled.txt"
fi

# ---------------- 3.6 Cache orphan antigo ----------------
find "$HOME/.claude/plugins/cache" -maxdepth 3 -mindepth 3 -type d > "$TMPDIR_QA/cache.txt"
while read -r dir; do
  mkt=$(basename "$(dirname "$(dirname "$dir")")")
  plug=$(basename "$(dirname "$dir")")
  key="$plug@$mkt"
  installed_path=$(jq -r --arg k "$key" '.plugins[$k][0].installPath // empty' "$INSTALLED")
  if [ "$installed_path" != "$dir" ]; then
    age_days=$(( ( $(date +%s) - $(stat -f %m "$dir") ) / 86400 ))
    if [ "$age_days" -gt 7 ]; then
      echo "LOW|3.6|$key|orphan-cache: $(basename "$dir") idade ${age_days}d não referenciado|yes" >> "$FINDINGS"
    fi
  fi
done < "$TMPDIR_QA/cache.txt"

# ---------------- 3.7 Version duplicated (plugin.json vs marketplace.json) ----------------
# Doc oficial: "avoid setting the version in both places. The plugin manifest always wins silently".
# Se plugin.json tem version E marketplace.json tem version pra mesma entry, o plugin.json vence
# e o bump em marketplace.json fica invisível (bug silencioso já sentido na pele).
jq -r --arg m "$MKT_NAME" '.plugins[] | select(.source | type == "string") | "\(.name)\t\(.source)\t\(.version // "")"' "$MKT_JSON" > "$TMPDIR_QA/l3.tsv"
while IFS=$'\t' read -r name plugin_dir mkt_ver; do
  [ -z "$mkt_ver" ] && continue       # sem version em marketplace.json → não há duplicação possível
  plugin_json_path="$plugin_dir/.claude-plugin/plugin.json"
  [ -f "$plugin_json_path" ] || continue
  pjs_ver=$(jq -r '.version // ""' "$plugin_json_path" 2>/dev/null || echo "")
  if [ -n "$pjs_ver" ]; then
    echo "MEDIUM|3.7|$name|version-duplicated: plugin.json=$pjs_ver marketplace.json=$mkt_ver (plugin.json vence silenciosamente)|yes" >> "$FINDINGS"
  fi
done < "$TMPDIR_QA/l3.tsv"

# ---------------- Relatório ----------------
count_sev() { awk -F'|' -v s="$1" '$1==s{n++}END{print n+0}' "$FINDINGS"; }
N_HIGH=$(count_sev HIGH)
N_MED=$(count_sev MEDIUM)
N_LOW=$(count_sev LOW)
N_TOTAL=$((N_HIGH + N_MED + N_LOW))

echo ""
echo "HIGH ($N_HIGH):"
awk -F'|' '$1=="HIGH"{printf "  [%s] %s: %s [auto-fixable: %s]\n", $2, $3, $4, $5}' "$FINDINGS"
echo ""
echo "MEDIUM ($N_MED):"
awk -F'|' '$1=="MEDIUM"{printf "  [%s] %s: %s [auto-fixable: %s]\n", $2, $3, $4, $5}' "$FINDINGS"
echo ""
echo "LOW ($N_LOW):"
awk -F'|' '$1=="LOW"{printf "  [%s] %s: %s [auto-fixable: %s]\n", $2, $3, $4, $5}' "$FINDINGS"
echo ""
echo "Total: $N_TOTAL findings ($N_HIGH high, $N_MED medium, $N_LOW low)"
echo ""
echo "(findings persistidos em $FINDINGS — usar na seção de auto-fix)"
