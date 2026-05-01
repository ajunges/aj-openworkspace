# Tiers — escala de maturidade do produto

Reference do plugin `sdd-workflow` (v3.0). A escolha do tier determina dimensões obrigatórias da Audit, recursos mínimos da stack, e rigor do Ship.Deploy.

## 1. Princípio: tier projetado, não estado atual

O tier é a **visão final** do desenvolvimento, não o estado atual. Se eu começo um sistema sabendo que será MVP em 3 meses, o tier é `mvp` desde o dia 1 — mesmo que hoje o código seja só protótipo. Os gates da Audit são executados pra esse tier alvo.

Mudança de tier = decisão consciente, registrada via Promoção de Tier (sub-skill `sdd-promote-tier`).

---

## 2. Os 5 níveis

| # | Tier | Significado |
|---|---|---|
| 1 | `prototipo_descartavel` | Validar conceito, depois jogar fora |
| 2 | `uso_interno` | Eu/equipe pequena, não vai pra fora |
| 3 | `mvp` | Primeiros usuários reais, escopo pequeno |
| 4 | `beta_publico` | Público maior, ainda em validação |
| 5 | `producao_real` | Sistema sério, manutenção contínua |

**Default quando não declarado**: pedir explicitamente sempre. Sem fallback silencioso.

---

## 3. Matriz de obrigatoriedade da Audit (13 dimensões × 5 tiers)

| Dimensão | protótipo | interno | MVP | beta púb. | prod real |
|---|---|---|---|---|---|
| 1. Segurança | — | obrigatório | obrigatório | obrigatório | obrigatório |
| 2. Isolamento dados | — | obrigatório | obrigatório | obrigatório | obrigatório |
| 3. Integridade dados | perguntar | obrigatório | obrigatório | obrigatório | obrigatório |
| 4. Performance | — | perguntar | perguntar | obrigatório | obrigatório |
| 5. Responsividade | — | perguntar | obrigatório | obrigatório | obrigatório |
| 6. UX/Layout | — | perguntar | obrigatório | obrigatório | obrigatório |
| 7. Código | perguntar | obrigatório | obrigatório | obrigatório | obrigatório |
| 8. Lógica de negócio | obrigatório | obrigatório | obrigatório | obrigatório | obrigatório |
| 9. Acessibilidade | — | — | perguntar | perguntar | perguntar |
| 10. Observabilidade | — | — | opcional | obrigatório | obrigatório |
| 11. Conformidade legal | — | — | opcional | obrigatório | obrigatório |
| 12. Documentação operacional | perguntar | obrigatório | obrigatório | obrigatório | obrigatório |
| 13. Manutenibilidade | — | — | perguntar | perguntar | obrigatório |

**Legenda**:
- `obrigatório`: gate falha sem cobertura. Achados 🔴 bloqueiam Delivery.
- `opcional`: IA recomenda e roda; achados informativos, não bloqueiam.
- `perguntar`: IA pergunta no início da Audit; resposta registrada na constitution.
- `—`: dimensão não rodada nesse tier; explicitamente pulada.

---

## 4. Impactos em outras fases

| Fase | Como o tier impacta |
|---|---|
| Pré-spec.Stack | Define recursos mínimos (DB gerenciado vs SQLite, etc.) |
| Spec.Design | Define rate limiting, escalabilidade, observabilidade |
| Build.Implementation | Define cobertura mínima de testes |
| Ship.Audit | Define dimensões obrigatórias (matriz acima) |
| Ship.Deploy | Define rollback, monitoramento, alertas |

---

## 5. Promoção de Tier

Mudar de tier ao longo do projeto = decisão consciente registrada na constitution. Sub-skill `sdd-promote-tier` orquestra os 11 passos da promoção (incremental, não recomeça do zero).

Ver `references/audit-dimensoes.md` pra detalhe das dimensões e `sdd-promote-tier/SKILL.md` pro fluxo.
