# Tipos de projeto — catálogo curado

Reference do plugin `sdd-workflow` (v1.0.0). O `tipo_projeto` registrado na constitution determina stack default sugerida (`references/stacks.md`), princípios da Camada 2 (inline aqui), e quais skills domain-específicas (Família B) entram em cena.

## 1. Catálogo (4 tipos)

| Tipo | Resumo |
|---|---|
| `web-saas` | Sistema web full-stack com UI rica |
| `claude-plugin` | Plugin para Claude Code (markdown + JSON, sem build system) |
| `hubspot` | Extensão HubSpot (CLI, custom objects, UI extensions, serverless) |
| `outro` | Stack Decision livre (research na Pré-spec.Stack obrigatório) |

---

## 2. Override sempre permitido

Override é permitido em todos os tipos. O **checkpoint da Pré-spec.Stack** força reflexão crítica sobre particularidades antes de aceitar a default — não é confirmação automática.

**Detecção evolutiva:** mesmo com tipo declarado, durante Discovery/Stack a IA pode detectar particularidades que pedem refinamento. Ver `references/stacks.md` seção 7.

---

## 3. Detalhe por tipo (com Camada 2 inline)

A Camada 2 (princípios arquiteturais por tipo) **ativa em `mvp+`**. Em tier 1-2 vira informativa (IA cita como contexto, não força).

### 3.1 `web-saas`

- **Stack default**: ver `references/stacks.md#web-saas` (Next.js 16+ App Router + Supabase + Prisma + Tailwind v4 + shadcn/ui CLI v4 + MCP + Resend + Vercel Pro)
- **Skills B**: `frontend-design` (Spec.Design — UI distintiva); condicional: `claude-api`, `agent-sdk-dev:new-sdk-app`
- **Particularidades operacionais**:
  - Spec.Design tem seção Mobile-first obrigatória (375/768/1440)
  - Build.Implementation segue ordem típica Infra → Auth+Layout → CRUDs → Lógica → Dashboards → Polish
  - Brand colors definidas na constitution e refletidas no `tailwind.config.ts` ou shadcn presets
  - shadcn/ui CLI v4 + MCP `shadcn.io` configurados (reduz API guessing pela metade)

#### Princípios da Camada 2 (`web-saas`)

| # | Princípio | Conteúdo |
|---|---|---|
| P-ws1 | Stack convencional preferida | SaaS solo precisa de stack que IA consegue ajudar. Next.js + Supabase + Vercel resolve 80% dos casos. Inovação de stack só com justificativa registrada via H5 |
| P-ws2 | Auth e billing terceirizados | Solo-dev não constrói auth/billing do zero. Supabase Auth/Clerk/Better Auth + Stripe/Mercado Pago são default. Construir custom precisa de justificativa |
| P-ws3 | Multi-tenancy desde dia 1 (mesmo se single-tenant inicial) | Migrar single para multi depois é doloroso. Schema preparado mesmo se cliente único. **RLS ativado em todas as tabelas** quando Supabase |
| P-ws4 | Integration testing em fronteiras críticas | Auth, billing, payment flow exigem testes integrados, não só unit (D-bp1 reforça em `beta_publico+`) |

### 3.2 `claude-plugin`

- **Stack default**: ver `references/stacks.md#claude-plugin`
- **Skills B**: `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin`
- **Particularidades operacionais**:
  - Pré-spec.Stack pergunta Level 1, 2 ou 3 (HEAD, SHA pin, local)
  - Spec.Design define quais componentes (commands, skills, hooks, agents, MCP)
  - Build.Implementation TDD = instalar local + testar manualmente; testes automatizados raros, validação via `plugin-validator`
  - **Ship.Audit substitui dimensões 1-7** pelo checklist do `plugin-dev:plugin-validator`. Mantém dim 8 (lógica = comportamento do plugin), 12 (doc operacional = README) e 14 (defesa prompt injection — se o plugin orquestra LLM)

#### Princípios da Camada 2 (`claude-plugin`)

| # | Princípio | Conteúdo |
|---|---|---|
| P-cp1 | Library-First | Plugin é por natureza biblioteca + skills + commands. Composição de unidades reutilizáveis é o modelo certo (Spec Kit Article I aplicável) |
| P-cp2 | CLI/Slash Mandate | Plugin Claude Code interage via slash commands. Toda funcionalidade pública precisa ter command correspondente (Spec Kit Article II adaptado) |
| P-cp3 | SKILL.md como contrato | Skills do plugin têm metadata padronizado. Toda skill pública declara `name`, `description`, `disable-model-invocation` quando aplicável, `triggers`, `tags` (Anthropic Agent Skills standard) |
| P-cp4 | Versionamento explícito | Plugin distribuído precisa SemVer rigoroso. Breaking changes em SKILL.md exigem major bump. **Operacionalização:** se `marketplace-tools:publish-plugin` está instalado, automatiza bump+push+sync. Se não, segue fluxo manual em `references/alvos-deploy.md` seção `claude-plugin`. Em ambos, regra é a mesma: nunca alterar plugin público sem bumpar |

### 3.3 `hubspot`

- **Stack default**: ver `references/stacks.md#hubspot`
- **Skills B**: nenhuma nativa no marketplace — usar guia interno do plugin SDD; MCP `context7` recomendado pra docs HubSpot atualizadas
- **Particularidades operacionais**:
  - Pré-spec.Constitution **exige seção Scopes** (princípio do menor privilégio)
  - Pré-spec.Stack faz inventário explícito de ferramentas (CLI + MCP + acesso a sandbox/prod) e ajusta fluxo conforme disponibilidade
  - Spec.Design tem seções dedicadas: Custom Objects schemas, UI Extensions hierarchy, Serverless endpoints, Webhooks payload contracts
  - Build.Implementation segue padrão HubSpot CLI (`hs project upload`, `hs project deploy`)
  - **Ship.Audit eleva dimensão Segurança ao máximo** — vazamento de token compromete CRM inteiro. Checks específicos: nenhum `hs` token versionado, scopes documentados, sandbox testado antes de prod

#### Princípios da Camada 2 (`hubspot`)

| # | Princípio | Conteúdo |
|---|---|---|
| P-hs1 | UI Extensions seguem padrão React/HubSpot SDK | Plataforma tem padrão. Desviar do padrão custa caro em manutenção e debugging (HubSpot developer docs) |
| P-hs2 | Serverless functions com timeout consciente | HubSpot serverless tem limites duros. Funções precisam ser idempotentes e rápidas |
| P-hs3 | Dados sensíveis nunca em frontend | UI Extension roda no browser. Tokens, API keys, lógica sensível ficam em serverless |
| P-hs4 | Workflow vs UI Extension vs Custom Object — escolha consciente | Há 3 caminhos pra automatizar HubSpot. Cada um tem trade-off. Decisão precisa ser registrada via H5 |

### 3.4 `outro`

- **Stack default**: N/A — Pré-spec.Stack faz Stack Decision livre baseada nas particularidades
- **Skills B**: caso a caso, decididas baseado em pesquisa do tipo
- **Particularidades operacionais**:
  - Pré-spec.Stack **obrigatoriamente** faz pesquisa de stack/padrões usando MCP `context7` (docs atualizadas) e/ou WebSearch antes de propor stack
  - Se durante a pesquisa identificar tipo conhecido (ex: "ah, é um MCP server"), oferece adicionar ao catálogo formal e migrar pra ele

#### Princípios da Camada 2 (`outro`)

| # | Princípio | Conteúdo |
|---|---|---|
| P-ou1 | Discovery obrigatório de tipo real | "Outro" é categoria temporária. Antes de prosseguir, descobre se há padrão a herdar (mobile native? CLI? game? ML pipeline? MCP server?) |
| P-ou2 | Princípios arquiteturais propostos pela IA, validados pelo usuário | IA pesquisa o tipo descoberto via WebSearch + MCP `context7` + análise de Discovery e propõe princípios da Camada 2 aplicáveis baseado em padrões de comunidade similares. Usuário valida, ajusta ou rejeita. Decisão registrada via H5 (ADR). **Não é usuário declarando do zero** — é IA pesquisando e oferecendo, usuário aprovando |
| P-ou3 | Promoção a tipo nomeado quando 2+ projetos similares | Se "outro" está sendo usado pra mobile native repetidamente, vira `tipo_projeto: mobile-native`. Catálogo cresce organicamente (ver item 4.2.4 do BACKLOG pra catálogo aberto futuro) |

---

## 4. Critério pra adicionar tipo novo ao catálogo

**2+ projetos do mesmo tipo nos últimos 6 meses.**

Adição vira tarefa de manutenção do plugin SDD: editar este arquivo, atualizar `references/stacks.md`, atualizar `SKILL.md` principal, eventualmente novo `references/tipo-X.md` se complexo.

Item 4.2.4 do BACKLOG considera transformar este catálogo em "catálogo aberto" (cada `tipo_projeto` vira `tipos/<nome>.md` autocontido, plugin escaneia o diretório, usuários adicionam tipos próprios). Quando virar prioridade, sai de pesquisa pra implementação.
