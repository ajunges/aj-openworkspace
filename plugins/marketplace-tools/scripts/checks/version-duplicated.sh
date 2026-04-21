#!/usr/bin/env bash
# Detecta se 'version' está em ambos plugin.json e marketplace.json (bug silencioso documentado).
# Uso: version-duplicated.sh <plugin_name> <plugin_dir> <mkt_json_path>
# Exit: 0 ok, 1 duplicado, 2 uso inválido

set -Eeuo pipefail
trap 'echo "ERRO em version-duplicated.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

PLUGIN_NAME="${1:-}"
PLUGIN_DIR="${2:-}"
MKT_JSON="${3:-}"

if [ -z "$PLUGIN_NAME" ] || [ -z "$PLUGIN_DIR" ] || [ -z "$MKT_JSON" ]; then
  echo "Uso: version-duplicated.sh <plugin_name> <plugin_dir> <mkt_json_path>" >&2
  exit 2
fi

command -v jq >/dev/null || { echo "ERRO: jq não instalado" >&2; exit 2; }
test -f "$MKT_JSON" || { echo "ERRO: $MKT_JSON não existe" >&2; exit 2; }

MKT_VER=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .version // ""' "$MKT_JSON")
[ -z "$MKT_VER" ] && exit 0

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
[ -f "$PLUGIN_JSON" ] || exit 0

PJS_VER=$(jq -r '.version // ""' "$PLUGIN_JSON")
if [ -n "$PJS_VER" ]; then
  echo "MEDIUM|3.7|$PLUGIN_NAME|version-duplicated: plugin.json=$PJS_VER marketplace.json=$MKT_VER (plugin.json vence silenciosamente)|yes"
  exit 1
fi

exit 0
