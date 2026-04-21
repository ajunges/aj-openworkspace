# marketplace-tools

Plugin próprio do marketplace `aj-openworkspace` — toolkit de manutenção do próprio marketplace. Encapsula fluxos manuais forçados pelos bugs conhecidos de cache do Claude Code Desktop ([#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081)).

## Comandos disponíveis

| Comando | Resumo |
|---|---|
| `/check-marketplace-updates` | Verifica updates em plugins Level 2 (SHA pinnado) e aplica seletivamente |
| `/marketplace-qa` | Diagnóstico de saúde do marketplace local (clone stale, dangling paths, version drift) |
| `/publish-plugin <nome> [patch\|minor\|major]` | Publica mudança em plugin Level 3 — bump + commit + push + re-cache |
| `/validate` | Validação pré-commit: schema oficial + convenções do marketplace (tags, SemVer, version duplicada em L3) |
| `/restart-desktop` | Reinicia o Claude Code Desktop (útil após `/publish-plugin`) |

Todos seguem o padrão **opção Z**: lógica operacional em `scripts/*.sh`, `.md` só explica quando usar e o que o script faz conceitualmente.

## Roadmap (ondas futuras)

### Onda 2 — Edição do catálogo
- `/add-plugin` — adicionar Level 1/2 ao `marketplace.json` a partir de uma URL
- `/remove-plugin` — remover entry + cleanup de cache
- `/reclassify` — mudar `tags[0]` entre `recomendado`/`em-testes`/`nao-recomendado`

### Onda 3 — Automação residual
- `/nuke-cache` — invalidação total pra casos de emergência
- `/changelog` — gera changelog entre versions de um plugin L3

### Onda 4 — Scaffolding
- `/new-plugin` — cria dir + plugin.json + entry em marketplace.json pra plugin Level 3 novo

## Como testar

Testes automatizados cobrem os sub-scripts de `scripts/checks/` (funções puras, determinísticas):

```bash
brew install bats-core                  # se ainda não tem
cd plugins/marketplace-tools
bats tests/checks/
```

Scripts de orquestração (`check.sh`, `validate.sh`, `qa.sh`, `publish.sh`, `restart.sh`) não têm testes automatizados na Onda 1 — testabilidade manual rodando cada um fora do Claude Code.

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install marketplace-tools@aj-openworkspace
```

## Autor

André Junges (@ajunges). Plugin escrito em colaboração com Claude Code.
