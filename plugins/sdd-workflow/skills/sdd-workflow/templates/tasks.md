# Tasks — plano-mestre

> Este arquivo é o **índice** das features. Cada feature tem seu próprio plano detalhado em `specs/plans/<feature>.md` (formato `superpowers:writing-plans` com 5 ajustes de convenção SDD — ver SKILL.md principal seção 5.1.1).

## 1. Visão geral

| # | Feature | Plano detalhado | 🔒 (validação dados reais) | Dependências | Status |
|---|---|---|---|---|---|
| 1 | [Nome da feature] | `specs/plans/01-<slug>.md` | sim/não | — | ⏸️ Aguardando |
| 2 | [Nome da feature] | `specs/plans/02-<slug>.md` | sim | Feature 1 | ⏸️ Aguardando |
| 3 | [...] | `specs/plans/03-<slug>.md` | não | Feature 2 | ⏸️ Aguardando |

**Legenda de status**: ⏸️ Aguardando · 🔄 Em andamento · ✅ Concluída · ❌ Bloqueada

## 2. Ordem de execução

(Ordem típica pra `web-saas` — adaptar conforme tipo de projeto)

1. **Infra e Setup** — Docker, scripts, banco
2. **Auth + Layout** — login, JWT, sidebar, mobile drawer (se UI)
3. **CRUDs administrativos** — entidades base
4. **Lógica de negócio 🔒** — cálculos, validações (validação obrigatória contra dados reais)
5. **Dashboards e visualizações** (se aplicável)
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** — isolamento, validações, responsividade

## 3. Marcação 🔒 — features de validação contra dados reais

Features marcadas 🔒 exigem validação obrigatória contra dados reais dos documentos de referência (princípio inviolável 1). Quality Gate por feature inclui mostrar comparativo ao usuário antes de avançar.

Exemplos típicos: cálculos financeiros, motor de regras de negócio, importadores/exportadores que devem replicar comportamento de planilha existente.

## 4. Gate por feature

Cada feature concluída exige:

- [ ] Todos os steps do plano detalhado executados
- [ ] Testes da feature passando (output mostrado)
- [ ] Se 🔒: comparativo contra dados reais mostrado e aprovado
- [ ] Aprovação humana antes de marcar ✅ e avançar pra próxima

## 5. Próximos passos

Cada feature segue ciclo individual via `superpowers:executing-plans` ou `superpowers:subagent-driven-development` no plano detalhado.
