---
description: Verifica gate da fase atual; lista critérios atendidos e pendências (não libera automaticamente)
---

# /sdd-workflow:gate

Verifica o **Quality Gate** da fase atual do projeto SDD. Lista os critérios do gate, identifica quais estão atendidos, sinaliza pendências.

**Não libera automaticamente** — aprovação humana ainda é exigida pra avançar pra próxima fase. Este command é diagnóstico, não ação.

## Uso

```
/sdd-workflow:gate
```

## Output

Pra cada item do checklist da fase atual:

- `✅ [item]` — atendido
- `❌ [item]` — pendente
- `📋 [item]` — aceito com justificativa registrada

Resumo final:

```
Gate da fase <fase>:
  ✅ N atendidos
  ❌ M pendentes
  📋 K aceitos com justificativa

Status: [LIBERADO PRA AVANÇAR | BLOQUEADO]
```

Se BLOQUEADO, lista pendentes com sugestão de ação.

## Pré-requisitos

- Projeto SDD com `specs/progress.md` indicando fase atual
