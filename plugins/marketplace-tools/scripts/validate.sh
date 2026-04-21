#!/usr/bin/env bash
# marketplace-tools validate.sh — validação pré-commit do marketplace
# Uso: bash scripts/validate.sh
# Invocado pelo slash command /marketplace-tools:validate
#
# Roda:
#   1. claude plugin validate .
#   2. scripts/checks/tags-valid.sh pra cada plugin
#   3. scripts/checks/semver-valid.sh pra plugins com version
#   4. scripts/checks/version-duplicated.sh pra plugins Level 3

set -Eeuo pipefail
trap 'echo "ERRO em validate.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
command -v jq >/dev/null || { echo "ERRO: jq não instalado."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MKT_JSON=".claude-plugin/marketplace.json"
FINDINGS=$(mktemp) || { echo "ERRO: mktemp falhou"; exit 1; }
PLUGINS_TSV=$(mktemp) || { echo "ERRO: mktemp falhou"; exit 1; }
trap 'rm -f "$FINDINGS" "$PLUGINS_TSV"' EXIT
FAIL=0

echo "=== /validate ==="

# 1. claude plugin validate
if command -v claude >/dev/null 2>&1; then
  echo ""
  echo "[1/2] claude plugin validate ."
  if ! claude plugin validate .; then
    FAIL=1
  fi
else
  echo "[1/2] AVISO: 'claude' CLI não disponível — pulando schema validation."
fi

echo ""
echo "[2/2] Checks custom de convenção..."

# Helper: roda sub-script e trata exit code
run_check() {
  local check_name="$1"
  shift
  set +e
  bash "$SCRIPT_DIR/checks/$check_name" "$@" >> "$FINDINGS"
  local rc=$?
  set -e
  case $rc in
    0) ;;
    1) FAIL=1 ;;
    *) echo "ERRO: $check_name retornou exit $rc (uso inválido)" >&2; exit 3 ;;
  esac
}

# 2. Por plugin: tags-valid + semver-valid + version-duplicated (L3 only)
jq -r '.plugins[] | [.name, (.source | if type == "string" then . else "" end), (.version // "")] | @tsv' "$MKT_JSON" > "$PLUGINS_TSV"

while IFS=$'\t' read -r name plugin_dir version; do
  run_check "tags-valid.sh" "$name" "$MKT_JSON"
  if [ -n "$version" ]; then
    run_check "semver-valid.sh" "$version" "$name"
  fi
  if [ -n "$plugin_dir" ]; then
    run_check "version-duplicated.sh" "$name" "$plugin_dir" "$MKT_JSON"
  fi
done < "$PLUGINS_TSV"

# 3. Relatório
count_sev() { awk -F'|' -v s="$1" '$1==s{n++}END{print n+0}' "$FINDINGS"; }
N_HIGH=$(count_sev HIGH)
N_MED=$(count_sev MEDIUM)
N_LOW=$(count_sev LOW)
N_TOTAL=$((N_HIGH + N_MED + N_LOW))

echo ""
if [ "$N_TOTAL" -eq 0 ] && [ "$FAIL" -eq 0 ]; then
  echo "Validação OK — sem findings."
  exit 0
fi

if [ "$N_HIGH" -gt 0 ]; then
  echo "HIGH ($N_HIGH):"
  awk -F'|' '$1=="HIGH"{printf "  [%s] %s: %s\n", $2, $3, $4}' "$FINDINGS"
  echo ""
fi
if [ "$N_MED" -gt 0 ]; then
  echo "MEDIUM ($N_MED):"
  awk -F'|' '$1=="MEDIUM"{printf "  [%s] %s: %s\n", $2, $3, $4}' "$FINDINGS"
  echo ""
fi
if [ "$N_LOW" -gt 0 ]; then
  echo "LOW ($N_LOW):"
  awk -F'|' '$1=="LOW"{printf "  [%s] %s: %s\n", $2, $3, $4}' "$FINDINGS"
  echo ""
fi
echo "Total: $N_TOTAL findings ($N_HIGH high, $N_MED medium, $N_LOW low)"
exit 1
