# Plano — sdd-workflow v1.0.0

Versão: 1.0.0
Data: 2026-05-03
Spec correspondente: `docs/superpowers/specs/sdd-workflow-v1.0.0.md`

## 6 Fases de execução

### Fase 0 — Spec + plano (este documento)

Artefatos: `docs/superpowers/specs/sdd-workflow-v1.0.0.md`, `docs/superpowers/plans/sdd-workflow-v1.0.0.md`. Commit intermediário ao final.

### Fase 1 — Camada 1 + premissa fundadora + gates configuráveis

Arquivos:
- `plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md` (NOVO) — 9 heurísticas detalhadas
- `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` — preâmbulo com premissa fundadora; substituição da seção "Princípios invioláveis" por referência às 3 camadas; manter resto do fluxo
- `plugins/sdd-workflow/skills/sdd-workflow/templates/constitution.md` — campos novos no YAML (`gates:`, `audiencia:`, `gera_receita:`, `trade_offs:`); seção "Princípios aplicáveis" listando heurísticas + Camada 2 + Camada 3; seção "Emendas" (H5)

Commit intermediário ao final.

### Fase 2 — Camada 3 + Audit atualizada

Arquivos:
- `plugins/sdd-workflow/skills/sdd-workflow/references/disciplinas-tier.md` (NOVO) — disciplinas por tier (cumulativas) com detalhe operacional
- `plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md` — dim 2 e 3 com tratamento RLS quando Supabase; dim 14 prompt injection adicionada (1.14)
- `plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md` — matriz 14x5 (adicionar dim 14 com lógica condicional a "tem LLM no caminho?")
- `plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md` — adicionar dim 14 condicional ao template

Commit intermediário ao final.

### Fase 3 — Stack web-saas reescrita

Arquivos:
- `plugins/sdd-workflow/skills/sdd-workflow/references/stacks.md` — REESCRITA COMPLETA. Stack default Next.js+Supabase+Prisma+Tailwind v4+shadcn/ui CLI v4+MCP+Resend+Vercel Pro; tabela de overrides estruturais; janela de revisão Q3-Q4 2026
- `plugins/sdd-workflow/skills/sdd-workflow/references/starters-catalog.md` (NOVO) — catálogo de starters com licença, tração, Claude-native (≥3 critérios)
- `plugins/sdd-workflow/skills/sdd-workflow/references/overrides-matrix.md` (NOVO) — matriz Auth/Billing/Email/Storage/Hosting com quando-usar e quando-evitar
- `plugins/sdd-workflow/skills/sdd-workflow/references/tipos-projeto.md` — `web-saas` particularidades atualizadas (Tailwind v4, shadcn/ui CLI v4 + MCP, RLS by default); Camada 2 P-ws1 a P-ws4 inline

Commit intermediário ao final.

### Fase 4 — Camada 2 resto + integrações

Arquivos:
- `plugins/sdd-workflow/skills/sdd-workflow/references/tipos-projeto.md` (resto) — Camada 2 inline para `claude-plugin` (P-cp1 a P-cp4), `hubspot` (P-hs1 a P-hs4), `outro` (P-ou1 a P-ou3)
- `plugins/sdd-workflow/skills/sdd-workflow/references/integracao-skills.md` — refletir nova taxonomia onde aplicável
- `plugins/sdd-workflow/skills/sdd-workflow/templates/spike.md` — link com H4
- `plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md` — link com H9

Commit intermediário ao final.

### Fase 5 — Migração + cleanup

Arquivos:
- `plugins/sdd-workflow/skills/sdd-migrate-v1/SKILL.md` (NOVA SUB-SKILL) — fluxo de detecção e migração v0.x → v1.0.0
- `plugins/sdd-workflow/commands/migrate-v1.md` (NOVO) — atalho para `sdd-migrate-v1`
- `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` — finalizar atualização da seção Migração e demais ajustes pós-references
- `plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md` — link com H9
- `plugins/sdd-workflow/BACKLOG.md` — limpar 4.2.1, 4.2.2, 4.2.3 (cobertos); atualizar 4.2.4 (catálogo aberto vai pra v1.1) e 4.2.5 (Library-First condicional virou P-cp1/P-ou2 — cobertos)

Commit intermediário ao final.

### Fase 6 — Validar + bump

1. `claude plugin validate .`
2. Grep final por referências órfãs (princípios antigos, sintaxe MCP errada)
3. Cross-link sanity check
4. `marketplace-tools:publish-plugin sdd-workflow major` → v1.0.0

Push final via publish-plugin.

## Riscos e mitigações

| Risco | Mitigação |
|---|---|
| Inconsistências cross-arquivo | Ordem das fases + grep final |
| SKILL.md grande demais | Progressive disclosure: tabela curta no SKILL.md + detalhe nos references |
| Numeração de heurísticas/disciplinas inconsistente | Taxonomia documentada nesta spec |
| Algum Edit falhar no meio | Commits intermediários por fase = ponto de retorno |
| Sub-skill `sdd-migrate-v1` sem teste real | Migração é opt-in; só toca em constitution.md; markers `[INFERIDO]` |

## Pós-v1.0.0

Items que ficam no BACKLOG pra v1.1+:

- 4.1.1 a 4.1.7 (NEEDS CLARIFICATION marker, Constitutional Amendment Process operacional, sdd-bootstrap, sdd-bugfix, drift detection, TinySpec, templates ativos)
- 4.2.4 (catálogo aberto de tipos `tipos/<nome>.md`)

Janela de revisão de stack default: Q3-Q4 2026 (TanStack Start 1.0).
