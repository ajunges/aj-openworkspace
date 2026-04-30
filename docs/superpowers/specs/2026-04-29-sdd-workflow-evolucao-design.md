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

### 1.3 Relação com SDD canônico (GitHub Spec Kit)

O SDD canônico mainstream é o **GitHub Spec Kit** (toolkit open source publicado em 2025), com fases `Constitution → Specify → Plan → Tasks → Verify`. Nosso fluxo aplica esses princípios na íntegra, com extensões opinativas:

| Spec Kit canônico | Nosso design |
|---|---|
| Constitution | Pré-spec.Constitution |
| Specify | Spec.Requirements |
| Plan | Spec.Design + Build.Tasks |
| Tasks | Build.Tasks (writing-plans) |
| Verify | Ship.Audit (mais rica — 13 dimensões × 5 tiers) |

**Adições nossas** (não cobertas pelo Spec Kit oficial): tier projetado, tipo_projeto + catálogo, Pré-spec.Stack com inventário de dependências, Spec.Spike opcional, Ship.Deploy, Promoção de Tier. Não são violações dos princípios SDD — são overlay opinativo pra audiência específica (não-dev dirigindo IA).

Fontes: [GitHub Spec Kit](https://github.com/github/spec-kit), [Martin Fowler — Understanding SDD](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html).

---

## 2. Princípios invioláveis (após evolução)

| # | Princípio | Origem |
|---|---|---|
| 1 | Dados reais sempre, nunca fictícios — em seed, testes, exemplos, demos | herdado v2.x |
| 2 | Tier é projetado (visão final do desenvolvimento), não observado (estado atual) | novo v3.0 |
| 3 | Defensividade sobre dependências externas — não pressupor CLI/MCP/skill/credencial sem inventário formal | novo v3.0 |
| 4 | Gates explícitos por fase — pausa obrigatória, aprovação humana antes de avançar | herdado v2.x |
| 5 | TDD canônico por task (Red → Green → Refactor) — escrever teste que falha, fazer passar com mínimo de código, refatorar mantendo o teste passando, só então commitar. Ciclo do Kent Beck preservado integralmente | herdado v2.x, agora estruturado via `superpowers:writing-plans` com Refactor explícito (ajuste SDD em 5.1.1) |
| 6 | Decisões registradas — toda escolha estrutural (tipo_projeto, tier, stack, alvo deploy) vai pra constitution com data e motivação | novo v3.0 |
| 7 | Promoção de tier é decisão consciente, registrada, incremental — nunca recomeço do zero | novo v3.0 |
| 8 | Linguagem ubíqua — vocabulário compartilhado entre IA, usuário, documentos de referência, código e UI. Termos definidos em Pré-spec.Discovery e Pré-spec.Constitution propagam pra requirements, design, tasks, código e UI sem traduções intermediárias | novo v3.0 (origem: DDD/BDD) |

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

### 4.5 Linguagens de especificação: EARS (Requirements) + BDD (Tasks 🔒)

Duas linguagens controladas operam em camadas diferentes do fluxo, cada uma no que faz melhor:

- **EARS — Easy Approach to Requirements Syntax** (Alistair Mavin, Rolls-Royce, 2009): linguagem controlada com 5 padrões e poucas keywords pra **escrever requirements precisos sem ambiguidade**. 15+ anos de uso em sistemas críticos (aerospace, defesa). Em consideração pra integração no SDD canônico ([Spec Kit Issue #1356](https://github.com/github/spec-kit/issues/1356)). Origem: [Alistair Mavin — EARS](https://alistairmavin.com/ears/), [Jama Software — Adopting EARS](https://www.jamasoftware.com/requirements-management-guide/writing-requirements/adopting-the-ears-notation-to-improve-requirements-engineering/).

- **BDD — Behavior-Driven Development** com formato **Given-When-Then/Gherkin** (Dan North, ~2006): cenários executáveis pra teste de comportamento, expressando setup → ação → asserção. Mainstream em testing há quase 20 anos. Origem: [Cucumber — History of BDD](https://cucumber.io/docs/bdd/history/), [Martin Fowler — Given When Then](https://martinfowler.com/bliki/GivenWhenThen.html).

A audiência do plugin SDD (executivo dirigindo IA, sem ler código) se beneficia das duas: EARS é mais preciso que prosa pra requirements, BDD é mais natural que prosa pra cenários de teste com dados reais. Aplicação por camada:

#### 4.5.1 Em Spec.Requirements — EARS (recomendado)

Requirements são escritos em **EARS** em vez de prosa. As 5 categorias EARS:

| Padrão | Keyword | Estrutura |
|---|---|---|
| Ubiquitous | (nenhuma) | `O <sujeito> deve <comportamento>` |
| State-driven | `Enquanto` | `Enquanto <estado>, o <sujeito> deve <comportamento>` |
| Event-driven | `Quando` | `Quando <evento>, o <sujeito> deve <comportamento>` |
| Optional Feature | `Onde` | `Onde <feature presente>, o <sujeito> deve <comportamento>` |
| Unwanted Behavior | `Se / então não` | `Se <condição>, então o <sujeito> não deve <comportamento>` |
| Complex | combinação | `Enquanto X, quando Y, o <sujeito> deve Z` |

Exemplo prático:

```ears
Ubiquitous:
  O sistema deve operar em pt-BR para textos de UI.

State-driven:
  Enquanto não houver sessão autenticada, o sistema deve redirecionar para /login.

Event-driven:
  Quando um pedido for fechado com valor maior que R$ 1000, o sistema deve aplicar
  desconto progressivo de 5% sobre o valor excedente.

Optional Feature:
  Onde o módulo de exportação estiver habilitado, o sistema deve oferecer botão
  "Exportar XLSX" na tela de relatórios.

Unwanted Behavior:
  Se o token JWT estiver expirado, então o sistema não deve processar a requisição
  e deve retornar HTTP 401.

Complex:
  Enquanto o usuário tiver perfil "admin", quando ele clicar em "Promover Tier",
  o sistema deve abrir o sub-fluxo de promoção registrando a ação no histórico.
```

**Vantagens vs prosa**:
- Reduz ambiguidade drasticamente (linguagem controlada com gramática rígida)
- LLMs parseiam confiavelmente (sintaxe regular)
- Curva de aprendizado mínima (5-6 keywords)
- Validação humana fica trivial (cada requirement é uma frase verificável)

#### 4.5.2 Em Build.Tasks 🔒 (validação contra dados reais) — BDD/Given-When-Then (recomendado)

Tasks marcadas 🔒 (validação contra dados reais — princípio inviolável 1) usam Given-When-Then porque o formato setup → ação → asserção é mais natural pra cenários de teste com dados específicos. Exemplo:

```gherkin
Cenário: Cálculo bate com planilha de referência (fevereiro 2026)
  Dado os dados reais da planilha "pedidos-fev-2026.xlsx"
  Quando recalculo total com a nova regra de desconto progressivo
  Então cada linha bate com a coluna "Total Final" da planilha
  E a soma total bate com a célula F999 da planilha
```

**Por que BDD aqui em vez de EARS**: EARS é otimizado pra requirements (o que o sistema deve fazer), enquanto Given-When-Then é otimizado pra cenários de teste executáveis com dados específicos. As duas notações são complementares, não competem.

#### 4.5.3 Em Ship.Audit dimensão 8 (Lógica de negócio)

Audit usa **as duas notações** em pontos diferentes:
- Cada requirement EARS de Spec.Requirements vira uma asserção verificável: "O sistema cumpre este EARS?"
- Cada cenário Given-When-Then de Tasks 🔒 vira um teste de validação executado contra dados reais

#### 4.5.4 Quando usar cada uma

| Situação | Notação |
|---|---|
| Requirements (o que o sistema deve fazer/não fazer) | **EARS** |
| Cenários de teste com dados específicos | **BDD/Given-When-Then** |
| Regras de negócio complexas (cálculos, validações, fluxos de aprovação) | EARS pra regra + BDD pros cenários de validação |
| CRUDs simples sem lógica de domínio | Opcional (prosa pode bastar pra projetos triviais) |

#### 4.5.5 Sobre GEARS — possível evolução pra v4.0

**GEARS (Generalized EARS)** foi publicado em janeiro/2026 como extensão do EARS otimizada pra IA. Promete unificar specs e tests numa sintaxe só (substituindo a separação EARS+BDD adotada aqui). Origem: [GEARS — DEV Community](https://dev.to/sublang/gears-the-spec-syntax-that-makes-ai-coding-actually-work-4f3f).

**Decisão atual (v3.0)**: não adotar. GEARS é muito novo (3 meses), pouca tração comprovada, pode mudar de forma. EARS e BDD são maduros e LLMs modernos parseiam ambos sem dificuldade. GEARS fica no radar pra revisão na v4.0 (6-12 meses), quando tiver sinais de adoção mainstream e o Spec Kit eventualmente posicionar-se sobre o tema.

### 4.6 Camada DDD opcional pra projetos com domínio complexo

**Domain-Driven Design** (Eric Evans, 2003) é abordagem de modelagem rica do domínio. Origem: [Wikipedia — DDD](https://en.wikipedia.org/wiki/Domain-driven_design), [Martin Fowler — Bounded Context](https://martinfowler.com/bliki/BoundedContext.html).

DDD completo (strategic + tactical) é **overkill pra maioria dos projetos** que o plugin SDD atende. Mas conceitos pontuais agregam:

#### 4.6.1 Linguagem ubíqua — princípio inviolável 8

Já incorporado como **princípio 8 (seção 2)**. Aplica em todos os tipos de projeto e tiers — termos definidos na Pré-spec viram vocabulário do código, UI, docs e testes. Origem: DDD (Evans), reforçado por BDD (North).

#### 4.6.2 Bounded contexts — opcional pra projetos complexos

A Spec.Design pergunta se o projeto tem **bounded contexts naturais** (áreas com modelos distintos, possivelmente vocabulários diferentes). Aplicável quando:

- `tier: producao_real` com domínio rico (ex: ERP, CRM, sistema multi-área de gestão)
- `tipo_projeto: hubspot` extension grande (custom objects + workflows + UI extensions + serverless cobrindo múltiplas áreas)
- Sistema com **grupos diferentes de usuários** usando vocabulários sutilmente diferentes (ex: "vendas" e "financeiro" chamando a mesma coisa de jeitos diferentes)

**Não aplicável**:
- `prototipo_descartavel`, `uso_interno`, `mvp` típicos
- `claude-plugin` (não tem domain model rico — é ferramenta)
- Projetos com domínio simples (CRUDs diretos sem lógica de negócio complexa)

Se aplicável: Spec.Design propõe modelo de bounded contexts com context map. Se não: segue com modelo simples.

#### 4.6.3 Tactical patterns (aggregates, entities, value objects) — fora do escopo

Tactical patterns do DDD (aggregates, repositórios, domain services, etc.) são padrões de código que o `superpowers:writing-plans` ou outras skills de implementação podem cobrir. Não fazem parte do workflow SDD em si — são decisão da fase Build.Implementation conforme a stack.

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

A skill `writing-plans` é mais granular (steps de 2-5 minutos) e técnica (paths exatos, código real, comandos com expected output) que o `tasks.md` antigo. Adotada com 5 ajustes:

1. **Marcação 🔒** — header de task `### Task N: [Component] 🔒` ou step extra `- [ ] **Step X: 🔒 Validar contra dados reais**` antes do commit. Decoração, não conflita com formato writing-plans
2. **Quebra por fase típica** — continua existindo no nível do gate por feature (Build.Implementation). Cada feature vira um plano writing-plans próprio. `tasks.md` vira plano-mestre indexando as features
3. **Quality Gate 4 SDD absorvido** — gate por feature: todos os steps do plano executados + testes passando + validações 🔒 aprovadas + aprovação humana
4. **Localização override** — planos vivem em `specs/plans/<feature>.md` no projeto (autocontido), não em `docs/superpowers/plans/`
5. **Refactor explícito no ciclo TDD** — o template padrão do writing-plans é `write-test → run-fail → implement → run-pass → commit` (4 passos + commit). Por aderência ao **TDD canônico (Kent Beck — Red/Green/Refactor)**, adicionamos passo Refactor antes do commit:

   ```
   write test → run (FAIL) → implement → run (PASS) →
   REFACTOR (improve design, run tests again, mantém PASS) → commit
   ```

   O step Refactor é onde o código vira "well structured", não só "working". É o passo que distingue TDD de "test-first hack". Pode ser noop quando o código já saiu limpo do step Implement — mas a decisão é consciente, não pulada. Origem: [Kent Beck — TDD](https://martinfowler.com/bliki/TestDrivenDevelopment.html), [Wikipedia — TDD](https://en.wikipedia.org/wiki/Test-driven_development).

#### 5.1.2 Refactor em arquivos não-código (markdown, JSON, YAML)

Projetos do tipo `claude-plugin` (e qualquer projeto cujo "deliverable" é primariamente markdown/JSON, não código executável) não têm testes unit no sentido clássico. O Refactor canônico ("improve design without changing behavior") precisa de **semântica adaptada** pra esses contextos, mas continua sendo passo obrigatório do ciclo — não é exceção. A "evolução do TDD canônico" adotada aqui (princípio 5) aplica universalmente.

**Adaptação semântica por tipo de arquivo**:

| Tipo de arquivo | "Behavior" preservado | Refactor possível |
|---|---|---|
| **Markdown** (skills, templates, references, commands, READMEs) | Significado/conteúdo informacional, links válidos, estrutura semântica (hierarquia de seções) | Eliminar redundância entre seções, condensar prosa verbosa em listas/tabelas, padronizar tom imperativo dentro do arquivo, melhorar exemplos pra clareza, garantir links cruzados funcionando, ordem de seções coerente |
| **JSON** (plugin.json, marketplace.json) | Validação de schema + valores | Reordenar campos pra ordem canônica do schema, garantir consistência de naming, eliminar campos redundantes ou obsoletos |
| **Frontmatter YAML** (de skills/commands) | Metadados parseáveis | Padronizar quoting, ordem dos campos, indentação |

**Templates de "test" adaptados**:

- Markdown → grep por seções obrigatórias, `wc -l` pra detectar overflow, `mdformat`/lint quando aplicável
- JSON → `jq .` pra parse, `claude plugin validate .` pra schema, comparação com schema esperado
- YAML frontmatter → script Python ou `yq` pra parsing + validação de campos obrigatórios

**Cuidado importante**: o step Refactor pode ser declarado **noop conscientemente** (com justificativa breve no commit ou no log da task) quando o Green saiu limpo. Isso preserva o espírito do princípio 5 (Refactor não é opcional, é etapa explícita) sem inflar artificialmente arquivos que já estão bons.

**Anti-pattern**: pular o step Refactor silenciosamente sem registrar a decisão. Se foi noop, declarar; se foi feito, mostrar o diff.

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
    │       ├── alvos-deploy.md
    │       └── linguagens-especificacao.md    (EARS + BDD/Given-When-Then — guia, exemplos, antipatterns)
    └── sdd-promote-tier/
        └── SKILL.md                          (sub-fluxo de Promoção — 11 passos)
```

### 9.1 Decomposição da SKILL.md principal

Esqueleto proposto (~350-400 linhas, vs ~500 atuais com mais cobertura):

1. Frontmatter — name, description, version 3.0.0, `disable-model-invocation: true`, triggers atualizados
2. Princípios invioláveis (~25 linhas) — os 8 da seção 2 deste design
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
| Relação com SDD canônico | Aplicar Spec Kit do GitHub na íntegra com extensões opinativas (tier, tipo_projeto, deploy, promoção) | reflexão SDD/TDD/BDD/DDD |
| TDD canônico | Adotar ciclo Red/Green/**Refactor** (Kent Beck) — Refactor explícito antes do commit | reflexão SDD/TDD/BDD/DDD |
| Linguagens de especificação | **EARS** (Mavin/Rolls-Royce, 2009) pra Spec.Requirements + **BDD/Given-When-Then** (North, 2006) pra Build.Tasks 🔒. Audit usa as duas. **GEARS** descartado pra v3.0 (muito novo) — fica no radar pra v4.0 | reflexão SDD/TDD/BDD/DDD + reflexão EARS/GEARS |
| DDD parcial | Linguagem ubíqua como princípio 8 (sempre); bounded contexts opcional pra producao_real complexo / hubspot extension grande | reflexão SDD/TDD/BDD/DDD |

---

## 12. Próximos passos

1. **User review deste design** (após este doc estar commitado)
2. **Implementation plan** via `superpowers:writing-plans` — quebrar em tasks de 2-5 minutos com paths exatos, código real, comandos com expected output
3. **Implementação** via `superpowers:executing-plans` ou `:subagent-driven-development`
4. **Release** seguindo o plano de 7 etapas (seção 10.3)

