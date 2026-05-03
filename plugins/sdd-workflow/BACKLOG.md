# Backlog do plugin sdd-workflow

Inventário consolidado de itens pendentes pra evoluções futuras do plugin. Não é roadmap rígido — é checkpoint pra retomada de contexto sem precisar redescobrir o que já foi catalogado.

Atualizado em: 2026-05-03 (pós-v0.2.4 — seção 1 esvaziada).

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

## 4. Manutenção deste arquivo

Convenções:

- **Adicionar item**: novo registro na seção apropriada (1 = polish, 2 = roadmap v4.0, 3 = sugestão operacional) com link pro local de impacto. Numeração por seção é referência informal — usar em commit messages tipo `aplicado item 1.2 do backlog`.
- **Remover item resolvido**: deletar a linha após o commit que aplicou. Não manter histórico de "resolvido" aqui — git log do plugin cobre.
- **Bumpar prioridade**: mover entre seções. Cada movimento exige justificativa no commit (ex: "polish 1.4 vira sugestão operacional 3.X após X projetos pediram").
- **Bump de version do plugin**:
  - **Não exigido** pra updates triviais do backlog (adicionar/remover linha, ajustar prosa).
  - **Exigido** quando a mudança do backlog **acompanha** mudança de comportamento (skill, command, sub-skill, template, reference). O bump vem da mudança de comportamento, não do backlog em si.
- **Não usar como TODO list ativo** — itens aqui não têm dono nem prazo. Quando algo virar prioridade real, vira spec/plano dedicado em `docs/superpowers/specs/` e `docs/superpowers/plans/` do repo, não uma linha extra aqui.
