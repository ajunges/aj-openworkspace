# sdd-workflow — v1.0

Plugin Claude Code com playbook **Spec-Driven Development** completo. 4 estágios nomeados, tier projetado em 5 níveis, governança em 3 camadas (heurísticas universais + princípios arquiteturais por tipo + disciplinas operacionais por tier), EARS pra Requirements + BDD pra Tasks, auditoria dimensional 14×5 com defesa contra prompt injection, integração com superpowers.

## Audiência

Não-programadores (executivos, etc.) e programadores iniciantes que dirigem o Claude Code pra construir sistemas completos. O workflow compensa a falta de conhecimento técnico direto com:

- **Gates explícitos** em cada fase — nada avança sem aprovação. Modo configurável (`explicitos` / `reduzidos` / `minimos`)
- **Governança em 3 camadas** — 9 heurísticas universais (sempre ativas) + princípios arquiteturais por `tipo_projeto` + disciplinas operacionais escalando por tier (cumulativas)
- **TDD canônico universal** Red/Green/Refactor — testes antes do código, refactor explícito (heurística H9, aplica inclusive a markdown/JSON com refactor adaptado)
- **EARS** (Easy Approach to Requirements Syntax) — requirements precisos sem ambiguidade
- **BDD** (Given-When-Then) — cenários de teste com dados reais
- **Auditoria dimensional** em 14 dimensões × 5 tiers, com obrigatoriedade variável + dimensão dedicada à defesa contra prompt injection (se LLM no caminho)
- **Tier projetado** — visão final do desenvolvimento, não estado atual. Premissa fundadora: rigor escala pelo destino
- **Heurística H1 (dados reais sempre)** — antes de simular, busca dados reais. Heurísticas não são invioláveis: H5 (Decisões registradas) embute mecanismo formal de exceção via ADR

## 4 estágios × 11 fases

| Estágio | Fases | Saídas |
|---|---|---|
| **I. Pré-spec** | Discovery → Constitution (com setup) → Stack | `specs/constitution.md` |
| **II. Spec** | Requirements (EARS) → Design → Spike (opcional) | `specs/requirements.md`, `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks (plano-mestre) → Implementation (loop por feature) | `specs/tasks.md`, `specs/plans/<feature>.md`, código entregue |
| **IV. Ship** | Audit → Delivery → Deploy | `specs/audit-<data>.md`, sistema rodando, sistema em produção |

## 5 níveis de tier

`prototipo_descartavel` → `uso_interno` → `mvp` → `beta_publico` → `producao_real`

Tier determina dimensões obrigatórias da Audit, recursos mínimos da stack, rigor do Ship.Deploy, e disciplinas operacionais ativas (Camada 3 — cumulativas). **Tier é projetado** (visão final), não observado (estado atual). Mudança = decisão consciente registrada via Promoção de Tier (sub-skill `sdd-promote-tier`).

## 4 tipos de projeto suportados

- `web-saas` — sistema web full-stack (Next.js 16+ App Router + Supabase + Prisma + Tailwind v4 + shadcn/ui CLI v4 + MCP `shadcn.io` + Resend + Vercel Pro a partir de `mvp`)
- `claude-plugin` — plugin Claude Code (markdown + JSON, sem build)
- `hubspot` — extensão HubSpot (CLI, custom objects, UI extensions, serverless)
- `outro` — Stack Decision livre (research em Pré-spec.Stack obrigatório)

Override é permitido em todos os tipos, sempre como decisão registrada via H5 (ADR). Catálogo de Auth/Billing/Email/Storage/Hosting com quando-usar/quando-evitar em `references/overrides-matrix.md` da skill principal. Janela de revisão da stack default `web-saas`: Q3-Q4 2026 (lançamento de TanStack Start 1.0 estável).

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
| `/sdd-workflow:migrate-v1` | Invoca sub-skill de migração v0.x/v2.x → v1.0.0 |

## Triggers naturais (frase em pt-BR)

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "Status do projeto"
- "Promover este projeto pra [tier]"
- "Migrar pra v1.0.0" / "atualizar workflow SDD"

## Migração de projetos legados

Projetos em fluxos anteriores (v0.x ou v2.x) são detectados automaticamente quando a skill é invocada. Sinais incluem: ausência do bloco YAML `tipo_projeto`/`tier`/`gates`/`audiencia`/`gera_receita`/`tier_confianca` na constitution, presença de "princípios invioláveis" sem mencionar Camadas, ou stack registrada como Vite + Express + Prisma + Postgres (default v0.x).

A sub-skill `sdd-migrate-v1` (também acessível via `/sdd-workflow:migrate-v1`) refunda a governança em 3 camadas, adiciona campos novos no YAML inicial da constitution, adiciona seção "Emendas" (mecanismo formal de exceção a heurísticas/princípios/disciplinas), e oferece revisar a stack default `web-saas` se aplicável. Migração é opt-in, preserva conteúdo existente, marca propostas com `[INFERIDO — confirmar]`. Não toca em código do projeto.

## Status

`em-testes` — primeira versão pública pós-renumeração v3.0 → v1.0.0. Promove pra `recomendado` após pelo menos um projeto rodado ponta-a-ponta com feedback de uso real.

## Autor

André Junges (@ajunges). Playbook desenvolvido na prática, 100% via Claude Code. Sem garantia — use por conta e risco.
