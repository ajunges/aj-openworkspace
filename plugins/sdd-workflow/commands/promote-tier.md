---
description: Invoca sub-skill sdd-promote-tier (sub-fluxo de 11 passos pra promoção/regressão de tier)
---

# /sdd-workflow:promote-tier

Invoca a sub-skill **`sdd-promote-tier`** que executa os 11 passos da Promoção de Tier. Incremental — não recomeça Discovery/Constitution/Requirements/Design.

## Uso

### Sem argumentos (sub-skill faz a pergunta)

```
/sdd-workflow:promote-tier
```

### Com tier alvo (pula a pergunta inicial)

```
/sdd-workflow:promote-tier --alvo mvp
```

Tiers aceitos:

`prototipo_descartavel, uso_interno, mvp, beta_publico, producao_real`

## O que acontece

A sub-skill executa 11 passos (ver `skills/sdd-promote-tier/SKILL.md` no plugin):

1. Reconfirma contexto (lê constitution)
2. Pergunta novo tier (pulado se `--alvo` foi passado)
3. Detecta saltos não-adjacentes (exige justificativa formal mais detalhada)
4. Detecta regressão (raríssima, registra com motivação)
5. Atualiza constitution (YAML + histórico de decisões)
6. Reaviva Pré-spec.Stack (deltas: aplicar agora ou débito técnico)
7. Reaviva Spec.Design parcialmente (deltas)
8. Atualiza tasks.md / cria novos `specs/plans/<feature>-tier-upgrade.md`
9. Reauditoria focada (só dimensões novas obrigatórias)
10. Aplica fixes 🔴/🟡
11. Ship.Deploy se aplicável

## Outputs

- Constitution atualizada
- `specs/plans/<feature>-tier-upgrade.md` pra features novas
- `specs/audit-<data>-tier-upgrade.md` focada nas dimensões novas

## Pré-requisitos

- Projeto SDD existente com `specs/constitution.md` válida (bloco YAML v1.0 com `tipo_projeto`, `tier` e demais campos)
- Se v0.x/v2.x legado (sem bloco YAML completo), oferece migração via sub-skill `sdd-migrate-v1` antes
