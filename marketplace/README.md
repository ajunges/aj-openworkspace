# Marketplace aj-openworkspace — guia de uso

> Curadoria pessoal de plugins do Claude Code do André Junges.
> 15 plugins, modelo híbrido em 3 níveis, sistema de classificação opinativo.

Este marketplace é uma fonte funcional de instalação de plugins — você adiciona, escolhe o que instalar, e gerencia direto na sessão do Claude Code Desktop. Tudo que está aqui foi testado por alguém que não é desenvolvedor e usa Claude Code pra gerar 100% do código.

Para administração do marketplace (adicionar plugins, atualizar SHAs, criar plugins próprios), veja [ADMIN.md](ADMIN.md).

---

## 1. Adicionar o marketplace

Antes de instalar qualquer plugin, adicione este marketplace ao seu Claude Code. Na sessão do Desktop app, digite:

```
/plugin marketplace add ajunges/aj-openworkspace
```

Pra verificar que foi adicionado:

```
/plugin marketplace list
```

O `aj-openworkspace` deve aparecer na lista.

> **Nota CLI**: se você usa o Claude Code via terminal em vez do Desktop app, o equivalente é `claude plugin marketplace add ajunges/aj-openworkspace`.

---

## 2. Navegar e instalar plugins

### 2.1 Explorar o catálogo

Digite `/plugin` na sessão pra abrir o browser de plugins. Os plugins deste marketplace aparecem com sufixo `@aj-openworkspace`, cada um com description em português e tags de classificação.

### 2.2 Instalar um plugin

Na sessão do Desktop app:

```
/plugin install superpowers@aj-openworkspace
```

Isso instala o plugin no escopo **user** (default) — disponível em qualquer repo da sua máquina, visível só pra você.

### 2.3 Escopos de instalação

Cada install tem um **escopo** que determina onde o plugin fica disponível:

| Escopo | Disponível em | Vai pro git? | Quando usar |
|---|---|---|---|
| **user** (default) | Qualquer repo da sua máquina | Não | Plugins que você quer em todo lugar |
| **project** | Só neste repo | Sim (time vê) | Plugins específicos do projeto que o time deve ter |
| **local** | Só neste repo | Não (gitignored) | Testar plugins sem afetar o time |

Pra instalar com escopo diferente do default:

```
/plugin install pyright-lsp@aj-openworkspace --scope project
/plugin install marketing@aj-openworkspace --scope local
```

### 2.4 Exemplos por caso de uso

**Workflow pessoal (quer em todo lugar)**:

```
/plugin install superpowers@aj-openworkspace
/plugin install commit-commands@aj-openworkspace
/plugin install code-review@aj-openworkspace
```

**Projeto Python (time todo precisa do LSP)**:

```
/plugin install pyright-lsp@aj-openworkspace --scope project
```

**Testando plugin novo (só eu, só aqui)**:

```
/plugin install claude-code-setup@aj-openworkspace --scope local
```

---

## 3. Desinstalar plugins

```
/plugin uninstall superpowers@aj-openworkspace
```

Desinstala do escopo default (user). Pra desinstalar de escopo específico:

```
/plugin uninstall pyright-lsp@aj-openworkspace --scope project
/plugin uninstall marketing@aj-openworkspace --scope local
```

Se o plugin estava em múltiplos escopos, ele permanece nos outros. Dados persistentes do plugin são removidos automaticamente quando o último escopo é desinstalado.

---

## 4. Habilitar e desabilitar (sem desinstalar)

Desabilitar mantém o plugin instalado mas inativo. Reabilitar é instantâneo (sem re-download):

```
/plugin disable superpowers@aj-openworkspace
/plugin enable superpowers@aj-openworkspace
```

Use quando:
- Um plugin está causando problema e você quer isolar sem perder a configuração
- Quer reduzir carga de plugins numa sessão específica
- Testar se um comportamento vem de um plugin específico

---

## 5. Atualizar plugins

O modelo de update do Claude Code é baseado em **refresh do marketplace**, não em comando por plugin. Quando o catálogo sincroniza, os plugins instalados recebem as novas versões automaticamente. Não existe `/plugin update <plugin>` — isso é consequência, não comando.

### 5.1 Ligar auto-update (recomendado)

Marketplaces third-party (como `aj-openworkspace`) vêm com auto-update **desligado** por default — apenas os marketplaces oficiais da Anthropic têm auto-update on. Pra ligar:

1. Roda `/plugin` (sem args) — abre a UI tabbed
2. Vai pra tab **Marketplaces**
3. Seleciona `aj-openworkspace`
4. **Enable auto-update**

Depois disso, todo startup do Claude Code puxa updates do catálogo e aplica nos plugins instalados. Quando algo muda, aparece um prompt pra rodar `/reload-plugins`.

Funciona igual no Desktop e no CLI.

### 5.2 Refresh manual do marketplace

Sem auto-update ligado, pra forçar sync do catálogo:

```
/plugin marketplace update aj-openworkspace
```

Plugins Level 1 e Level 3 recebem as novas versões automaticamente após o refresh. Level 2 só muda se o SHA pinnado no catálogo tiver sido bumpado (ver 5.4).

### 5.3 Plugins Level 1 (HEAD — sem SHA pin)

Se atualizam automaticamente a cada refresh do marketplace (manual ou auto). Não precisa fazer mais nada.

### 5.4 Plugins Level 2 (SHA pin)

Estes **não** mudam quando o marketplace sincroniza — ficam travados no SHA do catálogo. É intencional (estabilidade).

Pra bumpar o SHA e disponibilizar a nova versão aos usuários do marketplace, use o slash command do plugin `marketplace-tools` **na raiz do repo do marketplace**:

```
/check-marketplace-updates
```

O comando verifica cada plugin Level 2 contra o HEAD atual do upstream, mostra diffs (commits + arquivos), e pergunta plugin-por-plugin: aplicar / skip / detalhar / parar. Cada update aceito vira um commit individual no repo do marketplace.

Requer `gh` CLI autenticado (`gh auth status`) e `jq` instalado.

Após o bump ser commitado, usuários instalados recebem a nova versão no próximo refresh do marketplace (auto ou manual via 5.2).

### 5.5 Plugins Level 3 (locais)

Vivem no próprio repo. Atualizações chegam automaticamente a cada refresh do marketplace.

---

## 6. Entender a classificação dos plugins

### 6.1 Níveis de controle

O nível é derivado de como o plugin é referenciado no marketplace — você não precisa configurar nada.

| Nível | Significado | Updates | Quando é usado |
|---|---|---|---|
| **Level 1** | HEAD, sempre atualizado | Automáticos | Tools passivas (MCP servers, LSPs) |
| **Level 2** | SHA pin, commit fixo | Opt-in via `/check-marketplace-updates` | Plugins que injetam skills/hooks/agents |
| **Level 3** | Código local no repo | Via sync do marketplace | Plugins próprios do autor |

### 6.2 Status (primeira tag de cada plugin)

| Status | O que significa | O que fazer |
|---|---|---|
| `recomendado` | Uso ativo, confiável, maduro | Instale sem hesitar |
| `em-testes` | Em avaliação, pode mudar | Instale com `--scope local` pra testar antes |
| `nao-recomendado` | Testei e não compensa | Leia o motivo na description do plugin |

### 6.3 Tags livres

Após o status, 2-4 tags descrevem origem, função e domínio:

| Grupo | Exemplos |
|---|---|
| **Origem** | `oficial-anthropic`, `terceiro-oficial`, `comunidade`, `proprio` |
| **Função** | `workflow`, `meta-skills`, `review`, `seguranca`, `mcp`, `lsp`, `integracao` |
| **Domínio** | `git`, `python`, `jira`, `azure`, `docs`, `core`, `solo-dev`, `meta-marketplace` |

---

## 7. Catálogo de plugins

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

## 8. Remover o marketplace

Se não quiser mais usar este marketplace, na sessão:

```
/plugin marketplace remove aj-openworkspace
```

Isso remove o marketplace da lista mas **não desinstala plugins já instalados**. Pra desinstalar os plugins antes de remover o marketplace, desinstale cada um individualmente (seção 3).

---

## 9. Troubleshooting

| Problema | Causa provável | Solução |
|---|---|---|
| Plugin não aparece após install | Sessão precisa de restart | Sair e reabrir a sessão do Claude Code |
| `Plugin not found in marketplace` | Marketplace não adicionado ou desatualizado | `/plugin marketplace update aj-openworkspace` |
| Slash command não funciona | Plugin não está enabled | `/plugin enable <nome>@aj-openworkspace` |
| `gh` commands falham no `/check-marketplace-updates` | gh CLI não autenticado | Rodar `gh auth login` no terminal |
| Plugin funciona em um repo mas não em outro | Instalado com `--scope project` ou `--scope local` | Reinstalar com escopo user (default) |

---

## 10. Fontes

- [Doc oficial: Discover and install plugins](https://code.claude.com/docs/en/discover-plugins)
- [Doc oficial: Plugin marketplaces](https://code.claude.com/docs/en/plugin-marketplaces)
- [Doc oficial: Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Guia de administração deste marketplace](ADMIN.md)
