# Marketplace curado aj-openworkspace — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Criar o marketplace `.claude-plugin/marketplace.json` com 15 plugins curados (13 externos + 2 Level 3 próprios), reorganizar o repo em subpastas (`guias/`, `marketplace/`, `docs/`), implementar o plugin `marketplace-tools` com slash command `/check-marketplace-updates`, e publicar o plugin `sdd-workflow` a partir de uma versão sanitizada do SKILL.md privado do usuário.

**Architecture:** Repo público markdown-only vira simultaneamente (1) playbook pessoal organizado e (2) fonte funcional de instalação de plugins via `/plugin marketplace add ajunges/aj-openworkspace`. Os 13 plugins externos são referenciados por `git-subdir` (Anthropic-authored, dentro de `anthropics/claude-plugins-official`) ou `url` (terceiros com repo próprio), com SHA pin nos 9 plugins que injetam workflow (Level 2) e sem SHA nos 4 plugins MCP/LSP passivos (Level 1). Os 2 plugins Level 3 (`marketplace-tools` e `sdd-workflow`) ficam em `./plugins/`.

**Tech Stack:** Markdown, JSON, Bash, `jq`, `gh` CLI (autenticado), Claude Code plugin schema (`.claude-plugin/marketplace.json` e `.claude-plugin/plugin.json`), convenção de slash commands (`commands/*.md`) e skills (`skills/*/SKILL.md`).

**Reference spec:** `docs/superpowers/specs/2026-04-15-marketplace-design.md` (commit `701ca31`). Leia antes de começar qualquer task pra ter contexto das decisões.

**Reference doc:** `https://code.claude.com/docs/en/plugin-marketplaces` — doc oficial do Claude Code sobre marketplaces.

---

## File structure

Arquivos que serão criados/modificados/movidos. Use esta lista como ground truth de decomposição.

### Criados (9)

| Path | Responsabilidade |
|---|---|
| `.claude-plugin/marketplace.json` | Catálogo curado com 15 plugins |
| `plugins/marketplace-tools/.claude-plugin/plugin.json` | Manifest do plugin próprio marketplace-tools |
| `plugins/marketplace-tools/commands/check-marketplace-updates.md` | Slash command que verifica updates nos SHAs Level 2 |
| `plugins/marketplace-tools/README.md` | README humano do plugin marketplace-tools |
| `plugins/sdd-workflow/.claude-plugin/plugin.json` | Manifest do plugin próprio sdd-workflow |
| `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` | Skill sanitizada (sem Supero/caminhos/regras de negócio) |
| `plugins/sdd-workflow/README.md` | README humano do plugin sdd-workflow |
| `marketplace/README.md` | README do marketplace (contexto, modelo 3 níveis, catálogo, fontes) |

### Movidos (1, via git mv)

| De | Para |
|---|---|
| `claude-code-desktop-performance.md` | `guias/claude-code-desktop-performance.md` |

### Modificados (1)

| Path | Mudanças |
|---|---|
| `README.md` | (§10.1) adicionar seção "Contexto"; (§10.2) atualizar link do guia movido; (§10.3) adicionar seção "Marketplace" |

---

## Task 1: Reorganizar estrutura existente (git mv do guia + update de link)

**Files:**
- Move: `claude-code-desktop-performance.md` → `guias/claude-code-desktop-performance.md`
- Modify: `README.md:11` (link pro guia)

- [ ] **Step 1: Criar o diretório `guias/`**

```bash
mkdir -p guias
```

Expected: diretório criado sem erro.

- [ ] **Step 2: Mover o guia preservando histórico**

```bash
git mv claude-code-desktop-performance.md guias/claude-code-desktop-performance.md
```

Expected: `git mv` silencioso. Validar com `git status` — deve mostrar rename detectado:

```bash
git status --short
```

Expected output (aproximado):
```
R  claude-code-desktop-performance.md -> guias/claude-code-desktop-performance.md
```

- [ ] **Step 3: Atualizar o link no README.md principal**

Use Edit para substituir a linha exata:

Old string:
```
[claude-code-desktop-performance.md](claude-code-desktop-performance.md)
```

New string:
```
[guias/claude-code-desktop-performance.md](guias/claude-code-desktop-performance.md)
```

- [ ] **Step 4: Verificar que o link ficou consistente**

```bash
grep -n "claude-code-desktop-performance" README.md
```

Expected: uma linha mostrando o novo path `guias/claude-code-desktop-performance.md`.

- [ ] **Step 5: Commit**

```bash
git add README.md guias/claude-code-desktop-performance.md
git commit -m "Reorganizar: mover claude-code-desktop-performance.md para guias/

Preparação para suportar subpastas no repo (guias/, plugins/, marketplace/,
docs/). O único guia existente estava na raiz por falta de organização. git mv
preserva histórico. Link no README.md atualizado."
```

Expected: commit criado com 1 arquivo renomeado + 1 modificado.

---

## Task 2: Adicionar seção "Contexto" (CRO + IA) ao README.md

**Files:**
- Modify: `README.md` (inserir seção após o blockquote de abertura)

- [ ] **Step 1: Inserir a seção Contexto**

Use Edit para inserir a nova seção logo após o blockquote de abertura. O old string pega a transição do blockquote para `## Guias`:

Old string:
```
> Playbook pessoal do André Junges sobre Claude Code, workflows de AI e produtividade com LLMs. Notas organizadas e opinativas, em pt-BR com termos técnicos em inglês.

## Guias
```

New string:
```
> Playbook pessoal do André Junges sobre Claude Code, workflows de AI e produtividade com LLMs. Notas organizadas e opinativas, em pt-BR com termos técnicos em inglês.

## Contexto

Este repo é mantido por André Junges, CRO do Grupo Supero. **Não sou desenvolvedor** — todo o código deste repositório (`marketplace.json`, plugins próprios, scripts, configs) é escrito por IA via Claude Code. Uso este espaço como playbook pessoal de trabalho com LLMs e, agora, para distribuir minha curadoria de plugins.

Não é um projeto de engenharia profissional — é um workbook público de alguém aprendendo e documentando em público como dirigir IA para produzir software.

## Guias
```

- [ ] **Step 2: Verificar que a inserção ficou consistente**

```bash
head -20 README.md
```

Expected: seção "Contexto" presente com 2 parágrafos entre o blockquote e `## Guias`.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "README: adicionar seção Contexto (CRO + código por IA)

Expõe explicitamente que o repo é mantido por um não-programador (CRO do
Grupo Supero) e que todo o código aqui é escrito por Claude Code. Decisão
consciente de branding tomada no brainstorm do marketplace — o repo é um
workbook público de alguém dirigindo IA, não projeto de engenharia."
```

---

## Task 3: Criar marketplace.json com 13 plugins externos

**Files:**
- Create: `.claude-plugin/marketplace.json`

Esta task cria o marketplace com 13 plugins externos. Os 2 plugins Level 3 próprios (`marketplace-tools` e `sdd-workflow`) entram numa task posterior (Task 6), depois que os plugins existirem no filesystem. Ordem importa: entries de plugin não podem referenciar paths inexistentes.

- [ ] **Step 1: Criar o diretório `.claude-plugin/`**

```bash
mkdir -p .claude-plugin
```

- [ ] **Step 2: Re-confirmar o SHA atual de `anthropics/claude-plugins-official`**

```bash
gh api repos/anthropics/claude-plugins-official/commits/main --jq '{sha: .sha, date: .commit.author.date}'
```

Expected: JSON com `sha` (40 chars) e `date`. Anotar o SHA — será usado em 9 entries do marketplace.json.

Se o SHA coletado for diferente de `48aa43517886014e90ee80a6461f9de75045369d` (baseline do spec de 2026-04-15), usar o novo.

- [ ] **Step 3: Re-confirmar o SHA atual de `obra/superpowers`**

```bash
gh api repos/obra/superpowers/commits/main --jq '{sha: .sha, date: .commit.author.date}'
```

Expected: JSON com `sha` e `date`. Anotar.

Se o SHA coletado for diferente de `34c17aefb23c43960580b4a7f0ed5cb45c270cbe` (baseline do spec), usar o novo.

- [ ] **Step 4: Escrever o marketplace.json com 13 plugins**

Substitua `<ANTHROPIC_SHA>` pelo SHA coletado no Step 2 e `<SUPERPOWERS_SHA>` pelo SHA coletado no Step 3.

Use Write para criar o arquivo com o conteúdo abaixo:

```json
{
  "name": "aj-openworkspace",
  "owner": {
    "name": "André Junges"
  },
  "metadata": {
    "description": "Curadoria pessoal de plugins e skills do Claude Code do André Junges (CRO do Grupo Supero, não-dev, todo código escrito via Claude Code). Sistema de classificação em 3 dimensões: nível de controle (referência, pin, snapshot local), status (recomendado, em-testes, não-recomendado) e tags livres."
  },
  "plugins": [
    {
      "name": "superpowers",
      "description": "Pacote de skills que ensinam brainstorming, TDD, debugging sistemático, subagent-driven development e criação de skills. Base do meu workflow. SHA pinnado porque as skills injetam comportamento ativo e updates frequentes podem mudar o fluxo mid-sprint.",
      "source": {
        "source": "url",
        "url": "https://github.com/obra/superpowers.git",
        "sha": "<SUPERPOWERS_SHA>"
      },
      "category": "development",
      "tags": ["recomendado", "comunidade", "meta-skills", "workflow", "core"],
      "homepage": "https://github.com/obra/superpowers"
    },
    {
      "name": "code-review",
      "description": "Agent de code review com scoring por confidence. Uso como segundo par de olhos antes de merge em branches de trabalho.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/code-review",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "productivity",
      "tags": ["recomendado", "oficial-anthropic", "review", "workflow"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review"
    },
    {
      "name": "code-simplifier",
      "description": "Agent que refina código recém-modificado para clareza e manutenção sem mudar comportamento. Rodo no final de feature antes do commit final.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/code-simplifier",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "productivity",
      "tags": ["recomendado", "oficial-anthropic", "workflow"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-simplifier"
    },
    {
      "name": "commit-commands",
      "description": "Slash commands /commit, /commit-push-pr e /clean_gone. Substitui digitação manual do fluxo git. Personalização: removi o Co-Authored-By: Claude do template no meu CLAUDE.md global — sou CRO do Grupo Supero (não-dev), todo código neste repo é escrito via Claude Code, e prefiro manter o author primário como eu mesmo: a IA é ferramenta, não colaborador atribuído.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/commit-commands",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "productivity",
      "tags": ["recomendado", "oficial-anthropic", "git", "workflow"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/commit-commands"
    },
    {
      "name": "feature-dev",
      "description": "Workflow de desenvolvimento de features com agents de exploração, arquitetura e review. Complementa superpowers em projetos maiores.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/feature-dev",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "development",
      "tags": ["recomendado", "oficial-anthropic", "workflow"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev"
    },
    {
      "name": "skill-creator",
      "description": "Meta-skill para criar, editar e avaliar skills. Uso quando vou escrever skills próprias (Level 3 deste marketplace).",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/skill-creator",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "development",
      "tags": ["recomendado", "oficial-anthropic", "meta-skills"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator"
    },
    {
      "name": "claude-md-management",
      "description": "Skills para auditar e melhorar CLAUDE.md. Mantém o arquivo conciso e alinhado com best practices.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/claude-md-management",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "productivity",
      "tags": ["recomendado", "oficial-anthropic", "meta-skills", "docs"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management"
    },
    {
      "name": "security-guidance",
      "description": "Hook que avisa de padrões inseguros (injection, XSS, etc) ao editar arquivos. Rede de segurança passiva.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/security-guidance",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "security",
      "tags": ["recomendado", "oficial-anthropic", "seguranca"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance"
    },
    {
      "name": "claude-code-setup",
      "description": "Skill que analisa um codebase e recomenda automações (hooks/skills/MCPs/subagents). Em avaliação — rodei algumas vezes, ainda formando opinião.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/claude-code-setup",
        "sha": "<ANTHROPIC_SHA>"
      },
      "category": "productivity",
      "tags": ["em-testes", "oficial-anthropic", "meta-skills"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup"
    },
    {
      "name": "github",
      "description": "MCP server oficial do GitHub. Core da integração com repos/issues/PRs. HEAD porque updates são estáveis.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "external_plugins/github"
      },
      "category": "productivity",
      "tags": ["recomendado", "terceiro-oficial", "mcp", "git", "integracao"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/github"
    },
    {
      "name": "atlassian",
      "description": "MCP server oficial da Atlassian (Jira + Confluence). Uso no trabalho diário. Tool passiva, HEAD é seguro.",
      "source": {
        "source": "url",
        "url": "https://github.com/atlassian/atlassian-mcp-server.git"
      },
      "category": "productivity",
      "tags": ["recomendado", "terceiro-oficial", "mcp", "integracao", "jira"],
      "homepage": "https://github.com/atlassian/atlassian-mcp-server"
    },
    {
      "name": "microsoft-docs",
      "description": "MCP server de docs Microsoft/Azure. Em avaliação — instalado para consultas pontuais sobre stack Microsoft.",
      "source": {
        "source": "url",
        "url": "https://github.com/MicrosoftDocs/mcp.git"
      },
      "category": "development",
      "tags": ["em-testes", "terceiro-oficial", "mcp", "docs", "azure"],
      "homepage": "https://github.com/microsoftdocs/mcp"
    },
    {
      "name": "pyright-lsp",
      "description": "Pyright LSP para Python. Em avaliação — uso Python ocasionalmente.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/pyright-lsp"
      },
      "category": "development",
      "tags": ["em-testes", "oficial-anthropic", "lsp", "python"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/pyright-lsp"
    }
  ]
}
```

- [ ] **Step 5: Validar sintaxe JSON com `jq`**

```bash
jq . .claude-plugin/marketplace.json > /dev/null && echo "JSON válido"
```

Expected: `JSON válido` (sem erro).

Se jq reportar erro, a mensagem aponta linha/coluna do problema — corrigir e re-rodar.

- [ ] **Step 6: Validar contagem de plugins**

```bash
jq '.plugins | length' .claude-plugin/marketplace.json
```

Expected: `13`.

- [ ] **Step 7: Validar que todos os plugins têm `tags[0]` com status válido**

```bash
jq '.plugins[] | select(.tags[0] | IN("recomendado", "em-testes", "nao-recomendado") | not) | .name' .claude-plugin/marketplace.json
```

Expected: output vazio (nenhum plugin viola a convenção).

Se algum nome aparecer, esse plugin tem status inválido no `tags[0]` — corrigir e re-rodar.

- [ ] **Step 8: Rodar validador oficial (se disponível)**

```bash
claude plugin validate . 2>&1 || echo "validator não disponível ou erro — continuar manual"
```

Expected: `All checks passed` (caso ideal) ou warnings aceitáveis. Erros críticos bloqueiam avanço.

- [ ] **Step 9: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Criar marketplace.json com 13 plugins externos curados

9 plugins Level 2 (SHA pin) que injetam workflow:
- superpowers, code-review, code-simplifier, commit-commands, feature-dev,
- skill-creator, claude-md-management, security-guidance, claude-code-setup

4 plugins Level 1 (HEAD) passivos (MCP/LSP):
- github, atlassian, microsoft-docs, pyright-lsp

Status: 10 recomendados, 3 em-testes (claude-code-setup, microsoft-docs,
pyright-lsp). SHAs Level 2 pinnados no HEAD atual de anthropics/claude-plugins-
official e obra/superpowers. Os 2 plugins Level 3 próprios serão adicionados
em commit separado após existirem no filesystem."
```

---

## Task 4: Criar plugin marketplace-tools

**Files:**
- Create: `plugins/marketplace-tools/.claude-plugin/plugin.json`
- Create: `plugins/marketplace-tools/commands/check-marketplace-updates.md`
- Create: `plugins/marketplace-tools/README.md`

- [ ] **Step 1: Criar a estrutura de diretórios do plugin**

```bash
mkdir -p plugins/marketplace-tools/.claude-plugin plugins/marketplace-tools/commands
```

- [ ] **Step 2: Criar `plugin.json`**

Use Write para criar `plugins/marketplace-tools/.claude-plugin/plugin.json`:

```json
{
  "name": "marketplace-tools",
  "description": "Ferramentas para manter o marketplace aj-openworkspace — principalmente verificação de updates em plugins com SHA pinnado (Level 2).",
  "version": "0.1.0",
  "author": {
    "name": "André Junges"
  },
  "homepage": "https://github.com/ajunges/aj-openworkspace/tree/main/plugins/marketplace-tools"
}
```

- [ ] **Step 3: Validar o JSON**

```bash
jq . plugins/marketplace-tools/.claude-plugin/plugin.json > /dev/null && echo "plugin.json válido"
```

Expected: `plugin.json válido`.

- [ ] **Step 4: Criar o slash command `check-marketplace-updates.md`**

Use Write para criar `plugins/marketplace-tools/commands/check-marketplace-updates.md` com o conteúdo completo abaixo. Este arquivo é lido pelo Claude Code quando o usuário invoca `/check-marketplace-updates`:

```markdown
---
description: Verifica updates nos plugins com SHA pinnado no marketplace e aplica sob confirmação
---

# /check-marketplace-updates

Verifica cada plugin Level 2 (com `source.sha`) em `.claude-plugin/marketplace.json` contra o HEAD atual do upstream e apresenta updates disponíveis. Aplica updates aceitos editando o JSON e criando commits individuais.

## Pré-requisitos

- Rodar a partir da raiz de um repo que contenha `.claude-plugin/marketplace.json`
- `gh` CLI autenticado (checar com `gh auth status`)
- `jq` instalado

## Fluxo

Siga os passos abaixo em ordem. Pare no primeiro erro crítico.

### 1. Sanity check do ambiente

Verificar que estamos no lugar certo e com as ferramentas instaladas:

```bash
test -f .claude-plugin/marketplace.json || { echo "ERRO: .claude-plugin/marketplace.json não encontrado. Rode da raiz de um repo com marketplace."; exit 1; }
command -v gh >/dev/null || { echo "ERRO: gh CLI não instalado."; exit 1; }
command -v jq >/dev/null || { echo "ERRO: jq não instalado."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERRO: gh não autenticado. Rode 'gh auth login'."; exit 1; }
```

### 2. Coletar plugins Level 2 (com SHA)

Extrair lista de plugins pinnados com metadados necessários para o check:

```bash
jq -r '.plugins[] | select(.source.sha) | [.name, .source.source, .source.url, .source.path // "", .source.ref // "main", .source.sha] | @tsv' .claude-plugin/marketplace.json
```

Para cada linha do output (formato TSV: `name | source-type | url | path | ref | sha`), executar o check do passo 3.

### 3. Para cada plugin pinnado, resolver HEAD atual do upstream

**Se `source.source == "url"` (repo próprio do plugin):**

```bash
CURRENT_SHA=$(git ls-remote "$URL" "$REF" | awk '{print $1}' | head -1)
```

**Se `source.source == "git-subdir"` (plugin dentro de monorepo):**

Extrair `owner/repo` da URL e usar GitHub API:

```bash
OWNER_REPO=$(echo "$URL" | sed -E 's|https://github.com/([^/]+/[^/]+)\.git|\1|')
CURRENT_SHA=$(gh api "repos/$OWNER_REPO/commits/$REF" --jq '.sha')
```

Se `CURRENT_SHA` é vazio ou falha, logar erro e seguir pro próximo plugin (não abortar).

### 4. Comparar e extrair diff (se mudou)

Se `CURRENT_SHA != OLD_SHA`, buscar o compare entre os SHAs:

```bash
COMPARE=$(gh api "repos/$OWNER_REPO/compare/$OLD_SHA...$CURRENT_SHA")
```

Extrair do compare:
- Número de commits: `echo "$COMPARE" | jq '.commits | length'`
- Arquivos alterados: `echo "$COMPARE" | jq '.files | length'`
- Commits relevantes (filtrar por path se for git-subdir):

```bash
if [ -n "$PATH_PREFIX" ]; then
  RELEVANT_FILES=$(echo "$COMPARE" | jq -r ".files[] | select(.filename | startswith(\"$PATH_PREFIX/\")) | .filename")
else
  RELEVANT_FILES=$(echo "$COMPARE" | jq -r '.files[].filename')
fi
```

Se `RELEVANT_FILES` vazio (mudou o SHA mas nenhum arquivo do plugin foi afetado), pular este plugin.

Extrair top 5 commit messages:

```bash
TOP_COMMITS=$(echo "$COMPARE" | jq -r '.commits[:5][] | "- " + (.commit.message | split("\n")[0])')
```

Detectar breaking change por keyword nas commit messages:

```bash
BREAKING=$(echo "$COMPARE" | jq -r '.commits[] | .commit.message | select(test("BREAKING|breaking:|!:"; "i"))')
```

### 5. Apresentar sumário ao usuário

Para cada plugin com updates, apresentar:

```
### <nome do plugin>
- SHA antigo: <short-sha-antigo>
- SHA novo:   <short-sha-novo>
- Commits:    <N>
- Arquivos:   <N> (filtrados por path, se aplicável)
- Breaking:   <sim/não>

Top 5 commits:
<lista>

O que fazer? [A]plicar / [S]kip / [D]etalhar / [P]arar tudo
```

Aguardar input. Processar conforme:
- `A` / `apply` → atualizar SHA (passo 6)
- `S` / `skip` → não mexer, passar pro próximo plugin
- `D` / `detail` → mostrar lista completa de arquivos alterados e commit messages, depois perguntar de novo
- `P` / `stop` → encerrar o comando

### 6. Aplicar update (se aceito)

Editar o SHA no `marketplace.json` via `jq` (não regex):

```bash
jq --arg name "$PLUGIN_NAME" --arg new_sha "$CURRENT_SHA" \
  '(.plugins[] | select(.name == $name) | .source.sha) = $new_sha' \
  .claude-plugin/marketplace.json > .claude-plugin/marketplace.json.tmp \
  && mv .claude-plugin/marketplace.json.tmp .claude-plugin/marketplace.json
```

Validar JSON após edit:

```bash
jq . .claude-plugin/marketplace.json > /dev/null || { echo "ERRO: JSON quebrou após edit. Restaurar via git checkout."; exit 1; }
```

Commit individual para cada plugin atualizado:

```bash
git add .claude-plugin/marketplace.json
git commit -m "bump $PLUGIN_NAME para ${CURRENT_SHA:0:12}"
```

### 7. Output final

Após processar todos os plugins:

```
Verificados:      <N>
Sem updates:      <N>
Com updates:      <N>
Aplicados agora:  <N>
Pulados:          <N>
Erros:            <N>
```

Se erros > 0, listar quais plugins falharam e por quê.

## Tratamento de erros

- **Upstream inacessível**: loga (`ERRO ao checar <plugin>: <razão>`) e segue pro próximo plugin.
- **Rate limit do gh**: mostra mensagem explicativa e aborta (usuário deve esperar reset).
- **marketplace.json inválido após edit**: aborta imediatamente, restaura via `git checkout .claude-plugin/marketplace.json`.
- **Conflito de merge**: nunca acontece porque cada bump é um commit isolado, sem paralelismo.

## Não-objetivos (v0.1)

- Não verifica plugins Level 1 (sem SHA) — esses recebem updates automáticos do Claude Code
- Não faz rollback automático
- Não atualiza Level 3 (./plugins/) — esses são local-owned
- Não detecta vulnerabilidades de segurança no diff
- Não suporta private repos que exijam auth customizada além do `gh` default
```

- [ ] **Step 5: Criar o README.md do plugin**

Use Write para criar `plugins/marketplace-tools/README.md`:

```markdown
# marketplace-tools

Plugin próprio do marketplace `aj-openworkspace` com ferramentas para manter o próprio marketplace. Primeira versão (v0.1.0) expõe um slash command:

## `/check-marketplace-updates`

Verifica cada plugin Level 2 (com `source.sha` pinnado) no `.claude-plugin/marketplace.json` do repo atual, resolve o HEAD atual do upstream, mostra o diff e aplica updates sob confirmação.

### Como usar

1. Estar na raiz de um repo que contenha `.claude-plugin/marketplace.json`
2. Ter `gh` CLI autenticado (`gh auth status`)
3. Invocar `/check-marketplace-updates` no Claude Code

O comando apresenta um sumário por plugin com updates disponíveis e pergunta: aplicar, skip, detalhar ou parar. Aplicações bem-sucedidas geram commits individuais no formato `bump <plugin> to <short-sha>`.

### Limitações v0.1

- Só checa plugins Level 2 (com SHA). Plugins Level 1 recebem updates automaticamente via Claude Code.
- Não faz rollback automático.
- Não cobre plugins Level 3 (./plugins/).
- Não detecta vulnerabilidades de segurança no diff.

### Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install marketplace-tools@aj-openworkspace
```

### Autor

André Junges (@ajunges). Plugin escrito 100% via Claude Code.
```

- [ ] **Step 6: Verificar estrutura do plugin**

```bash
find plugins/marketplace-tools -type f
```

Expected:
```
plugins/marketplace-tools/.claude-plugin/plugin.json
plugins/marketplace-tools/commands/check-marketplace-updates.md
plugins/marketplace-tools/README.md
```

- [ ] **Step 7: Commit**

```bash
git add plugins/marketplace-tools/
git commit -m "Criar plugin marketplace-tools com /check-marketplace-updates

Plugin próprio (Level 3) que expõe um slash command para verificar updates
nos plugins Level 2 (SHA pinnado) do marketplace. Lógica documentada no
command file — sanity check, resolve HEAD upstream, compara, filtra diff por
path quando git-subdir, apresenta sumário e aplica sob confirmação usando jq
para edição segura do JSON. Dogfood do skill-creator."
```

---

## Task 5: Criar plugin sdd-workflow (SKILL.md sanitizado)

**Files:**
- Read: `~/Downloads/SKILL.md` (baseline — proteção de source obrigatória)
- Create: `plugins/sdd-workflow/.claude-plugin/plugin.json`
- Create: `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
- Create: `plugins/sdd-workflow/README.md`

Esta é a task mais longa do plano por causa das substituições de sanitização. **Nenhum atalho** — cada substituição é obrigatória pra não vazar dados profissionais do usuário no repo público.

- [ ] **Step 1: Proteção do source — re-ler o SKILL.md fonte**

```bash
test -f ~/Downloads/SKILL.md || { echo "ERRO: ~/Downloads/SKILL.md não existe. O spec (§8.4) exige que o arquivo esteja presente na implementação. Pausar e confirmar com o usuário antes de prosseguir."; exit 1; }
wc -l ~/Downloads/SKILL.md
```

Expected: arquivo existe, output mostra ~490 linhas.

Se o arquivo sumiu ou tem linhas muito diferentes (ex: 200 ou 800), **pausar** e confirmar com o usuário que o conteúdo não mudou antes de aplicar as substituições (os números de linha da tabela ficariam inválidos).

- [ ] **Step 2: Criar a estrutura de diretórios do plugin**

```bash
mkdir -p plugins/sdd-workflow/.claude-plugin plugins/sdd-workflow/skills/sdd-workflow
```

- [ ] **Step 3: Criar `plugin.json`**

Use Write para criar `plugins/sdd-workflow/.claude-plugin/plugin.json`:

```json
{
  "name": "sdd-workflow",
  "description": "Workflow de Spec-Driven Development para desenvolvedores solo gerando software 100% por IA. 7 fases (Discovery → Entrega) com quality gates explícitos, TDD e auditoria em 8 dimensões. Escrito por um CRO não-dev dirigindo Claude Code.",
  "version": "0.1.0",
  "author": {
    "name": "André Junges"
  },
  "homepage": "https://github.com/ajunges/aj-openworkspace/tree/main/plugins/sdd-workflow"
}
```

- [ ] **Step 4: Validar o plugin.json**

```bash
jq . plugins/sdd-workflow/.claude-plugin/plugin.json > /dev/null && echo "plugin.json válido"
```

Expected: `plugin.json válido`.

- [ ] **Step 5: Copiar a baseline do SKILL.md para o destino**

```bash
cp ~/Downloads/SKILL.md plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
```

Expected: arquivo copiado sem erro. Verificar:

```bash
wc -l plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
```

Expected: mesmo número de linhas do original (~490).

- [ ] **Step 6: Substituição 1 — frontmatter L4 (description)**

Use Edit em `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`:

Old string:
```
  Workflow completo de Spec-Driven Development para criar novos projetos Dev Monorepo.
```

New string:
```
  Workflow completo de Spec-Driven Development para criar novos projetos solo gerados por IA.
```

- [ ] **Step 7: Substituição 2 — L30 (intro)**

Old string:
```
Workflow completo para desenvolvimento de novos projetos Dev Monorepo. O desenvolvedor é não-programador — todo código é gerado por IA. Cada fase produz um artefato que deve ser aprovado antes de avançar.
```

New string:
```
Workflow completo para desenvolvimento de novos projetos solo, opcionalmente em monorepo. O desenvolvedor é não-programador — todo código é gerado por IA. Cada fase produz um artefato que deve ser aprovado antes de avançar.
```

- [ ] **Step 8: Inserir bloco "Contexto do autor" após o título**

Use Edit para inserir o bloco de contexto do autor entre o H1 do título e a "REGRA INVIOLÁVEL".

Old string:
```
# Spec-Driven Development Workflow

Workflow completo para desenvolvimento de novos projetos solo, opcionalmente em monorepo. O desenvolvedor é não-programador — todo código é gerado por IA. Cada fase produz um artefato que deve ser aprovado antes de avançar.

**REGRA INVIOLÁVEL**: Sempre usar dados REAIS dos documentos fornecidos. NUNCA inventar dados fictícios para seed, testes ou demonstrações.
```

New string:
```
# Spec-Driven Development Workflow

Workflow completo para desenvolvimento de novos projetos solo, opcionalmente em monorepo. O desenvolvedor é não-programador — todo código é gerado por IA. Cada fase produz um artefato que deve ser aprovado antes de avançar.

> **Contexto do autor**: este workflow foi desenvolvido por um não-programador
> (CRO do Grupo Supero) para dirigir o Claude Code na construção de sistemas
> completos — todo o código é gerado por IA. Os gates, quality checks e a
> auditoria em 8 dimensões existem exatamente para compensar a falta de
> conhecimento técnico direto: o humano valida resultado e regras de negócio,
> a IA escreve código. Se você é desenvolvedor experiente, provavelmente
> muitos dos guard rails vão parecer excessivos — use o que fizer sentido pro
> seu contexto.

**REGRA INVIOLÁVEL**: Sempre usar dados REAIS dos documentos fornecidos. NUNCA inventar dados fictícios para seed, testes ou demonstrações.
```

- [ ] **Step 9: Substituição 3 — L59-60 (mkdir command)**

Old string:
```bash
mkdir -p ~/repos/dev-monorepo/NOME_DO_PROJETO/specs
mkdir -p ~/repos/dev-monorepo/NOME_DO_PROJETO/src
```

New string:
```bash
# PROJECTS_DIR e PROJECT_NAME são configuráveis no CLAUDE.md raiz
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/specs"
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/src"
```

- [ ] **Step 10: Substituição 4 — L67-72 (git push command)**

Old string:
```bash
cd ~/repos/dev-monorepo
git add NOME_DO_PROJETO/
git commit -m "Init NOME_DO_PROJETO — setup do projeto"
git push
```

New string:
```bash
cd "$PROJECTS_DIR"
git add "$PROJECT_NAME/"
git commit -m "Init $PROJECT_NAME — setup do projeto"
git push
```

- [ ] **Step 11: Substituição 5 — L107 (brand colors na tabela)**

Old string:
```
| Brand colors | #E8611A (laranja Supero), #333333 (charcoal) |
```

New string:
```
| Brand colors | definir no constitution de cada projeto (primary + neutral) |
```

- [ ] **Step 12: Substituição 6 — L99 mudança do título "Stack Obrigatória"**

Old string:
```
## Stack Obrigatória
```

New string:
```
## Stack Default (preferência do autor; substituir no constitution se o projeto exigir outra)
```

- [ ] **Step 13: Substituição 7 — L192 (stack ref na Fase 3)**

Old string:
```
- Stack tecnológica (conforme constitution — não renegociar)
```

New string:
```
- Stack tecnológica definida no constitution do projeto (pode divergir da default)
```

- [ ] **Step 14: Substituição 8 — L199 (brand colors no quality gate)**

Old string:
```
□ Brand colors (#E8611A, #333333) configurados no Tailwind
```

New string:
```
□ Brand colors do projeto configurados no Tailwind conforme constitution
```

- [ ] **Step 15: Substituição 9 — L261-265 (exemplo de teste de comissão)**

Old string:
```javascript
test('comissão base 3% quando receita > baseline', () => {
  const result = calcularComissao({ receita: 150000, baseline: 100000 })
  expect(result.percentual).toBe(0.03)
})
```

New string:
```javascript
test('desconto progressivo 5% quando pedido > threshold', () => {
  const result = calcularDesconto({ valor: 1500, threshold: 1000 })
  expect(result.percentual).toBe(0.05)
})
```

- [ ] **Step 16: Substituição 10 — L347 (brand colors auditoria 6.6)**

Old string:
```
Brand colors (#E8611A, #333333), loading states (Skeleton), empty states, toast para feedback (nunca `alert()`), consistência visual, espaçamentos.
```

New string:
```
Brand colors do projeto, loading states (Skeleton), empty states, toast para feedback (nunca `alert()`), consistência visual, espaçamentos.
```

- [ ] **Step 17: Substituição 11 — L460 (Regras Gerais, brand colors)**

Old string:
```
- Brand colors Grupo Supero: `#E8611A` (laranja), `#333333` (charcoal)
```

New string:
```
- Brand colors do projeto conforme constitution — nunca hardcoded no código
```

- [ ] **Step 18: Substituição 12 — L466 (referência a security.md)**

Old string:
```
- Respeitar `.claude/rules/security.md` — regras de segurança invioláveis
```

New string:
```
- Respeitar regras de segurança do projeto e do CLAUDE.md raiz — regras invioláveis
```

- [ ] **Step 19: Grep final — validar ausência de strings sensíveis**

Este é o gate de qualidade da sanitização. **Deve retornar exit 0** (nada encontrado):

```bash
if grep -iE "Supero|dev-monorepo|~/repos/|E8611A|#333333|#333" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md; then
  echo "FALHA: strings sensíveis encontradas no SKILL.md sanitizado. Revisar acima e corrigir antes de seguir."
  exit 1
else
  echo "Sanitização validada: nenhuma string sensível encontrada."
fi
```

Expected: `Sanitização validada: nenhuma string sensível encontrada.`

Se falhar: **não commitar**. Ver linha(s) reportadas pelo grep e voltar aplicar mais substituições antes de prosseguir.

- [ ] **Step 20: Verificar que o arquivo mantém tamanho razoável**

```bash
wc -l plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
```

Expected: entre 490 e 510 linhas (original ~490 + bloco de contexto do autor ~10 linhas — substituições in-place mantêm tamanho ~constante).

Se menor que 480 ou maior que 520, pode ter havido perda/duplicação — inspecionar.

- [ ] **Step 21: Criar o README.md do plugin**

Use Write para criar `plugins/sdd-workflow/README.md`:

```markdown
# sdd-workflow

Playbook pessoal de **Spec-Driven Development** para desenvolvedores solo que geram 100% do código via IA. Primeira versão pública (v0.1.0), sanitizada a partir de um workflow privado do autor.

## Audiência

Não-programadores (ou programadores iniciantes) que usam o Claude Code pra construir sistemas completos. O workflow compensa a falta de conhecimento técnico direto com:

- **Gates explícitos** em cada fase — nada avança sem aprovação
- **TDD rigoroso** — testes escritos antes do código
- **Auditoria em 8 dimensões** — segurança, isolamento de dados, integridade, performance, responsividade, UX, código, lógica de negócio
- **Seed com dados reais** — nunca dados fictícios (regra inviolável)

## As 7 fases

| # | Fase | Output |
|---|---|---|
| 0 | Discovery | Entendimento documentado no chat |
| 0.5 | Setup | Estrutura de pastas, CLAUDE.md, README.md inicial |
| 1 | Constitution | `specs/constitution.md` com princípios, stack, quality standards |
| 2 | Requirements | `specs/requirements.md` com módulos e regras de negócio |
| 3 | Design | `specs/design.md` com schema, APIs, arquitetura |
| 4 | Tasks | `specs/tasks.md` com plano incremental |
| 5 | Implementação | Loop de task → TDD → implementar → verificar → commit |
| 6 | Auditoria | Relatório em 8 dimensões |
| 7 | Entrega | Sistema rodando + resumo final |

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install sdd-workflow@aj-openworkspace
```

## Como invocar

A skill é `disable-model-invocation: true` — só ativa por triggers explícitos. Use uma das frases:

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "/sdd" ou "/sdd.status" ou "/sdd.gate"

## Status

`em-testes` — primeira versão pública. Pode virar `recomendado` após rodada de uso e feedback.

## Autor

André Junges (@ajunges). Playbook desenvolvido na prática, 100% via Claude Code. Sem garantia — use por conta e risco.
```

- [ ] **Step 22: Verificar estrutura final do plugin**

```bash
find plugins/sdd-workflow -type f
```

Expected:
```
plugins/sdd-workflow/.claude-plugin/plugin.json
plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
plugins/sdd-workflow/README.md
```

- [ ] **Step 23: Commit**

```bash
git add plugins/sdd-workflow/
git commit -m "Criar plugin sdd-workflow (SKILL.md sanitizado)

Plugin próprio (Level 3) com skill de Spec-Driven Development para
desenvolvedores solo gerando código via IA. Derivado de versão privada do
autor, removendo:
- Menções a Grupo Supero
- Caminhos absolutos (~/repos/dev-monorepo) substituídos por \$PROJECTS_DIR
- Brand colors específicas (#E8611A, #333333) abstraídas
- Exemplo de regra de comissão (cliente específico) substituído por desconto
- Stack 'obrigatória' generalizada para 'default opinativa'
- Referência a .claude/rules/security.md que não existe neste repo

Adições:
- Bloco de contexto do autor no topo explicando a audiência (não-dev)
- README.md do plugin com as 7 fases em tabela e instruções de invocação

Sanitização validada via grep final: Supero|dev-monorepo|~/repos/|E8611A|#333333 → 0 matches."
```

---

## Task 6: Adicionar os 2 plugins Level 3 ao marketplace.json

**Files:**
- Modify: `.claude-plugin/marketplace.json` (adicionar entries 14 e 15)

Agora que `plugins/marketplace-tools/` e `plugins/sdd-workflow/` existem no filesystem, podemos referenciá-los no marketplace.json.

- [ ] **Step 1: Adicionar entry do marketplace-tools**

Use Edit em `.claude-plugin/marketplace.json`. A entry é adicionada **depois** da última (`pyright-lsp`).

Old string:
```json
    {
      "name": "pyright-lsp",
      "description": "Pyright LSP para Python. Em avaliação — uso Python ocasionalmente.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/pyright-lsp"
      },
      "category": "development",
      "tags": ["em-testes", "oficial-anthropic", "lsp", "python"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/pyright-lsp"
    }
  ]
}
```

New string:
```json
    {
      "name": "pyright-lsp",
      "description": "Pyright LSP para Python. Em avaliação — uso Python ocasionalmente.",
      "source": {
        "source": "git-subdir",
        "url": "https://github.com/anthropics/claude-plugins-official.git",
        "path": "plugins/pyright-lsp"
      },
      "category": "development",
      "tags": ["em-testes", "oficial-anthropic", "lsp", "python"],
      "homepage": "https://github.com/anthropics/claude-plugins-official/tree/main/plugins/pyright-lsp"
    },
    {
      "name": "marketplace-tools",
      "description": "Plugin próprio com slash command /check-marketplace-updates que verifica updates nos SHAs pinnados deste marketplace, mostra diffs e aplica sob confirmação.",
      "source": "./plugins/marketplace-tools",
      "category": "productivity",
      "tags": ["recomendado", "proprio", "meta-marketplace", "workflow"],
      "author": {
        "name": "André Junges"
      }
    },
    {
      "name": "sdd-workflow",
      "description": "Playbook pessoal de Spec-Driven Development para projetos solo gerados 100% por IA. Primeira versão pública sanitizada do workflow privado do autor.",
      "source": "./plugins/sdd-workflow",
      "category": "development",
      "tags": ["em-testes", "proprio", "workflow", "meta-skills", "solo-dev"],
      "author": {
        "name": "André Junges"
      }
    }
  ]
}
```

- [ ] **Step 2: Validar JSON após o edit**

```bash
jq . .claude-plugin/marketplace.json > /dev/null && echo "JSON válido"
```

Expected: `JSON válido`.

- [ ] **Step 3: Validar contagem de plugins agora é 15**

```bash
jq '.plugins | length' .claude-plugin/marketplace.json
```

Expected: `15`.

- [ ] **Step 4: Validar que todos os 15 têm `tags[0]` com status válido**

```bash
jq '.plugins[] | select(.tags[0] | IN("recomendado", "em-testes", "nao-recomendado") | not) | .name' .claude-plugin/marketplace.json
```

Expected: output vazio.

- [ ] **Step 5: Validar que os sources dos Level 3 apontam pra paths existentes**

```bash
jq -r '.plugins[] | select(.source | type == "string") | .source' .claude-plugin/marketplace.json | while read path; do
  if [ -d "$path" ]; then
    echo "OK: $path existe"
  else
    echo "ERRO: $path não existe"
  fi
done
```

Expected: ambos marcados como `OK`.

- [ ] **Step 6: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Adicionar plugins Level 3 (marketplace-tools e sdd-workflow) ao marketplace

Completa o marketplace para 15 plugins. Os 2 plugins próprios foram
referenciados via source relativo (./plugins/xxx) agora que existem no
filesystem. marketplace-tools é 'recomendado' (resolve dor real de manter
pins Level 2), sdd-workflow é 'em-testes' (primeira versão pública)."
```

---

## Task 7: Criar marketplace/README.md

**Files:**
- Create: `marketplace/README.md`

- [ ] **Step 1: Criar o diretório `marketplace/`**

```bash
mkdir -p marketplace
```

- [ ] **Step 2: Criar `marketplace/README.md`**

Use Write para criar `marketplace/README.md` com o conteúdo completo abaixo:

```markdown
# Marketplace aj-openworkspace — plugins curados do Claude Code

> Curadoria pessoal do André Junges. 15 plugins, modelo híbrido em 3 níveis.
> Contexto: sou CRO do Grupo Supero (não-dev), todo o código deste marketplace
> é escrito por IA via Claude Code.

Este marketplace é simultaneamente (1) um playbook pessoal público de plugins que uso e recomendo para workflow com Claude Code, e (2) uma fonte funcional de instalação — você pode adicionar via `/plugin marketplace add ajunges/aj-openworkspace` e instalar plugins individualmente.

Repo mantido por André Junges, CRO do Grupo Supero, não-programador. Todo o código, configuração e plugins próprios deste marketplace foi escrito por IA via Claude Code. Isto é um playbook público de alguém aprendendo em público a dirigir IA para produzir software — não é projeto de engenharia profissional.

---

## 1. Como instalar

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install <nome>@aj-openworkspace
```

Exemplo: `/plugin install superpowers@aj-openworkspace`. Você ganha os 15 plugins com tagging opinativo, description em português, e acesso ao slash command `/check-marketplace-updates` via `marketplace-tools` para revisar updates dos pins.

---

## 2. Modelo de 3 níveis

Cada plugin é classificado em 1 dos 3 níveis de controle, derivado do formato do campo `source`:

| Nível | Source | Semântica | Quando uso |
|---|---|---|---|
| **1** | `url`/`git-subdir` **sem** `sha` | HEAD sempre atualizado | Tools passivas (MCP servers puros, LSPs, docs) — updates silenciosos não quebram workflow |
| **2** | `url`/`git-subdir` **com** `sha` | Commit fixo, updates opt-in | Plugins que injetam skills/hooks/agents ativos — estabilidade importa mais que atualidade |
| **3** | `./plugins/xxx` | Código no próprio repo | Skills/commands próprios, forks locais, independência total |

O nível **não vai nas `tags`** — é derivado direto do `source`.

---

## 3. Status (primeira posição do array `tags`)

Todo plugin tem **exatamente uma** das três tags abaixo, **sempre no `tags[0]`**:

| Status | Significado | Ação implícita |
|---|---|---|
| `recomendado` | Uso ativo, confiável, maduro | Instale |
| `em-testes` | Em avaliação; pode virar recomendado ou sair | Instale com critério |
| `nao-recomendado` | Testei e não compensa | Não instale, veja o motivo em `description` |

Convenção estrita: `tags[0]` sempre é uma dessas três. O restante do array são tags livres.

---

## 4. Vocabulário de tags livres

Após o status, cada plugin tem 2-4 tags livres do vocabulário base (aberto — novas tags podem ser adicionadas sem rito):

| Grupo | Valores base |
|---|---|
| **Origem** | `oficial-anthropic`, `terceiro-oficial`, `comunidade`, `proprio` |
| **Função** | `workflow`, `meta-skills`, `review`, `seguranca`, `mcp`, `lsp`, `integracao` |
| **Domínio** | `git`, `python`, `jira`, `azure`, `docs`, `core`, `solo-dev`, `meta-marketplace` |

---

## 5. Plugins hoje

### 5.1 Level 2 — SHA pin (9 plugins de workflow)

- **superpowers** `recomendado` — Pacote de skills (brainstorming, TDD, debugging, subagent-driven-development). Base do meu workflow. [obra/superpowers](https://github.com/obra/superpowers)
- **code-review** `recomendado` — Agent de code review com scoring por confidence. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review)
- **code-simplifier** `recomendado` — Agent que refina código recém-modificado sem mudar comportamento. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-simplifier)
- **commit-commands** `recomendado` — Slash commands `/commit`, `/commit-push-pr`, `/clean_gone`. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/commit-commands)
- **feature-dev** `recomendado` — Workflow de desenvolvimento de features com agents. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev)
- **skill-creator** `recomendado` — Meta-skill pra criar/editar/avaliar skills. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator)
- **claude-md-management** `recomendado` — Skills pra auditar CLAUDE.md. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management)
- **security-guidance** `recomendado` — Hook que avisa de padrões inseguros. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance)
- **claude-code-setup** `em-testes` — Skill que analisa codebase e recomenda automações. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup)

### 5.2 Level 1 — HEAD (4 plugins passivos)

- **github** `recomendado` — MCP server oficial do GitHub. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/github)
- **atlassian** `recomendado` — MCP server oficial da Atlassian (Jira + Confluence). [atlassian/atlassian-mcp-server](https://github.com/atlassian/atlassian-mcp-server)
- **microsoft-docs** `em-testes` — MCP server de docs Microsoft/Azure. [MicrosoftDocs/mcp](https://github.com/microsoftdocs/mcp)
- **pyright-lsp** `em-testes` — Pyright LSP para Python. [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/pyright-lsp)

### 5.3 Level 3 — snapshots locais (2 plugins próprios)

- **marketplace-tools** `recomendado` — Slash command `/check-marketplace-updates` para verificar updates dos SHAs Level 2. Dogfood do skill-creator. [./plugins/marketplace-tools](../plugins/marketplace-tools)
- **sdd-workflow** `em-testes` — Playbook de Spec-Driven Development para solo devs gerando código via IA. [./plugins/sdd-workflow](../plugins/sdd-workflow)

---

## 6. Atualizando pins (Level 2)

Plugins Level 2 são pinnados em SHAs específicos, então updates upstream **não chegam automaticamente**. Pra revisar e aplicar updates quando quiser:

```
/check-marketplace-updates
```

(slash command exposto pelo plugin `marketplace-tools`)

O comando verifica cada plugin Level 2 contra o HEAD atual do upstream, mostra o diff (commits + arquivos filtrados por path quando git-subdir), e pergunta plugin-por-plugin: aplicar / skip / detalhar / parar. Cada aplicação vira um commit individual `bump <plugin> to <short-sha>`.

Requer `gh` CLI autenticado (`gh auth status`) e `jq` instalado.

---

## 7. Adicionando plugin próprio (Level 3)

Quando você quer criar um plugin próprio no marketplace (vive em `./plugins/<nome>`):

1. **Criar estrutura**:
   ```bash
   mkdir -p plugins/<nome>/.claude-plugin plugins/<nome>/skills/<nome> plugins/<nome>/commands
   ```

2. **Criar `plugin.json`** em `plugins/<nome>/.claude-plugin/plugin.json`:
   ```json
   {
     "name": "<nome>",
     "description": "<descrição curta>",
     "version": "0.1.0",
     "author": { "name": "André Junges" }
   }
   ```

3. **Escrever a skill ou command**:
   - Skill: `plugins/<nome>/skills/<nome>/SKILL.md` com frontmatter YAML
   - Command: `plugins/<nome>/commands/<cmd>.md` com frontmatter YAML

4. **Usar `skill-creator`** se precisar de ajuda (`/plugin install skill-creator@aj-openworkspace` primeiro se ainda não instalado).

5. **Adicionar entry no `.claude-plugin/marketplace.json`**:
   ```json
   {
     "name": "<nome>",
     "description": "<descrição>",
     "source": "./plugins/<nome>",
     "tags": ["recomendado", "proprio", "<função>", "<domínio>"],
     "author": { "name": "André Junges" }
   }
   ```

6. **Validar**: `jq . .claude-plugin/marketplace.json` + `claude plugin validate .` (se disponível).

7. **Commit**.

---

## 8. Fontes

- Schema oficial do marketplace: https://anthropic.com/claude-code/marketplace.schema.json
- Doc oficial "Create and distribute a plugin marketplace": https://code.claude.com/docs/en/plugin-marketplaces
- Doc oficial "Discover and install plugins": https://code.claude.com/docs/en/discover-plugins
- [anthropics/claude-plugins-official](https://github.com/anthropics/claude-plugins-official) — marketplace upstream oficial da Anthropic, fonte dos 9 plugins Level 2 Anthropic-authored e 2 plugins Level 1 pinnados por path
- [obra/superpowers](https://github.com/obra/superpowers) — upstream do plugin superpowers (Jesse Vincent)
- [guias/claude-code-desktop-performance.md](../guias/claude-code-desktop-performance.md) — guia de estilo deste repo
```

- [ ] **Step 3: Verificar tamanho e consistência**

```bash
wc -l marketplace/README.md
```

Expected: entre 180 e 300 linhas (guia de referência compacto).

- [ ] **Step 4: Commit**

```bash
git add marketplace/README.md
git commit -m "Criar marketplace/README.md (doc humana do marketplace)

README do marketplace explicando modelo de 3 níveis, status, vocabulário
de tags, catálogo agrupado dos 15 plugins hoje, como atualizar pins via
/check-marketplace-updates, como adicionar plugin próprio (Level 3), e
fontes canônicas. Fica em marketplace/ pra agrupar futuras docs do
marketplace (CHANGELOG, update-policy, examples)."
```

---

## Task 8: Atualizar README.md principal com seção Marketplace

**Files:**
- Modify: `README.md` (inserir seção "Marketplace" entre "Guias" e "Roadmap")

- [ ] **Step 1: Inserir a seção Marketplace**

Use Edit para inserir a nova seção. O old string pega a transição entre o final da seção Guias e o começo do Roadmap:

Old string:
```
Referência em 15 seções numeradas cobrindo gestão de `context window`, memória persistente (`CLAUDE.md` + Auto Memory), escolha de modelo e `/effort`, workflow Explore → Plan → Implement → Commit, `prompts` efetivos, `subagents`/`skills`/`plugins`, diff review e `/rewind`, gestão de sessões, remote/dispatch/parallelism, `MCP servers` e `hooks`, `permissions` e Auto Mode, env vars úteis, anti-patterns oficiais e quick reference de comandos. Atualizado em abril/2026.

## Roadmap
```

New string:
```
Referência em 15 seções numeradas cobrindo gestão de `context window`, memória persistente (`CLAUDE.md` + Auto Memory), escolha de modelo e `/effort`, workflow Explore → Plan → Implement → Commit, `prompts` efetivos, `subagents`/`skills`/`plugins`, diff review e `/rewind`, gestão de sessões, remote/dispatch/parallelism, `MCP servers` e `hooks`, `permissions` e Auto Mode, env vars úteis, anti-patterns oficiais e quick reference de comandos. Atualizado em abril/2026.

## Marketplace

### aj-openworkspace — plugins curados do Claude Code

[marketplace/README.md](marketplace/README.md)

Curadoria pessoal de 15 plugins do Claude Code com sistema de classificação em 3 dimensões (nível de controle, status, tags). Instalável via `/plugin marketplace add ajunges/aj-openworkspace`. Inclui dois plugins próprios: `marketplace-tools` (verifica updates dos SHAs pinnados) e `sdd-workflow` (playbook de Spec-Driven Development para solo devs não-programadores).

## Roadmap
```

- [ ] **Step 2: Verificar consistência**

```bash
head -40 README.md
```

Expected: a seção "Marketplace" aparece entre o parágrafo descritivo do guia e `## Roadmap`.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "README: adicionar seção Marketplace linkando para marketplace/README.md

Completa as mudanças no README.md principal (após a seção Contexto e o
update do link do guia movido). Agora o README principal tem: Guias,
Marketplace, Roadmap, Referências externas, Licença."
```

---

## Task 9: Validação manual end-to-end

**Files:** nenhum (validação runtime)

Esta task valida que o marketplace efetivamente funciona. Qualquer falha aqui é fix-forward num commit subsequente — não bloqueia os commits anteriores.

- [ ] **Step 1: Validar sintaxe do JSON final**

```bash
jq . .claude-plugin/marketplace.json > /dev/null && echo "OK: marketplace.json sintaxe válida"
jq . plugins/marketplace-tools/.claude-plugin/plugin.json > /dev/null && echo "OK: marketplace-tools/plugin.json sintaxe válida"
jq . plugins/sdd-workflow/.claude-plugin/plugin.json > /dev/null && echo "OK: sdd-workflow/plugin.json sintaxe válida"
```

Expected: 3 linhas "OK".

- [ ] **Step 2: Validar com o validador oficial (se disponível)**

```bash
claude plugin validate . 2>&1 | tee /tmp/validate-output.txt
```

Expected: `All checks passed` ou apenas warnings não-críticos.

Se reportar erros, listá-los e decidir plano de correção antes do step 3.

- [ ] **Step 3: Teste local de resolução do marketplace**

```bash
# Adicionar o marketplace localmente (aponta pro diretório atual)
claude plugin marketplace add . 2>&1 || echo "NOTA: add local pode falhar no Desktop app — tentar via /plugin no Claude Code"
```

Se a CLI não suporta `add .`, abrir o Claude Code no worktree e rodar `/plugin marketplace add ./` interativamente.

- [ ] **Step 4: Teste de install de um plugin Level 3**

No Claude Code:
```
/plugin install marketplace-tools@aj-openworkspace
```

Expected: install sucedido, marketplace-tools aparece em `/plugin list`.

- [ ] **Step 5: Teste do slash command `/check-marketplace-updates`**

Com o plugin instalado:
```
/check-marketplace-updates
```

Expected: o comando roda, checa os 9 plugins Level 2, e apresenta sumário. Como os SHAs foram re-confirmados no Task 3 Step 2/3, provavelmente mostrará "Sem updates" para a maioria — isso é sucesso (comando funcionou sem crash).

Se crashar, capturar o erro e corrigir o command file. Documentar o fix num commit separado.

- [ ] **Step 6: Teste de install de um plugin Level 2 (escolher `superpowers`)**

```
/plugin install superpowers@aj-openworkspace
```

Expected: install clona o repo no SHA pinnado e o plugin fica disponível. Se já instalado previamente de outro marketplace, o Claude pode pedir confirmação para substituir.

- [ ] **Step 7: Teste de install de um plugin Level 1 (escolher `atlassian`)**

```
/plugin install atlassian@aj-openworkspace
```

Expected: install via HEAD. Funciona.

- [ ] **Step 8: Consolidar resultados da validação**

Criar um resumo mental dos resultados dos steps 1-7:
- JSON sintaxe: OK?
- Validador oficial: OK / warnings / erros?
- Marketplace add: OK?
- Install Level 3: OK?
- Slash command: OK?
- Install Level 2: OK?
- Install Level 1: OK?

Se tudo OK: reportar sucesso ao usuário, marcar task concluída.

Se algo falhou: documentar em commit adicional com prefixo `fix:` ou em TODO no issue tracker do repo. Não reescrever commits anteriores.

- [ ] **Step 9: Commit de fix se necessário (condicional)**

Se houver fixes a partir dos steps 1-7:

```bash
git add <arquivos corrigidos>
git commit -m "fix: <descrição curta do que foi corrigido>"
```

Repetir validação relevante até passar.

- [ ] **Step 10: Sumário final ao usuário**

Reportar:
- 15 plugins no marketplace (9 Level 2, 4 Level 1, 2 Level 3)
- 2 plugins próprios funcionais
- Slash command `/check-marketplace-updates` operacional
- Repo reorganizado em subpastas
- Link do repo: `https://github.com/ajunges/aj-openworkspace`
- Comando pra outros usuários: `/plugin marketplace add ajunges/aj-openworkspace`

---

## Spec-to-plan coverage check

Cobertura do spec (commit `701ca31`) por task:

| Seção do spec | Task(s) |
|---|---|
| §3 Estrutura de arquivos | Task 1 (guias/), Task 3 (.claude-plugin/), Task 4+5 (plugins/), Task 7 (marketplace/) |
| §4 Metadados do marketplace | Task 3 |
| §5 Classificação em 3 dimensões | Documentada em Task 7 (marketplace/README.md §§2-4) |
| §6 Os 15 plugins curados | Task 3 (13 externos) + Task 6 (2 Level 3) |
| §6.4 Descriptions personalizadas | Incluídas nos JSON de Task 3 e Task 6 |
| §7 Plugin marketplace-tools | Task 4 |
| §8 Plugin sdd-workflow (sanitização) | Task 5 (inclui proteção do source no Step 1 e grep final no Step 19) |
| §9 marketplace/README.md | Task 7 |
| §10 README.md updates | Task 1 (§10.2 link), Task 2 (§10.1 Contexto), Task 8 (§10.3 Marketplace) |
| §11 Ordem de implementação | Tasks 1-9 (com commits frequentes, mais granular que o spec sugeriu) |
| §12 Fora do escopo | Não implementado (por definição) |
| §13 Fontes | Referenciadas no marketplace/README.md §8 |

Nada do spec ficou sem task correspondente.
