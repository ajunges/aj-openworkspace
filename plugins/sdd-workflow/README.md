# sdd-workflow — v3.0

Plugin Claude Code com playbook **Spec-Driven Development** completo. 4 estágios nomeados, tier projetado, integração com superpowers, EARS pra Requirements + BDD pra Tasks 🔒, auditoria expandida 13 dimensões × 5 tiers.

## Audiência

Não-programadores (executivos, etc.) e programadores iniciantes que dirigem o Claude Code pra construir sistemas completos. O workflow compensa a falta de conhecimento técnico direto com:

- **Gates explícitos** em cada fase — nada avança sem aprovação
- **TDD canônico** Red/Green/Refactor — testes antes do código, refactor obrigatório
- **EARS** (Easy Approach to Requirements Syntax) — requirements precisos sem ambiguidade
- **BDD** (Given-When-Then) — cenários de teste com dados reais
- **Auditoria expandida** em 13 dimensões com obrigatoriedade variável por tier
- **Tier projetado** — visão final do desenvolvimento, não estado atual
- **Princípio inviolável**: dados reais, nunca fictícios

## 4 estágios × 11 fases

| Estágio | Fases | Saídas |
|---|---|---|
| **I. Pré-spec** | Discovery → Constitution (com setup) → Stack | `specs/constitution.md` |
| **II. Spec** | Requirements (EARS) → Design → Spike (opcional) | `specs/requirements.md`, `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks (plano-mestre) → Implementation (loop por feature) | `specs/tasks.md`, `specs/plans/<feature>.md`, código entregue |
| **IV. Ship** | Audit → Delivery → Deploy | `specs/audit-<data>.md`, sistema rodando, sistema em produção |

## 5 níveis de tier

`prototipo_descartavel` → `uso_interno` → `mvp` → `beta_publico` → `producao_real`

Tier determina dimensões obrigatórias da Audit, recursos mínimos da stack, e rigor do Ship.Deploy. **Tier é projetado** (visão final), não observado (estado atual). Mudança = decisão consciente registrada via Promoção de Tier (sub-skill dedicada).

## 4 tipos de projeto suportados

- `web-saas` — sistema web full-stack (React/Vite/Tailwind/shadcn/Express/Prisma/PG)
- `claude-plugin` — plugin Claude Code (markdown + JSON, sem build)
- `hubspot` — extensão HubSpot (CLI, custom objects, UI extensions, serverless)
- `outro` — Stack Decision livre

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install sdd-workflow@aj-openworkspace
```

> **Nota**: a skill principal tem `disable-model-invocation: true` — não dispara automaticamente em conversas casuais. Ative por trigger explícito (frase em pt-BR ou slash command abaixo).

## Slash commands

| Command | Função |
|---|---|
| `/sdd-workflow:start` | Atalho pra invocar a skill principal |
| `/sdd-workflow:status` | Lê `specs/progress.md` (read-only) |
| `/sdd-workflow:gate` | Verifica gate da fase atual; lista pendências |
| `/sdd-workflow:audit` | Dispara Ship.Audit standalone (`--dimensoes <lista>` opcional) |
| `/sdd-workflow:promote-tier` | Invoca sub-skill de promoção de tier (`--alvo <tier>` opcional) |

## Triggers naturais (frase em pt-BR)

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "Status do projeto"
- "Promover este projeto pra [tier]"

## Migração v2.x → v3.0

Projetos no fluxo antigo (sem bloco YAML `tipo_projeto`/`tier` na constitution) são detectados automaticamente. A skill oferece migração que adiciona campos novos sem perder histórico.

## Status

`em-testes` — primeira versão pública pós-evolução estrutural. Promove pra `recomendado` após uso real e feedback.

## Autor

André Junges (@ajunges). Playbook desenvolvido na prática, 100% via Claude Code. Sem garantia — use por conta e risco.
