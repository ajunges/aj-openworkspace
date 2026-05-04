# Catálogo de starters

Reference do plugin `sdd-workflow` (v1.0.0). Catálogo de starters/templates GitHub avaliados por critérios objetivos pra desenvolvimento solo dirigido por Claude Code.

## 1. Critério "Claude-native ≥3 critérios"

Starter é considerado **Claude-native** se atende ao menos 3 dos 5 critérios:

1. `CLAUDE.md` ou `AGENTS.md` na raiz com instruções operacionais
2. `.claude/commands/` ou `.claude/skills/` com comandos/skills customizados
3. `.claude/agents/` ou `.cursorrules` com sub-agents/regras
4. MCP servers configurados (`.mcp.json` ou similar) — Supabase MCP, shadcn MCP, GitHub MCP
5. Estrutura `specs/` (Spec-Driven Development) com PRD/spec/plan/tasks

Starters Claude-native podem ser aceitos como ponto de partida sem refazer constitution from scratch — sub-skill `sdd-bootstrap` (futuro, item 4.1.3 do BACKLOG) instrumentalizará isso.

## 2. Aviso sobre licenças copyleft

**Para SaaS proprietário, AGPL é tóxica:** servir uma modificação do código pela rede dispara obrigação de release do código completo do seu SaaS. Trate AGPL como "ler e aprender, não importar nem fork-and-modify".

Licenças seguras pra SaaS proprietário: **MIT, Apache 2.0, BSD-2/3, ISC**. Tudo o que tiver "AGPL", "GPL v3 + Network", "BSL", "Anyone PL" entra na zona de cuidado.

## 3. Categoria A — Starters pra clonar (boilerplate produtivo)

| Starter | Stack chave | Licença | Claude-native | Quando escolher |
|---|---|---|---|---|
| [maximilian-V/next-supabase-starter](https://github.com/maximilian-V/next-supabase-starter) | Next.js 15+ + Supabase + Tailwind v4 + Vitest | MIT | **Sim** (CLAUDE.md explícito, server actions, queries patterns) | **Default proposto pelo plugin** — Solo + IA leigo, padrão alinhado com stack default v1.0.0 |
| [KolbySisk/next-supabase-stripe-starter](https://github.com/KolbySisk/next-supabase-stripe-starter) | Next.js + Supabase + Stripe + shadcn/ui + Resend | MIT | Parcial | SaaS pago dia 1, Stripe global |
| [t3-oss/create-t3-turbo](https://github.com/t3-oss/create-t3-turbo) | Next.js + Expo + tRPC + Drizzle + Better Auth + Supabase | MIT | Parcial | Web + iOS/Android desde dia 1 (mobile-first nativo) |
| [t3-oss/create-t3-app](https://github.com/t3-oss/create-t3-app) | Next.js + tRPC + Prisma/Drizzle + Tailwind + Auth.js | MIT | Não nativo (mas convenções fortes) | Default histórico TS solo; legado |
| [Razikus/supabase-nextjs-template](https://github.com/Razikus/supabase-nextjs-template) | Next.js 15 + Supabase + Tailwind + Mobile (Expo) | MIT | Parcial | Production-ready com RLS, i18n |
| [Better-T-Stack](https://github.com/AmanVarshney01/create-better-t-stack) | Next.js OR TanStack Start + Better Auth + Drizzle + Hono | MIT | Não nativo | Variante moderna do T3 com Better Auth |
| [vercel/nextjs-subscription-payments](https://vercel.com/templates/next.js/supabase) | Next.js + Supabase + Stripe | MIT | Não | Subscription kit oficial Vercel |

### Comerciais premium (pagos)

| Starter | Stack chave | Claude-native | Quando escolher |
|---|---|---|---|
| [Makerkit](https://makerkit.dev/next-supabase) | Next.js + Supabase + Tailwind + Stripe + multi-tenant | **Sim** (oficial: MCP server, custom rules para Claude Code) | Usuário com US$200-300, quer máximo conforto, multi-tenant pronto |
| [Supastarter](https://supastarter.dev/) | Next.js OR Nuxt + Supabase + Tailwind | **Sim** ("ready for Cursor, Claude Code, Codex") | Lifetime license, foco em SaaS B2C |

## 4. Categoria B — Produtos OSS pra estudar padrão (não clonar pra novo projeto)

Repositórios públicos em produção que servem de referência arquitetural. **Atenção à licença antes de fork-and-modify.**

### Licenças seguras pra fork (MIT/Apache 2.0/BSD)

| Repo | Stack | Licença | Notas |
|---|---|---|---|
| [Taxonomy](https://github.com/shadcn-ui/taxonomy) | Next.js App Router + Prisma + NextAuth + Stripe | MIT | Reference shadcn SaaS patterns. Excelente pra aprender |
| [Trigger.dev](https://github.com/triggerdotdev/trigger.dev) | Next.js + Prisma + Postgres + Redis | Apache 2.0 | Background jobs. Pode estudar e usar |
| [Affine](https://github.com/toeverything/AFFiNE) | Next.js + Rust | MIT | Notion alternative |
| [Excalidraw](https://github.com/excalidraw/excalidraw) | React + canvas | MIT | Whiteboard |
| [Medusa.js](https://github.com/medusajs/medusa) | Node + TypeScript | MIT | Headless commerce |
| [Saleor](https://github.com/saleor/saleor) | Python + GraphQL | BSD-3 | Commerce |
| [Vendure](https://github.com/vendure-ecommerce/vendure) | NestJS + TypeScript | MIT | Commerce TS |
| [Suna](https://github.com/kortix-ai/suna) | Next.js + Python + Supabase | Apache 2.0 | Open source generalist agent |
| [Ghost](https://github.com/TryGhost/Ghost) | Node + Ember | MIT | Publishing |
| [shadcn/ui](https://github.com/shadcn-ui/ui) | React + Tailwind | MIT | Componente library defacto |

### Licenças copyleft (estudar, NÃO fork-and-modify pra SaaS proprietário)

| Repo | Stack | Licença | Notas |
|---|---|---|---|
| [Cal.com](https://github.com/calcom/cal.com) | Next.js + tRPC + Prisma + NextAuth + Turborepo | **AGPL** | Reference T3 patterns at scale |
| [Documenso](https://github.com/documenso/documenso) | Next.js + Prisma + Tailwind | **AGPL** | Esign open source |
| [Dub.co](https://github.com/dub-co/dub) | Next.js + Prisma + Tinybird + Tailwind | **AGPL** | Link shortener edge-heavy |
| [Papermark](https://github.com/mfts/papermark) | Next.js + Prisma + Tailwind + Tinybird | **AGPL** | Document sharing |
| [Inbox Zero](https://github.com/elie222/inbox-zero) | Next.js + Prisma + Tailwind | **AGPL** | AI assistant for email |
| [Formbricks](https://github.com/formbricks/formbricks) | Next.js + Prisma + Tailwind | **AGPL** | Surveys/forms |
| [OpenStatus](https://github.com/openstatusHQ/openstatus) | Next.js + Drizzle + Tinybird + Tailwind | **AGPL** | Status pages |
| [Plane](https://github.com/makeplane/plane) | Next.js + Django + Tailwind | **AGPL** | Linear clone |
| [Twenty](https://github.com/twentyhq/twenty) | Next.js + NestJS + Postgres | **AGPL** | CRM |
| [Maybe Finance](https://github.com/maybe-finance/maybe) | Rails + Hotwire + Postgres | **AGPL** | Personal finance, Rails |
| [Logseq](https://github.com/logseq/logseq) | ClojureScript + React | **AGPL** | Knowledge graph |
| [AppFlowy](https://github.com/AppFlowy-IO/AppFlowy) | Flutter + Rust | **AGPL** | Notion alt |
| [Outline](https://github.com/outline/outline) | Node + React + Postgres | **BSL** | Wiki — Business Source License |

## 5. Política de catálogo

Critério pra catalogar starter novo:

1. >5k stars GitHub (sinal de tração)
2. Commits últimos 90 dias (sinal de manutenção)
3. Caso público de produção OU recomendação de fonte primária

Starter que não cumpre os 3 não é catalogado oficialmente — pode ser referenciado em ADR (H5) caso a caso.

## 6. Como o plugin usa este catálogo

**Pré-spec.Stack** referencia este arquivo quando o usuário pergunta "tem template/starter pronto pra começar?". A IA propõe o starter da Categoria A apropriado ao `tipo_projeto` + tier + audiência (pago ou free) e oferece clonar.

Se o starter for Claude-native ≥3 critérios, IA aceita como ponto de partida e adapta a constitution mantendo os artefatos existentes do starter (CLAUDE.md, .claude/, specs/, MCP). Se for parcial ou não-nativo, IA scaffold o que falta após o clone.

Ver `references/stacks.md` pra contexto da stack default e overrides estruturais.
Ver `references/overrides-matrix.md` pra escolha de Auth/Billing/Email/Storage/Hosting que vai junto com o starter.
