# Backlog do plugin sdd-workflow

Inventário consolidado de itens pendentes pra evoluções futuras do plugin. Não é roadmap rígido — é checkpoint pra retomada de contexto sem precisar redescobrir o que já foi catalogado.

Atualizado em: 2026-05-03 (pós-v0.2.4 — seção 1 esvaziada, seção 4 adicionada com inspirações do Spec Kit).

---

## 1. Polish (🟢 — patches v0.2.x)

Itens da autorrevisão pós-v0.2.1 que não foram aplicados porque são polish, não correção. Acumular e aplicar em batch ou isolados conforme conveniência.

(Sem itens pendentes no momento.)

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

### 4.2 Refinamentos estruturais do brainstorming Spec Kit (decisões de design)

Itens que surgiram do confronto com Spec Kit mas **não** são portes diretos — são respostas aos gaps que apareceram comparando os dois.

| # | Item | Tensão que endereça | Hipótese de implementação |
|---|---|---|---|
| 4.2.1 | **Tier flexível** — adicionar campo `tier_observado` ao lado de `tier:` (projetado), atualizado a cada Quality Gate; IA propõe Promoção quando observado encosta no projetado | Tier projetado ambicioso desde dia 1 cria fricção; subdeclaração estratégica pula gates obrigatórios | YAML: `tier: mvp` + `tier_observado: uso_interno` + `tier_decidido_em: …` |
| 4.2.2 | **Tier preliminar** — `tier_preliminar: mvp` permite declarar com baixa confiança; IA aplica gates do tier inferior por janela definida e força definição firme até Build.Tasks | Mesma tensão acima — fricção dia 1 leva a abandono ou ritual quebrado | Janela = "até Build.Tasks ou 14 dias, o que vier antes"; IA pergunta confirmação no Pré-spec.Stack |
| 4.2.3 | **Detector heurístico de subdeclaração** — IA pergunta sinais ("vai cobrar dinheiro?", "armazenar dado pessoal?", "ficar online 24/7?") na Discovery e contrasta com tier declarado | Subdeclaração estratégica passa silenciosamente | Não bloqueia, força reflexão — registro na constitution se aceita inconsistência |
| 4.2.4 | **Catálogo aberto de `tipo_projeto`** — mover cada tipo pra `tipos/<nome>.md` autocontido com seções padronizadas (stack default, skills B, particularidades, override Audit); plugin escaneia o diretório no Pré-spec.Discovery | Catálogo fechado de 4 tipos engessa conforme universo cresce (mobile, CLI, ML, data eng, MCP server, agente autônomo) | Manter `web-saas`/`claude-plugin`/`hubspot` como tipos oficiais; novo arquivo por tipo; usuário pode adicionar; critério "2+ em 6 meses" vira promoção pra oficial, não barreira de entrada |
| 4.2.5 | **Library-First condicional** — não como princípio universal, mas como recomendação opcional na Spec.Design pra `tipo_projeto: outro` quando o tipo descoberto for "CLI tool / lib / SDK / data pipeline" e pra `producao_real` complexo | Library-First do Spec Kit é forte mas opinativo demais pra audiência leiga + stacks típicas (`web-saas`, `hubspot`); descartar inteiramente perde ativo | Citar como inspiração na seção sobre Bounded Contexts (já opcional no Design); nova nota "Quando Library-First faz sentido?" |

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
