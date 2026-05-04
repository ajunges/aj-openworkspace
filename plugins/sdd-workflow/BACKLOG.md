# Backlog do plugin sdd-workflow

Inventário consolidado de itens pendentes pra evoluções futuras do plugin. Não é roadmap rígido — é checkpoint pra retomada de contexto sem precisar redescobrir o que já foi catalogado.

Atualizado em: 2026-05-04 (pós-v1.0.1 — itens 1.1 (shadcn/ui setup operacional) e 1.2 (matriz Drizzle vs Prisma) da seção Polish resolvidos; itens 4.1.x permanecem pendentes).

---

## 1. Polish (🟢 — patches v1.0.x)

Itens de polish pós-v1.0.0 — não são correção, são refinamento operacional. Acumular e aplicar em batch ou isolados conforme conveniência.

_Atualmente vazio. Adicionar próximo polish aqui (manter formato tabela com colunas # / Item / Local de impacto / Esforço)._

---

## 2. Roadmap v4.0 (🔵 — minor/major bumps)

Itens explicitamente registrados como "no radar pra v4.0" no spec/SKILL atual. Revisar quando bater o trigger associado.

| # | Item | Origem | Trigger pra revisitar |
|---|---|---|---|
| 2.1 | **GEARS** — avaliar substituição/complemento do EARS pra Requirements | `references/linguagens-especificacao.md:98-104` + spec `4.5.5` | Tração mainstream + posicionamento do Spec Kit, ou 6-12 meses (o que vier antes) |
| 2.2 | **DDD tactical patterns** (aggregates, entities, value objects) | spec `4.6.3` (fora do escopo v3) | Quando aparecer projeto `producao_real` complexo que justifique |
| 2.3 | **Sub-skill `sdd-migrate`** pra automatizar migração v2.x → v3.0 (hoje é manual via skill principal — IA pergunta e edita) | `SKILL.md:393-401` | Se a migração manual virar dor recorrente em uso real |

---

## 3. Sugestões operacionais

### 3.1 Critério explícito de quando rodar Ship.Audit fora do fluxo principal

Hoje o command `/sdd-workflow:audit` existe pra disparar Audit standalone, mas o `SKILL.md` não documenta **quando** essa execução fora-do-fluxo é apropriada. Decisão fica pro julgamento da IA/user, sem tier policy ou trigger explícito.

Casos típicos que mereceriam recomendação explícita:

- Após mudança em código de feature já entregue (regression risk em dimensões `obrigatório` da Audit)
- Após bump de tier (já coberto pela sub-skill `sdd-promote-tier`, mas `/audit --dimensoes` é alternativa pra reauditoria parcial)
- Antes de pull request grande pra revisão
- Periodicamente (mensal/trimestral) em projetos `mvp+` em produção real

**Sugestão de implementação**: adicionar sub-seção em "Como invocar" do SKILL principal, após a tabela de slash commands, com matriz "quando rodar `/sdd-workflow:audit`".

### 3.2 Trigger pra revisitar Stripe Managed Payments

`overrides-matrix.md` seção 3 cita Stripe Managed Payments como "em expansão (preview público fev/2026)". Hoje sem gatilho explícito de revisão — fica fácil esquecer.

**Casos pra revisitar:**
- Stripe anuncia GA (general availability) do Managed Payments
- Algum projeto real chega a ARR onde MoR (Merchant of Record) muda economia (~$100k+ ARR)
- Lemon Squeezy é deprecada (acquisition pela Stripe pode acelerar isso)

**Sugestão de implementação**: agendar lembrete via `/schedule` (skill scheduled-tasks) pra revisar `overrides-matrix.md` seção billing em Q4 2026. Ou criar entrada formal numa "tabela de revisões agendadas" em `references/stacks.md` (junto da janela Q3-Q4 2026 do TanStack Start).

---

## 4. Inspirações do Spec Kit a digerir (🟣 — pesquisa, não TODO ativo)

Resultado do levantamento comparativo contra o GitHub Spec Kit (referência [github/spec-kit](https://github.com/github/spec-kit), maio/2026). Cada item exige decisão de adoção/adaptação antes de virar feature — não tem dono nem ETA. Quando algo daqui virar prioridade, mover pra seção 1, 2 ou 3 conforme natureza.

### 4.1 Inspirações diretas do Spec Kit (top 7 priorizadas)

| # | Item | Origem no Spec Kit | Por que considerar | Decisão pendente |
|---|---|---|---|---|
| 4.1.1 | Marker `[NEEDS CLARIFICATION: <pergunta>]` como gate | Templates oficiais do Spec Kit forçam IA a marcar ambiguidade explícita em vez de adivinhar | Operacionaliza nosso princípio 3 (defensividade). Vira Quality Gate adicional: spec não avança com markers pendentes | Adotar como Quality Gate em Discovery/Requirements/Design ou só como recomendação? Aplica a Build também ou TDD já cobre? |
| 4.1.2 | Constitutional Amendment Process formal | Section 4.2 do `spec-driven.md` — princípios imutáveis com processo de emenda (rationale + review + backwards compat) | Resolve gap "princípios invioláveis sem mecanismo de exceção". Mantém rigor com saída honesta | Adicionar seção "Emendas" na constitution (template) ou criar sub-skill `sdd-emendar`? |
| 4.1.3 | Sub-skill `sdd-bootstrap` (Brownfield) | Extensão `spec-kit-brownfield` da comunidade Spec Kit | Gap claro: nosso fluxo assume novo projeto. Audiência real raramente é greenfield | Sub-skill nova (como `sdd-promote-tier`) ou modo do `sdd-workflow:start`? |
| 4.1.4 | Sub-skill `sdd-bugfix` | Extensão `spec-kit-bugfix` da comunidade Spec Kit | Não cobrimos hoje (só feature). Bug é evento corrente em projeto real | Trace pra qual artefato? Requirements + Design + plan da feature original? |
| 4.1.5 | Drift detection (Spec Sync / Verify Tasks) | Extensões `spec-kit-sync`, `spec-kit-reconcile`, `spec-kit-verify-tasks` | TDD ajuda mas não previne drift e "phantom completion" (task marcada done sem implementação) | Conjunto de slash commands de manutenção ou sub-skill única `sdd-reconcile`? |
| 4.1.6 | TinySpec mode | Extensão `spec-kit-tinyspec` | Endereça crítica de "heavy process always-on". Leigos vão querer fazer coisa pequena sem ritual completo | Slash command `/sdd-workflow:lite` que pula direto a Build pra `tier: prototipo_descartavel`? Ou mecanismo no `start`? |
| 4.1.7 | Templates como prompt engineering ativo | Doutrina central do Spec Kit: cada template é "unit test" do spec com checklists embutidos, marcadores de ambiguidade, gates concretos | Nossos templates são "preencha aqui". Tornar cada um auto-validador multiplica qualidade | Refactor incremental dos 8 templates ou template-meta novo que outros referenciam? |
| 4.1.8 | Reference `custos-por-tier.md` consolidada | Pesquisa de stack v1.0.0 trouxe tabela detalhada Stack A vs B vs C com 1k MAU vs 10k MAU. Hoje fica implícito espalhado em `overrides-matrix.md` | Leigo precisa saber "quanto vou pagar" antes de comprometer com stack. Mas manter números atualizados é overhead — só vale se virar dor recorrente | Aguardar 2-3 projetos reais pedirem antes de virar reference oficial. Origem: `docs/superpowers/research/sdd-stack-research-2026-05.md` seção P8 |

### 4.2 Refinamentos estruturais do brainstorming Spec Kit (decisões de design)

Status pós-v1.0.0:

| # | Item | Status |
|---|---|---|
| 4.2.1 | Tier flexível (campo `tier_observado` separado) | **Descartado por excesso de complexidade** — análise concluiu que custo > benefício pra audiência leiga em projetos curtos. Reconsiderar quando aparecer caso real de projeto longo onde autor perdeu o tier de vista |
| 4.2.2 | Tier preliminar | **Coberto em v1.0.0 de forma simplificada** — substituído pelo campo `tier_confianca: alta\|media\|baixa` no YAML da constitution. Sem janela temporal, sem campo separado, sem novo conceito |
| 4.2.3 | Detector heurístico de subdeclaração | **Coberto em v1.0.0** — perguntas de Discovery "audiencia / gera_receita / armazena dado pessoal / fica online 24/7" contrastam com tier declarado. Inconsistências viram ADR via H5 |
| 4.2.4 | Catálogo aberto de `tipo_projeto` | **Reformulado pra v1.1** — em v1.0.0 a Camada 2 (princípios arquiteturais por tipo) está inline em `tipos-projeto.md` por tipo. Próximo passo é decompor em arquivos `tipos/<nome>.md` autocontidos quando aparecer demanda real (catálogo aberto) |
| 4.2.5 | Library-First condicional | **Coberto em v1.0.0** — virou P-cp1 (princípio explícito da Camada 2 pra `claude-plugin`) e P-ou2 (princípios propostos pela IA pra `outro` quando descoberto é "CLI tool / lib / SDK / data pipeline") |

### 4.3 Decisão consciente de NÃO adotar (registrar pra não revisitar sem novo trigger)

| Item rejeitado do Spec Kit | Motivo |
|---|---|
| Article I — Library-First Principle universal | Exige conceitos (library, boundary, CLI contract) que quebram premissa de audiência leiga; estorva `web-saas` e `hubspot` |
| Article II — CLI Interface Mandate | Idem — força CLI em paradigmas (React app, Hubspot UI Extension) onde não cabe |
| Suporte multi-agente (Copilot, Cursor, Windsurf, Codex) | Custo enorme de manutenção; viver dentro do Claude Code é decisão estratégica |
| CLI próprio (`specify init`) | Claude Code já é entry point via slash + skill; CLI duplicaria interface |
| Estrutura por branch numerada `001-feature-name` | Nossa `specs/plans/<feature>.md` cobre o caso; branch numerada vira friction em projeto solo informal |

Trigger pra revisitar 4.3: ecossistema externo virar dominante (Claude Code perder share) ou demanda recorrente (3+ usuários reais pedindo) por algum item.

---

## 5. Manutenção deste arquivo

Convenções:

- **Adicionar item**: novo registro na seção apropriada (1 = polish, 2 = roadmap v4.0, 3 = sugestão operacional, 4 = inspirações do Spec Kit) com link pro local de impacto. Numeração por seção é referência informal — usar em commit messages tipo `aplicado item 1.2 do backlog`.
- **Remover item resolvido**: deletar a linha após o commit que aplicou. Não manter histórico de "resolvido" aqui — git log do plugin cobre.
- **Bumpar prioridade**: mover entre seções. Cada movimento exige justificativa no commit (ex: "polish 1.4 vira sugestão operacional 3.X após X projetos pediram").
- **Bump de version do plugin**:
  - **Não exigido** pra updates triviais do backlog (adicionar/remover linha, ajustar prosa).
  - **Exigido** quando a mudança do backlog **acompanha** mudança de comportamento (skill, command, sub-skill, template, reference). O bump vem da mudança de comportamento, não do backlog em si.
- **Não usar como TODO list ativo** — itens aqui não têm dono nem prazo. Quando algo virar prioridade real, vira spec/plano dedicado em `docs/superpowers/specs/` e `docs/superpowers/plans/` do repo, não uma linha extra aqui.
