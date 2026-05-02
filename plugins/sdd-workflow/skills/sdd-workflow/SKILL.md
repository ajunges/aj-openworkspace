---
name: sdd-workflow
description: >
  Workflow Spec-Driven Development v3.0 pra projetos solo gerados por IA.
  Use quando o usuário disser "novo projeto", "criar um sistema", "quero desenvolver",
  "use o workflow SDD", "promover este projeto pra <tier>", ou variações.
  Audiência: não-programadores (executivos, etc.) dirigindo Claude Code pra construir
  software completo. 4 estágios (Pré-spec → Spec → Build → Ship), 5 níveis de tier,
  catálogo de tipo_projeto, EARS pra Requirements + BDD pra Tasks 🔒, integração com
  superpowers (Modo 2), TDD canônico Red/Green/Refactor.
disable-model-invocation: true
version: 3.0.0
triggers:
  - sdd
  - novo projeto
  - criar um sistema
  - quero desenvolver
  - workflow sdd
  - nova feature
  - status do projeto
  - promover este projeto
  - evoluir tier
tags:
  - development-methodology
  - project-management
  - spec-driven
  - workflow
  - tier-projetado
  - ears-bdd
---

# Spec-Driven Development Workflow — v3.0

Workflow completo pra desenvolvimento de novos projetos solo gerados 100% por IA. Cada estágio produz artefatos que devem ser aprovados antes de avançar. **Princípios invioláveis** abaixo são contrato: violação = STOP.

> **Origem**: aplica os princípios canônicos do **GitHub Spec Kit** (`Constitution → Specify → Plan → Tasks → Verify`) com extensões opinativas pra audiência específica (não-dev dirigindo IA). Ver spec do plugin pra detalhe.

---

## Princípios invioláveis

| # | Princípio | Origem |
|---|---|---|
| 1 | **Dados reais sempre, nunca fictícios** — em seed, testes, exemplos, demos | herdado |
| 2 | **Tier é projetado** (visão final do desenvolvimento), não observado (estado atual) | v3.0 |
| 3 | **Defensividade sobre dependências externas** — não pressupor CLI/MCP/skill/credencial sem inventário formal | v3.0 |
| 4 | **Gates explícitos por fase** — pausa obrigatória, aprovação humana antes de avançar | herdado |
| 5 | **TDD canônico Red/Green/Refactor** — write test que falha, fazer passar com mínimo de código, refatorar mantendo o teste passando, só então commitar. Aplica universalmente, incluindo arquivos não-código (markdown/JSON com Refactor adaptado — ver `references/linguagens-especificacao.md` e seção sobre Build.Implementation) | herdado/v3.0 |
| 6 | **Decisões registradas** — toda escolha estrutural (tipo_projeto, tier, stack, alvo deploy, inventário) vai pra constitution com data e motivação | v3.0 |
| 7 | **Promoção de tier é decisão consciente, registrada, incremental** — nunca recomeço do zero | v3.0 |
| 8 | **Linguagem ubíqua** — vocabulário compartilhado entre IA, usuário, documentos de referência, código e UI. Termos definidos em Pré-spec.Discovery e Pré-spec.Constitution propagam pra requirements, design, tasks, código e UI sem traduções intermediárias | v3.0 (DDD/BDD) |

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

**Quality Gate Discovery** ✅: Problema/usuários/dados/referência/escopo entendidos | tipo_projeto e tier respondidos com justificativa | Documentos de referência analisados (se houver) | Aprovação verbal do usuário.

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

**Quality Gate Constitution** ✅: Bloco YAML preenchido | Stack default (ou override) justificada | Princípios não conflitam com `/CLAUDE.md` raiz | Brand colors definidos (se UI) | progress.md criado (template) | Commit init feito | Aprovação do usuário.

### Pré-spec.Stack — checkpoint explícito (3 sub-componentes)

**Não é confirmação automática**. Pausa real onde a IA pergunta criticamente:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Os 3 sub-componentes a registrar na constitution:

1. **Inventário de dependências** — ver `references/inventario-dependencias.md`. Categorias: CLI do sistema, MCP servers, skills do marketplace, acesso a serviços externos. Família A (`superpowers:*` essenciais) bloqueia se faltar.

2. **Stack técnica** — ver `references/stacks.md`. Default sugerida por `tipo_projeto`. Override permitido sempre, com justificativa.

3. **Alvo de deploy** — ver `references/alvos-deploy.md`. **Decisão explícita do projeto**, não derivada de tipo+tier. IA pergunta "onde o produto vai viver?".

**Quality Gate Stack** ✅: Inventário registrado (todas as categorias) | Stack confirmada ou override registrado com justificativa | Alvo de deploy registrado (decisão explícita) | Particularidades de Discovery consideradas (anti-pattern: aceitar default sem reflexão) | Aprovação do usuário.

---

## Estágio II — Spec

### Spec.Requirements (formato EARS)

Escreva `specs/requirements.md` copiando + preenchendo `templates/requirements.md`. **Formato EARS** (ver `references/linguagens-especificacao.md`) pra cada regra de negócio:

```ears
Ubiquitous:    O <sujeito> deve <comportamento>.
State-driven:  Enquanto <estado>, o <sujeito> deve <comportamento>.
Event-driven:  Quando <evento>, o <sujeito> deve <comportamento>.
Optional:      Onde <feature presente>, o <sujeito> deve <comportamento>.
Unwanted:      Se <condição>, então o <sujeito> não deve <comportamento>.
Complex:       Enquanto X, quando Y, o <sujeito> deve Z.
```

Conteúdo obrigatório do `requirements.md`:

- Visão geral do sistema
- Usuários e perfis de acesso
- Dados de referência (linkar paths/URLs dos documentos reais)
- Módulos do sistema com requirements EARS
- Regras de negócio críticas com exemplos de **dados reais** (princípio 1)
- Requisitos não-funcionais conforme tier (ver `references/tiers.md`)
- Dados iniciais (seed) — extraídos dos documentos reais
- Fora do escopo V1

**Quality Gate Requirements** ✅: Cada módulo tem requirements EARS bem-formados | Regras de negócio com exemplos de dados reais | Documentos de referência analisados e linkados | Isolamento de dados entre perfis definido (se aplicável) | Aprovação do usuário.

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
- `plugin:context7:context7` pra docs atualizadas de libs
- `plugin-dev:*` se `tipo_projeto: claude-plugin`

**Quality Gate Design** ✅: Schema cobre todos os módulos dos requirements | APIs têm autenticação e autorização definidas | Stack bate com constitution | Brand colors do projeto configurados (Tailwind, se UI) | Mobile-first documentado (sidebar, tabelas, cards) se UI | Decisão Spike registrada (sim/não) | Aprovação do usuário.

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

**Quality Gate Spike** ✅: Hipóteses validadas (ou negadas com pivot decidido) | Riscos resolvidos ou aceitos com justificativa | Decisão registrada (constitution histórico) | Aprendizados extraídos pra constitution | Aprovação do usuário.

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

**Quality Gate Tasks** ✅: Cada feature tem plano detalhado planejado em `specs/plans/<feature>.md` | Dependências entre features claras | Features 🔒 identificadas | Plano-mestre revisado e aprovado | progress.md atualizado com features.

### Build.Implementation — loop por feature

Pra cada feature do plano-mestre:

1. **Escrever plano detalhado** em `specs/plans/<feature>.md` usando `superpowers:writing-plans` com **5 ajustes de convenção SDD**:

   1. **Marcação 🔒** — header de task `### Task N: [Component] 🔒` ou step extra `- [ ] **Step X: 🔒 Validar contra dados reais**` antes do commit
   2. **Quebra por fase típica** absorvida no nível superior (`tasks.md` plano-mestre)
   3. **Quality Gate por feature** absorve gates antigos
   4. **Localização**: `specs/plans/<feature>.md` no projeto (autocontido)
   5. **Refactor explícito no ciclo TDD canônico**:

      ```
      write test → run (FAIL) → implement → run (PASS) →
      REFACTOR (improve design, run tests, mantém PASS) → commit
      ```

      Refactor pode ser noop conscientemente declarado (não pulado silenciosamente). Pra arquivos não-código (markdown, JSON), Refactor adapta semântica — ver `references/linguagens-especificacao.md` ou seção 5.1.2 do spec do plugin.

2. **Cenário BDD pra tasks 🔒** (validação contra dados reais):

   ```gherkin
   Cenário: Cálculo bate com planilha de referência
     Dado os dados reais da planilha "<arquivo>.xlsx"
     Quando recalculo total com a regra de negócio
     Então cada linha bate com a coluna "Total Final" da planilha
   ```

   Formato Given/When/Then — padrão BDD Gherkin.

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

5. **Quality Gate por feature** ✅ (gate além do gate por task): Todos os steps do plano detalhado executados | Testes da feature passando (output mostrado) | Se 🔒: comparativo contra dados reais mostrado e aprovado | Refactor declarado (executado ou noop justificado) | Aprovação humana antes de marcar ✅ no progress.md.

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

**Quality Gate Audit** ✅: Todas as dimensões `obrigatório` do tier executadas | Dimensões `perguntar` decididas e registradas na constitution | Achados 🔴 zerados ou tratados antes de avançar | Achados 🟡 corrigidos ou aceitos com justificativa registrada | Lógica de negócio validada contra dados reais (dimensão 8 sempre obrigatória) | progress.md atualizado | Aprovação do usuário.

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

### Migração de projetos v2.x → v3.0

Quando invocada num projeto que tem `specs/constitution.md` mas **falta o bloco YAML novo** (`tipo_projeto`, `tier`), perguntar:

> "Este projeto está no fluxo SDD antigo (v2.x). Migrar pra v3.0?
> - Adiciona bloco YAML na constitution (perguntar tipo_projeto, tier, inventário, alvo deploy)
> - Mantém requirements.md, design.md, progress.md como estão (compatíveis)
> - Reformata tasks.md pra plano-mestre + cria specs/plans/ pras features futuras
> - Tasks já implementadas ficam no histórico, novas features usam writing-plans"

Aceitar → migração executada. Pular → continua na v2.x conceitualmente, sem feature nova. Cancelar → não invoca a skill.

**Compatibilidade**: projetos que não migrarem continuam funcionando. Mas Spike, Promoção de Tier, Build.Implementation por feature exigem migração.

---

## Apêndice — references e templates

### References (progressive disclosure — IA carrega sob demanda)

| Reference | Conteúdo |
|---|---|
| `references/tiers.md` | 5 níveis + matriz Audit + princípio "tier projetado" |
| `references/tipos-projeto.md` | Catálogo: web-saas, claude-plugin, hubspot, outro |
| `references/stacks.md` | Stack default por tipo + variação por tier |
| `references/inventario-dependencias.md` | 4 categorias + Família A bloqueia |
| `references/audit-dimensoes.md` | 13 dimensões + override por tipo |
| `references/integracao-skills.md` | 4 famílias + 2 modos de integração |
| `references/alvos-deploy.md` | Alvos típicos por tipo + tier |
| `references/linguagens-especificacao.md` | EARS + BDD + GEARS no radar |

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

### Sub-skill

`sdd-promote-tier` — fluxo de 11 passos pra promoção/regressão de tier. Acionada por trigger natural ("promover este projeto pra X") ou `/sdd-workflow:promote-tier`.
