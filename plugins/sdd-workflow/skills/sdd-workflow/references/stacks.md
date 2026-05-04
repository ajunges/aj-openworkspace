# Stacks — catálogo por tipo de projeto

Reference do plugin `sdd-workflow` (v1.0.0). Stack default sugerida por `tipo_projeto`. **Override é permitido em todos** — o checkpoint da Pré-spec.Stack força reflexão crítica antes de aceitar default.

## 1. Princípio: stack escala com o tier

A stack default escala com o tier projetado. Override pra cima é normal (ex: `prototipo_descartavel` em produção real); override pra baixo exige justificativa registrada via H5 (ADR).

**Janela de revisão da stack default `web-saas`:** Q3-Q4 2026 (lançamento de TanStack Start 1.0 estável). Antes disso, default fica congelado pra evitar churn em projetos em uso.

---

## 2. `web-saas` — stack default v1.0.0

Stack default opinada baseada em pesquisa de convergência de mercado pra desenvolvimento solo dirigido por Claude Code (maio/2026). Argumentos centrais:

- **Volume de training data** — modelos atuais (Sonnet/Opus 4.x) saturados de exemplos canônicos dessa combinação
- **Distância semântica spec→código** — file-system routing 1:1 com spec textual; RLS = "user só vê seus dados"
- **Convergência empírica** — starters mais starados (MakerKit, Supastarter, KolbySisk, Razikus) e geradores agênticos (v0, Lovable, Bolt) convergem aqui
- **MCP nativo** — Supabase e shadcn/ui têm MCP servers oficiais que reduzem API guessing pela metade

### Camadas default

| Camada | Tecnologia | Notas |
|---|---|---|
| Linguagem | TypeScript 5.x estrito | sem `any`, `noUncheckedIndexedAccess: true` |
| Frontend + Backend | Next.js 16+ (App Router) | Server Components, Server Actions, route handlers |
| UI | Tailwind CSS v4 + shadcn/ui CLI v4 | **Skill obrigatória**: `npx shadcn@latest skill add`. **MCP obrigatório**: `shadcn.io` MCP. Brand colors via `tailwind.config.ts` ou shadcn presets |
| Banco | PostgreSQL 17 via Supabase | RLS habilitado em **todas** as tabelas (P-ws3) |
| ORM | Prisma | schema declarativo legível, ergonomia de iniciante. Drizzle como override pra `producao_real` edge ou `outro` edge-heavy |
| Auth | Supabase Auth | RLS multi-tenant by default; OAuth Google + email/senha como mínimo |
| Storage default | Supabase Storage | 1GB free, integrado com auth + RLS |
| Email default | Resend | 3k/mês free, integração React Email |
| Hosting default | Vercel | **Pro a partir de `mvp`** ($20/seat). Hobby OK em `prototipo_descartavel` e `uso_interno` **não-comercial** (Vercel ToS proíbe Hobby pra projetos que geram receita) |
| Observabilidade | Sentry (Vercel marketplace) + Supabase logs | obrigatório a partir de `mvp` (D-mvp1) |
| Mobile-first | 375 / 768 / 1440 | particularidade do tipo `web-saas` |
| Janela de revisão | Q3-Q4 2026 | TanStack Start 1.0 pode justificar abertura de override tier-1 |

### Por que Prisma e não Drizzle (default)

Pesquisa de mercado aponta Drizzle ganhando momentum (PlanetScale acquisition mar/2026, T3 Turbo migrou). Mas a audiência primária do plugin é leigo dirigindo IA — Prisma "magic" reduz curva de aprendizado: schema declarativo legível, queries em objeto JS, mensagens de erro explicativas. Drizzle vence em critérios técnicos (cold start edge, type inference instantâneo, SQL legível) que importam **menos** quando o usuário não audita SQL diretamente.

**Override pra Drizzle:**
- `producao_real` com edge runtime crítico (cold start dominante)
- `tipo_projeto: outro` quando descoberto é edge-heavy (CLI tool, MCP server, etc.)

### Vercel Pro vs Hobby

| Tier do projeto | Vercel plan |
|---|---|
| `prototipo_descartavel` | Hobby OK (declarar não-comercial) |
| `uso_interno` | Hobby OK se uso é não-comercial; Pro se vai cobrar (mesmo internamente) |
| `mvp` em diante | **Vercel Pro obrigatório** ($20/mês/seat) — termo de uso exige |

Constitution registra `gera_receita: sim|nao|talvez` na Pré-spec.Discovery. Resposta "sim" ou "talvez" + tier `mvp+` = Pro obrigatório no `references/overrides-matrix.md` seção hosting.

### Particularidades operacionais

- **Mobile-first obrigatório** (375/768/1440): sidebar vira drawer no mobile, tabelas com scroll horizontal, cards quando layout não cabe.
- **Brand colors definidas na constitution** e refletidas no `tailwind.config.ts` ou shadcn presets — não usar cores hardcoded fora dessa configuração.
- **RLS em todas as tabelas** — princípio P-ws3 (Multi-tenancy desde dia 1) ativo em `mvp+`. Adicionar `enable row level security` em **toda** tabela criada, mesmo que o policy seja "user pode tudo" — preserva o gate quando produto vira multi-tenant.

---

## 3. Overrides estruturais (catalogados)

Override do default exige justificativa registrada na constitution via H5 (ADR). Catálogo de quando preferir alternativa:

| Trigger | Override | Justificativa |
|---|---|---|
| Usuário avançado quer máxima portabilidade | TanStack Start (RC) + Better Auth + Drizzle + Cloudflare Workers | Aposta "stack 2027"; type-safety end-to-end; sem lock-in Vercel |
| Solo dev quer monolito DHH-style | Rails 8 + Hotwire + Postgres + Render/Heroku | Convenções DHH favorecem agentes; multi-tenancy `acts_as_tenant` limpo. Caso público: OnboardingHub (Cláudio Pinto, 727 commits, 38k LOC, ~95% Claude-driven em 8 semanas) |
| Solo dev micro-SaaS, $5 VPS | PocketBase + Cloudflare Pages | Binário Go único, simplicidade extrema |
| Produto colaborativo real-time-first | Convex | Reativo nativo; lock-in alto |
| Mobile + Web desde dia 1 | T3 Turbo (Next.js + Expo + Drizzle + Better Auth) | API compartilhada via tRPC |
| Brasil-first com Pix | Mercado Pago no lugar de Stripe | Pix nativo, recorrência via webhook |
| Custo acima de tudo, aceita ops | Cloudflare full-stack (Workers + D1/Neon + R2) ou self-host VPS Hetzner + Coolify | 10-20% do custo Vercel a partir de scale; trade-off em horas/mês |
| Marketing site / blog separado | Astro + MDX + Tailwind | Islands architecture; ótimo pra conteúdo estático |
| Auth com SAML SSO B2B | Auth0 ou WorkOS | SAML + organizations enterprise |
| Auth com UI premium pronta + organizations | Clerk | UI components prontos, free tier 50k MRU |
| Auth com zero lock-in | Better Auth | Open source, framework-agnostic, multi-tenancy nativo |
| Billing global com MoR | Stripe Managed Payments / Paddle | Merchant of Record reduz complexidade fiscal |
| Storage high-bandwidth (vídeo, downloads públicos) | Cloudflare R2 | Zero egress muda economia |
| File uploads UX premium | UploadThing | Drag & drop pronto, integração React |
| Background jobs sérios | Trigger.dev ou Inngest | Crons + retries + observability |

Detalhe de cada override (quando usar, quando evitar, custo, Brasil/global) em `references/overrides-matrix.md`.

---

## 4. `claude-plugin`

| Camada | Default |
|---|---|
| Skill files | Markdown + frontmatter YAML |
| Commands | Markdown + frontmatter YAML |
| Hooks | Shell scripts |
| Plugin manifest | `.claude-plugin/plugin.json` (JSON) |
| Marketplace entry | `.claude-plugin/marketplace.json` (JSON, no marketplace que vai hospedar) |
| Validação | `claude plugin validate .` |
| Versionamento | SemVer no `marketplace.json` (Level 3) ou `plugin.json` (Level 1/2) |

**Sem build system, sem test runner**. TDD adaptado pra markdown — ver H9 em `references/heuristicas.md` e `references/linguagens-especificacao.md` seção 3.

Princípios da Camada 2 inline em `references/tipos-projeto.md` seção 3.2 (P-cp1 a P-cp4).

---

## 5. `hubspot`

| Camada | Default |
|---|---|
| CLI | HubSpot CLI (`hs`) |
| Auth | Private App com scopes mínimos (preferir API key sobre OAuth quando viável) |
| Custom Objects | Schema JSON (em `src/objects/`) |
| UI Extensions | React + HubSpot Extensions SDK (em `src/extensions/`) |
| Serverless Functions | Node.js (em `src/serverless/`) |
| Webhooks | Endpoints registrados na app config |
| Secrets | `.env` ou `hs auth` (NUNCA versionados) |

Princípios da Camada 2 inline em `references/tipos-projeto.md` seção 3.3 (P-hs1 a P-hs4).

---

## 6. `outro`

Sem default. Pré-spec.Stack obrigatoriamente:
1. Pesquisa via MCP `context7` ou WebSearch + WebFetch
2. Avalia padrões da comunidade pra tipo identificado
3. Propõe stack **e princípios da Camada 2** com justificativa (P-ou2)
4. Se durante pesquisa identificar tipo conhecido, oferece migrar pra catálogo formal (P-ou3)

Princípios da Camada 2 inline em `references/tipos-projeto.md` seção 3.4 (P-ou1 a P-ou3).

---

## 7. Override por particularidade — fluxo

Mesmo nos tipos com default, o checkpoint da Pré-spec.Stack pergunta:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Override é decisão registrada via H5 (ADR) na constitution com justificativa. Skipping da pergunta = anti-pattern (viola H5 — Decisões registradas).

**Detecção evolutiva durante a conversa:** mesmo com tipo declarado (`web-saas`, por exemplo), durante Discovery/Stack a IA pode detectar particularidades que pedem refinamento (componente ML, multi-tenancy específico, real-time crítico). Resultado pode ser:

| Saída da detecção | Ação |
|---|---|
| Default puro encaixa | Aceita declaração, segue fluxo |
| Default + overrides pontuais | Aceita declaração, registra overrides explícitos via H5 |
| Subtipo conhecido | Sugere migração (ex: "isso parece `web-saas-ml`; quer migrar?") |
| Subtipo recorrente que não existe | Sugere criar novo tipo (futuro: catálogo aberto, item 4.2.4 do BACKLOG) |

Ver `references/overrides-matrix.md` pra catálogo de Auth/Billing/Email/Storage/Hosting com quando-usar.

Ver `references/starters-catalog.md` pra starters Claude-native que aceleram bootstrap.

Ver `references/tiers.md` pra como o tier escala recursos.
