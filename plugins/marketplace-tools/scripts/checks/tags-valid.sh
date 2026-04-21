#!/usr/bin/env bash
# Detecta se tags[0] está fora do conjunto {recomendado, em-testes, nao-recomendado}.
# Uso: tags-valid.sh <plugin_name> <mkt_json_path>
# Exit: 0 ok, 1 inválido, 2 uso inválido

set -Eeuo pipefail
trap 'echo "ERRO em tags-valid.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

PLUGIN_NAME="${1:-}"
MKT_JSON="${2:-}"

if [ -z "$PLUGIN_NAME" ] || [ -z "$MKT_JSON" ]; then
  echo "Uso: tags-valid.sh <plugin_name> <mkt_json_path>" >&2
  exit 2
fi

command -v jq >/dev/null || { echo "ERRO: jq não instalado" >&2; exit 2; }
test -f "$MKT_JSON" || { echo "ERRO: $MKT_JSON não existe" >&2; exit 2; }

TAG0=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .tags[0] // ""' "$MKT_JSON")

if [ -z "$TAG0" ]; then
  echo "MEDIUM|tag-convention|$PLUGIN_NAME|tags-valid: tags[0] ausente (esperado: recomendado/em-testes/nao-recomendado)|no"
  exit 1
fi

case "$TAG0" in
  recomendado|em-testes|nao-recomendado) exit 0 ;;
  *)
    echo "MEDIUM|tag-convention|$PLUGIN_NAME|tags-valid: tags[0]='$TAG0' fora do conjunto permitido (recomendado/em-testes/nao-recomendado)|no"
    exit 1
    ;;
esac
