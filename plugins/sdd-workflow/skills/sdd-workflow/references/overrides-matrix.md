# Matriz de overrides — Auth / Billing / Email / Storage / Hosting

Reference do plugin `sdd-workflow` (v1.0.0). Catálogo dos componentes mais swappables da stack. **Default sempre se aplica**, override é decisão registrada via H5 (ADR) na constitution.

## 1. Quando usar override vs default

| Mudança | Tipo |
|---|---|
| Override de **DB / ORM / framework** | Mudança estrutural — só com justificativa explícita registrada via H5 |
| Override de **Auth** | Mudança grande na constitution — registrar antes de Build.Implementation. Custo de troca tarde é altíssimo |
| Override de **Billing** | **Pergunta inicial obrigatória** na Pré-spec.Discovery: "audiência principal: BR / global / híbrida?" |
| Override de **Hosting / Storage / Email / Observability** | Swappable a qualquer momento (custo de troca baixo) |

## 2. Auth — escolha estrutural única no default

Auth tem o maior custo de troca tarde. Registrar na constitution antes de Build.Implementation.

| Provider | Quando usar | Quando evitar | Custo 10k MAU |
|---|---|---|---|
| **Supabase Auth** (default) | SaaS multi-tenant, RLS no Postgres, B2C/B2B leve | B2B com SAML SSO obrigatório | $0 (incluído no Supabase Pro) |
| Clerk | B2B com UI polida, organizations, free tier 50k MRU desde fev/2026 | Custo crítico em escala (>50k MRU pesa) | $0 free → $25/mês Pro + add-ons |
| Better Auth | Zero lock-in, framework-agnostic, multi-tenancy nativo, T3 Turbo já usa | Equipe sem familiaridade com auth flows | $0 (self-host) |
| Auth.js v5 | Migração de NextAuth, ecossistema Next | DX inferior — Better Auth é alternativa mais nova | $0 |
| Auth0 | Enterprise, HIPAA BAA, SAML SSO obrigatório | Solo bootstrapper (preço alto) | ~$175/mês |
| WorkOS | Add-on de SSO/SCIM em qualquer auth | MVP (overkill) | Variável |

**Regra:** override de auth deve estar registrado na seção "Stack" da constitution **antes** de iniciar Build.Implementation. Trocar auth depois custa semanas de refactor.

## 3. Billing — override por modelo de negócio (Brasil-first matters)

**Pergunta inicial obrigatória na Pré-spec.Discovery:** "Audiência principal: BR / global / híbrida?". Resposta determina caminho de billing.

### Override por audiência

| Audiência | Default proposto | Justificativa |
|---|---|---|
| **BR** | Mercado Pago Pix + recorrência via webhook próprio | Pix nativo (~0.99% Pix; ~3.79-4.99% cartão); UX local |
| **Global** | Stripe Subscriptions | DX gold standard; ecossistema saturado; Pix nativo Stripe disponível desde 2024 |
| **Híbrida** | Stripe (internacional) + Mercado Pago (BR) em paralelo | Implementação mais complexa; IA gera se spec for clara |

### Catálogo completo

| Provider | Quando usar | Brasil/Pix | Solo + IA | Custo headline |
|---|---|---|---|---|
| **Stripe direto** | Mercado global, B2B, MRR alto, controle total | Pix nativo desde 2024 | Excelente (docs gold standard) | 2.9% + $0.30 |
| **Stripe Managed Payments** (ex-Lemon Squeezy MoR) | Substituto do Stripe quando MoR vira necessário (>~$100k ARR) | Em expansão (preview público fev/2026) | Bom | ~5% + $0.50 |
| **Lemon Squeezy** (legado, sendo absorvido pelo Stripe Managed Payments) | Indie hackers, MoR < $100k MRR | Limitado | Bom | 5% + $0.50 |
| **Paddle** | MoR enterprise, B2B SAML | Limitado | Bom (lock-in checkout) | 5% + $0.50 |
| **Polar.sh** | Devtools, OSS monetization, GitHub-native | Limitado | OK | ~4% + $0.40 |
| **Mercado Pago** | SaaS BR + Pix, B2C BR, B2C+Pix | Nativo | Médio (docs voltadas a PHP/Express; integração Next.js exige tutorial — IA gera) | Pix ~0.99% + R$0,40; cartão 3.79-4.99% |
| **Pagar.me** (Stone) | Volume > R$ 100k/mês BR, customização | Nativo | Médio | Negociável |
| **Pix direto via PSP** (banco/Sicredi/etc.) | DIY, ARR alto, dor com taxas | Nativo | Ruim pra leigo | 0,4-0,99% Pix |

**Sobre Mercado Pago:** plugin documenta o **caminho** de integração Mercado Pago Pix com Next.js + Prisma (link pros docs oficiais MP atualizados), mas **não mantém snippet pronto** no plugin. A IA gera o código no Build.Implementation usando os docs como referência. Isso evita débito de manutenção.

## 4. Email transacional — override sempre

| Provider | Free tier | Pro start | Quando usar | Quando evitar |
|---|---|---|---|---|
| **Resend** (default) | 3k/mês permanente | $20/mês 50k | React + Next.js, React Email, DX moderna | Volume >200k/mês onde custo importa |
| Postmark | 100/mês | $15/mês 10k | Deliverability mission-critical (financial, booking) | Marketing emails (separação rígida) |
| Amazon SES | 3k charges/mês 12 meses | $0.10 / 1k emails | Volume alto + equipe técnica | Solo leigo (config IAM, DKIM manual) |
| Mailgun | 100/dia | $15/mês 10k | Routing avançado, EU SLA | DX legacy |
| SendGrid | (free morto pra novos) | $19.95/mês 50k | Volume + integração Twilio | Solo dev novo (DX antiga) |
| Loops | 1k/mês | $49+/mês | Lifecycle marketing | Transacional puro |

## 5. Storage — override sempre

| Provider | Free tier | Quando usar | Quando evitar |
|---|---|---|---|
| **Supabase Storage** (default) | 1GB free / 8GB Pro | Integrado com auth, RLS, fácil | High-bandwidth público (custos egress) |
| Cloudflare R2 | 10GB free, **zero egress** | High-bandwidth, mídia, downloads, public files | Quer auth integrado simples |
| AWS S3 | 5GB 12 meses | Equipe AWS, compliance | Solo dev (custo egress real, DX) |
| Backblaze B2 | 10GB free | Backup barato, S3-compatible | Latency global crítica |
| UploadThing | 2GB free | UX upload premium em React, drag & drop pronto | Custo crítico em escala |

## 6. Hosting — override por trade-off custo × DX × portabilidade

| Provider | Quando usar | Quando evitar |
|---|---|---|
| **Vercel Pro** (default `mvp+`) | DX para Next.js (zero config, Preview Deploys, ISR, edge middleware) | Custo > 5k MAU pesa; per-seat $20 + bandwidth |
| **Vercel Hobby** (default `prototipo_descartavel`/`uso_interno` não-comercial) | Validar ideia antes de monetizar | **Termo de uso proíbe Hobby comercial** — Pro obrigatório se gera receita |
| Cloudflare Pages + Workers + R2 + D1 | Custo (zero egress R2) + edge global | DX Next.js (precisa OpenNext, alguns recursos não suportados como ISR plenamente) |
| Railway | Pricing previsível full-stack (front + back + Postgres + Redis no mesmo lugar) | Edge global (single-region), SLA público formal |
| Fly.io | Container near user, processo persistente (WebSocket, jobs longos) | DX (mais hands-on); cortes no free tier (trial 2h em 2025) |
| Render | "Heroku successor", pricing claro, multi-language | Features avançadas |
| VPS Hetzner / Contabo + Coolify | Self-host total, 10-20% do custo Vercel a partir de scale | Solo dev sem horas pra ops (2-10h/mês de manutenção) |

**Regra Vercel anti-comercial:** termo de uso da Vercel Hobby **proíbe uso comercial explicitamente**. Constitution registra `gera_receita: sim|nao|talvez`. Resposta "sim" ou "talvez" + `tier: mvp+` força Vercel Pro como override default ou alternativa Cloudflare/self-host.

## 7. Política do plugin sobre overrides

1. **Default sempre** a menos que constitution explicite override via H5
2. **Override de billing é obrigatório no spec inicial** (pergunta de audiência)
3. **Override de auth é mudança grande** (registrar antes de Build.Implementation)
4. **Override de hosting/storage/email/observability** é swappable a qualquer momento
5. **Override de DB/ORM/framework é mudança estrutural** (justificativa explícita do usuário)

## 8. Observabilidade — escolha por tier

| Tier | Mínimo (Camada 3) |
|---|---|
| `prototipo_descartavel` | Nenhum requisito |
| `uso_interno` | Logs estruturados (D-ui1) |
| `mvp` | **Sentry default** (Vercel marketplace) + Supabase logs (D-mvp1) |
| `beta_publico` | Sentry + audit logs imutáveis (D-bp3) + métricas de performance (D-bp4) |
| `producao_real` | Tudo de `beta_publico` + SLO ativo (D-pr1) |

Alternativas a Sentry: BetterStack, Highlight, Logflare, Axiom. Override registrado via H5.

## 9. Background jobs — override por necessidade

| Provider | Quando usar |
|---|---|
| Trigger.dev | Background jobs sérios, crons, retries, observability |
| Inngest | Eventos + jobs assíncronos |
| Vercel Cron | Crons simples (já incluso no Vercel Pro) |
| Supabase Edge Functions + cron | Background dentro do Supabase |

Default: usar Vercel Cron + Supabase Edge Functions enquanto cabe. Trigger/Inngest entram como override quando jobs viram parte central do produto.
