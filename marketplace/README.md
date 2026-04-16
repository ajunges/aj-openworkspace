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
