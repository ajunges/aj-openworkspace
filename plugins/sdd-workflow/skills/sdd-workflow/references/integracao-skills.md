# Integração com skills externas

Reference do plugin `sdd-workflow` (v3.0). Foco principal da evolução v3.0 (eixo 3 do brainstorming). Modo híbrido por família — A em **Modo 2** (instrução imperativa), demais em **Modo 1** (referência condicional/informativa).

## 1. Modos de integração

| Modo | Significado |
|---|---|
| **Modo 2** (imperativo) | A SKILL.md instrui "agora invoque X". Skill é passo padrão do fluxo. Se essencial não está instalada, IA bloqueia |
| **Modo 1** (referencial) | A SKILL.md sugere "considere usar X aqui". Skill é opcional. Ausência registrada mas não bloqueia |

---

## 2. Família A — Superpowers universais (Modo 2)

| Fase | Skills A invocadas |
|---|---|
| Pré-spec.Discovery | `superpowers:brainstorming` |
| Spec.Spike | `superpowers:test-driven-development`, `superpowers:systematic-debugging` |
| Build.Tasks | `superpowers:writing-plans` (com 5 ajustes de convenção SDD — ver SKILL.md principal) |
| Build.Implementation | `superpowers:executing-plans` ou `:subagent-driven-development` (escolha por quantidade/independência); `:test-driven-development`; `:systematic-debugging`; `:verification-before-completion`; `:using-git-worktrees` (quando feature precisa isolamento); `:dispatching-parallel-agents` (quando subtasks independem) |
| Ship.Audit | `superpowers:requesting-code-review`; `:dispatching-parallel-agents` |
| Ship.Delivery | `superpowers:finishing-a-development-branch` |

---

## 3. Família B — Domain-específicas (Modo 1, condicional por `tipo_projeto`)

Mencionadas como referência quando o tipo se manifesta. Detalhe completo em `references/tipos-projeto.md`.

| `tipo_projeto` | Skills B referenciadas |
|---|---|
| `web-saas` | `frontend-design` (Spec.Design); condicional: `claude-api`, `agent-sdk-dev:new-sdk-app` |
| `claude-plugin` | `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin` |
| `hubspot` | (sem skill nativa) — guia próprio dentro do plugin SDD; MCP `context7` recomendado pra docs HubSpot atualizadas |
| `outro` | livre — usuário invoca o que fizer sentido |

---

## 4. Família C — Qualidade/finalização (Modo 1, **sem `humanizador`**)

| Ponto do fluxo | Skills C referenciadas |
|---|---|
| Build.Implementation | `commit-commands:commit` (substituir commits manuais); `simplify` (depois de bloco grande) |
| Ship.Audit | `code-review:code-review`; `security-review` (dimensão Segurança); `review` |
| Ship.Delivery | `commit-commands:commit-push-pr`; `pr-review-toolkit:review-pr` (se PR aberto) |
| Final de sessão | `claude-md-management:revise-claude-md`; `remember:remember`; `session-report:session-report` |
| Manutenção periódica | `claude-md-management:claude-md-improver` |

**Por que `humanizador` está fora**: o usuário invoca quando quer (skill global). Não faz parte do workflow SDD.

---

## 5. Família D — Situacionais (Modo 1, condicional)

| Quando | Skills D / ferramentas |
|---|---|
| Discovery/Requirements/Design precisam buscar info externa | **1ª escolha (free)**: `WebSearch` + `WebFetch` (built-in). **Páginas dinâmicas/JS**: browser MCPs (`mcp__Claude_in_Chrome__*` / `Kapture` / `Control_Chrome`). **Fallback (pago)**: `firecrawl` (`firecrawl-search`, `:scrape`, `:map`, `:crawl`, `:interact`) — só quando free não resolve |
| Stack ou Design precisam docs atualizadas de lib | MCP `context7` |
| Documento de referência é PDF | `anthropic-skills:pdf` |
| Documento de referência é Excel | `anthropic-skills:xlsx` |
| Documento de referência é Word | `anthropic-skills:docx` |
| Documento de referência é PowerPoint | `anthropic-skills:pptx` |

---

## 6. Checklist de inventário por família (Pré-spec.Stack)

A IA usa este checklist durante o inventário de dependências (ver `references/inventario-dependencias.md`):

**Família A — verificar presença (bloqueia se essencial faltar):**
- [ ] `superpowers:brainstorming`
- [ ] `superpowers:writing-plans`
- [ ] `superpowers:test-driven-development`
- [ ] `superpowers:executing-plans` OU `superpowers:subagent-driven-development`
- [ ] `superpowers:verification-before-completion`
- [ ] `superpowers:systematic-debugging`
- [ ] (opcional) `superpowers:using-git-worktrees`
- [ ] (opcional) `superpowers:dispatching-parallel-agents`
- [ ] (opcional) `superpowers:requesting-code-review`
- [ ] (opcional) `superpowers:finishing-a-development-branch`

**Família B — verificar conforme `tipo_projeto`** (registrar ausência, não bloquear).

**Famílias C/D — não inventariar proativamente.** Mencionar pontualmente no fluxo quando o contexto pedir.

---

## 7. Anti-patterns de integração

- **Invocar skill sem verificar instalação**: Modo 2 especialmente — bloquear early evita frustração no meio do fluxo.
- **Sugerir todas as skills opcionais de uma vez**: overwhelm o usuário. Mencionar apenas quando o momento do fluxo pede.
- **Tratar `humanizador` como parte do SDD**: é decisão estética do usuário, não gate do workflow.
- **Misturar Modo 1 e Modo 2 sem deixar claro**: a distinção imperativo vs. sugestão deve ser explícita na instrução ao usuário.
