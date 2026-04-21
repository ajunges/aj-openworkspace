---
description: Reinicia o Claude Code Desktop — útil após publicar plugin Level 3 pra app detectar nova version
---

# /restart-desktop

Encerra o Claude Code Desktop e abre de novo. Utilidade principal: após rodar `/publish-plugin`, o app precisa ser reiniciado pra detectar a nova entry em `installed_plugins.json`.

## Quando usar

- Logo após `/publish-plugin <nome>` completar
- Quando suspeitar que o app está com cache stale (ex: plugin atualizado não reflete no menu)
- Debug de estados inconsistentes pós-`/marketplace-qa` com HIGH findings

## Execução

A lógica vive em `scripts/restart.sh`:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/restart.sh
```

O script pede confirmação `[y/N]` antes de fechar o app. Sem argumentos.

## O que o script faz

1. Prompt `[y/N]` — abortar se diferente de `y`/`Y`
2. `osascript -e 'tell application "Claude" to quit'` — quit gentil (salva estado, fecha janelas)
3. `sleep 2` — aguarda quit completar
4. `open -a "Claude"` — reabre

## Tratamento de erros

- **osascript falha**: geralmente significa que o app não está aberto, travou, ou falta permissão de Automation. Script mostra diagnóstico e tenta `open` mesmo assim.
- **App travado hard**: se `osascript` não funciona, o usuário precisa forçar quit manualmente (`Cmd+Option+Esc`) ou via terminal (`killall Claude`) — o script **não** faz kill automático (destrutivo).

## Não-objetivos

- Não funciona fora do macOS (usa AppleScript via `osascript` e `open -a`).
- Não garante que plugins recém-publicados serão detectados — isso depende do app ler `installed_plugins.json` no startup (o que ele faz, mas sem garantia).
- Não suporta nome do app diferente de "Claude" (se você tem uma build custom, ajustar o script).

## Testar o script isoladamente

Fora do Claude Code:

```bash
bash plugins/marketplace-tools/scripts/restart.sh
```

(Só testar quando for oportuno fechar o app.)
