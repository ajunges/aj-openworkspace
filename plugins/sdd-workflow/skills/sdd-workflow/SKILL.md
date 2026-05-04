---
name: sdd-workflow
description: >
  Workflow Spec-Driven Development v1.0.0 pra projetos solo gerados por IA.
  Use quando o usuário disser "novo projeto", "criar um sistema", "quero desenvolver",
  "use o workflow SDD", ou variações pra iniciar/retomar projeto SDD.
  Audiência: não-programadores (executivos, etc.) e iniciantes dirigindo Claude Code
  pra construir software completo. 4 estágios (Pré-spec → Spec → Build → Ship), 5 níveis
  de tier, catálogo de tipo_projeto, governança em 3 camadas (9 heurísticas universais
  + princípios arquiteturais por tipo + disciplinas operacionais por tier), EARS pra
  Requirements + BDD pra Tasks 🔒, integração com superpowers (Modo 2), TDD canônico
  Red/Green/Refactor universal. Pra promoção/regressão de tier em projeto existente,
  ver sub-skill `sdd-promote-tier`. Pra migrar projeto v0.x → v1.0.0, ver sub-skill
  `sdd-migrate-v1`.
disable-model-invocation: true
version: 1.0.0
triggers:
  - sdd
  - novo projeto
  - criar um sistema
  - quero desenvolver
  - workflow sdd
  - status do projeto
tags:
  - development-methodology
  - project-management
  - spec-driven
  - workflow
  - tier-projetado
  - ears-bdd
  - governanca-3-camadas
---

# Spec-Driven Development Workflow — v1.0.0

Workflow completo pra desenvolvimento de novos projetos solo gerados 100% por IA. Cada estágio produz artefatos que devem ser aprovados antes de avançar conforme o nível de gates configurado.

> **Origem**: aplica os princípios canônicos do **GitHub Spec Kit** (`Constitution → Specify → Plan → Tasks → Verify`) com extensões opinativas pra audiência específica (não-dev e iniciantes dirigindo IA). Ver `docs/superpowers/specs/sdd-workflow-v1.0.0.md` no repo do plugin pra detalhe da governança v1.0.0.

---

## Premissa fundadora

Este plugin parte da premissa de que **rigor escala pelo destino, não pelo estado atual**. Tier projetado captura essa premissa e ativa Camada 3 (Disciplinas Operacionais) proporcionalmente.

Não é princípio inviolável — é a tese fundadora. Quem não concorda da tese provavelmente está no plugin errado.

> **Convenção de naming do conceito de tier**: o mesmo conceito aparece em formas distintas conforme contexto. `tier` (palavra simples em prosa). `tier:` (identifier YAML em código — snake_case quando composto, ex: `tier_decidido_em`). `tier-projetado` (tag YAML em frontmatter — kebab-case por convenção dos manifests Claude Code). "tier projetado" (descrição narrativa com adjetivo). Todas as formas referem o mesmo conceito; a forma muda só pra respeitar a convenção do contexto onde aparece.

---

## Governança em 3 camadas

A governança do plugin opera em três camadas que se complementam:

### Camada 1 — Heurísticas universais (sempre ativas)

9 disciplinas de raciocínio que rodam antes de qualquer ação significativa. Não dependem de tipo nem tier. Detalhe completo em `references/heuristicas.md`.

| # | Heurística | Resumo |
|---|---|---|
| H1 | Dados reais sempre | Antes de simular, busca dados reais. Sem dados, declara estimativa explícita |
| H2 | Reuso antes de construção | Busca lib/skill/template existente antes de codar do zero |
| H3 | Simplicidade preferida | Solução mais simples primeiro. Complexidade exige justificativa |
| H4 | Anti-abstração prematura | 3+ casos antes de abstrair. Duplicação > abstração errada |
| H5 | Decisões registradas | ADR pra toda decisão técnica significativa. Mecanismo de exceção embutido |
| H6 | Defensividade sobre dependências externas | Timeout, retry, fallback, degradação graciosa |
| H7.1 | Custo consciente — auto-execução quando barata = melhor | Sem perguntar quando há vencedor claro |
| H7.2 | Custo consciente — trade-offs pré-declarados | Constitution declara preferências; IA respeita sem perguntar caso a caso |
| H8 | Linguagem ubíqua | Vocabulário consistente entre spec, código, docs, UI |
| H9 | TDD canônico universal | Red→Green→Refactor→commit. Inclui markdown/JSON com refactor adaptado |

**Mecanismo de exceção:** quando IA precisa desviar de uma heurística, registra via H5 como ADR. As heurísticas não são "invioláveis" — são padrão a desviar conscientemente, não inadvertidamente.

### Camada 2 — Princípios arquiteturais por tipo

Princípios técnicos condicionais ao `tipo_projeto`. **Ativos em `mvp+`; informativos em `prototipo_descartavel` e `uso_interno`.**

Detalhe inline em `references/tipos-projeto.md` (cada `tipo_projeto` lista seus princípios). Resumo:

- **`claude-plugin`:** Library-First, CLI/Slash Mandate, SKILL.md como contrato, Versionamento explícito
- **`web-saas`:** Stack convencional preferida, Auth/billing terceirizados, Multi-tenancy desde dia 1, Integration testing em fronteiras
- **`hubspot`:** UI Extensions seguem padrão, Serverless com timeout consciente, Dados sensíveis nunca em frontend, Workflow vs UI Extension vs Custom Object — escolha consciente
- **`outro`:** Discovery obrigatório de tipo real, Princípios propostos pela IA validados pelo usuário, Promoção a tipo nomeado quando 2+ projetos similares

### Camada 3 — Disciplinas operacionais por tier

Disciplinas que escalam com o nível de risco declarado. **Cumulativas** — cada tier herda do anterior. Detalhe completo em `references/disciplinas-tier.md`.

| Tier | Disciplinas |
|---|---|
| 1 prototipo_descartavel | Nenhuma (Camada 1 + Camada 2 informativa) |
| 2 uso_interno | Logs básicos, README operacional |
| 3 mvp | Observability básica (Sentry default), backup com restore testado, doc de recovery |
| 4 beta_publico | (mvp +) integration testing, SemVer, audit logs imutáveis, performance baseline declarado, rate limiting |
| 5 producao_real | (beta_publico +) SLO, DR testado, compliance, audit dimensional completo, defesa prompt injection (se LLM), plano de incidente |

---

## Gates configuráveis

Pausas entre fases adaptam conforme escolha do usuário, registrada na constitution como campo `gates:`:

| Modo | Comportamento |
|---|---|
| `gates: explicitos` (default) | Pausa em todo Quality Gate; IA aguarda aprovação humana antes de avançar pra próxima fase |
| `gates: reduzidos` | Pausa só em transições de **estágio** (Pré-spec → Spec → Build → Ship), não em transições de **fase** dentro do estágio |
| `gates: minimos` | Pausa só em transições críticas: antes de Build.Implementation (escrever código), antes de Ship.Delivery (validar com usuário), antes de Ship.Deploy (subir prod) |

Default `explicitos` se usuário não souber responder. Mudança requer ADR via H5 (registrar motivação).

---

## Visão geral do fluxo — 4 estágios nomeados

```
I.  Pré-spec  →  Discovery  →  Constitution (com setup)  →  Stack (3 sub-componentes)
II. Spec      →  Requirements (EARS)  →  Design  →  [Spike opcional]
III. Build    →  Tasks (plano-mestre)  →  Implementation (loop por feature, gate por feature)
IV. Ship      →  Audit (13 dim. × 5 tier)  →  Delivery  →  Deploy
```

Cada estágio tem fases internas com **gates explícitos**. Cada gate é pausa obrigatória — IA apresenta resumo e aguarda aprovação antes de avançar.

| Estágio | Fases | Saídas |
|---|---|---|
| **I. Pré-spec** | Discovery, Constitution (absorve setup), Stack | `specs/constitution.md` (com YAML + inventário + alvo deploy) |
| **II. Spec** | Requirements, Design, Spike (opcional) | `specs/requirements.md` (EARS), `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks (plano-mestre), Implementation (loop por feature) | `specs/tasks.md` (índice), `specs/plans/<feature>.md` (writing-plans), código entregue |
| **IV. Ship** | Audit, Delivery, Deploy | `specs/audit-<data>.md`, sistema rodando, sistema em produção |

References e templates disponíveis estão indexados no **Apêndice** ao final desta SKILL.md (progressive disclosure — IA carrega sob demanda).

> **Nota sobre Quality Gates**: cada gate ✅ pausa conforme o modo de gates configurado na constitution (ver "Gates configuráveis" acima). As listas abaixo enumeram **critérios específicos** de cada gate sem repetir o passo de aprovação humana, que é universal e adapta ao modo declarado — exceto quando a aprovação tem semântica adicional (ex: "validou fluxos rodando" no Delivery).

---

## Estágio I — Pré-spec

### Pré-spec.Discovery

Faça perguntas ao usuário pra entender:

1. **Problema**: que dor operacional este projeto resolve?
2. **Usuários**: quem vai usar? quantas pessoas? em que dispositivo?
3. **Dados**: que dados entram, como são processados, o que sai?
4. **Referência**: existe planilha, documento ou processo manual que será substituído?
5. **Escopo V1**: o que é essencial vs. nice-to-have?
6. **`tipo_projeto`** (decisão estrutural — ver `references/tipos-projeto.md`):
   - `web-saas` — sistema web full-stack com UI rica
   - `claude-plugin` — plugin para Claude Code
   - `hubspot` — extensão HubSpot
   - `outro` — Stack Decision livre
7. **`tier` projetado** (visão final — ver `references/tiers.md`):
   - `prototipo_descartavel` | `uso_interno` | `mvp` | `beta_publico` | `producao_real`
   - **Tier é projetado**, não estado atual. Pedir explicitamente.

Se documentos de referência foram fornecidos (Excel, PDF, etc.), analisar antes de avançar:
- PDF → `anthropic-skills:pdf`
- Excel → `anthropic-skills:xlsx`
- Word → `anthropic-skills:docx`
- PowerPoint → `anthropic-skills:pptx`

Use `superpowers:brainstorming` pra explorar problema/requisitos quando útil.

**Quality Gate Discovery** ✅: Problema/usuários/dados/referência/escopo entendidos | tipo_projeto e tier respondidos com justificativa | Documentos de referência analisados (se houver).

### Pré-spec.Constitution (com Setup absorvido)

Após Discovery aprovada, executar:

1. **Criar estrutura de pastas e commit init**:
```bash
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/specs"
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/src"
cd "$PROJECTS_DIR/$PROJECT_NAME"
git init  # se aplicável
```

2. **Escrever `specs/constitution.md`** copiando + preenchendo `templates/constitution.md`. Bloco YAML inicial obrigatório:

```yaml
---
tipo_projeto: <da Discovery>
tier: <da Discovery>
tier_decidido_em: YYYY-MM-DD
---
```

Mais bloco textual obrigatório explicando **por que** esse tier.

3. **Escrever `CLAUDE.md` do projeto** com referência aos padrões universais (`/CLAUDE.md` raiz). Use `claude-md-management:revise-claude-md`.

4. **Escrever `README.md` inicial**.

5. **Commit inicial**:
```bash
git add .
git commit -m "init: $PROJECT_NAME — setup + constitution"
```

**Quality Gate Constitution** ✅: Bloco YAML preenchido | Stack default (ou override) justificada | Princípios não conflitam com `/CLAUDE.md` raiz | Brand colors definidos (se UI) | progress.md criado (template) | Commit init feito.

### Pré-spec.Stack — checkpoint explícito (3 sub-componentes)

**Não é confirmação automática**. Pausa real onde a IA pergunta criticamente:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Os 3 sub-componentes a registrar na constitution:

1. **Inventário de dependências** — ver `references/inventario-dependencias.md`. Categorias: CLI do sistema, MCP servers, skills do marketplace, acesso a serviços externos. Família A (`superpowers:*` essenciais) bloqueia se faltar.

2. **Stack técnica** — ver `references/stacks.md`. Default sugerida por `tipo_projeto`. Override permitido sempre, com justificativa.

3. **Alvo de deploy** — ver `references/alvos-deploy.md`. **Decisão explícita do projeto**, não derivada de tipo+tier. IA pergunta "onde o produto vai viver?".

**Quality Gate Stack** ✅: Inventário registrado (todas as categorias) | Stack confirmada ou override registrado com justificativa | Alvo de deploy registrado (decisão explícita) | Particularidades de Discovery consideradas (anti-pattern: aceitar default sem reflexão).

---

## Estágio II — Spec

### Spec.Requirements (formato EARS)

Escreva `specs/requirements.md` copiando + preenchendo `templates/requirements.md`. **Formato EARS** pra cada regra de negócio — 5 padrões (Ubiquitous, State-driven, Event-driven, Optional Feature, Unwanted Behavior) + Complex pra combinações. Sintaxe e exemplos: `references/linguagens-especificacao.md` seção 1.

Conteúdo obrigatório do `requirements.md`:

- Visão geral do sistema
- Usuários e perfis de acesso
- Dados de referência (linkar paths/URLs dos documentos reais)
- Módulos do sistema com requirements EARS
- Regras de negócio críticas com exemplos de **dados reais** (princípio 1)
- Requisitos não-funcionais conforme tier (ver `references/tiers.md`)
- Dados iniciais (seed) — extraídos dos documentos reais
- Fora do escopo V1

**Quality Gate Requirements** ✅: Cada módulo tem requirements EARS bem-formados | Regras de negócio com exemplos de dados reais | Documentos de referência analisados e linkados | Isolamento de dados entre perfis definido (se aplicável).

### Spec.Design

Escreva `specs/design.md` copiando + preenchendo `templates/design.md`. Conteúdo:

- Stack confirmada (da constitution + ajustes desta fase)
- Schema do banco (tabelas, relações, constraints, índices) se aplicável
- API Routes (rotas, payloads, autenticação, autorização)
- Arquitetura de componentes frontend (mobile-first se `web-saas`)
- Organização de pastas
- Estratégia de seed com dados reais
- **Bounded contexts** opcional (DDD parcial — apenas se `tier: producao_real` complexo ou `hubspot` extension grande). Senão noop declarado.
- **Decisão Spike**: este Design identificou risco técnico? Sim → cria `specs/spike.md`; Não → segue direto pra Build.Tasks.
- Decisões importantes (cross-link com constitution)

Skills sugeridas:
- `frontend-design` se UI distintiva (web-saas)
- `claude-api` se usa API Anthropic
- `plugin-dev:*` se `tipo_projeto: claude-plugin`

MCP sugerido:
- `context7` pra docs atualizadas de libs

**Quality Gate Design** ✅: Schema cobre todos os módulos dos requirements | APIs têm autenticação e autorização definidas | Stack bate com constitution | Brand colors do projeto configurados (Tailwind, se UI) | Mobile-first documentado (sidebar, tabelas, cards) se UI | Decisão Spike registrada (sim/não).

### Spec.Spike (opcional)

Entra **apenas** se Spec.Design identificou risco técnico (integração externa nova, lib desconhecida, dependência crítica). Box temporal sugerido: 1-3 dias.

Escreva `specs/spike.md` copiando + preenchendo `templates/spike.md`. Estrutura:

1. Risco identificado (origem: Spec.Design seção 8)
2. Hipóteses (principal + alternativas)
3. Critérios de sucesso
4. Investigação (setup mínimo, resultados, surpresas)
5. **Decisão tripartite**: confirmada / parcialmente confirmada / não confirmada
6. Próximo passo
7. Aprendizados pra registrar na Constitution

Skills usadas:
- `superpowers:test-driven-development` (validar hipóteses com testes)
- `superpowers:systematic-debugging` (quando spike der erro)

**Quality Gate Spike** ✅: Hipóteses validadas (ou negadas com pivot decidido) | Riscos resolvidos ou aceitos com justificativa | Decisão registrada (constitution histórico) | Aprendizados extraídos pra constitution.

---

## Estágio III — Build

### Build.Tasks (plano-mestre)

Escreva `specs/tasks.md` copiando + preenchendo `templates/tasks.md`. **Plano-mestre** = índice de features. Cada feature terá seu próprio plano detalhado em `specs/plans/<feature>.md`.

Quebra típica de features (adaptar conforme `tipo_projeto`):

1. **Infra e Setup** (Docker, scripts, banco)
2. **Auth + Layout** (login, JWT, sidebar, mobile drawer) se UI
3. **CRUDs** (entidades administrativas)
4. **Lógica de negócio 🔒** (cálculos, validações — validação obrigatória contra dados reais)
5. **Dashboards e visualizações** (se aplicável)
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** (isolamento, validações, responsividade)

Cada feature do plano-mestre deve:
- Ser testável independentemente
- Ter critério claro de done
- Indicar dependências
- Indicar 🔒 se exige validação contra dados reais

**Quality Gate Tasks** ✅: Cada feature tem plano detalhado planejado em `specs/plans/<feature>.md` | Dependências entre features claras | Features 🔒 identificadas | Plano-mestre revisado | progress.md atualizado com features.

### Build.Implementation — loop por feature

Pra cada feature do plano-mestre:

1. **Escrever plano detalhado** em `specs/plans/<feature>.md` usando `superpowers:writing-plans` com **5 ajustes de convenção SDD**:

   1. **Marcação 🔒** — header de task `### Task N: [Component] 🔒` ou step extra `- [ ] **Step X: 🔒 Validar contra dados reais**` antes do commit
   2. **Quebra por fase típica** absorvida no nível superior (`tasks.md` plano-mestre)
   3. **Quality Gate por feature** absorve gates antigos
   4. **Localização**: `specs/plans/<feature>.md` no projeto (autocontido)
   5. **Refactor explícito no ciclo TDD canônico** — `write test → run (FAIL) → implement → run (PASS) → REFACTOR → commit`. Refactor pode ser noop conscientemente declarado (não pulado silenciosamente); pra arquivos não-código (markdown, JSON) adapta semântica. Notação completa e anti-patterns: `references/linguagens-especificacao.md` seção 3.

2. **Cenário BDD pra tasks 🔒** (validação contra dados reais) — formato Given/When/Then com dados reais específicos (planilha, exportação, dataset). Estrutura completa e exemplo: `references/linguagens-especificacao.md` seção 2.

3. **Executar plano detalhado** com:
   - `superpowers:executing-plans` — execução inline com checkpoints, OU
   - `superpowers:subagent-driven-development` — fresh subagent per task com review entre tasks (recomendado pra features grandes)

4. **Skills durante Implementation**:
   - `superpowers:test-driven-development` — TDD canônico Red/Green/Refactor
   - `superpowers:systematic-debugging` — em erros (reproduzir → isolar → diagnosticar → corrigir)
   - `superpowers:verification-before-completion` — antes de declarar task pronta
   - `superpowers:using-git-worktrees` — quando feature precisa isolamento
   - `superpowers:dispatching-parallel-agents` — quando subtasks independem
   - `commit-commands:commit` — substituir commits manuais
   - `simplify` — depois de bloco grande de implementação

5. **Quality Gate por feature** ✅ (gate além do gate por task): Todos os steps do plano detalhado executados | Testes da feature passando (output mostrado) | Se 🔒: comparativo contra dados reais mostrado e aprovado | Refactor declarado (executado ou noop justificado) | progress.md marcado ✅.

6. **Atualizar `specs/progress.md`** ao concluir feature.

### Final de sessão (não é fase, é evento)

Quando a sessão de trabalho encerrar (mesmo no meio da Implementation):

1. **Atualizar `specs/progress.md`** com estado atual
2. **Revisar `CLAUDE.md` do projeto** com aprendizados (`claude-md-management:revise-claude-md`)
3. **Salvar na memória**: `remember:remember`
4. **Relatório de sessão** (opcional): `session-report:session-report`

---

## Estágio IV — Ship

### Ship.Audit — 13 dimensões × 5 tiers

Auditoria expandida. Detalhe completo das 13 dimensões: `references/audit-dimensoes.md`. Matriz de obrigatoriedade por tier: `references/tiers.md` seção 3.

Fluxo da Audit:

1. **Pergunta dimensões `perguntar`** ao usuário no início (registra resposta na constitution)
2. **Roda dimensões `obrigatório` e `opcional`** em paralelo via `superpowers:dispatching-parallel-agents`
3. **Sub-agentes especializados**:
   - `code-review:code-review` — dimensão Código
   - `security-review` (built-in) — dimensão Segurança
   - `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`
4. **Compila relatório** em `specs/audit-<YYYY-MM-DD>.md` copiando + preenchendo `templates/audit.md`. Achados classificados 🔴 (críticos — bloqueiam Delivery), 🟡 (importantes), 🟢 (melhorias).
5. **`superpowers:requesting-code-review`** — review humana antes da Audit começar, se aplicável

**Quality Gate Audit** ✅: Todas as dimensões `obrigatório` do tier executadas | Dimensões `perguntar` decididas e registradas na constitution | Achados 🔴 zerados ou tratados antes de avançar | Achados 🟡 corrigidos ou aceitos com justificativa registrada | Lógica de negócio validada contra dados reais (dimensão 8 sempre obrigatória) | progress.md atualizado.

### Ship.Delivery

Sistema rodando em ambiente de avaliação. Pré-deploy.

1. **Aplicar fixes** dos achados 🔴 e 🟡 da Audit
2. **Commit final** das correções
3. **Subir o sistema**: Docker compose ou equivalente conforme `tipo_projeto`
4. **Validar fluxos principais** com o usuário
5. **`superpowers:finishing-a-development-branch`** se branch isolada
6. **`commit-commands:commit-push-pr`** se PR aberto
7. **`pr-review-toolkit:review-pr`** se aplicável

**Quality Gate Delivery** ✅: Zero 🔴 da Audit | Seeds funcionando do zero (limpar banco + popular com dados reais) | Sistema rodando e acessível em ambiente de avaliação | README.md atualizado com instruções de setup e uso | Usuário validou fluxos principais | progress.md atualizado.

### Ship.Deploy — parametrizado por tier

Decisão do alvo foi tomada na Pré-spec.Stack (registrada na constitution). Esta fase **executa o deploy** conforme tier.

Comportamento por tier (ver `references/alvos-deploy.md` pra detalhe):

- **`prototipo_descartavel`**: não tem deploy. Roda local apenas. Ship.Deploy é noop declarado.
- **`uso_interno`**: deploy simples (Docker compose num servidor, Vercel free, hosting básico). Sem rollback formal.
- **`mvp`**: hosting gerenciado, deploy manual, monitoramento básico.
- **`beta_publico`**: rollback plan obrigatório, observabilidade obrigatória, error tracking.
- **`producao_real`**: rollback automático, alertas, on-call ou processo de incidente, monitoramento avançado.

Pra `claude-plugin` no marketplace:

- Se `marketplace-tools:publish-plugin` está instalado, usar o plugin (automatiza fluxo dos 6 passos com workaround dos bugs de cache)
- Senão, fluxo manual: bump version no `marketplace.json` → commit → push → invalidar cache local

**Quality Gate Deploy** ✅: Env de prod separado (secrets fora do código) | Rollback plan documentado (mvp+) ou declarado noop (prototipo/uso_interno) | Monitoramento básico configurado (mvp+) ou declarado noop | Domínio configurado (se aplicável) | Fluxos validados em prod (smoke test pelo menos) | progress.md em 100%.

### Promoção de Tier (sub-fluxo dedicado)

Quando o usuário expressar intenção de mudar tier ("promover esse projeto pra MVP", "agora vai virar prod real"), invocar a sub-skill **`sdd-promote-tier`** ou usar o command `/sdd-workflow:promote-tier`. 11 passos incrementais — não recomeça do zero.

---

## Como invocar

A SKILL.md tem `disable-model-invocation: true` — só ativa por triggers explícitos (frase ou slash command).

### Triggers naturais (frase em pt-BR)

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "Use o workflow SDD"
- "Status do projeto"
- "Promover este projeto pra [tier]"

### Slash commands (em `commands/`)

| Command | Função |
|---|---|
| `/sdd-workflow:start` | Atalho pra invocar a skill principal |
| `/sdd-workflow:status` | Lê `specs/progress.md` e mostra resumo |
| `/sdd-workflow:gate` | Verifica gate da fase atual; lista pendências |
| `/sdd-workflow:audit` | Dispara Ship.Audit standalone (`--dimensoes <lista>` opcional) |
| `/sdd-workflow:promote-tier` | Invoca sub-skill `sdd-promote-tier` (`--alvo <tier>` opcional) |
| `/sdd-workflow:migrate-v1` | Invoca sub-skill `sdd-migrate-v1` (migração v0.x → v1.0.0) |

### Migração de projetos existentes

**v0.x → v1.0.0:** quando invocada num projeto que tem `specs/constitution.md` v0.x (8 princípios invioláveis, stack web-saas legacy, sem campos `gates:`/`audiencia:`/`gera_receita:`/`trade_offs:`), oferecer migração via sub-skill `sdd-migrate-v1`. Migração é opt-in, preserva conteúdo, marca tudo com `[INFERIDO — confirmar]`. Detalhe completo em `skills/sdd-migrate-v1/SKILL.md`.

**v2.x → v3.0 (legado):** quando invocada num projeto v2.x (sem bloco YAML `tipo_projeto`/`tier`), perguntar se quer migrar. Aceitar → adiciona bloco YAML, reformata tasks.md pra plano-mestre, mantém requirements.md/design.md/progress.md. Pular → continua em v2.x conceitualmente. Cancelar → não invoca a skill. Detalhe operacional integrado ao `sdd-migrate-v1`.

**Compatibilidade**: projetos que não migrarem continuam funcionando. Spike, Promoção de Tier, Build.Implementation por feature exigem migração.

---

## Apêndice — references e templates

### References (progressive disclosure — IA carrega sob demanda)

| Reference | Conteúdo |
|---|---|
| `references/heuristicas.md` | **Camada 1**: 9 heurísticas universais detalhadas (sempre ativas) |
| `references/disciplinas-tier.md` | **Camada 3**: disciplinas operacionais por tier (cumulativas) |
| `references/tiers.md` | 5 níveis + matriz Audit 14×5 + premissa "tier projetado" |
| `references/tipos-projeto.md` | Catálogo: web-saas, claude-plugin, hubspot, outro + **Camada 2** inline (princípios arquiteturais por tipo) |
| `references/stacks.md` | Stack default v1.0.0 por tipo + tabela de overrides estruturais |
| `references/starters-catalog.md` | Catálogo de starters com licença, tração, Claude-native (≥3 critérios) |
| `references/overrides-matrix.md` | Matriz Auth/Billing/Email/Storage/Hosting com quando-usar e quando-evitar |
| `references/inventario-dependencias.md` | 4 categorias + Família A bloqueia |
| `references/audit-dimensoes.md` | 14 dimensões + override por tipo |
| `references/integracao-skills.md` | 4 famílias + 2 modos de integração |
| `references/alvos-deploy.md` | Alvos típicos por tipo + tier |
| `references/linguagens-especificacao.md` | EARS + BDD + ciclo TDD canônico (H9) + GEARS no radar |

### Templates (IA copia + preenche pro `specs/` do projeto-alvo)

| Template | Vai virar |
|---|---|
| `templates/constitution.md` | `specs/constitution.md` (YAML + 9 seções) |
| `templates/requirements.md` | `specs/requirements.md` (EARS por módulo) |
| `templates/design.md` | `specs/design.md` (schema + APIs + arquitetura + spike opcional) |
| `templates/tasks.md` | `specs/tasks.md` (plano-mestre — índice de features) |
| `templates/plan-feature.md` | `specs/plans/<feature>.md` (writing-plans + 5 ajustes SDD) |
| `templates/progress.md` | `specs/progress.md` (4 estágios × fases + status line + histórico tier) |
| `templates/spike.md` | `specs/spike.md` (hipótese + investigação + decisão tripartite) |
| `templates/audit.md` | `specs/audit-<data>.md` (13 dimensões × tier + achados) |

### Sub-skills

`sdd-promote-tier` — fluxo de 11 passos pra promoção/regressão de tier. Acionada por trigger natural ("promover este projeto pra X") ou `/sdd-workflow:promote-tier`.

`sdd-migrate-v1` — fluxo de migração de projeto SDD v0.x pra v1.0.0 (refunda governança em 3 camadas + atualiza stack default `web-saas` opcional). Acionada por trigger natural ("migrar pra v1.0.0", "atualizar workflow SDD") ou `/sdd-workflow:migrate-v1`.
