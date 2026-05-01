---
name: sdd-workflow
description: >
  Workflow Spec-Driven Development v3.0 pra projetos solo gerados por IA.
  Use quando o usuário disser "novo projeto", "criar um sistema", "quero desenvolver",
  "use o workflow SDD", "promover este projeto pra <tier>", ou variações.
  Audiência: não-programadores (executivos, etc.) dirigindo Claude Code pra construir
  software completo. 4 estágios (Pré-spec → Spec → Build → Ship), 5 níveis de tier,
  catálogo de tipo_projeto, EARS pra Requirements + BDD pra Tasks 🔒, integração com
  superpowers (Modo 2), TDD canônico Red/Green/Refactor.
disable-model-invocation: true
version: 3.0.0
triggers:
  - sdd
  - novo projeto
  - criar um sistema
  - quero desenvolver
  - workflow sdd
  - nova feature
  - status do projeto
  - promover este projeto
  - evoluir tier
tags:
  - development-methodology
  - project-management
  - spec-driven
  - workflow
  - tier-projetado
  - ears-bdd
---

# Spec-Driven Development Workflow — v3.0

Workflow completo pra desenvolvimento de novos projetos solo gerados 100% por IA. Cada estágio produz artefatos que devem ser aprovados antes de avançar. **Princípios invioláveis** abaixo são contrato: violação = STOP.

> **Origem**: aplica os princípios canônicos do **GitHub Spec Kit** (`Constitution → Specify → Plan → Tasks → Verify`) com extensões opinativas pra audiência específica (não-dev dirigindo IA). Ver spec do plugin pra detalhe.

---

## Princípios invioláveis

| # | Princípio | Origem |
|---|---|---|
| 1 | **Dados reais sempre, nunca fictícios** — em seed, testes, exemplos, demos | herdado |
| 2 | **Tier é projetado** (visão final do desenvolvimento), não observado (estado atual) | v3.0 |
| 3 | **Defensividade sobre dependências externas** — não pressupor CLI/MCP/skill/credencial sem inventário formal | v3.0 |
| 4 | **Gates explícitos por fase** — pausa obrigatória, aprovação humana antes de avançar | herdado |
| 5 | **TDD canônico Red/Green/Refactor** — write test que falha, fazer passar com mínimo de código, refatorar mantendo o teste passando, só então commitar. Aplica universalmente, incluindo arquivos não-código (markdown/JSON com Refactor adaptado — ver `references/linguagens-especificacao.md` e seção sobre Build.Implementation) | herdado/v3.0 |
| 6 | **Decisões registradas** — toda escolha estrutural (tipo_projeto, tier, stack, alvo deploy, inventário) vai pra constitution com data e motivação | v3.0 |
| 7 | **Promoção de tier é decisão consciente, registrada, incremental** — nunca recomeço do zero | v3.0 |
| 8 | **Linguagem ubíqua** — vocabulário compartilhado entre IA, usuário, documentos de referência, código e UI. Termos definidos em Pré-spec.Discovery e Pré-spec.Constitution propagam pra requirements, design, tasks, código e UI sem traduções intermediárias | v3.0 (DDD/BDD) |

---

## Visão geral do fluxo — 4 estágios nomeados

```
I.  Pré-spec  →  Discovery  →  Constitution (com setup)  →  Stack (3 sub-componentes)
II. Spec      →  Requirements (EARS)  →  Design  →  [Spike opcional]
III. Build    →  Tasks (plano-mestre)  →  Implementation (loop por feature, gate por feature)
IV. Ship      →  Audit (13 dim. × 5 tier)  →  Delivery  →  Deploy
```

Cada estágio tem fases internas com **gates explícitos**. Cada gate é pausa obrigatória — IA apresenta resumo e aguarda aprovação antes de avançar.

| Estágio | Fases | Saídas |
|---|---|---|
| **I. Pré-spec** | Discovery, Constitution (absorve setup), Stack | `specs/constitution.md` (com YAML + inventário + alvo deploy) |
| **II. Spec** | Requirements, Design, Spike (opcional) | `specs/requirements.md` (EARS), `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks (plano-mestre), Implementation (loop por feature) | `specs/tasks.md` (índice), `specs/plans/<feature>.md` (writing-plans), código entregue |
| **IV. Ship** | Audit, Delivery, Deploy | `specs/audit-<data>.md`, sistema rodando, sistema em produção |

**References disponíveis** (progressive disclosure — IA carrega sob demanda):

- `references/tiers.md` — 5 níveis + matriz Audit + princípio "tier projetado"
- `references/tipos-projeto.md` — catálogo: web-saas, claude-plugin, hubspot, outro
- `references/stacks.md` — stack default por tipo + variação por tier
- `references/inventario-dependencias.md` — 4 categorias + Família A bloqueia
- `references/audit-dimensoes.md` — 13 dimensões + override por tipo
- `references/integracao-skills.md` — 4 famílias + 2 modos de integração
- `references/alvos-deploy.md` — alvos típicos por tipo + tier
- `references/linguagens-especificacao.md` — EARS + BDD + GEARS no radar

**Templates disponíveis** (em `templates/` — IA copia + preenche pro `specs/` do projeto-alvo):

- `constitution.md`, `requirements.md`, `design.md`, `tasks.md`, `plan-feature.md`, `progress.md`, `spike.md`, `audit.md`

---
