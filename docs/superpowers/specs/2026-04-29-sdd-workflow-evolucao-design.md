# SDD Workflow — Evolução v3.0 (design)

**Data**: 2026-04-29
**Plugin**: `sdd-workflow` (Level 3, marketplace `aj-openworkspace`)
**Versão alvo**: plugin `0.2.0` · SKILL.md interna `3.0.0`
**Tag mantida**: `em-testes` (promove pra `recomendado` após uso real)

---

## 1. Contexto e motivação

### 1.1 Estado atual (v0.1.1, SKILL.md 2.1.0)

Plugin Level 3 com estrutura mínima:

```
plugins/sdd-workflow/
├── .claude-plugin/plugin.json
├── README.md
└── skills/sdd-workflow/SKILL.md  (~16K, 500 linhas, tudo inline)
```

Criado a partir de um workflow privado sanitizado. Cobre 7 fases (0 Discovery → 7 Entrega) com gates explícitos, TDD rigoroso, regra inviolável de "dados reais", auditoria em 8 dimensões e mobile-first como padrão.

Sem commands, sem hooks, sem agents, sem sub-skills. As 4 skills externas mencionadas (`superpowers:test-driven-development`, `:systematic-debugging`, `:verification-before-completion`, `claude-md-management:revise-claude-md`) entram como referência textual, não como sub-rotina.

### 1.2 Motivação da evolução

Foco principal: **refinamento de conteúdo** — a estrutura está boa, mas o playbook precisa amadurecer. Ranking de prioridades:

1. **Principal**: integração com outras skills (eixo 3)
2. **Secundários**: estrutura das fases (eixo 1) + suporte a stacks alternativas (eixo 4)
3. **Terciários**: regras/gates (eixo 2) + templates dos artefatos (eixo 5)

---

## 2. Princípios invioláveis (após evolução)

| # | Princípio | Origem |
|---|---|---|
| 1 | Dados reais sempre, nunca fictícios — em seed, testes, exemplos, demos | herdado v2.x |
| 2 | Tier é projetado (visão final do desenvolvimento), não observado (estado atual) | novo v3.0 |
| 3 | Defensividade sobre dependências externas — não pressupor CLI/MCP/skill/credencial sem inventário formal | novo v3.0 |
| 4 | Gates explícitos por fase — pausa obrigatória, aprovação humana antes de avançar | herdado v2.x |
| 5 | TDD por task — testes antes do código, rodando os testes pra confirmar que falham antes de implementar | herdado v2.x, agora estruturado via `superpowers:writing-plans` |
| 6 | Decisões registradas — toda escolha estrutural (tipo_projeto, tier, stack, alvo deploy) vai pra constitution com data e motivação | novo v3.0 |
| 7 | Promoção de tier é decisão consciente, registrada, incremental — nunca recomeço do zero | novo v3.0 |

---

## 3. Estrutura de fases (Layout β — 4 estágios nomeados)

| Estágio | Fases internas | Saída principal |
|---|---|---|
| **I. Pré-spec** | Discovery → Constitution → Stack | `specs/constitution.md` (com bloco YAML) e stack/inventário/alvo registrados |
| **II. Spec** | Requirements → Design → **Spike** (opcional) | `specs/requirements.md`, `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks → Implementation (loop por feature, gate por feature) | `specs/tasks.md` (plano-mestre) + `specs/plans/<feature>.md` (writing-plans) + código entregue |
| **IV. Ship** | Audit → Delivery → **Deploy** | `specs/audit-<data>.md`, sistema rodando em ambiente de avaliação, sistema em produção |

### 3.1 Mudanças vs v2.x

| Mudança | Origem |
|---|---|
| Pré-spec.Constitution **absorve setup atual** (cria pastas, escreve CLAUDE.md/README.md, commit init) — fim da fase 0.5 separada | eixo 1.f |
| Pré-spec.Stack vira **checkpoint explícito** com 3 sub-componentes (inventário, stack técnica, alvo deploy) | eixo 1.c + reflexão sobre particularidades |
| Spec.Spike **opcional**, ativado quando Spec.Design identificar risco técnico | eixo 1.d |
| Build.Implementation com **gate por feature** além do gate por task | eixo 1.e |
| Ship.Deploy **nova fase** — env de prod, secrets, rollback, monitoramento — parametrizada por tier | eixo 1.b |
| Layout em 4 estágios nomeados (Pré-spec / Spec / Build / Ship), sem decimais | eixo 1, opção β |

---

## 4. Conceitos novos da Pré-spec

### 4.1 `tipo_projeto`

Identifica o tipo de produto. Determina a stack default sugerida e quais skills domain-específicas (Família B) entram. Catálogo inicial:

- `web-saas` — sistema web full-stack com UI rica
- `claude-plugin` — plugin para Claude Code
- `hubspot` — extensão HubSpot (CLI, custom objects, UI extensions, serverless)
- `outro` — Stack Decision livre

**Critério pra adicionar tipo novo ao catálogo**: 2+ projetos do mesmo tipo nos últimos 6 meses.

### 4.2 `tier` (escala de 5 níveis — escala C)

Visão **final** do desenvolvimento. Determina dimensões obrigatórias da Audit, recursos mínimos da stack e rigor do Ship.Deploy.

| # | Tier | Significado |
|---|---|---|
| 1 | `prototipo_descartavel` | Validar conceito, depois jogar fora |
| 2 | `uso_interno` | Eu/equipe pequena, não vai pra fora |
| 3 | `mvp` | Primeiros usuários reais, escopo pequeno |
| 4 | `beta_publico` | Público maior, ainda em validação |
| 5 | `producao_real` | Sistema sério, manutenção contínua |

**Default quando não declarado**: pedir explicitamente sempre. Sem fallback silencioso.

### 4.3 Bloco YAML formal no `specs/constitution.md`

```yaml
---
tipo_projeto: web-saas
tier: mvp
tier_decidido_em: 2026-04-29
---
```

Mais bloco textual obrigatório explicando **por que** esse tier. A constitution é a fonte da verdade — Discovery é input que vira tag.

### 4.4 Inventário de dependências

Pré-spec.Stack passa a ter 3 sub-componentes (todos registrados na constitution):

1. **Inventário de dependências** — CLIs do sistema, MCPs, skills do marketplace, credenciais/acesso a serviços
2. **Stack técnica** — libs, frameworks, banco, auth
3. **Alvo de deploy** — onde o produto vai viver (decisão explícita do projeto, não derivada de tipo+tier)

| Categoria | Exemplos | Comportamento se faltar |
|---|---|---|
| CLI do sistema | `gh`, `hs`, `docker`, `node`, `python`, `claude` | Avisar e orientar instalação; bloquear se essencial pra fase atual |
| MCP servers | HubSpot MCP, GitHub MCP, browser MCPs | Avisar e oferecer alternativa |
| Skills do marketplace | `superpowers:*`, `plugin-dev:*`, `marketplace-tools:*` | Família A (Modo 2) bloqueia se essencial faltar; Famílias B/C/D registram ausência mas continuam |
| Acesso a serviços externos | API keys, tokens, contas | Bloquear avanço se essencial; registrar como pré-requisito |

---

## 5. Mapa de integração com skills externas

Modo híbrido por família — Família A em **Modo 2** (instrução imperativa), demais famílias em **Modo 1** (referência condicional/informativa).

### 5.1 Família A — Superpowers universais (Modo 2)

Passo padrão do fluxo. SKILL.md instrui "agora invoque X". Se essencial não está instalada, IA bloqueia. Se opcional, IA avisa e segue.

| Fase | Skills A invocadas |
|---|---|
| Pré-spec.Discovery | `superpowers:brainstorming` |
| Spec.Spike | `superpowers:test-driven-development`, `superpowers:systematic-debugging` |
| Build.Tasks | `superpowers:writing-plans` (com 4 ajustes de convenção SDD — ver 5.1.1) |
| Build.Implementation | `superpowers:executing-plans` ou `:subagent-driven-development` (escolha por quantidade/independência); `:test-driven-development`; `:systematic-debugging`; `:verification-before-completion`; `:using-git-worktrees` (quando feature precisa isolamento); `:dispatching-parallel-agents` (quando subtasks independem) |
| Ship.Audit | `superpowers:requesting-code-review`; `:dispatching-parallel-agents` (paraleliza dimensões) |
| Ship.Delivery | `superpowers:finishing-a-development-branch` |

#### 5.1.1 Ajustes de convenção SDD sobre `superpowers:writing-plans`

A skill `writing-plans` é mais granular (steps de 2-5 minutos) e técnica (paths exatos, código real, comandos com expected output) que o `tasks.md` antigo. Adotada com 4 ajustes:

1. **Marcação 🔒** — header de task `### Task N: [Component] 🔒` ou step extra `- [ ] **Step X: 🔒 Validar contra dados reais**` antes do commit. Decoração, não conflita com formato writing-plans
2. **Quebra por fase típica** — continua existindo no nível do gate por feature (Build.Implementation). Cada feature vira um plano writing-plans próprio. `tasks.md` vira plano-mestre indexando as features
3. **Quality Gate 4 SDD absorvido** — gate por feature: todos os steps do plano executados + testes passando + validações 🔒 aprovadas + aprovação humana
4. **Localização override** — planos vivem em `specs/plans/<feature>.md` no projeto (autocontido), não em `docs/superpowers/plans/`

### 5.2 Família B — Domain-específicas (Modo 1, condicional por `tipo_projeto`)

Mencionadas como referência quando o tipo se manifesta.

| `tipo_projeto` | Skills B referenciadas |
|---|---|
| `web-saas` | `frontend-design` (Spec.Design); condicional: `claude-api`, `agent-sdk-dev:new-sdk-app` |
| `claude-plugin` | `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin` |
| `hubspot` | (sem skill nativa) — guia próprio dentro do plugin SDD orientando uso do MCP HubSpot, CLI HubSpot, fluxo de custom objects/UI extensions/serverless. `plugin:context7:context7` recomendado pra docs HubSpot atualizadas |
| `outro` | livre — usuário invoca o que fizer sentido |

### 5.3 Família C — Qualidade/finalização (Modo 1, sem `humanizador`)

| Ponto do fluxo | Skills C referenciadas |
|---|---|
| Build.Implementation | `commit-commands:commit` (substituir commits manuais); `simplify` (depois de bloco grande) |
| Ship.Audit | `code-review:code-review`; `security-review` (dimensão Segurança); `review` |
| Ship.Delivery | `commit-commands:commit-push-pr`; `pr-review-toolkit:review-pr` (se PR aberto) |
| Final de sessão | `claude-md-management:revise-claude-md`; `remember:remember`; `session-report:session-report` |
| Manutenção periódica | `claude-md-management:claude-md-improver` |

### 5.4 Família D — Situacionais (Modo 1, condicional)

| Quando | Skills D / ferramentas |
|---|---|
| Discovery/Requirements/Design precisam buscar info externa | **1ª escolha (free)**: `WebSearch` + `WebFetch` (built-in). **Páginas dinâmicas/JS**: browser MCPs (`mcp__Claude_in_Chrome__*` / `Kapture` / `Control_Chrome`). **Fallback (pago)**: `firecrawl` (`firecrawl-search`, `:scrape`, `:map`, `:crawl`, `:interact`) — só quando free não resolve |
| Stack ou Design precisam docs atualizadas de lib | `plugin:context7:context7` |
| Documento de referência é PDF | `anthropic-skills:pdf` |
| Documento de referência é Excel | `anthropic-skills:xlsx` |
| Documento de referência é Word | `anthropic-skills:docx` |
| Documento de referência é PowerPoint | `anthropic-skills:pptx` |

---

## 6. Catálogo de tipos de projeto

Override permitido em todos os tipos — checkpoint da Pré-spec.Stack força reflexão crítica sobre particularidades antes de aceitar a default.

### 6.1 `web-saas`

**Stack default**: React + Vite + Tailwind + shadcn/ui (frontend) · Node.js + Express + Prisma (backend) · PostgreSQL Docker (uso_interno) → PG gerenciado tipo Supabase/Neon/RDS (mvp+) · JWT (uso_interno) → Auth0/Clerk/Supabase Auth (beta_publico+) · Recharts.

**Skills B**: `frontend-design`; condicional `claude-api`, `agent-sdk-dev:new-sdk-app`.

**Particularidades**:
- Spec.Design tem seção Mobile-first obrigatória (375/768/1440)
- Build.Implementation segue ordem típica Infra → Auth+Layout → CRUDs → Lógica → Dashboards → Polish (cada um vira plano `specs/plans/<feature>.md`)
- Brand colors definidas na constitution e refletidas no Tailwind config

**Alvos Ship.Deploy** (decisão explícita perguntada na Pré-spec.Stack):
- `uso_interno`: Docker compose local
- `mvp`: hosting gerenciado (Vercel/Netlify front, Railway/Render back, Supabase/Neon DB)
- `beta_publico+`: hosting com rollback, error tracking, CDN

### 6.2 `claude-plugin`

**Stack default**: Markdown (commands, skills) + JSON (plugin.json, marketplace.json) + shell scripts (hooks). Sem build system, sem test runner. Validação via `claude plugin validate .`. SemVer no `marketplace.json` (Level 3).

**Skills B** (Pré-spec.Stack e Spec.Design, conforme componentes): `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin`.

**Particularidades**:
- Pré-spec.Stack pergunta **Level 1, 2 ou 3** (HEAD, SHA pin, local)
- Spec.Design define quais componentes (commands, skills, hooks, agents, MCP)
- Build.Implementation TDD = instalar local + testar manualmente; testes automatizados raros, validação via `plugin-validator`
- Ship.Audit **substitui dimensões 1-7** pelo checklist do `plugin-dev:plugin-validator`. Mantém dimensões 8 (lógica = comportamento do plugin) e 12 (doc operacional = README)

**Alvos Ship.Deploy** (decisão explícita perguntada):
- Local apenas — instalar via `claude plugin install /path/to/plugin`, sem repo nem marketplace
- Repo próprio sem marketplace — clonar e instalar via path
- Marketplace privado — publicar em marketplace próprio ou da equipe (com bump de version)
- Marketplace público/comunitário — publicar pra distribuição ampla (com bump de version)

Se o usuário tiver `marketplace-tools:publish-plugin` instalado, é citado como atalho. Se não, descreve o fluxo manual (bump → commit → push → invalidar cache).

### 6.3 `hubspot`

**Stack default**: HubSpot CLI (`hs`) · Private App com scopes mínimos · Custom Objects (schema JSON) · UI Extensions (React + HubSpot Extensions SDK) · Serverless Functions (Node.js) · Webhooks · API key/OAuth via `.env` ou `hs auth`.

**Skills B**: nenhuma nativa no marketplace — guia próprio dentro do plugin SDD. `plugin:context7:context7` recomendado pra docs HubSpot atualizadas.

**Particularidades**:
- Pré-spec.Constitution exige seção Scopes (princípio do menor privilégio)
- Pré-spec.Stack faz **inventário explícito** de ferramentas HubSpot (CLI + MCP + acesso a sandbox/prod) e ajusta fluxo conforme disponibilidade:
  - CLI + MCP: CLI pra deploy/upload, MCP pra inspeção do CRM ao vivo
  - Só CLI: tudo via CLI; inspeção via API direta
  - Só MCP: deploy via API direta; inspeção via MCP
  - Nenhum: bloquear avanço, orientar instalação
- Spec.Design tem seções dedicadas: Custom Objects schemas, UI Extensions hierarchy, Serverless endpoints, Webhooks payload contracts
- Build.Implementation segue padrão HubSpot CLI (`hs project upload`, `hs project deploy`)
- Ship.Audit eleva dimensão Segurança ao máximo — vazamento de token compromete CRM inteiro. Adiciona checks específicos: nenhum `hs` token versionado, scopes documentados, sandbox testado antes de prod

**Alvos Ship.Deploy**:
- `uso_interno`: portal próprio (sandbox + prod do user)
- `mvp+`: app publicado privadamente em portal de cliente
- `producao_real`: app no marketplace HubSpot (se distribuível)

### 6.4 `outro`

Stack Decision livre na Pré-spec.Stack. Skills B caso a caso.

**Particularidades**:
- Pré-spec.Stack **obrigatoriamente** faz pesquisa de stack/padrões usando `plugin:context7:context7` (docs atualizadas) e/ou WebSearch antes de propor stack
- Se durante a pesquisa identificar tipo conhecido (ex: "ah, é um MCP server"), oferece adicionar ao catálogo formal e migrar pra ele
- Spec.Design adapta seções conforme o tipo identificado

---

## 7. Auditoria expandida (Ship.Audit) — 13 dimensões × 5 tiers

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
- `obrigatório`: gate falha sem cobertura. Achados 🔴 bloqueiam Delivery
- `opcional`: IA recomenda e roda; achados informativos, não bloqueiam
- `perguntar`: IA pergunta no início da Audit; resposta registrada na constitution
- `—`: dimensão não rodada nesse tier; explicitamente pulada

### 7.1 Override por `tipo_projeto`

- **`claude-plugin`**: dimensões 1-7 substituídas pelo checklist do `plugin-dev:plugin-validator`. Dimensões 8 e 12 permanecem
- **`hubspot`**: dimensão 1 (Segurança) ganha checks específicos de tokens/scopes. Dimensão 2 (Isolamento) verifica não-vazamento entre portais

### 7.2 Skills usadas na Audit

- `superpowers:dispatching-parallel-agents` — paraleliza dimensões independentes
- `superpowers:requesting-code-review` — review humana antes da Audit, se aplicável
- `code-review:code-review` (sub-agente para Código)
- `security-review` (built-in — para Segurança)
- `plugin-dev:plugin-validator` (substitui dimensões 1-7 em `claude-plugin`)

### 7.3 Output

`specs/audit-<YYYY-MM-DD>.md`:

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

Audit é repetível. Promoção de Tier dispara nova Audit focada nas dimensões novas obrigatórias.

---

## 8. Promoção de Tier (sub-fluxo)

Disparado por trigger natural ("promover esse projeto pra MVP", "agora vai virar prod real") ou via command `/sdd-workflow:promote-tier`.

### 8.1 Fluxo de 11 passos

1. **Reconfirma contexto** — lê constitution atual, identifica tier atual, `tipo_projeto`, decisões registradas
2. **Pergunta novo tier** — qual o alvo? Por quê? Captura justificativa formal
3. **Detecta saltos não-adjacentes** — se pula mais de 1 nível (ex: `prototipo_descartavel` → `mvp`), exige justificativa formal mais detalhada. Não bloqueia, força reflexão
4. **Detecta regressão** — se o tier diminui, registra com motivação. Gates do tier antigo congelados como histórico
5. **Atualiza constitution** — adiciona entrada no histórico de decisões (`data + tier antigo → novo + motivação`). Atualiza campo `tier:` no YAML. Atualiza bloco textual da nova justificativa
6. **Reaviva Pré-spec.Stack** — pergunta se stack atual atende novo tier. Identifica deltas (SQLite → PG gerenciado; sem rate limiting → com; auth caseiro → Auth0). Pra cada delta, decide aplicar agora ou aceitar débito técnico (registrado)
7. **Reaviva Spec.Design parcialmente** — pra cada decisão de design afetada (escalabilidade, observabilidade, rate limiting, monitoramento), decide se entra ou aceita débito
8. **Atualiza `tasks.md` / cria novos `specs/plans/`** — features novas pra fechar gaps entre tier antigo e novo (cada uma vira plano writing-plans)
9. **Reauditoria focada** — Ship.Audit roda só nas dimensões que viraram obrigatórias no novo tier. Não reaudita dimensões já validadas
10. **Aplica fixes** — com base nos achados 🔴/🟡 da reauditoria
11. **Ship.Deploy (se aplicável)** — se ainda não tinha sido executado e o novo tier exige, executa agora; se alvo mudou, redeploy

### 8.2 Princípios

- **Incremental, não recomeço**: Discovery, Requirements e Design originais permanecem válidos. Só os deltas são revisitados
- **Histórico preservado**: gates do tier antigo ficam congelados — auditoria 6 meses depois preserva contexto completo
- **Decisões formais**: cada promoção/regressão é decisão consciente, registrada com data e motivação

### 8.3 Outputs

- Constitution atualizada (histórico de tier expandido)
- `specs/plans/<feature>-tier-upgrade.md` pra features novas que entraram
- `specs/audit-<data>-tier-upgrade.md` focada nas dimensões novas

---

## 9. Estrutura de arquivos do plugin

```
plugins/sdd-workflow/
├── .claude-plugin/plugin.json
├── README.md
├── commands/
│   ├── start.md                              (/sdd-workflow:start → invoca skill principal)
│   ├── status.md                             (/sdd-workflow:status → lê progress.md)
│   ├── gate.md                               (/sdd-workflow:gate → verifica gate atual)
│   ├── audit.md                              (/sdd-workflow:audit → Audit standalone)
│   └── promote-tier.md                       (/sdd-workflow:promote-tier → sub-fluxo)
└── skills/
    ├── sdd-workflow/
    │   ├── SKILL.md                          (orquestra Pré-spec → Ship)
    │   ├── templates/
    │   │   ├── constitution.md
    │   │   ├── requirements.md
    │   │   ├── design.md
    │   │   ├── tasks.md                      (plano-mestre — índice de features)
    │   │   ├── plan-feature.md               (template writing-plans pra cada feature)
    │   │   ├── progress.md
    │   │   ├── spike.md
    │   │   └── audit.md
    │   └── references/
    │       ├── tipos-projeto.md
    │       ├── tiers.md
    │       ├── stacks.md
    │       ├── inventario-dependencias.md
    │       ├── audit-dimensoes.md
    │       ├── integracao-skills.md
    │       └── alvos-deploy.md
    └── sdd-promote-tier/
        └── SKILL.md                          (sub-fluxo de Promoção — 11 passos)
```

### 9.1 Decomposição da SKILL.md principal

Esqueleto proposto (~350-400 linhas, vs ~500 atuais com mais cobertura):

1. Frontmatter — name, description, version 3.0.0, `disable-model-invocation: true`, triggers atualizados
2. Princípios invioláveis (~20 linhas) — os 7 da seção 2 deste design
3. Visão geral do fluxo (~30 linhas) — 4 estágios + diagrama textual
4. Pré-spec (~80 linhas) — Discovery (com pergunta de tipo+tier), Constitution (com formato YAML), Stack (com inventário + decisão técnica + alvo deploy)
5. Spec (~60 linhas) — Requirements, Design, Spike (opcional)
6. Build (~80 linhas) — Tasks (plano-mestre), Implementation (loop por feature, cada uma writing-plans)
7. Ship (~60 linhas) — Audit (referência ao references/audit-dimensoes.md), Delivery, Deploy
8. Como invocar (~15 linhas) — triggers, exemplos
9. Apêndice rápido — links pros references e templates

### 9.2 Detalhe dos 5 commands

| Command | Função |
|---|---|
| `/sdd-workflow:start` | Atalho pra invocar a skill principal. Equivalente a digitar "use o workflow SDD" em prosa |
| `/sdd-workflow:status` | Lê `specs/progress.md` e mostra resumo: estágio atual, fase atual, gate atual, features concluídas/total, bloqueios. Read-only |
| `/sdd-workflow:gate` | Verifica gate da fase atual. Lista critérios, identifica atendidos, sinaliza pendências. Não libera automaticamente — aprovação humana exigida |
| `/sdd-workflow:audit` | Dispara Ship.Audit standalone, fora do fluxo principal. Aceita arg opcional `--dimensoes <lista>` (ex: `--dimensoes seguranca,observabilidade`) pra rodar subset |
| `/sdd-workflow:promote-tier` | Invoca a sub-skill `sdd-promote-tier` (11 passos). Aceita arg opcional `--alvo <tier>` pra pular pergunta inicial (ex: `--alvo mvp`) |

---

## 10. Versionamento e migração

### 10.1 Bumps

- Plugin no `marketplace.json`: `0.1.1` → **`0.2.0`** (minor — features grandes, mas pré-1.0 sinalizando iteração)
- SKILL.md interna no frontmatter: `2.1.0` → **`3.0.0`** (major — refatoração estrutural, novos campos obrigatórios, novo formato de tasks)
- Tag mantida `em-testes` até validação em projeto real. Promove pra `recomendado` (e bump pra `1.0.0`) só depois de feedback de uso

### 10.2 Migração de projetos existentes (v2.x → v3.0)

A SKILL.md detecta projetos antigos automaticamente. Quando invocada num projeto que tem `specs/constitution.md` mas falta o bloco YAML novo, pergunta:

> "Este projeto está no fluxo SDD antigo (v2.x). Migrar pra v3.0?
> - Adiciona bloco YAML na constitution (pergunta tipo_projeto, tier, inventário, alvo deploy)
> - Mantém requirements.md, design.md, progress.md como estão (são compatíveis)
> - Reformata tasks.md pra plano-mestre + cria specs/plans/ pras features futuras
> - Tasks já implementadas ficam no histórico, novas features usam writing-plans"

Aceitar → migração executada. Pular → continua na v2.x conceitualmente, sem feature nova. Cancelar → não invoca a skill.

**Compatibilidade**: projetos que não migrarem continuam funcionando. Mas features novas (Spike, Promoção de Tier, Build.Implementation por feature) exigem migração.

### 10.3 Plano de release de 7 etapas

| # | Ação | Verificação |
|---|---|---|
| 1 | Branch de feature, implementar nova SKILL.md, sub-skill, templates, references, commands | Estrutura completa de arquivos |
| 2 | Validar com `claude plugin validate .` | Plugin schema ok |
| 3 | Bump version no marketplace.json (0.1.1 → 0.2.0) | Version drift check via `/marketplace-tools:marketplace-qa` |
| 4 | Aplicar fluxo de publicação Level 3 (`/marketplace-tools:publish-plugin`) | Cache invalidado, plugin rodando v0.2.0 |
| 5 | Rodar v3.0 em projeto real (sugestão: novo, do zero) | Fluxo completo Pré-spec → Ship sem bug |
| 6 | Coletar achados, ajustar, bump pra 0.2.1 ou 0.3.0 conforme necessário | Estabilização |
| 7 | Quando estável, promover tag `em-testes` → `recomendado` e bump pra 1.0.0 | Tier final do plugin |

---

## 11. Decisões consolidadas (rápida referência)

| Eixo | Decisão | Origem |
|---|---|---|
| Foco principal | Refinamento de conteúdo (eixo 3 da brainstorming) — integração com skills externas | P1, P2 |
| Famílias de skills | A (superpowers universais), B (domain-específicas), C sem `humanizador`, D (situacionais) | P3 |
| Modo de integração | Híbrido — A em Modo 2 (imperativo), B/C/D em Modo 1 (referencial) | P4 |
| Detecção de tipo de projeto | Híbrido — pergunta no Discovery, tag no constitution | P5 |
| Estrutura de fases | Adicionar Deploy, Stack, Spike (opcional), gate por feature em Implementation, juntar Setup com Constitution | P6 |
| Layout de fases | Opção β — 4 estágios nomeados (Pré-spec / Spec / Build / Ship) com fases internas | P7 |
| Stacks | Catálogo enxuto + livre (`web-saas`, `claude-plugin`, `hubspot`, `outro`); override sempre permitido com checkpoint explícito | P8 |
| Gates | Adicionar gate Pré-spec.Stack, Spec.Spike, Ship.Deploy, gate por feature em Build.Implementation; descartar check programático de "dados reais" | P9 |
| Auditoria expandida | 8 → 13 dimensões com matriz de obrigatoriedade por tier | P9 (item f) |
| Tier | Escala C — 5 níveis (`prototipo_descartavel`, `uso_interno`, `mvp`, `beta_publico`, `producao_real`); tier projetado, default = pedir explícito | P10, P11 |
| Promoção de Tier | Sub-fluxo dedicado de 11 passos, incremental, registrado em histórico | P11, S6 |
| Templates | Extrair pra `templates/` (Opção 2) | P12 |
| Estrutura do plugin | Híbrida — 1 skill principal + sub-skill `sdd-promote-tier` + templates + references | S7 |
| Slash commands | Todos os 5 (`start`, `status`, `gate`, `audit`, `promote-tier`); namespace `sdd-workflow` | S7 (item c) |
| Versionamento | Plugin 0.1.1 → 0.2.0; SKILL.md 2.1.0 → 3.0.0; tag `em-testes` mantida | S8 |
| Migração | Auto-detect + perguntar; v2.x continua funcionando se não migrar | S8 |

---

## 12. Próximos passos

1. **User review deste design** (após este doc estar commitado)
2. **Implementation plan** via `superpowers:writing-plans` — quebrar em tasks de 2-5 minutos com paths exatos, código real, comandos com expected output
3. **Implementação** via `superpowers:executing-plans` ou `:subagent-driven-development`
4. **Release** seguindo o plano de 7 etapas (seção 10.3)

