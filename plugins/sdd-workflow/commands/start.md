---
description: Iniciar fluxo SDD Workflow num projeto novo ou retomar projeto existente
---

# /sdd-workflow:start

Atalho pra invocar a skill `sdd-workflow`. Equivalente a digitar "use o workflow SDD" em prosa.

A skill principal é responsável por:

- Detectar se há projeto SDD existente em `specs/` (e se está em v2.x ou v3.0)
- Se não há, iniciar Pré-spec.Discovery
- Se há projeto v3.0, retomar pela fase em andamento (consultar `specs/progress.md`)
- Se há projeto v2.x, oferecer migração v2.x → v3.0

## Uso

```
/sdd-workflow:start
```

Sem argumentos. A skill faz as perguntas necessárias.
