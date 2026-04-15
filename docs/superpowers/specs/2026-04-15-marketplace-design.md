# Marketplace curado de plugins do Claude Code — design spec

> Brainstorming session de 2026-04-15. Autor: André Junges (@ajunges).
> Status: aguardando review antes de ir para writing-plans.

---

## 1. Objetivo

Adicionar ao repo público `ajunges/aj-openworkspace` um Claude Code marketplace curado — `.claude-plugin/marketplace.json` — servindo duas funções simultâneas:

1. **Fonte de instalação funcional** — permite `/plugin marketplace add ajunges/aj-openworkspace` e instalação direta dos plugins a partir daqui (não é docs-only; cada entry resolve de verdade)
2. **Playbook pessoal público** — exposição opinativa da stack de plugins que o André Junges usa, com sistema de classificação explícito (níveis, status, tags)

Objetivo secundário: criar os primeiros plugins próprios do repo em `./plugins/`, começando por dois casos reais — um utilitário que resolve a manutenção do próprio marketplace (`marketplace-tools`) e um playbook de desenvolvimento solo (`sdd-workflow`, versão sanitizada de um workflow privado).

---

## 2. Contexto e decisões fechadas no brainstorm

Decisões tomadas durante a sessão de brainstorming, para referência:

| # | Decisão | Alternativas consideradas | Rationale |
|---|---|---|---|
| 1 | Uso: **marketplace funcional** | Catálogo docs-only / híbrido | Permite instalação via `/plugin` e reuso por outros; aumenta o valor além de documentar |
| 2 | Abordagem: **Level 2 por função (plugins de workflow) + Level 1 por função (tools passivas)** | Purista (Level 1 só Anthropic) / Pragmática (tudo Level 1) / Meio-termo | Justificativa honesta (criticidade) em vez de burocrática (origem); compatível com slash command de update |
| 3 | Escopo: **marketplace + slash command de update num único spec** | Marketplace primeiro, slash command depois | Evita migração futura; slash command viabiliza o uso ampliado de Level 2 |
| 4 | Slash command mora em: **plugin Level 3 próprio (`marketplace-tools`)** | Prompt template no README / skill dentro de plugin existente | Dogfood do skill-creator; primeiro plugin Level 3 nasce resolvendo dor real |
| 5 | Formato do marketplace-tools: **slash command (`commands/check-marketplace-updates.md`)** | Skill com auto-invoke / Ambos | Ação explícita e previsível, apropriada para checks periódicos |
| 6 | SDD workflow: **publicar sanitizado como segundo plugin Level 3** | Template só / Publicar tal-qual / Não publicar | Aproveita skill de valor alto, sanitização remove exposição acidental de dados profissionais |

---

## 3. Estrutura de arquivos

Tudo na raiz do repo, seguindo a convenção markdown-flat do `CLAUDE.md` local.

```
aj-openworkspace/
├── .claude-plugin/
│   └── marketplace.json                           # 15 plugins curados (raiz obrigatória pelo schema)
├── plugins/                                       # raiz (convenção do modelo de plugins)
│   ├── marketplace-tools/
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── commands/
│   │   │   └── check-marketplace-updates.md
│   │   └── README.md
│   └── sdd-workflow/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── skills/
│       │   └── sdd-workflow/
│       │       └── SKILL.md                       # sanitizado (ver seção 8)
│       └── README.md
├── marketplace/                                   # docs humanas do marketplace
│   └── README.md                                  # conteúdo detalhado na seção 9
├── guias/
│   └── claude-code-desktop-performance.md         # movido da raiz (git mv)
├── docs/
│   └── superpowers/specs/
│       └── 2026-04-15-marketplace-design.md       # este spec (artefato de brainstorming)
├── README.md                                      # atualizado: contexto (CRO+IA) + marketplace + link do guia movido
└── CLAUDE.md                                      # inalterado
```

**Decisões estruturais** (Opção B escolhida no brainstorm):

- **`.claude-plugin/marketplace.json` na raiz** — obrigatório pelo protocolo do Claude Code. Quando o usuário roda `/plugin marketplace add ajunges/aj-openworkspace`, o Claude Code clona o repo e procura exatamente esse path. Não é configurável. Citação da doc oficial: *"Create `.claude-plugin/marketplace.json` in your repository root."*
- **`plugins/` na raiz** — segue a convenção oficial do modelo. A doc exemplifica sempre com `./plugins/<nome>`. Fugir disso é possível (via `./marketplace/plugins/xxx`) mas foi **rejeitado** pelo trade-off de confundir leitores e quebrar assumptions de ferramentas externas. Descartada no brainstorm como Opção C.
- **`marketplace/` (nova pasta)** — agrupa docs humanas específicas do marketplace (README do marketplace + futuros CHANGELOG, update-policy, examples). Substitui o `CLAUDE-PLUGINS.md` na raiz que estava no design original. Motivo: o prefixo `CLAUDE-` é convenção para arquivos que instruem o Claude; o README do marketplace é doc pra humanos e não deveria usar esse prefixo. Além disso, agrupar numa pasta antecipa docs futuras do marketplace.
- **`guias/` (nova pasta)** — agrupa guias opinativos do repo. O único guia existente (`claude-code-desktop-performance.md`) está na raiz só porque nunca foi organizado. A implementação deve mover via `git mv` (preserva histórico) e atualizar o link no `README.md`.
- **`docs/superpowers/specs/` (nova árvore)** — abriga artefatos de processo do brainstorming, separado do produto principal (`guias/`). O primeiro (e por enquanto único) arquivo é este próprio spec.
- **`.gitkeep`** não é necessário em nenhuma pasta nova — todas têm conteúdo desde o dia zero.

---

## 4. marketplace.json — metadados top-level

```json
{
  "$schema": "https://anthropic.com/claude-code/marketplace.schema.json",
  "name": "aj-openworkspace",
  "description": "Curadoria pessoal de plugins e skills do Claude Code do André Junges. Sistema de classificação em 3 dimensões: nível de controle (referência, pin, snapshot local), status (recomendado, em-testes, não-recomendado) e tags livres.",
  "owner": {
    "name": "André Junges"
  },
  "plugins": [ /* ver seção 6 */ ]
}
```

**Decisões de metadados**:

- `name: "aj-openworkspace"` bate exatamente com o nome do repo, eliminando ambiguidade no comando `/plugin marketplace add ajunges/aj-openworkspace`.
- `owner.email` omitido — repo público, usuário não quis expor endereço. Pode ser adicionado depois via edit.
- `description` em pt-BR, alinhado com o tom do repo.

---

## 5. Classificação em 3 dimensões

### 5.1 Nível de controle (derivado do `source`)

| Nível | Source | Semântica | Quando usar |
|---|---|---|---|
| **1** | `url`/`git-subdir` **sem** `sha` | HEAD sempre atualizado | Tools passivas (MCP servers puros, LSPs, docs) onde updates silenciosos não quebram workflow |
| **2** | `url`/`git-subdir` **com** `sha` | Commit fixo, updates opt-in | Plugins que injetam skills/hooks/agents ativos; criticidade alta no workflow; stability-first |
| **3** | `./plugins/xxx` | Código no próprio repo | Skills/commands próprios, forks locais, independência total |

O nível **não vai no array `tags`** — é derivado do campo `source` e explicado no `marketplace/README.md`.

### 5.2 Status (primeira posição do `tags`)

Todo plugin tem **exatamente uma** das três tags abaixo, **sempre no `tags[0]`**:

| Status | Significado | Ação implícita |
|---|---|---|
| `recomendado` | Uso ativo, confiável, maduro | Instale |
| `em-testes` | Em avaliação; pode virar recomendado ou sair | Instale com critério |
| `nao-recomendado` | Testei e não compensa | Não instale, eis o motivo (ver description) |

Convenção estrita: `tags[0]` sempre é uma dessas três. O restante do array são tags livres.

### 5.3 Vocabulário de tags livres

Campo aberto (2-4 tags após o status), vocabulário base:

| Grupo | Valores | Uso |
|---|---|---|
| **Origem** | `oficial-anthropic`, `terceiro-oficial`, `comunidade`, `proprio` | Quem mantém o upstream |
| **Função** | `workflow`, `meta-skills`, `review`, `seguranca`, `mcp`, `lsp`, `integracao` | O que o plugin faz |
| **Domínio** | `git`, `python`, `jira`, `azure`, `docs`, `core`, `solo-dev`, `meta-marketplace` | Área de atuação |

Vocabulário é **aberto** — novas tags podem ser adicionadas livremente. Esta é a baseline documentada no `marketplace/README.md`.

---

## 6. Os 15 plugins curados

SHAs de baseline coletados em 2026-04-15 durante o brainstorm:

- `anthropics/claude-plugins-official` HEAD: `48aa43517886014e90ee80a6461f9de75045369d` (14/abr/2026)
- `obra/superpowers` HEAD: `34c17aefb23c43960580b4a7f0ed5cb45c270cbe` (15/abr/2026)

Estes SHAs devem ser **re-confirmados no momento da implementação** via `gh api repos/{owner}/{repo}/commits/main --jq .sha` caso haja gap de mais de algumas horas entre o spec e a execução. Se mudar, usar o novo HEAD.

### 6.1 Level 2 — SHA pin (9 plugins de workflow)

| # | Plugin | Status | Source (resumo) | Tags livres |
|---|---|---|---|---|
| 1 | superpowers | recomendado | `url` `https://github.com/obra/superpowers.git` @ `34c17aef...` | `comunidade`, `meta-skills`, `workflow`, `core` |
| 2 | code-review | recomendado | `git-subdir` `anthropics/claude-plugins-official` path=`plugins/code-review` @ `48aa4351...` | `oficial-anthropic`, `review`, `workflow` |
| 3 | code-simplifier | recomendado | `git-subdir` idem path=`plugins/code-simplifier` @ `48aa4351...` | `oficial-anthropic`, `workflow` |
| 4 | commit-commands | recomendado | `git-subdir` idem path=`plugins/commit-commands` @ `48aa4351...` | `oficial-anthropic`, `git`, `workflow` |
| 5 | feature-dev | recomendado | `git-subdir` idem path=`plugins/feature-dev` @ `48aa4351...` | `oficial-anthropic`, `workflow` |
| 6 | skill-creator | recomendado | `git-subdir` idem path=`plugins/skill-creator` @ `48aa4351...` | `oficial-anthropic`, `meta-skills` |
| 7 | claude-md-management | recomendado | `git-subdir` idem path=`plugins/claude-md-management` @ `48aa4351...` | `oficial-anthropic`, `meta-skills`, `docs` |
| 8 | security-guidance | recomendado | `git-subdir` idem path=`plugins/security-guidance` @ `48aa4351...` | `oficial-anthropic`, `seguranca` |
| 9 | claude-code-setup | em-testes | `git-subdir` idem path=`plugins/claude-code-setup` @ `48aa4351...` | `oficial-anthropic`, `meta-skills` |

### 6.2 Level 1 — HEAD (4 plugins passivos)

| # | Plugin | Status | Source (resumo) | Tags livres |
|---|---|---|---|---|
| 10 | github | recomendado | `git-subdir` anthropics/claude-plugins-official path=`external_plugins/github` | `terceiro-oficial`, `mcp`, `git`, `integracao` |
| 11 | atlassian | recomendado | `url` `https://github.com/atlassian/atlassian-mcp-server.git` | `terceiro-oficial`, `mcp`, `integracao`, `jira` |
| 12 | microsoft-docs | em-testes | `url` `https://github.com/MicrosoftDocs/mcp.git` | `terceiro-oficial`, `mcp`, `docs`, `azure` |
| 13 | pyright-lsp | em-testes | `git-subdir` anthropics/claude-plugins-official path=`plugins/pyright-lsp` | `oficial-anthropic`, `lsp`, `python` |

### 6.3 Level 3 — snapshots locais (2 plugins próprios)

| # | Plugin | Status | Source | Tags livres |
|---|---|---|---|---|
| 14 | marketplace-tools | recomendado | `./plugins/marketplace-tools` | `proprio`, `meta-marketplace`, `workflow` |
| 15 | sdd-workflow | em-testes | `./plugins/sdd-workflow` | `proprio`, `workflow`, `meta-skills`, `solo-dev` |

### 6.4 Descriptions personalizadas (pt-BR, opinativas)

Cada plugin tem uma `description` em pt-BR escrita do ponto de vista do usuário (não copiada do upstream). Baseline proposta (ajustes finais na implementação):

- **superpowers** — "Pacote de skills que ensinam brainstorming, TDD, debugging sistemático, subagent-driven development e criação de skills. Base do meu workflow. SHA pinnado porque as skills injetam comportamento ativo e updates frequentes podem mudar o fluxo mid-sprint."
- **code-review** — "Agent de code review com scoring por confidence. Uso como segundo par de olhos antes de merge em branches de trabalho."
- **code-simplifier** — "Agent que refina código recém-modificado pra clareza e manutenção sem mudar comportamento. Rodo no final de feature antes do commit final."
- **commit-commands** — "Slash commands `/commit`, `/commit-push-pr` e `/clean_gone`. Substitui digitação manual do fluxo git. Personalização: removi o `Co-Authored-By: Claude` do template no meu `CLAUDE.md` global — sou CRO do Grupo Supero (não-dev), todo código neste repo é escrito via Claude Code, e prefiro manter o author primário como eu mesmo: a IA é ferramenta, não colaborador atribuído."
- **feature-dev** — "Workflow de desenvolvimento de features com agents de exploração, arquitetura e review. Complementa superpowers em projetos maiores."
- **skill-creator** — "Meta-skill pra criar, editar e avaliar skills. Uso quando vou escrever skills próprias (Level 3 deste marketplace)."
- **claude-md-management** — "Skills pra auditar e melhorar `CLAUDE.md`. Mantém o arquivo conciso e alinhado com best practices."
- **security-guidance** — "Hook que avisa de padrões inseguros (injection, XSS, etc) ao editar arquivos. Rede de segurança passiva."
- **claude-code-setup** — "Skill que analisa um codebase e recomenda automações (hooks/skills/MCPs/subagents). Em avaliação — rodei algumas vezes, ainda formando opinião."
- **github** — "MCP server oficial do GitHub. Core da integração com repos/issues/PRs. HEAD porque updates são estáveis."
- **atlassian** — "MCP server oficial da Atlassian (Jira + Confluence). Uso no trabalho diário. Tool passiva, HEAD é seguro."
- **microsoft-docs** — "MCP server de docs Microsoft/Azure. Em avaliação — instalado para consultas pontuais sobre stack Microsoft."
- **pyright-lsp** — "Pyright LSP pra Python. Em avaliação — uso Python ocasionalmente."
- **marketplace-tools** — "Plugin próprio com slash command `/check-marketplace-updates` que verifica updates nos SHAs pinnados deste marketplace, mostra diffs e aplica sob confirmação."
- **sdd-workflow** — "Playbook pessoal de Spec-Driven Development para projetos solo gerados 100% por IA. Em avaliação — primeira versão pública sanitizada do meu workflow privado."

Texto final pode variar ligeiramente na implementação; o essencial é tom opinativo e pt-BR.

---

## 7. Plugin Level 3: marketplace-tools

### 7.1 Propósito

Plugin que mora em `./plugins/marketplace-tools/` e expõe um slash command `/check-marketplace-updates` capaz de:

1. Ler o próprio `.claude-plugin/marketplace.json` do repo
2. Para cada plugin com `source.sha` fixo (Level 2), resolver o HEAD atual do upstream
3. Comparar SHAs, buscar diff, filtrar por path (em casos `git-subdir`)
4. Apresentar sumário por plugin com opção de [A]tualizar / [S]kip / [D]etalhar / [P]arar
5. Editar o `marketplace.json` e commitar quando houver update aceito

### 7.2 Estrutura de arquivos

```
plugins/marketplace-tools/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── check-marketplace-updates.md
└── README.md
```

### 7.3 plugin.json

```json
{
  "name": "marketplace-tools",
  "description": "Ferramentas para manter o marketplace aj-openworkspace — principalmente verificação de updates em plugins com SHA pinnado (Level 2).",
  "version": "0.1.0",
  "author": {
    "name": "André Junges"
  }
}
```

### 7.4 Lógica do `/check-marketplace-updates`

O comando é um markdown em `commands/check-marketplace-updates.md` contendo instruções para o Claude seguir quando invocado. Estrutura do arquivo:

```markdown
---
description: Verifica updates nos plugins com SHA pinnado no marketplace e aplica sob confirmação
---

# /check-marketplace-updates

## Objetivo

Checar cada plugin Level 2 em `.claude-plugin/marketplace.json` contra o HEAD
atual do upstream e apresentar updates disponíveis ao usuário.

## Pré-requisitos

- Estar na raiz de um repo que contenha `.claude-plugin/marketplace.json`
- `gh` CLI autenticado
- `jq` instalado (vem com Claude Code Desktop)

## Fluxo

1. Ler `.claude-plugin/marketplace.json`
2. Filtrar plugins onde `source.sha` existe (Level 2)
3. Para cada um:
   a. Resolver HEAD do upstream:
      - Se `source.source == "url"`:
        `git ls-remote <url> HEAD | awk '{print $1}'`
      - Se `source.source == "git-subdir"`:
        `gh api repos/<owner>/<repo>/commits/<source.ref // "main"> --jq .sha`
   b. Se HEAD ≠ source.sha, buscar compare:
      `gh api repos/<owner>/<repo>/compare/<old>...<new>`
   c. Se `source.path` existe, filtrar `.files[]` por prefix
   d. Extrair:
      - Contagem de commits
      - Contagem de arquivos alterados (filtrados pelo path, se aplicável)
      - Top 5 mensagens de commit
      - Flag de breaking change (procurar por BREAKING, breaking:, !: em commit msgs)
4. Apresentar sumário agrupado:
   - Plugins com updates disponíveis
   - Plugins sem updates
   - Erros (se o upstream não respondeu)
5. Para cada update, perguntar ao usuário:
   [A]tualizar SHA agora / [S]kip / [D]etalhar commits / [P]arar verificação
6. Para cada [A]:
   - Editar marketplace.json via jq (não regex)
   - Adicionar commit individual: "bump <plugin> to <short-sha>"
7. Output final: "N verificados, M com updates, X aplicados, Y ignorados"

## Tratamento de erros

- Upstream inacessível: loga e segue pro próximo plugin
- gh api rate limit: informa ao usuário e aborta
- marketplace.json inválido: aborta antes de tocar em nada

## Não-objetivos (v0.1)

- Não verifica plugins Level 1 (sem SHA) — esses são updates automáticos
- Não faz rollback automático de updates
- Não atualiza Level 3 (./plugins/) — esses são local-owned
- Não detecta vulnerabilidades de segurança no diff (fora do escopo)
```

A versão final do arquivo é escrita na implementação; esta é a estrutura esperada.

### 7.5 README.md do plugin

Curto (~30 linhas): propósito, como instalar (via `/plugin install marketplace-tools@aj-openworkspace`), como invocar o comando, limitações (v0.1).

---

## 8. Plugin Level 3: sdd-workflow

### 8.1 Propósito

Playbook sanitizado de Spec-Driven Development para desenvolvedores solo que geram 100% do código via IA. Derivado de um workflow privado do usuário, removendo referências profissionais (empresa, clientes, caminhos pessoais) mantendo a substância do processo (fases, gates, TDD, auditoria).

### 8.2 Estrutura de arquivos

```
plugins/sdd-workflow/
├── .claude-plugin/
│   └── plugin.json
├── skills/
│   └── sdd-workflow/
│       └── SKILL.md
└── README.md
```

### 8.3 plugin.json

```json
{
  "name": "sdd-workflow",
  "description": "Workflow de Spec-Driven Development para desenvolvedores solo gerando software 100% por IA. 7 fases (Discovery → Entrega) com quality gates explícitos, TDD e auditoria em 8 dimensões.",
  "version": "0.1.0",
  "author": {
    "name": "André Junges"
  }
}
```

### 8.4 Plano de sanitização do SKILL.md

Baseline: SKILL.md fornecido pelo usuário em `~/Downloads/SKILL.md` (versão privada 2.1.0, ~490 linhas, lido durante o brainstorm em 2026-04-15).

**Proteção do source**: antes de aplicar qualquer substituição, a implementação deve ler novamente o arquivo fonte. Se ele tiver mudado desde o brainstorm ou tiver sido removido, a implementação deve pausar e confirmar com o usuário antes de prosseguir — as tabelas de substituição abaixo referenciam números de linha da versão capturada no brainstorm e podem ficar inválidas se o arquivo mudou.

**Substituições obrigatórias** (remoção de identificação profissional):

| Linha original | Antes | Depois |
|---|---|---|
| L4 (frontmatter) | "criar novos projetos Dev Monorepo" | "criar novos projetos solo gerados por IA" |
| L30 | "Workflow completo para desenvolvimento de novos projetos Dev Monorepo" | "Workflow completo para desenvolvimento de novos projetos solo, opcionalmente em monorepo" |
| L59-60 | `mkdir -p ~/repos/dev-monorepo/NOME_DO_PROJETO/{specs,src}` | `mkdir -p "$PROJECTS_DIR/$PROJECT_NAME"/{specs,src}` com nota: "`PROJECTS_DIR` e `PROJECT_NAME` configuráveis no CLAUDE.md raiz" |
| L67-72 | `cd ~/repos/dev-monorepo && git add NOME_DO_PROJETO/ && git commit...` | `cd "$PROJECTS_DIR" && git add "$PROJECT_NAME/" && git commit...` |
| L107 | `Brand colors \| #E8611A (laranja Supero), #333333 (charcoal)` | `Brand colors \| definir no constitution de cada projeto (primary + neutral)` |
| L199 | `Brand colors (#E8611A, #333333) configurados no Tailwind` | `Brand colors do projeto configurados no Tailwind conforme constitution` |
| L347 | `Brand colors (#E8611A, #333333)` | `Brand colors do projeto` |
| L460 | `Brand colors Grupo Supero: #E8611A (laranja), #333333 (charcoal)` | `Brand colors do projeto conforme constitution — nunca hardcoded no código` |
| L261-265 | Exemplo `test('comissão base 3% quando receita > baseline'...)` | Exemplo genérico: `test('desconto progressivo 5% quando pedido > threshold'...)` |
| L466 | "Respeitar `.claude/rules/security.md`" | "Respeitar regras de segurança do projeto e do CLAUDE.md raiz" |

**Substituições de generalização** (stack opinativa, não obrigatória):

| Local | Antes | Depois |
|---|---|---|
| L99-108 | Título "Stack **Obrigatória**" | Título "Stack **Default** (preferência do autor; substituir no constitution se o projeto exigir outra)" |
| L192 | "Stack tecnológica (conforme constitution — não renegociar)" | "Stack tecnológica definida no constitution do projeto (pode divergir da default)" |

**Adição no topo do SKILL.md sanitizado** (bloco de contexto do autor, antes da Fase 0):

Inserir após o título `# Spec-Driven Development Workflow` e antes de `**REGRA INVIOLÁVEL**`:

```markdown
> **Contexto do autor**: este workflow foi desenvolvido por um não-programador
> (CRO do Grupo Supero) para dirigir o Claude Code na construção de sistemas
> completos — todo o código é gerado por IA. Os gates, quality checks e a
> auditoria em 8 dimensões existem exatamente para compensar a falta de
> conhecimento técnico direto: o humano valida resultado e regras de negócio,
> a IA escreve código. Se você é desenvolvedor experiente, provavelmente
> muitos dos guard rails vão parecer excessivos — use o que fizer sentido pro
> seu contexto.
```

Esse bloco é **informativo, não instrutivo** — não muda o comportamento da skill quando invocada, só contextualiza quem lê o arquivo de origem (no repo público ou pelo marketplace).

**O que NÃO é modificado** (preserva a substância):

- Estrutura completa de 7 fases + gates
- Tom imperativo
- "REGRA INVIOLÁVEL: dados reais, nunca fictícios"
- Target "desenvolvedor não-programador" (diferencial real)
- Auditoria em 8 dimensões
- Progress tracking e status line
- Feature management por comandos naturais
- Exemplos de invocação
- **Referências a outros skills do marketplace** (`superpowers:test-driven-development`, `superpowers:systematic-debugging`, `superpowers:verification-before-completion`, `claude-md-management:revise-claude-md`) — intencional, é dogfood do marketplace

**Tamanho final estimado**: ~450-470 linhas (vs 490 originais).

**Responsabilidade de validação**: após aplicar as substituições na implementação, fazer um grep final por `Supero`, `dev-monorepo`, `~/repos/`, `E8611A` e `#333333` no arquivo final — se algum match sobrar, falhar a implementação até remover.

### 8.5 README.md do plugin

~40 linhas: propósito, audiência (solo devs usando IA), as 7 fases (resumo), como instalar, como invocar, licença/uso (playbook pessoal, sem garantia).

---

## 9. marketplace/README.md — README do marketplace

Arquivo em `marketplace/README.md` (pasta nova, criada na Opção B). House style do projeto (H2 numeradas separadas por `---`, tom imperativo-opinativo, tabelas, pt-BR).

**Motivo da localização** (`marketplace/README.md` em vez de `CLAUDE-PLUGINS.md` na raiz, que era o design original):

- Prefixo `CLAUDE-` é convenção para arquivos que instruem o Claude (`CLAUDE.md`); este arquivo é doc pra humanos, não deve usar o prefixo.
- Agrupar docs do marketplace numa pasta dedicada antecipa adições futuras (`CHANGELOG.md`, `update-policy.md`, `examples.md`) sem espalhar arquivos na raiz.
- O `README.md` principal do repo linka pra cá na nova seção "Marketplace" (ver §10).

### 9.1 Estrutura de seções

```
# Marketplace aj-openworkspace — plugins curados do Claude Code

> Curadoria pessoal do André Junges. 15 plugins, modelo híbrido em 3 níveis.
> Contexto: sou CRO do Grupo Supero (não-dev), todo o código deste
> marketplace é escrito por IA via Claude Code.

## 1. Como instalar

## 2. Modelo de 3 níveis

## 3. Status (tags[0] de cada plugin)

## 4. Vocabulário de tags livres

## 5. Plugins hoje
   ### 5.1 Level 2 — SHA pin
   ### 5.2 Level 1 — HEAD
   ### 5.3 Level 3 — snapshots locais

## 6. Atualizando pins (Level 2)

## 7. Adicionando plugin próprio (Level 3)

## 8. Fontes
```

### 9.2 Conteúdo por seção

**Bloco de contexto no topo** — parágrafo curto após o blockquote de abertura: "Repo mantido por André Junges, CRO do Grupo Supero, não-programador. Todo o código, configuração e plugins próprios deste marketplace foi escrito por IA via Claude Code. Isto é um playbook público de alguém aprendendo em público a dirigir IA para produzir software — não é projeto de engenharia profissional."

**§1 Como instalar** — bloco com `/plugin marketplace add ajunges/aj-openworkspace` + `/plugin install <nome>@aj-openworkspace`. Um parágrafo sobre o que você ganha (os 15 plugins com tagging opinativo).

**§2 Modelo de 3 níveis** — tabela idêntica à §5.1 deste spec, um parágrafo por nível com critério de quando usar.

**§3 Status** — tabela idêntica à §5.2 deste spec. Destaque de que `tags[0]` sempre carrega o status.

**§4 Vocabulário de tags livres** — tabela idêntica à §5.3 deste spec. Nota de que é vocabulário aberto.

**§5 Plugins hoje** — três subseções agrupando por Level. Para cada plugin: nome, status (bullet indicando), descrição curta (1-2 linhas do parágrafo opinativo), link pro upstream. Visual de catálogo.

**§6 Atualizando pins** — explicação curta do problema (SHAs viram stale) + referência ao slash command `/check-marketplace-updates` do `marketplace-tools` + exemplo de invocação.

**§7 Adicionando plugin próprio** — passo a passo: criar pasta em `./plugins/<nome>`, usar `skill-creator`, adicionar entry no `marketplace.json`, commitar. Mini-checklist.

**§8 Fontes** — links canônicos:
- Schema oficial: `https://anthropic.com/claude-code/marketplace.schema.json`
- Docs Anthropic sobre marketplaces: `https://code.claude.com/docs/en/plugin-marketplaces`
- Repo `anthropics/claude-plugins-official` (upstream dos Level 1/2 Anthropic)
- Plugins individuais com link direto

### 9.3 Tamanho esperado

200-300 linhas. Segue o padrão do `guias/claude-code-desktop-performance.md` mas mais compacto (guia de referência, não tutorial).

---

## 10. Atualização do README.md existente

Três mudanças no `README.md` principal, em ordem:

### 10.1 Nova seção "Contexto" após o parágrafo de abertura

Inserir logo após o blockquote que descreve o repo ("Playbook pessoal do André Junges..."), antes de `## Guias`:

```markdown
## Contexto

Este repo é mantido por André Junges, CRO do Grupo Supero. **Não sou desenvolvedor** — todo o código deste repositório (`marketplace.json`, plugins próprios, scripts, configs) é escrito por IA via Claude Code. Uso este espaço como playbook pessoal de trabalho com LLMs e, agora, para distribuir minha curadoria de plugins.

Não é um projeto de engenharia profissional — é um workbook público de alguém aprendendo e documentando em público como dirigir IA para produzir software.
```

### 10.2 Atualização do link na seção "Guias"

O link atual aponta para `claude-code-desktop-performance.md` (raiz). Após o `git mv` para `guias/`, atualizar para:

```markdown
### Claude Code Desktop — Performance e boas práticas

[guias/claude-code-desktop-performance.md](guias/claude-code-desktop-performance.md)
```

Texto de descrição do guia (que começa com "Referência em 15 seções numeradas...") permanece inalterado.

### 10.3 Nova seção "Marketplace" entre "Guias" e "Roadmap"

```markdown
## Marketplace

### aj-openworkspace — plugins curados do Claude Code

[marketplace/README.md](marketplace/README.md)

Curadoria pessoal de 15 plugins do Claude Code com sistema de classificação em 3 dimensões (nível de controle, status, tags). Instalável via `/plugin marketplace add ajunges/aj-openworkspace`. Inclui dois plugins próprios: `marketplace-tools` (verifica updates dos SHAs pinnados) e `sdd-workflow` (playbook de Spec-Driven Development para solo devs não-programadores).
```

Não mexer em mais nada do `README.md` existente (seções "Roadmap", "Referências externas", "Licença / uso" ficam como estão).

---

## 11. Ordem de implementação (alto nível)

Este é um esboço. O detalhamento fino é trabalho da próxima etapa (`writing-plans`).

1. **Reorganização do repo existente** — criar pasta `guias/`, rodar `git mv claude-code-desktop-performance.md guias/claude-code-desktop-performance.md` (preserva histórico), atualizar o link no `README.md` principal
2. **Estrutura mínima do marketplace** — criar `.claude-plugin/marketplace.json` com os 13 plugins externos (sem os 2 Level 3 ainda), usando SHAs atuais re-confirmados no início da implementação
3. **Plugin marketplace-tools** — criar `plugins/marketplace-tools/` completo com `plugin.json`, `commands/check-marketplace-updates.md`, `README.md`
4. **Plugin sdd-workflow** — re-ler `~/Downloads/SKILL.md` (proteção do source §8.4), criar `plugins/sdd-workflow/` com `plugin.json`, `skills/sdd-workflow/SKILL.md` sanitizado + bloco de contexto do autor, `README.md`; rodar grep final por `Supero|dev-monorepo|~/repos/|E8611A|#333333` pra validar sanitização
5. **Adicionar os 2 Level 3 ao marketplace.json** — incluir entries 14 e 15 apontando para `./plugins/marketplace-tools` e `./plugins/sdd-workflow`
6. **marketplace/README.md** — escrever o README do marketplace (antigo CLAUDE-PLUGINS.md do design original) dentro da nova pasta `marketplace/`, incluindo bloco de contexto "CRO + IA"
7. **README.md update** — adicionar seção "Contexto" (§10.1), atualizar link do guia movido (§10.2), adicionar seção "Marketplace" (§10.3)
8. **Commit descritivo único** — "Adicionar marketplace curado (15 plugins, 2 próprios) e reorganizar repo em subpastas". Mensagem detalhada lista cada grupo de mudança.
9. **Validação manual**:
   - `jq . .claude-plugin/marketplace.json` (checa JSON válido)
   - `claude plugin validate .` (validador oficial se disponível)
   - `/plugin marketplace add ./` (teste local de resolução)
   - `/plugin install marketplace-tools@aj-openworkspace` (teste de install)
   - `/check-marketplace-updates` (valida o próprio slash command contra os 9 SHAs pinnados)

Passo 9 expõe um risco real: o `/check-marketplace-updates` não foi testado contra caso real até a implementação. Plano de contingência: se a validação falhar, fix-forward num commit subsequente, não bloqueia o commit principal. Detalhamento no `writing-plans`.

---

## 12. Fora do escopo (para iterações futuras)

- **nao-recomendado** com plugins específicos — começa vazio; só aparece quando o usuário tiver testado um plugin e quiser deixar registro.
- **CI/validação automática** do marketplace.json (hook ou GitHub Action checando schema + `tags[0]` válido).
- **Changelog do marketplace** — arquivo tipo `CHANGELOG.md` do marketplace registrando bumps e adições. Se viável, deixar pro `marketplace-tools` gerar automaticamente no futuro.
- **Upgrade do sdd-workflow para recomendado** — depende de rodada de uso público e feedback.
- **Outros plugins Level 3 próprios** — conforme necessidade, seguindo o padrão de `sdd-workflow`.
- **Hook de pre-commit** no repo que roda `jq` validation do marketplace.json.
- **Slash commands adicionais no marketplace-tools** — p.ex. `/lint-marketplace` (checa duplicatas de name, tags[0] válido), `/add-plugin <name>` (scaffold interativo de nova entry).

---

## 13. Fontes

- Schema oficial do marketplace: `https://anthropic.com/claude-code/marketplace.schema.json`
- Doc oficial "Create and distribute a plugin marketplace": `https://code.claude.com/docs/en/plugin-marketplaces` (consultada durante o brainstorm em 2026-04-15 pra confirmar a restrição de path `.claude-plugin/marketplace.json` na raiz)
- `anthropics/claude-plugins-official` — upstream dos 9 plugins Level 2 Anthropic-authored e 2 plugins Level 1 pinned-by-path (`github` e `pyright-lsp`)
- `obra/superpowers` — upstream do plugin superpowers (pin no HEAD atual do brainstorm)
- `~/Downloads/SKILL.md` — baseline privada do sdd-workflow a ser sanitizada (ver §8.4)
- `guias/claude-code-desktop-performance.md` — guia existente no repo (padrão de estilo H2 numerado com `---`)
