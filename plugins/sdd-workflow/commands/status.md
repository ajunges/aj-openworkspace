---
description: Mostra resumo do progresso do projeto SDD atual (read-only)
---

# /sdd-workflow:status

Lê `specs/progress.md` do projeto atual e mostra:

- Estágio atual (Pré-spec / Spec / Build / Ship)
- Fase atual (Discovery, Constitution, Stack, Requirements, Design, Spike, Tasks, Implementation, Audit, Delivery, Deploy)
- Gate atual (atendido ou pendente)
- Features concluídas / total
- Bloqueios ativos
- Histórico de promoções de tier

**Read-only**. Não modifica nada.

## Uso

```
/sdd-workflow:status
```

Output em formato de tabela + status line:

```
📊 [Feature Atual] ([Estágio.Fase]) → Próxima: [Feature Seguinte]
   Progresso: [●●●○○] X% | Concluídas: N/Total | Bloqueios: [Status]
```

## Pré-requisitos

- Projeto SDD com `specs/progress.md` no diretório atual ou parent (busca recursiva limitada)
- Se não encontrar, sugere `/sdd-workflow:start` pra iniciar projeto novo
