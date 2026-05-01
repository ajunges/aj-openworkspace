# Auditoria — 13 dimensões × 5 tiers

Reference do plugin `sdd-workflow` (v3.0). Detalhe das dimensões da Ship.Audit. Matriz de obrigatoriedade vive em `references/tiers.md` seção 3.

## 1. As 13 dimensões

### 1.1 Segurança
Senhas hardcoded, tokens expostos, CORS mal configurado, rotas desprotegidas, variáveis sensíveis no código, rate limiting, headers HTTP (helmet em Node).

### 1.2 Isolamento de dados
Confirmar que um perfil/tenant NÃO consegue acessar dados de outro via API. Testar com curl direto na API (não só via UI).

### 1.3 Integridade de dados
Validações de input no backend: valores negativos onde não deveria, campos obrigatórios, tipos errados, ranges (year/month, etc.).

### 1.4 Performance
Queries N+1, `await` em loop (usar `Promise.all`), imports desnecessários, bundle size do frontend, índices faltando no banco.

### 1.5 Responsividade
Testar em 375px (mobile), 768px (tablet), 1440px (desktop). Touch targets mínimo 20px. Tabelas com scroll horizontal. Drawer fecha ao navegar.

### 1.6 UX/Layout
Brand colors do projeto (constitution), loading states (Skeleton), empty states, toast para feedback (nunca `alert()`), consistência visual, espaçamentos.

### 1.7 Código
Imports errados ou não usados, `console.log` esquecidos, TODOs pendentes não trackados, try/catch em route handlers, error boundaries no React.

### 1.8 Lógica de negócio
Conferir cálculos e regras de negócio contra **dados reais** dos documentos de referência. Validar que resultados batem. **Esta dimensão é obrigatória em todos os tiers** porque é o coração do princípio inviolável 1.

### 1.9 Acessibilidade (a11y)
Contraste WCAG AA (4.5:1 pra texto normal), labels em inputs, alt em imagens, foco visível, navegação teclado, ARIA em componentes complexos.

### 1.10 Observabilidade
Logs estruturados (não só console.log), error tracking (Sentry-style), logs em boundaries críticos (auth, transações, integrações externas), health check endpoint, métricas básicas (latência, error rate).

### 1.11 Conformidade legal
LGPD se manipula dados pessoais (consentimento, opt-out, retenção, exportação), termos de uso/privacy policy, cookies com consentimento.

### 1.12 Documentação operacional
README cobre setup/run/deploy/troubleshooting, CHANGELOG, ADRs (Architecture Decision Records) se houve decisão arquitetural relevante.

### 1.13 Manutenibilidade
TODO/FIXME órfãos sem issue, duplicação significativa, arquivos/funções muito grandes, cobertura de teste mínima.

---

## 2. Override por `tipo_projeto`

### `claude-plugin`

Dimensões 1-7 (Segurança, Isolamento, Integridade, Performance, Responsividade, UX, Código) **substituídas** pelo checklist do `plugin-dev:plugin-validator`. Markdown não tem isolamento de dados nem queries N+1. Mantém:
- Dimensão 8 (Lógica de negócio = comportamento do plugin)
- Dimensão 12 (Documentação operacional = README do plugin)

### `hubspot`

- Dimensão 1 (Segurança) **eleva ao máximo** — checks específicos de tokens HubSpot vazados, scopes documentados, sandbox testado antes de prod
- Dimensão 2 (Isolamento) verifica não-vazamento entre portais

---

## 3. Skills usadas na Audit

- `superpowers:dispatching-parallel-agents` — paraleliza dimensões independentes (todas as obrigatórias rodam em paralelo)
- `superpowers:requesting-code-review` — review humana antes da Audit, se aplicável
- `code-review:code-review` — sub-agente pra dimensão Código
- `security-review` (built-in) — pra dimensão Segurança
- `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`

---

## 4. Output da Audit

`specs/audit-<YYYY-MM-DD>.md`. Estrutura:

```markdown
# Audit — [Projeto] — [Tier] — [Data]

## Dimensões executadas
[lista com 🟢/🟡/🔴 por dimensão]

## Achados 🔴 críticos (bloqueiam Delivery)
- [achado] em [arquivo:linha] — [recomendação de fix]

## Achados 🟡 importantes
[...]

## Achados 🟢 melhorias
[...]

## Dimensões puladas (com motivação)
- [dimensão] — [motivo: tier não exige / pergunta do usuário negou / etc.]
```

Audit é **repetível** — múltiplos audits ao longo do projeto preservam histórico. Promoção de Tier dispara nova Audit focada nas dimensões novas obrigatórias.
