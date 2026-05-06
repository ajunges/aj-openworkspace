---
description: Dispara Ship.Audit standalone, fora do fluxo principal. Aceita --dimensoes <lista> pra subset
---

# /sdd-workflow:audit

Dispara a fase **Ship.Audit** standalone, fora do fluxo principal do SDD. Útil pra:

- Auditar projeto existente em qualquer estágio
- Re-rodar audit após correções
- Auditar dimensões específicas sem rodar todas

## Uso

### Audit completa (todas as dimensões obrigatórias do tier)

```
/sdd-workflow:audit
```

### Audit subset (dimensões específicas)

```
/sdd-workflow:audit --dimensoes seguranca,observabilidade
```

Dimensões aceitas (correspondem às 14 dimensões da Ship.Audit):

`seguranca, isolamento, integridade, performance, responsividade, ux, codigo, logica-negocio, acessibilidade, observabilidade, conformidade, doc-operacional, manutenibilidade, defesa-prompt-injection`

Dim 14 (`defesa-prompt-injection`) só roda em projeto com LLM no caminho. Em projeto sem LLM, a dimensão é pulada mesmo se solicitada explicitamente.

## Output

`specs/audit-<YYYY-MM-DD>.md` (formato do `templates/audit.md` da skill principal)

Achados classificados como crítico / importante / melhoria. Críticos bloqueiam Delivery se a Audit é parte do fluxo principal.

## Pré-requisitos

- Projeto SDD com `specs/constitution.md` (pra ler tier alvo)
- Sistema rodando ou disponível pra inspeção
- Skills da Família A (`superpowers:dispatching-parallel-agents` recomendado)

## Skills usadas

- `superpowers:dispatching-parallel-agents` — paraleliza dimensões
- `code-review:code-review` — sub-agente pra dimensão Código
- `security-review` (built-in) — pra dimensão Segurança
- `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`
