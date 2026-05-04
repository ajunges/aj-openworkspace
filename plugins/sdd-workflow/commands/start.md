---
description: Iniciar fluxo SDD Workflow num projeto novo ou retomar projeto existente
---

# /sdd-workflow:start

Atalho pra invocar a skill `sdd-workflow`. Equivalente a digitar "use o workflow SDD" em prosa.

A skill principal é responsável por:

- Detectar se há projeto SDD existente em `specs/` (e qual versão: v0.x/v2.x legado ou v1.0)
- Se não há, iniciar Pré-spec.Discovery
- Se há projeto v1.0, retomar pela fase em andamento (consultar `specs/progress.md`)
- Se há projeto v0.x ou v2.x legado, oferecer migração via sub-skill `sdd-migrate-v1`

## Uso

```
/sdd-workflow:start
```

Sem argumentos. A skill faz as perguntas necessárias.
