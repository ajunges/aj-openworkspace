# Tipos de projeto — catálogo curado

Reference do plugin `sdd-workflow` (v3.0). O `tipo_projeto` registrado na constitution determina stack default sugerida e quais skills domain-específicas (Família B) entram em cena.

## 1. Catálogo (4 tipos)

| Tipo | Resumo |
|---|---|
| `web-saas` | Sistema web full-stack com UI rica |
| `claude-plugin` | Plugin para Claude Code (markdown + JSON, sem build system) |
| `hubspot` | Extensão HubSpot (CLI, custom objects, UI extensions, serverless) |
| `outro` | Stack Decision livre (research na Pré-spec.Stack obrigatório) |

---

## 2. Override sempre permitido

Override é permitido em todos os tipos. O **checkpoint da Pré-spec.Stack** força reflexão crítica sobre particularidades antes de aceitar a default — não é confirmação automática.

---

## 3. Detalhe por tipo

### 3.1 `web-saas`

- **Stack default**: ver `references/stacks.md#web-saas`
- **Skills B**: `frontend-design` (Spec.Design — UI distintiva); condicional: `claude-api`, `agent-sdk-dev:new-sdk-app`
- **Particularidades**:
  - Spec.Design tem seção Mobile-first obrigatória (375/768/1440)
  - Build.Implementation segue ordem típica Infra → Auth+Layout → CRUDs → Lógica → Dashboards → Polish
  - Brand colors definidas na constitution e refletidas no Tailwind config

### 3.2 `claude-plugin`

- **Stack default**: ver `references/stacks.md#claude-plugin`
- **Skills B**: `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin`
- **Particularidades**:
  - Pré-spec.Stack pergunta Level 1, 2 ou 3 (HEAD, SHA pin, local)
  - Spec.Design define quais componentes (commands, skills, hooks, agents, MCP)
  - Build.Implementation TDD = instalar local + testar manualmente; testes automatizados raros, validação via `plugin-validator`
  - **Ship.Audit substitui dimensões 1-7** pelo checklist do `plugin-dev:plugin-validator`. Mantém dimensões 8 (lógica = comportamento do plugin) e 12 (doc operacional = README)

### 3.3 `hubspot`

- **Stack default**: ver `references/stacks.md#hubspot`
- **Skills B**: nenhuma nativa no marketplace — usar guia interno do plugin SDD; `plugin:context7:context7` recomendado pra docs HubSpot atualizadas
- **Particularidades**:
  - Pré-spec.Constitution **exige seção Scopes** (princípio do menor privilégio)
  - Pré-spec.Stack faz inventário explícito de ferramentas (CLI + MCP + acesso a sandbox/prod) e ajusta fluxo conforme disponibilidade
  - Spec.Design tem seções dedicadas: Custom Objects schemas, UI Extensions hierarchy, Serverless endpoints, Webhooks payload contracts
  - Build.Implementation segue padrão HubSpot CLI (`hs project upload`, `hs project deploy`)
  - **Ship.Audit eleva dimensão Segurança ao máximo** — vazamento de token compromete CRM inteiro. Checks específicos: nenhum `hs` token versionado, scopes documentados, sandbox testado antes de prod

### 3.4 `outro`

- **Stack default**: N/A — Pré-spec.Stack faz Stack Decision livre baseada nas particularidades
- **Skills B**: caso a caso, decididas baseado em pesquisa do tipo
- **Particularidades**:
  - Pré-spec.Stack **obrigatoriamente** faz pesquisa de stack/padrões usando `plugin:context7:context7` (docs atualizadas) e/ou WebSearch antes de propor stack
  - Se durante a pesquisa identificar tipo conhecido (ex: "ah, é um MCP server"), oferece adicionar ao catálogo formal e migrar pra ele

---

## 4. Critério pra adicionar tipo novo ao catálogo

**2+ projetos do mesmo tipo nos últimos 6 meses.**

Adição vira tarefa de manutenção do plugin SDD: editar este arquivo, atualizar `references/stacks.md`, atualizar SKILL.md principal, eventualmente novo `references/tipo-X.md` se complexo.
