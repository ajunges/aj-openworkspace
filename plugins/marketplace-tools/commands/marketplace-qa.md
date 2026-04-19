---
description: Diagnóstico de saúde do marketplace local — detecta clone stale, dangling installPaths, version drift e outros estados inconsistentes
---

# /marketplace-qa

Faz um exame completo do estado dos plugins instalados vs. o que o marketplace declara. Produz um relatório com severidades e oferece auto-fix para findings com remédio mecânico.

Cobre os estados inconsistentes causados pelos bugs conhecidos [#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081) do Claude Code.

## Pré-requisitos

- Rodar da raiz de um repo com `.claude-plugin/marketplace.json`
- `jq`, `git` e `find` instalados
- Acesso de leitura a `~/.claude/plugins/`

## O que cada check faz

### 3.1 Clone behind remote (MEDIUM)

**Sinal direto**: `git fetch origin` no clone local do marketplace + comparação HEAD local vs. upstream. Substitui o check antigo baseado em `known_marketplaces.json.lastUpdated` (que era proxy enganoso — só atualizava quando a UI rodava `/plugin marketplace update`).

Se o fetch falhar (offline, credenciais), reporta `LOW fetch-failed` em vez de `MEDIUM clone-behind-remote` — sinal mais honesto de "não consegui medir" vs. "tem drift".

**Auto-fix**: `git pull --ff-only` no clone.

### 3.2 Dangling installPath (HIGH)

Plugin em `installed_plugins.json` cujo `installPath` aponta para diretório inexistente. Acontece quando o cache é apagado por GC do app mas a entry de metadata sobrevive (bug #14061).

**Auto-fix**: copiar do clone do marketplace para o path esperado.

### 3.3 SHA drift — Level 3 com commits afetando (MEDIUM)

`gitCommitSha` em `installed_plugins.json` diferente do HEAD do clone, **e** existem commits entre os dois SHAs que tocaram o diretório do plugin. Sem o filtro de path, o check disparava para todos os plugins cujo install é antigo, mesmo quando o plugin em si não mudou — falso positivo constante.

Só aplica a Level 3 (plugins com `source: "./plugins/..."`). Para Level 2 (SHA pinnado), a existência de drift contra HEAD do clone é **esperada** (o pin não muda automaticamente).

**Auto-fix**: `/publish-plugin <nome> patch` (ou bump apropriado).

### 3.4 Version drift — marketplace.json vs installed (MEDIUM)

Para plugins Level 3, `marketplace.json[].version` diferente de `installed_plugins.json[...].version`. Indica que bumpei no catálogo mas o ciclo de re-cache não passou.

**Auto-fix**: `/publish-plugin <nome>` com bump adequado.

### 3.5 Plugin habilitado mas não instalado (HIGH)

Entry em `settings.json.enabledPlugins` sem correspondência em `installed_plugins.json`. Órfão de settings — plugin foi removido do marketplace mas a flag de habilitação sobreviveu.

**Auto-fix manual**: remover do `enabledPlugins` ou reinstalar.

### 3.6 Cache orphan antigo (LOW)

Diretórios em `cache/<mkt>/<plugin>/<versão>/` não referenciados por `installed_plugins.json` e mais antigos que 7 dias (período de graça oficial expirado).

**Auto-fix**: `rm -rf` no diretório.

## Checks não implementados (v0.2)

- Validação de schema do `marketplace.json` (usar `claude plugin validate`)
- Detecção de loops de dependência em `dependencies`
- Comparação cross-marketplace (plugin com mesmo nome em marketplaces diferentes)
- Verificação de `permission` overrides em hooks do plugin

## Script de execução

Executar o script abaixo como **um único bloco** — não fragmentar. O shell do Claude Code às vezes perde PATH entre blocos separados, então consolidamos tudo em uma invocação. O script coleta findings, imprime o relatório e termina. Os auto-fixes ficam na seção seguinte (rodar após revisão humana).

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# --- Sanity check ---
test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
command -v jq  >/dev/null || { echo "ERRO: jq não instalado."; exit 1; }
command -v git >/dev/null || { echo "ERRO: git não instalado."; exit 1; }
command -v find >/dev/null || { echo "ERRO: find não instalado."; exit 1; }
test -f ~/.claude/plugins/installed_plugins.json  || { echo "ERRO: installed_plugins.json ausente."; exit 1; }
test -f ~/.claude/plugins/known_marketplaces.json || { echo "ERRO: known_marketplaces.json ausente."; exit 1; }

# --- Identificar marketplace ---
MKT_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
CLONE_PATH="$HOME/.claude/plugins/marketplaces/$MKT_NAME"
INSTALLED=~/.claude/plugins/installed_plugins.json
SETTINGS=~/.claude/settings.json
MKT_JSON=.claude-plugin/marketplace.json
FINDINGS=/tmp/mkt-qa-findings-$$.txt
: > "$FINDINGS"

echo "=== Marketplace QA: $MKT_NAME ==="

# --- 3.1 Clone behind remote ---
if [ -d "$CLONE_PATH" ]; then
  if git -C "$CLONE_PATH" fetch origin --quiet 2>/dev/null; then
    LOCAL_HEAD=$(git -C "$CLONE_PATH" rev-parse HEAD)
    TRACKING=$(git -C "$CLONE_PATH" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "origin/main")
    REMOTE_HEAD=$(git -C "$CLONE_PATH" rev-parse "$TRACKING" 2>/dev/null)
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

# --- 3.2 Dangling installPath ---
jq -r '.plugins | to_entries[] | "\(.key)\t\(.value[0].installPath)"' "$INSTALLED" > /tmp/mkt-qa-paths-$$.tsv
while IFS=$'\t' read -r name path; do
  [ -z "$path" ] && continue
  if [ ! -d "$path" ]; then
    echo "HIGH|3.2|$name|dangling-path: $path não existe|yes" >> "$FINDINGS"
  fi
done < /tmp/mkt-qa-paths-$$.tsv
rm -f /tmp/mkt-qa-paths-$$.tsv

# --- 3.3 SHA drift (Level 3 com commits afetando) ---
if [ -d "$CLONE_PATH" ]; then
  CLONE_HEAD=$(git -C "$CLONE_PATH" rev-parse HEAD)
  jq -r --arg m "$MKT_NAME" '.plugins | to_entries[] | select(.key | endswith("@\($m)")) | "\(.key)\t\(.value[0].gitCommitSha)"' "$INSTALLED" > /tmp/mkt-qa-sha-$$.tsv
  while IFS=$'\t' read -r name sha; do
    [ "$sha" = "$CLONE_HEAD" ] && continue
    plugin_name=${name%@*}
    source_type=$(jq -r --arg n "$plugin_name" '.plugins[] | select(.name == $n) | .source | type' "$MKT_JSON")
    [ "$source_type" != "string" ] && continue   # só Level 3
    plugin_path=$(jq -r --arg n "$plugin_name" '.plugins[] | select(.name == $n) | .source' "$MKT_JSON")
    affects=$(git -C "$CLONE_PATH" log --oneline "$sha..$CLONE_HEAD" -- "$plugin_path" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$affects" -gt 0 ]; then
      echo "MEDIUM|3.3|$name|sha-drift: ${sha:0:12} vs ${CLONE_HEAD:0:12} ($affects commits afetando $plugin_path)|yes" >> "$FINDINGS"
    fi
  done < /tmp/mkt-qa-sha-$$.tsv
  rm -f /tmp/mkt-qa-sha-$$.tsv
fi

# --- 3.4 Version drift (marketplace.json vs installed) ---
jq -r --arg m "$MKT_NAME" '.plugins[] | select(.source | type == "string") | "\(.name)\t\(.version // "none")"' "$MKT_JSON" > /tmp/mkt-qa-vers-$$.tsv
while IFS=$'\t' read -r name mkt_ver; do
  installed_ver=$(jq -r --arg k "$name@$MKT_NAME" '.plugins[$k][0].version // "none"' "$INSTALLED")
  if [ "$installed_ver" != "none" ] && [ "$mkt_ver" != "$installed_ver" ]; then
    echo "MEDIUM|3.4|$name|version-drift: marketplace=$mkt_ver installed=$installed_ver|yes" >> "$FINDINGS"
  fi
done < /tmp/mkt-qa-vers-$$.tsv
rm -f /tmp/mkt-qa-vers-$$.tsv

# --- 3.5 Enabled but not installed ---
if [ -f "$SETTINGS" ]; then
  jq -r '.enabledPlugins // {} | keys[]' "$SETTINGS" > /tmp/mkt-qa-enabled-$$.txt
  while read -r key; do
    if ! jq -e --arg k "$key" '.plugins[$k]' "$INSTALLED" >/dev/null 2>&1; then
      echo "HIGH|3.5|$key|enabled-not-installed: presente em settings mas sem entry em installed_plugins|no" >> "$FINDINGS"
    fi
  done < /tmp/mkt-qa-enabled-$$.txt
  rm -f /tmp/mkt-qa-enabled-$$.txt
fi

# --- 3.6 Cache orphan antigo ---
find ~/.claude/plugins/cache -maxdepth 3 -mindepth 3 -type d > /tmp/mkt-qa-cache-$$.txt
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
done < /tmp/mkt-qa-cache-$$.txt
rm -f /tmp/mkt-qa-cache-$$.txt

# --- Relatório ---
# awk é mais robusto que grep -c aqui — grep retorna "0" + exit 1, combinado com || echo 0 duplica
count_sev() { awk -F'|' -v s="$1" '$1==s{n++}END{print n+0}' "$FINDINGS"; }
N_HIGH=$(count_sev HIGH)
N_MED=$(count_sev MEDIUM)
N_LOW=$(count_sev LOW)
N_TOTAL=$((N_HIGH + N_MED + N_LOW))

echo ""
echo "HIGH ($N_HIGH):"
grep "^HIGH|" "$FINDINGS" | awk -F'|' '{printf "  [%s] %s: %s [auto-fixable: %s]\n", $2, $3, $4, $5}'
echo ""
echo "MEDIUM ($N_MED):"
grep "^MEDIUM|" "$FINDINGS" | awk -F'|' '{printf "  [%s] %s: %s [auto-fixable: %s]\n", $2, $3, $4, $5}'
echo ""
echo "LOW ($N_LOW):"
grep "^LOW|" "$FINDINGS" | awk -F'|' '{printf "  [%s] %s: %s [auto-fixable: %s]\n", $2, $3, $4, $5}'
echo ""
echo "Total: $N_TOTAL findings ($N_HIGH high, $N_MED medium, $N_LOW low)"
echo ""
echo "(findings persistidos em $FINDINGS — usar na seção de auto-fix)"
```

## Auto-fix interativo

Depois de revisar o relatório, passar por cada finding `auto-fixable: yes` e decidir manualmente se aplica. Estes são os fixes correspondentes:

### 3.1 clone-behind-remote
```bash
git -C "$CLONE_PATH" pull --ff-only
```

### 3.2 dangling-path
```bash
SUBPATH=$(echo "$path" | sed "s|$HOME/.claude/plugins/cache/||")
MKT=$(echo "$SUBPATH" | cut -d/ -f1)
PLUG=$(echo "$SUBPATH" | cut -d/ -f2)
SRC="$HOME/.claude/plugins/marketplaces/$MKT/plugins/$PLUG"
[ -d "$SRC" ] && cp -R "$SRC" "$path"
```

### 3.3 sha-drift / 3.4 version-drift
Invocar `/marketplace-tools:publish-plugin <nome> patch` (ou bump adequado).

### 3.6 orphan-cache
```bash
rm -rf "$dir"
```

## Tratamento de erros

- **`jq` fail**: erro específico na stderr, check continua pros próximos (findings parciais).
- **Clone path inacessível**: reportado como HIGH `marketplace-clone-missing`, checks dependentes do clone pulam.
- **`settings.json` ausente**: pula check 3.5.

## Não-objetivos (v0.2)

- Não checa plugins de outros marketplaces (limita-se ao marketplace do repo atual).
- Não aplica fixes automaticamente — requer revisão humana.
- Não reinicia o Claude Code Desktop (usuário faz manualmente após fixes).
- Não detecta bugs do plugin em si — só inconsistências de state.
