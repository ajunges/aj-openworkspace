#!/usr/bin/env bash
# marketplace-tools restart.sh — reinicia o Claude Code Desktop
# Uso: bash scripts/restart.sh
# Invocado pelo slash command /marketplace-tools:restart-desktop

set -Eeuo pipefail
trap 'echo "ERRO em restart.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

echo "Reiniciar Claude Code Desktop? [y/N]"
read -r answer
case "$answer" in
  y|Y) ;;
  *) echo "Abortado."; exit 0 ;;
esac

if ! osascript -e 'tell application "Claude" to quit' 2>/dev/null; then
  echo ""
  echo "AVISO: osascript falhou. Possíveis causas:"
  echo "  - App não está aberto"
  echo "  - App travado (Force Quit via Cmd+Option+Esc)"
  echo "  - macOS security: dar permissão em System Settings → Privacy → Automation"
  echo ""
  echo "Tentando abrir mesmo assim..."
fi

# Pequeno delay pra garantir quit completou antes de open
sleep 2

open -a "Claude"
echo "Claude Code Desktop (re)iniciado."
