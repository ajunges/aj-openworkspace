# Stacks — catálogo por tipo de projeto

Reference do plugin `sdd-workflow` (v3.0). Stack default sugerida por `tipo_projeto`. **Override é permitido em todos** — o checkpoint da Pré-spec.Stack força reflexão crítica antes de aceitar default.

## 1. Princípio: stack varia também por tier

A stack default escala com o tier. Exemplo `web-saas`: `uso_interno` aceita Postgres em Docker local; `mvp` puxa PG gerenciado leve (Supabase free, Neon free); `beta_publico+` exige PG gerenciado com backup, CDN, error tracking.

---

## 2. `web-saas`

| Camada | uso_interno | mvp | beta_publico+ |
|---|---|---|---|
| Frontend | React + Vite + Tailwind + shadcn/ui | (mesmo) | (mesmo) + CDN |
| Backend | Node.js + Express + Prisma | (mesmo) | (mesmo) + rate limiting |
| Banco | PostgreSQL Docker | PG gerenciado (Supabase/Neon/RDS) | + backup + replicas |
| Auth | JWT caseiro | (mesmo) ou Auth0/Clerk | Auth0/Clerk/Supabase Auth |
| Gráficos | Recharts | (mesmo) | (mesmo) |
| Brand colors | definir na constitution | (mesmo) | (mesmo) |

---

## 3. `claude-plugin`

| Camada | Default |
|---|---|
| Skill files | Markdown + frontmatter YAML |
| Commands | Markdown + frontmatter YAML |
| Hooks | Shell scripts |
| Plugin manifest | `.claude-plugin/plugin.json` (JSON) |
| Marketplace entry | `.claude-plugin/marketplace.json` (JSON, no marketplace que vai hospedar) |
| Validação | `claude plugin validate .` |
| Versionamento | SemVer no `marketplace.json` (Level 3) ou `plugin.json` (Level 1/2) |

**Sem build system, sem test runner**. TDD adaptado pra markdown — ver `references/linguagens-especificacao.md` e a seção 5.1.2 do spec do plugin SDD pra detalhe.

---

## 4. `hubspot`

| Camada | Default |
|---|---|
| CLI | HubSpot CLI (`hs`) |
| Auth | Private App com scopes mínimos (preferir API key sobre OAuth quando viável) |
| Custom Objects | Schema JSON (em `src/objects/`) |
| UI Extensions | React + HubSpot Extensions SDK (em `src/extensions/`) |
| Serverless Functions | Node.js (em `src/serverless/`) |
| Webhooks | Endpoints registrados na app config |
| Secrets | `.env` ou `hs auth` (NUNCA versionados) |

---

## 5. `outro`

Sem default. Pré-spec.Stack obrigatoriamente:
1. Pesquisa via MCP `context7` ou WebSearch + WebFetch
2. Avalia padrões da comunidade pra tipo identificado
3. Propõe stack com justificativa
4. Se durante pesquisa identificar tipo conhecido, oferece migrar pra catálogo formal

---

## 6. Override por particularidade

Mesmo nos tipos com default, o checkpoint da Pré-spec.Stack pergunta:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Override é decisão registrada na constitution com justificativa. Skipping da pergunta = anti-pattern.

Ver `references/tipos-projeto.md` pra mapeamento entre tipos e stacks, e `references/tiers.md` pra como o tier escala os recursos de cada camada.
