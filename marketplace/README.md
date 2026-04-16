# Marketplace aj-openworkspace — guia de uso

> Curadoria pessoal de plugins do Claude Code do André Junges.
> 15 plugins, modelo híbrido em 3 níveis, sistema de classificação opinativo.

Este marketplace é uma fonte funcional de instalação de plugins — você adiciona, escolhe o que instalar, e gerencia via comandos padrão do Claude Code. Tudo que está aqui foi testado por alguém que não é desenvolvedor e usa Claude Code pra gerar 100% do código.

Para administração do marketplace (adicionar plugins, atualizar SHAs, criar plugins próprios), veja [ADMIN.md](ADMIN.md).

---

## 1. Adicionar o marketplace

Antes de instalar qualquer plugin, adicione este marketplace ao seu Claude Code:

```bash
# Via CLI
claude plugin marketplace add ajunges/aj-openworkspace

# Via sessão interativa
/plugin marketplace add ajunges/aj-openworkspace
```

Verificar que foi adicionado:

```bash
claude plugin marketplace list
```

Expected: `aj-openworkspace` na lista com source `GitHub (ajunges/aj-openworkspace)`.

---

## 2. Listar plugins disponíveis

Depois de adicionar o marketplace, ver o catálogo completo:

```bash
# Via sessão interativa
/plugin
```

Os 15 plugins deste marketplace aparecem com sufixo `@aj-openworkspace`. Cada um tem description em português e tags de classificação.

---

## 3. Instalar plugins

### 3.1 Escopos de instalação

Cada install tem um **escopo** que determina onde o plugin fica disponível:

| Escopo | Flag | Settings file | Disponível em | Visível pra outros? | Quando usar |
|---|---|---|---|---|---|
| **user** | `--scope user` (default) | `~/.claude/settings.json` | Todos os repos | Não (só sua máquina) | Plugins que você quer em qualquer lugar |
| **project** | `--scope project` | `.claude/settings.json` do repo | Só neste repo | Sim (vai pro git) | Plugins que o time do projeto deve ter |
| **local** | `--scope local` | `.claude/settings.local.json` | Só neste repo | Não (gitignored) | Testar plugins sem afetar o time |

### 3.2 Instalar globalmente (user — default)

Plugin disponível em qualquer repo da sua máquina:

```bash
# Via CLI
claude plugin install superpowers@aj-openworkspace

# Via sessão interativa
/plugin install superpowers@aj-openworkspace
```

Não precisa de `--scope user` — é o default.

### 3.3 Instalar só neste repo (project — compartilhado com o time)

Plugin fica no `.claude/settings.json` do repo e vai pro git. Qualquer pessoa que clonar o repo e tiver o marketplace adicionado terá o plugin disponível:

```bash
claude plugin install playwright@aj-openworkspace --scope project
```

Use quando o plugin faz sentido especificamente pra aquele codebase (ex: `pyright-lsp` num projeto Python, `playwright` num projeto com testes E2E).

### 3.4 Instalar só neste repo (local — só pra você, gitignored)

Plugin fica no `.claude/settings.local.json` (gitignored). Ninguém do time vê:

```bash
claude plugin install marketing@aj-openworkspace --scope local
```

Use para:
- Testar um plugin novo antes de recomendar pro time
- Plugins que só fazem sentido pra você naquele repo
- Plugins `em-testes` que você quer avaliar sem comprometer

### 3.5 Exemplos por caso de uso

```bash
# Workflow pessoal (quer em todo lugar)
claude plugin install superpowers@aj-openworkspace
claude plugin install commit-commands@aj-openworkspace
claude plugin install code-review@aj-openworkspace

# Projeto Python (time todo precisa)
claude plugin install pyright-lsp@aj-openworkspace --scope project

# Testando plugin novo (só eu, só aqui)
claude plugin install claude-code-setup@aj-openworkspace --scope local
```

---

## 4. Desinstalar plugins

```bash
# Desinstalar do escopo default (user)
claude plugin uninstall superpowers@aj-openworkspace

# Desinstalar de escopo específico
claude plugin uninstall pyright-lsp@aj-openworkspace --scope project
claude plugin uninstall marketing@aj-openworkspace --scope local
```

A desinstalação remove o plugin do escopo indicado. Se o plugin estava instalado em múltiplos escopos, ele permanece nos outros.

Dados persistentes do plugin (`~/.claude/plugins/data/<plugin>-aj-openworkspace/`) são removidos automaticamente quando o último escopo é desinstalado. Para preservar:

```bash
claude plugin uninstall superpowers@aj-openworkspace --keep-data
```

---

## 5. Habilitar e desabilitar (sem desinstalar)

Desabilitar mantém o plugin instalado mas inativo. Reabilitar é instantâneo (sem re-download):

```bash
# Desabilitar temporariamente
claude plugin disable superpowers@aj-openworkspace

# Reabilitar
claude plugin enable superpowers@aj-openworkspace

# Com escopo explícito
claude plugin disable pyright-lsp@aj-openworkspace --scope project
claude plugin enable pyright-lsp@aj-openworkspace --scope project
```

Use quando:
- Um plugin está causando problema e você quer isolar sem perder a configuração
- Quer reduzir carga de plugins numa sessão específica
- Testar se um comportamento vem de um plugin específico

---

## 6. Atualizar plugins

### 6.1 Plugins Level 1 (HEAD — sem SHA pin)

Estes se atualizam automaticamente quando o Claude Code sincroniza o marketplace. Não precisa fazer nada.

Forçar atualização manual:

```bash
claude plugin marketplace update aj-openworkspace
```

### 6.2 Plugins Level 2 (SHA pin)

Estes **não** se atualizam sozinhos — é intencional (estabilidade). Para verificar se há updates e aplicar sob confirmação:

```bash
# Via sessão interativa (requer plugin marketplace-tools instalado)
/check-marketplace-updates
```

O comando verifica cada plugin Level 2 contra o HEAD atual do upstream, mostra diffs, e pergunta plugin-por-plugin: aplicar / skip / detalhar / parar. Cada update vira um commit individual no marketplace.json.

Requer `gh` CLI autenticado e `jq` instalado.

### 6.3 Plugins Level 3 (locais)

Estes vivem no próprio repo. Atualizações são commits diretos no código do plugin (em `./plugins/<nome>/`).

### 6.4 Atualizar um plugin individual

Após o marketplace ser atualizado (passo 6.1 ou 6.2):

```bash
claude plugin update superpowers@aj-openworkspace
```

Requer restart da sessão pra aplicar.

---

## 7. Entender a classificação dos plugins

### 7.1 Níveis de controle (derivado do `source`)

| Nível | Significado | Updates | Risco |
|---|---|---|---|
| **Level 1** | HEAD, sempre atualizado | Automáticos | Update pode quebrar (raro pra tools passivas) |
| **Level 2** | SHA pin, commit fixo | Opt-in via `/check-marketplace-updates` | Estabilidade garantida, mas pode ficar defasado |
| **Level 3** | Código local no repo | Manual (commit direto) | Controle total, manutenção sua |

### 7.2 Status (primeira posição do array `tags`)

| Status | O que significa | O que fazer |
|---|---|---|
| `recomendado` | Uso ativo, confiável, maduro | Instale sem hesitar |
| `em-testes` | Em avaliação, pode mudar | Instale com `--scope local` primeiro |
| `nao-recomendado` | Testei e não compensa | Leia o motivo na `description` antes de ignorar |

### 7.3 Tags livres

Após o status, 2-4 tags descrevem origem, função e domínio:

| Grupo | Exemplos |
|---|---|
| **Origem** | `oficial-anthropic`, `terceiro-oficial`, `comunidade`, `proprio` |
| **Função** | `workflow`, `meta-skills`, `review`, `seguranca`, `mcp`, `lsp`, `integracao` |
| **Domínio** | `git`, `python`, `jira`, `azure`, `docs`, `core`, `solo-dev`, `meta-marketplace` |

---

## 8. Catálogo de plugins

### Level 2 — SHA pin (9 plugins de workflow)

| Plugin | Status | O que faz |
|---|---|---|
| [superpowers](https://github.com/obra/superpowers) | `recomendado` | Skills de brainstorming, TDD, debugging, subagent-driven-development. Base do workflow. |
| [code-review](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review) | `recomendado` | Agent de code review com scoring por confidence. |
| [code-simplifier](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-simplifier) | `recomendado` | Refina código recém-modificado sem mudar comportamento. |
| [commit-commands](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/commit-commands) | `recomendado` | Slash commands `/commit`, `/commit-push-pr`, `/clean_gone`. |
| [feature-dev](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/feature-dev) | `recomendado` | Workflow de dev de features com agents especializados. |
| [skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) | `recomendado` | Meta-skill pra criar, editar e avaliar skills. |
| [claude-md-management](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management) | `recomendado` | Auditar e melhorar CLAUDE.md. |
| [security-guidance](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance) | `recomendado` | Hook que avisa de padrões inseguros ao editar arquivos. |
| [claude-code-setup](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup) | `em-testes` | Analisa codebase e recomenda automações. |

### Level 1 — HEAD (4 plugins passivos)

| Plugin | Status | O que faz |
|---|---|---|
| [github](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/github) | `recomendado` | MCP server oficial do GitHub (repos, issues, PRs). |
| [atlassian](https://github.com/atlassian/atlassian-mcp-server) | `recomendado` | MCP server oficial da Atlassian (Jira + Confluence). |
| [microsoft-docs](https://github.com/microsoftdocs/mcp) | `em-testes` | MCP server de docs Microsoft/Azure. |
| [pyright-lsp](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/pyright-lsp) | `em-testes` | Pyright LSP pra Python. |

### Level 3 — snapshots locais (2 plugins próprios)

| Plugin | Status | O que faz |
|---|---|---|
| [marketplace-tools](../plugins/marketplace-tools) | `recomendado` | `/check-marketplace-updates` — verifica updates dos SHAs Level 2. |
| [sdd-workflow](../plugins/sdd-workflow) | `em-testes` | Playbook de Spec-Driven Development pra solo devs + IA. |

---

## 9. Remover o marketplace

Se não quiser mais usar este marketplace:

```bash
claude plugin marketplace remove aj-openworkspace
```

Isso remove o marketplace da lista mas **não desinstala os plugins já instalados**. Pra limpar tudo:

```bash
# Desinstalar todos os plugins deste marketplace
for plugin in superpowers code-review code-simplifier commit-commands feature-dev skill-creator claude-md-management security-guidance claude-code-setup github atlassian microsoft-docs pyright-lsp marketplace-tools sdd-workflow; do
  claude plugin uninstall "${plugin}@aj-openworkspace" 2>/dev/null
done

# Depois remover o marketplace
claude plugin marketplace remove aj-openworkspace
```

---

## 10. Troubleshooting

| Problema | Causa provável | Solução |
|---|---|---|
| Plugin não aparece após install | Sessão precisa de restart | Sair e reabrir a sessão do Claude Code |
| `Plugin not found in marketplace` | Marketplace não adicionado ou desatualizado | `claude plugin marketplace update aj-openworkspace` |
| Slash command não funciona | Plugin não está enabled | `claude plugin enable <nome>@aj-openworkspace` |
| `gh` commands falham no `/check-marketplace-updates` | gh CLI não autenticado | `gh auth login` |
| Plugin funciona em um repo mas não em outro | Instalado com `--scope project` ou `--scope local` | Reinstalar com `--scope user` pra ter global |

---

## 11. Fontes

- [Doc oficial: Discover and install plugins](https://code.claude.com/docs/en/discover-plugins)
- [Doc oficial: Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Doc oficial: Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Schema do marketplace](https://anthropic.com/claude-code/marketplace.schema.json)
- [Guia de administração deste marketplace](ADMIN.md)
