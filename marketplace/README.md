# Marketplace aj-openworkspace — guia de uso

> Curadoria pessoal de plugins do Claude Code do André Junges.
> 29 plugins (7 Level 2, 18 Level 1, 4 Level 3 próprios), modelo híbrido em 3 níveis, sistema de classificação opinativo.

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
/plugin install hookify@aj-openworkspace --scope local
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
/plugin uninstall hookify@aj-openworkspace --scope local
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

> **Caveat Desktop app (2.1.109+):** regressão conhecida no autocomplete pode ocultar o built-in `/plugin` quando há skills com "plugin" no nome instaladas (ex: `marketplace-tools:publish-plugin`, `plugin-dev:create-plugin`). Se o picker forçar escolha de um sufixo, digite `/plugin` → **Esc** pra dispensar o picker → **Enter** pra submit literal. Alternativa: `claude plugin list` / `claude plugin install` via CLI fora da sessão. Tracking: [#49087](https://github.com/anthropics/claude-code/issues/49087), [#49454](https://github.com/anthropics/claude-code/issues/49454).

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
| `nao-recomendado` | Avaliado e descartado | Leia o motivo na description do plugin |

### 6.3 Tags livres

Após o status, 2-4 tags descrevem origem, função e domínio:

| Grupo | Exemplos |
|---|---|
| **Origem** | `oficial-anthropic`, `terceiro-oficial`, `comunidade`, `proprio` |
| **Função** | `workflow`, `meta-skills`, `review`, `seguranca`, `mcp`, `lsp`, `integracao` |
| **Domínio** | `git`, `python`, `jira`, `azure`, `docs`, `core`, `solo-dev`, `meta-marketplace` |

---

## 7. Catálogo de plugins

Organizado por status (recomendado primeiro). Para o listagem canônica e atualizada, ver [`.claude-plugin/marketplace.json`](../.claude-plugin/marketplace.json).

### 7.1 Recomendado (7 plugins)

Uso ativo confirmado, opinião formada. Instalar sem hesitar.

| Plugin | Nível | O que faz |
|---|---|---|
| [superpowers](https://github.com/obra/superpowers) | L2 | Skills de brainstorming, TDD, debugging, subagent-driven-development. Base do workflow. |
| [code-review](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review) | L2 | Agent de code review com scoring por confidence. |
| [commit-commands](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/commit-commands) | L2 | Slash commands `/commit`, `/commit-push-pr`, `/clean_gone`. |
| [skill-creator](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/skill-creator) | L2 | Meta-skill pra criar, editar e avaliar skills. |
| [claude-md-management](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-md-management) | L2 | Auditar e melhorar CLAUDE.md. |
| [security-guidance](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/security-guidance) | L2 | Hook que avisa de padrões inseguros ao editar arquivos. |
| [marketplace-tools](../plugins/marketplace-tools) | L3 próprio | Toolkit de manutenção do marketplace: `/check-marketplace-updates`, `/validate`, `/publish-plugin`, `/marketplace-qa`, `/restart-desktop`. |

### 7.2 Em testes (22 plugins)

Em avaliação — instalar com `--scope local` antes de promover pro scope `user`. Descriptions resumidas; ver JSON pro texto completo.

**Level 2 — SHA pin (1 plugin):**

| Plugin | O que faz |
|---|---|
| [claude-code-setup](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/claude-code-setup) | Analisa codebase e recomenda automações (hooks/skills/MCPs/subagents). |

**Level 1 — HEAD (18 plugins):**

| Plugin | O que faz |
|---|---|
| [pyright-lsp](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/pyright-lsp) | Pyright LSP pra Python. |
| [explanatory-output-style](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/explanatory-output-style) | Output style com insights educacionais sobre escolhas de implementação. |
| [learning-output-style](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/learning-output-style) | Output style interativo que pede contribuições em pontos de decisão. |
| [hookify](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/hookify) | Cria hooks customizados pra prevenir comportamentos indesejados a partir de padrões da conversa. |
| [session-report](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/session-report) | Relatório HTML explorável de uso da sessão (tokens, cache, subagents). |
| [pr-review-toolkit](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/pr-review-toolkit) | Agents especializados (comments, tests, error handling, type design, code quality). |
| [ralph-loop](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/ralph-loop) | Loops auto-referenciais pra tarefas que rodam até completar (Ralph Wiggum technique). |
| [playground](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/playground) | Playgrounds HTML single-file interativos com controles visuais. |
| [plugin-dev](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/plugin-dev) | Toolkit pra desenvolver plugins (7 skills: hooks, MCP, agents, empacotamento). |
| [mcp-server-dev](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/mcp-server-dev) | Skills pra projetar e construir MCP servers. |
| [agent-sdk-dev](https://github.com/anthropics/claude-plugins-public/tree/main/plugins/agent-sdk-dev) | Kit de desenvolvimento pro Claude Agent SDK. |
| [firecrawl](https://github.com/firecrawl/firecrawl-claude-plugin) | MCP de web scraping/crawling — transforma qualquer site em markdown limpo pra LLM. |
| [remember](https://github.com/Digital-Process-Tools/claude-remember) | Memória contínua com compressão tiered — alternativa à compactação automática. |
| [serena](https://github.com/anthropics/claude-plugins-public/tree/main/external_plugins/serena) | MCP server de análise semântica de código (refactoring, entendimento). |
| [semgrep](https://github.com/semgrep/mcp-marketplace) | SAST em tempo real pra código seguro desde o início. Complementa `security-guidance`. |
| [amplitude](https://github.com/amplitude/mcp-marketplace) | MCP de Amplitude — analista expert pra descobrir oportunidades e analisar coortes. |
| [frontend-design](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/frontend-design) | Interfaces frontend production-grade, evita estéticas genéricas de IA. |
| [context7](https://github.com/anthropics/claude-plugins-official/tree/main/external_plugins/context7) | MCP do Upstash Context7 — docs up-to-date de libraries direto dos repos. |

**Level 3 — próprios (3 plugins):**

| Plugin | O que faz |
|---|---|
| [sdd-workflow](../plugins/sdd-workflow) | Playbook de Spec-Driven Development pra projetos solo gerados 100% por IA. |
| [humanizador](../plugins/humanizador) | Remove sinais de escrita IA em pt-BR (36 padrões, calibração de voz e registro). |
| [portfolio-docs](../plugins/portfolio-docs) | Playbook de portfólio: dossiê canônico em 10 camadas + artefatos downstream (one-pager, battlecard, pitch deck, board update). |

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
