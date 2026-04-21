#!/usr/bin/env bash
# marketplace-tools check.sh — verifica updates em plugins Level 2 do marketplace
# Uso:
#   bash scripts/check.sh              → dry-run, emite TSV de updates disponíveis em stdout
#   bash scripts/check.sh --apply N1 N2 → aplica updates nos plugins listados (commit individual)
#
# Invocado pelo slash command /marketplace-tools:check-marketplace-updates

set -Eeuo pipefail
trap 'echo "ERRO em check.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# --- Parse args ---
MODE="dry-run"
APPLY_LIST=()
if [ "${1:-}" = "--apply" ]; then
  MODE="apply"
  shift
  if [ "$#" -eq 0 ]; then
    echo "Uso: check.sh --apply <plugin1> [plugin2] ..." >&2
    exit 2
  fi
  APPLY_LIST=("$@")
fi

# --- Sanity ---
test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz de um repo com marketplace."; exit 1; }
for cmd in gh jq git awk sed; do
  command -v "$cmd" >/dev/null || { echo "ERRO: $cmd não instalado."; exit 1; }
done
gh auth status >/dev/null 2>&1 || { echo "ERRO: gh não autenticado. Rode 'gh auth login'."; exit 1; }

MKT_JSON=".claude-plugin/marketplace.json"
TMPDIR_CHECK=$(mktemp -d) || { echo "ERRO: mktemp -d falhou"; exit 1; }
trap 'rm -rf "$TMPDIR_CHECK"' EXIT

# --- Helper: resolve HEAD atual do upstream ---
resolve_head() {
  local source_type="$1" url="$2" ref="$3"
  case "$source_type" in
    url)
      git ls-remote "$url" "$ref" 2>/dev/null | awk '{print $1}' | head -1
      ;;
    git-subdir)
      local owner_repo
      owner_repo=$(echo "$url" | sed -E 's|https://github.com/||; s|\.git$||')
      gh api "repos/$owner_repo/commits/$ref" --jq '.sha' 2>/dev/null || echo ""
      ;;
    *)
      echo ""
      ;;
  esac
}

# --- Helper: emite TSV line pra plugin com update ---
check_plugin() {
  local name="$1" source_type="$2" url="$3" path_prefix="$4" ref="$5" old_sha="$6"
  local new_sha
  new_sha=$(resolve_head "$source_type" "$url" "$ref")
  if [ -z "$new_sha" ]; then
    echo "ERRO: não consegui resolver HEAD de $name ($source_type $url $ref)" >&2
    return
  fi
  [ "$new_sha" = "$old_sha" ] && return  # sem update

  local owner_repo compare
  owner_repo=$(echo "$url" | sed -E 's|https://github.com/||; s|\.git$||')
  compare=$(gh api "repos/$owner_repo/compare/$old_sha...$new_sha" 2>/dev/null) || {
    echo "ERRO: gh compare falhou para $name" >&2
    return
  }

  local file_count
  if [ "$source_type" = "git-subdir" ] && [ "$path_prefix" != "-" ] && [ -n "$path_prefix" ]; then
    file_count=$(echo "$compare" | jq -r --arg p "$path_prefix/" '.files[]? | select(.filename | startswith($p)) | .filename' | wc -l | tr -d ' ')
  else
    file_count=$(echo "$compare" | jq '.files | length')
  fi

  [ "$file_count" -eq 0 ] && return  # SHA mudou mas nenhum arquivo relevante

  local commit_count breaking top_commits
  commit_count=$(echo "$compare" | jq '.commits | length')
  if echo "$compare" | jq -r '.commits[] | .commit.message' | grep -qiE 'BREAKING|breaking:|!:'; then
    breaking="yes"
  else
    breaking="no"
  fi
  top_commits=$(echo "$compare" | jq -r '.commits[:5][] | .commit.message | split("\n")[0]' | paste -sd '|' -)

  printf "%s\t%s\t%s\t%d\t%d\t%s\t%s\n" "$name" "${old_sha:0:12}" "${new_sha:0:12}" "$commit_count" "$file_count" "$breaking" "$top_commits"
}

# --- Extrair plugins Level 2 (com SHA) ---
# Uso de "-" como sentinela pra path vazio (bash IFS=$'\t' colapsa tabs consecutivos).
jq -r '.plugins[] | select((.source | type) == "object" and .source.sha) | [.name, .source.source, .source.url, (.source.path // "-"), .source.ref // "main", .source.sha] | @tsv' "$MKT_JSON" > "$TMPDIR_CHECK/l2.tsv"

if [ ! -s "$TMPDIR_CHECK/l2.tsv" ]; then
  echo "Nenhum plugin Level 2 (SHA pinnado) em $MKT_JSON." >&2
  exit 0
fi

# --- Modo dry-run ---
if [ "$MODE" = "dry-run" ]; then
  printf "PLUGIN\tOLD_SHA\tNEW_SHA\tCOMMITS\tFILES\tBREAKING\tTOP_COMMITS\n"
  while IFS=$'\t' read -r name source_type url path_prefix ref old_sha; do
    check_plugin "$name" "$source_type" "$url" "$path_prefix" "$ref" "$old_sha"
  done < "$TMPDIR_CHECK/l2.tsv"
  exit 0
fi

# --- Modo --apply é na Task 9 ---
echo "ERRO: modo --apply ainda não implementado (Task 9)." >&2
exit 1
