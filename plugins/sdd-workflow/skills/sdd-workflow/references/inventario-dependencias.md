# Inventário de dependências — checagem na Pré-spec.Stack

Reference do plugin `sdd-workflow` (v3.0). Princípio inviolável 3: **defensividade sobre dependências externas** — não pressupor CLI/MCP/skill/credencial sem inventário formal.

## 1. Quando acontece

Durante a Pré-spec.Stack, junto com a decisão técnica e o alvo de deploy. **3 sub-componentes obrigatórios**:

1. Inventário de dependências (este reference)
2. Stack técnica (`references/stacks.md`)
3. Alvo de deploy (`references/alvos-deploy.md`)

Tudo registrado na constitution como contrato versionado.

---

## 2. Categorias inventariadas

| Categoria | Exemplos | Comportamento se faltar |
|---|---|---|
| **CLI do sistema** | `gh`, `hs` (HubSpot CLI), `docker`, `node`, `python`, `claude` (Claude Code) | Avisar e orientar instalação. Bloquear se essencial pra fase atual; senão registrar e continuar com alternativa |
| **MCP servers** | HubSpot MCP, GitHub MCP, browser MCPs (`mcp__Claude_in_Chrome__*`) | Avisar e oferecer alternativa (ex: WebFetch no lugar de browser MCP) |
| **Skills do marketplace** | `superpowers:*`, `plugin-dev:*`, `marketplace-tools:*`, `frontend-design`, `claude-api`, etc. | Família A (Modo 2) bloqueia se essencial faltar; Famílias B/C/D (Modo 1) registram ausência mas continuam |
| **Acesso a serviços externos** | API keys, tokens, contas (HubSpot portal, OpenAI, etc.) | Bloquear avanço se essencial; registrar como pré-requisito |

---

## 3. Família A é exigência (Modo 2)

A IA inventaria todas as skills da Família A no início da Pré-spec e bloqueia se essenciais faltarem:

- `superpowers:brainstorming` (essencial — Pré-spec.Discovery)
- `superpowers:writing-plans` (essencial — Build.Tasks)
- `superpowers:test-driven-development` (essencial — Build.Implementation)
- `superpowers:executing-plans` ou `superpowers:subagent-driven-development` (pelo menos uma — Build.Implementation)
- `superpowers:verification-before-completion` (essencial)
- `superpowers:systematic-debugging` (essencial)

Opcionais (avisar se faltar mas continuar):
- `superpowers:using-git-worktrees`
- `superpowers:dispatching-parallel-agents`
- `superpowers:requesting-code-review`
- `superpowers:finishing-a-development-branch`

---

## 4. Famílias B/C/D são sugestões (Modo 1)

Famílias B (domain-específicas), C (qualidade/finalização sem `humanizador`) e D (situacionais) são sugeridas conforme contexto. Ausência registrada na constitution como item opcional não atendido. Não bloqueia.

Ver `references/integracao-skills.md` pra detalhe completo das famílias.

---

## 5. Formato de registro na constitution

Bloco YAML adicional ou seção textual no `specs/constitution.md`:

```yaml
inventario:
  cli_essencial:
    - gh         # disponível
    - docker     # disponível
  cli_opcional: []
  mcp_essencial:
    - github-mcp # disponível
  mcp_opcional:
    - hubspot-mcp # AUSENTE — usando API direta como alternativa
  skills_familia_a:
    - superpowers:brainstorming    # disponível
    - superpowers:writing-plans    # disponível
    # ... etc
  servicos_externos:
    - github_token    # disponível em env
    - openai_api_key  # AUSENTE — bloqueado pra feature X
  credenciais:
    - github_token    # disponível
    - stripe_api_key  # AUSENTE — pré-requisito pra fase Pagamentos
```

---

## 6. Regra de bloquear vs. continuar

Resumo da política: **bloquear** quando a dependência ausente impede a fase imediata de avançar. **Registrar e continuar** quando há alternativa viável ou quando a dependência só será necessária em fase futura.

---

## 7. Mudança no inventário ao longo do projeto

Inventário evolui conforme o projeto cresce (novas dependências entram, outras saem). Mudança = decisão registrada com data e motivação no histórico de decisões da constitution.
