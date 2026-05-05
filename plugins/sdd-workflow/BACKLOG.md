# Backlog do plugin sdd-workflow

Inventário consolidado de itens pendentes pra evoluções futuras do plugin. Não é roadmap rígido — é checkpoint pra retomada de contexto sem precisar redescobrir o que já foi catalogado.

Atualizado em: 2026-05-05 (pós-v1.0.1 — itens originais 1.1 (shadcn/ui setup operacional) e 1.2 (matriz Drizzle vs Prisma) resolvidos + cleanup mecânico de drift v0.x→v1.0.0 em SKILL.md/start.md/promote-tier.md/alvos-deploy.md/inventario-dependencias.md/plugin.json description; novo polish 1.1 do README.md flagado pra patch v1.0.2; novos polish 1.2 (cleanup de emojis alinhado a preferência global zero-emojis) e 1.3 (otimizar SKILL.md principal — 480 linhas) adicionados após avaliação minuciosa do plugin; nova seção 4.4 cataloga dimensões pendentes pra brainstormar 4.1.3-4.1.6 (Brownfield/Bugfix/Drift/TinySpec); itens 4.1.x permanecem pendentes).

---

## 1. Polish (🟢 — patches v1.0.x)

Itens de polish pós-v1.0.0 — não são correção, são refinamento operacional. Acumular e aplicar em batch ou isolados conforme conveniência.

| # | Item | Local de impacto | Esforço |
|---|---|---|---|
| 1.1 | Refresh do `README.md` pós-v1.0.0 — header "v3.0" → v1.0, description antiga ("13 dimensões × 5 tiers", "Princípio inviolável: dados reais", emoji 🔒), stack `web-saas` legacy (React/Vite/Express/Prisma/PG → Next.js/Supabase/Prisma/Tailwind v4/shadcn CLI v4/MCP), tabela slash commands faltando `migrate-v1`, seção "Migração v2.x → v3.0" defasada. Trabalho editorial real (decisão sobre quanto detalhe de governança em 3 camadas mencionar) | `plugins/sdd-workflow/README.md` | médio |
| 1.2 | Cleanup de emojis no plugin alinhado a preferência global "zero emojis" do autor. **Semânticos** (precisam virar marcadores textuais estáveis sem perder significado): 🔒 (valida dados reais — em SKILL/templates/references) → ex. `[VALIDA_DADOS_REAIS]` ou keyword inline; 🔴🟡🟢 (severity de achados na Audit) → `crítico/importante/melhoria`; ✅❌⏸️🔄📋 (status de gate/feature/promoção) → `atendido/pendente/aguardando/em-andamento/aceito-com-justificativa`. **Decorativos** (podem ser removidos): 📊 e ●●●○○ na status line do `progress.md`; 🟢🔵🟣 nos cabeçalhos das seções deste BACKLOG. **Trade-off**: emojis funcionam como anchor visual pra IA fazer scanning rápido — substituição precisa preservar legibilidade automática. **Decisão de escopo pendente**: cleanup completo (todos os emojis) vs. cleanup só dos decorativos (mantém os semânticos como convenção interna do plugin) — escolher quando aplicar | `SKILL.md` principal + templates (`tasks`, `plan-feature`, `audit`, `progress`) + references (`audit-dimensoes`, `disciplinas-tier`, `linguagens-especificacao`) + `BACKLOG.md` + outros referenciados | alto |
| 1.3 | Otimizar tamanho da `SKILL.md` principal — 480 linhas, perto do limite saudável de progressive disclosure. Candidato natural a mover pra reference(s): descrição detalhada dos 4 estágios (~265 linhas, seções "Estágio I — Pré-spec" até "Estágio IV — Ship") representam ~55% do arquivo e só são consultadas quando IA está numa fase específica. SKILL principal mantém: premissa fundadora, governança em 3 camadas (resumo), gates configuráveis, visão geral do fluxo (tabela), apêndice de references/templates, seção "Como invocar". **Trade-off**: progressive disclosure melhora (carregamento condicional por estágio reduz tokens fora da fase ativa), mas IA precisa carregar reference extra toda vez que entra numa fase nova (latência + contagem de tool calls). **Decisão de design pendente**: 1 reference único `references/fluxo-detalhado.md` vs. 4 references por estágio (`fluxo-pre-spec`, `fluxo-spec`, `fluxo-build`, `fluxo-ship`) vs. status quo. Meta: SKILL principal em ~250-300 linhas | `SKILL.md` principal + novo(s) reference(s) em `skills/sdd-workflow/references/` | médio-alto |

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

> Os itens **4.1.3, 4.1.4, 4.1.5 e 4.1.6** têm dimensões pendentes adicionais catalogadas em **4.4** abaixo — ler antes de promover qualquer um destes 4 pra prioridade ou virar spec.

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

### 4.4 Lacunas pendentes pra desenvolver inspirações estratégicas (4.1.3-4.1.6)

Os 4 itens **4.1.3** (Brownfield/`sdd-bootstrap`), **4.1.4** (`sdd-bugfix`), **4.1.5** (Drift detection/`sdd-reconcile`) e **4.1.6** (TinySpec mode) ficaram catalogados na tabela 4.1 com 1 pergunta-chave cada. Quando algum virar prioridade, estas dimensões precisam ser respondidas antes de virar spec. Não são TODOs — é checklist de "está pronto pra brainstormar" pra cada item.

#### 4.4.1 — Brownfield (`sdd-bootstrap`)

- **Detecção de brownfield**: sinais a checar (código existente sem `specs/`? `package.json` antigo? CLAUDE.md presente? código rodando em prod?)
- **Retroengenharia da constitution**: IA inspeciona o código e propõe `tipo_projeto`/`tier`, ou usuário declara como em greenfield?
- **Audit retroativo**: sub-skill roda audit pra rotular o estado atual antes de propor o tier projetado?
- **Tier real vs projetado**: projeto em prod existente não é `prototipo_descartavel` — como sinalizar divergência entre tier observado e projetado
- **Triggers naturais sugeridos**: "tenho um projeto pronto, quero usar SDD do meio pra frente", "importar projeto pro fluxo SDD"

#### 4.4.2 — Bugfix (`sdd-bugfix`)

- **Critério de invocação**: bugfix retroativo (após Ship.Delivery/Deploy) vs durante Build.Implementation (loop por feature já cobre o caso comum)
- **Trace pra spec**: nova regra EARS em `requirements.md`? cenário BDD em `tasks.md` ou no plano da feature original? ADR via H5 com causa raiz?
- **Integração com `superpowers:systematic-debugging`**: sub-skill orquestra os 4 passos canônicos (reproduzir → isolar → diagnosticar → corrigir) ou só invoca?
- **Reaudit**: ativa Ship.Audit nas dimensões impactadas após fix? Condicional ao tier?
- **Triggers naturais sugeridos**: "fix em produção", "bug encontrado pós-delivery"

#### 4.4.3 — Drift detection (`sdd-reconcile`)

- **Tipologia de drift (5 tipos a cobrir)**:
  - spec → código (requirement EARS sem implementação correspondente)
  - código → spec (impl sem requirement)
  - tasks → implementação ("phantom completion" — task marcada done sem código real)
  - constitution → realidade (decisão registrada obsoleta)
  - tier projetado → tier real (promoção informal não registrada)
- **Mecânica de detecção**: grep + heurística, AST, IA lendo ambos? Custo em tokens importa
- **Cadência**: periódico (mensal?), gate da Audit, ou só trigger manual?
- **Output**: relatório com classificação (intencional / débito técnico / erro) e proposta de reconciliação

#### 4.4.4 — TinySpec mode

- **Definição operacional de "tiny"**: LOC < N? features < N? só `prototipo_descartavel`? ou inclui `uso_interno`?
- **Fases enxugadas**: Discovery curto, Constitution só com YAML + 2 seções, Stack sem checkpoint crítico, Requirements como bullets em prosa em vez de EARS estruturado, Audit reduzido a dim 8 (Lógica de negócio)
- **Promoção pra fluxo completo**: gatilho automático quando projeto cresce ou migração manual? Como spec light vira spec completa sem retrabalho?
- **Risco existencial**: tinyspec abre exceção à tese fundadora ("rigor escala pelo destino"). Cabe ou contradiz?

#### 4.4.5 — Lacunas transversais entre os 4

- **Dependências**: bootstrap depende de drift detection (importar projeto = reconciliar com spec gerada). Bugfix pode usar drift detection (bug como manifestação de drift)
- **Prioridade relativa**: qual viria primeiro se algum virasse dor real? Hoje os 4 estão em paralelo sem ranking
- **Critério de "vira prioridade"**: quantos projetos reais pedindo? Sinal explícito (ex: 3+ usuários, 1 incidente que tinyspec teria evitado)
- **Sobreposição com sub-skills existentes**: bootstrap pode reaproveitar parte do `sdd-migrate-v1`? bugfix replicaria parte do loop de Build.Implementation?

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
