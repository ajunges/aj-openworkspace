# Audit — [Projeto] — [Tier] — [YYYY-MM-DD]

> Output da Ship.Audit. Referência pras 14 dimensões: `references/audit-dimensoes.md` da skill SDD. Matriz de obrigatoriedade por tier: `references/tiers.md` seção 3.

## 1. Contexto

- **Tier alvo**: [tier]
- **tipo_projeto**: [tipo]
- **Audit anterior**: [link pra audit anterior se houver, ou "primeira audit"]

## 2. Dimensões executadas

| # | Dimensão | Obrigatório no tier? | Status | Achados |
|---|---|---|---|---|
| 1 | Segurança | obrigatório | 🟢 | 0 |
| 2 | Isolamento dados | obrigatório | 🟢 | 0 |
| 3 | Integridade dados | obrigatório | 🟡 | 2 |
| 4 | Performance | perguntar (sim) | 🟡 | 1 |
| 5 | Responsividade | obrigatório | 🟢 | 0 |
| 6 | UX/Layout | obrigatório | 🔴 | 1 |
| 7 | Código | obrigatório | 🟢 | 0 |
| 8 | Lógica de negócio | obrigatório | 🟢 | 0 |
| 9 | Acessibilidade | perguntar (não) | — | (pulado) |
| 10 | Observabilidade | opcional | 🟡 | 3 |
| 11 | Conformidade legal | opcional | 🟢 | 0 |
| 12 | Documentação operacional | obrigatório | 🟡 | 1 |
| 13 | Manutenibilidade | perguntar (não) | — | (pulado) |
| 14 | Defesa contra prompt injection | obrigatório (sim — produto tem LLM) | 🟢 | 0 |

(Se `tipo_projeto: claude-plugin`, dimensões 1-7 são substituídas pelo checklist do `plugin-dev:plugin-validator`. Mantém 8 e 12.)

(Dim 14 condicional a "produto tem LLM no caminho?". Se não tem LLM, dimensão é `—` em todos os tiers. Se tem LLM apenas interno em `mvp+`, vira `perguntar`. Se tem LLM usuário-facing em `mvp+`, vira `obrigatório`.)

## 3. Achados 🔴 críticos (bloqueiam Delivery)

### 3.1 [Título do achado]

- **Dimensão**: [#]
- **Onde**: [arquivo:linha]
- **Recomendação**: [fix concreto]
- **Status**: ❌ pendente

## 4. Achados 🟡 importantes

### 4.1 [Título]

- **Dimensão**: [#]
- **Onde**: [arquivo:linha]
- **Recomendação**: [fix concreto]
- **Status**: ❌ pendente | ✅ corrigido | 📋 aceito com justificativa

## 5. Achados 🟢 melhorias (nice-to-have)

[Lista de melhorias opcionais]

## 6. Dimensões puladas (com motivação)

- Dimensão 9 (Acessibilidade) — pergunta do usuário negou: "ferramenta interna, sem requisito de a11y"
- Dimensão 13 (Manutenibilidade) — pergunta do usuário negou: "projeto curto, manutenção mínima esperada"

## 7. Resumo

- 🔴 críticos: 1 — **bloqueia Delivery**
- 🟡 importantes: 7 (1 corrigido, 6 pendentes)
- 🟢 melhorias: 0

## 8. Próximo passo

→ Corrigir 🔴 críticos antes de Ship.Delivery. 🟡 podem ser aceitos com justificativa registrada na constitution.
