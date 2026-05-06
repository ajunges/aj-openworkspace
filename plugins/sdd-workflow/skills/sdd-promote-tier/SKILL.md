---
name: sdd-promote-tier
description: >
  Sub-skill do plugin sdd-workflow. Sub-fluxo de 11 passos pra Promoção de Tier
  em projeto SDD existente. Use quando o usuário disser "promover este projeto pra
  <tier>", "evoluir tier", "agora vai virar prod real", ou variações. Incremental —
  não recomeça Discovery/Constitution/Requirements/Design do zero.
disable-model-invocation: true
version: 1.0.0
triggers:
  - promover este projeto
  - evoluir tier
  - promote tier
  - agora vai virar prod real
  - vamos pra mvp
  - regredir tier
tags:
  - sdd-sub-fluxo
  - tier
  - promocao
---

# Promoção de Tier — sub-fluxo do SDD Workflow

Sub-fluxo dedicado pra mudar `tier` de um projeto SDD existente. Roda **incremental**: aproveita Discovery, Constitution, Requirements, Design originais. Só revisita os deltas (Stack, Design parcial, Audit focada).

> **Ver também** (paths a partir do plugin root, em `plugins/sdd-workflow/`): `skills/sdd-workflow/references/tiers.md` (5 níveis + matriz Audit), `skills/sdd-workflow/references/audit-dimensoes.md` (14 dimensões), `skills/sdd-workflow/references/stacks.md` (variação de stack por tier), `skills/sdd-workflow/references/alvos-deploy.md` (variação de alvo por tier).

---

## Princípios

1. **Incremental, não recomeço**: Discovery, Requirements e Design originais permanecem válidos. Só os deltas são revisitados.
2. **Histórico preservado**: gates do tier antigo ficam congelados como histórico — auditoria 6 meses depois preserva contexto completo.
3. **Decisões formais**: cada promoção/regressão é decisão consciente, registrada com data e motivação.

---

## Fluxo de 11 passos

### Passo 1 — Reconfirma contexto

Ler `specs/constitution.md`. Identificar:

- Tier atual (campo `tier:` no bloco YAML)
- `tipo_projeto`
- Decisões registradas (histórico de tier, alvo de deploy, stack)
- Inventário atual de dependências

### Passo 2 — Pergunta novo tier

Apresentar tiers disponíveis (ver `tiers.md`):

```
1. prototipo_descartavel
2. uso_interno
3. mvp
4. beta_publico
5. producao_real
```

Perguntar:

> "Qual o tier alvo? Por quê? (Captura justificativa formal — vai pra histórico da constitution.)"

### Passo 3 — Detecta saltos não-adjacentes

Se a promoção pula mais de 1 nível (ex: `prototipo_descartavel` → `mvp`, pulando `uso_interno`), exigir justificativa formal mais detalhada.

> "Você está pulando [N] níveis. Por que esse salto e não a promoção incremental? Justificativa formal será registrada."

**Não bloqueia**, força reflexão.

### Passo 4 — Detecta regressão

Se o tier diminui (raríssimo, ex: `producao_real` → `mvp` por redução de escopo), registrar com motivação. Gates do tier antigo congelados como histórico, **não são "descumpridos"**.

> "Você está regredindo de [tier antigo] pra [tier novo]. Os gates já cumpridos ficarão como histórico — não vou desconsiderá-los. Justificativa?"

### Passo 5 — Atualiza constitution

Edit no `specs/constitution.md`:

1. Atualizar campo `tier:` no bloco YAML
2. Atualizar `tier_decidido_em:` pra data atual
3. Atualizar bloco textual da seção 2 (Tier — justificativa) com nova justificativa
4. Adicionar entrada na seção 9 (Decisões Registradas):

```markdown
| YYYY-MM-DD | Promoção de tier: <tier antigo> → <tier novo> | <motivação> |
```

### Passo 6 — Reaviva Pré-spec.Stack

Pra cada delta entre stack atual e stack esperada do novo tier (consultar `skills/sdd-workflow/references/stacks.md`):

> "No tier antigo, [camada X = tecnologia A]. No tier novo, recomendo [tecnologia B] porque [motivo]. Aplicar agora ou aceitar débito técnico?"

Decisões: `aplicar agora` ou `débito técnico` (registrado na constitution).

### Passo 7 — Reaviva Spec.Design parcialmente

Pra cada decisão de design afetada pelo novo tier (escalabilidade, observabilidade, rate limiting, monitoramento, conformidade legal, etc.):

> "[Decisão de design Z] precisa entrar pro tier [novo]. Aplicar agora ou aceitar débito?"

Decisões registradas como aplicar/débito.

### Passo 8 — Atualiza tasks.md / cria novos specs/plans/

Pra cada feature nova decidida nos passos 6-7:

1. Adicionar linha no `specs/tasks.md` (plano-mestre)
2. Criar `specs/plans/<feature>-tier-upgrade.md` usando `superpowers:writing-plans` com 5 ajustes SDD (ver SKILL.md principal)

### Passo 9 — Reauditoria focada

Roda Ship.Audit **apenas** nas dimensões que viraram obrigatórias no novo tier (não reaudita o que já passou e segue válido).

Comparar matriz do tier antigo vs novo (consultar `skills/sdd-workflow/references/tiers.md` seção 3). Dimensões que mudaram de `—`/`opcional`/`perguntar` pra `obrigatório` entram na reauditoria.

Output: `specs/audit-<YYYY-MM-DD>-tier-upgrade.md`.

### Passo 10 — Aplica fixes

Com base nos achados críticos/importantes da reauditoria:

- Críticos: corrigir antes de avançar (bloqueiam Ship.Delivery)
- Importantes: corrigir ou aceitar com justificativa registrada na constitution

### Passo 11 — Ship.Deploy (se aplicável)

Se Ship.Deploy ainda não tinha sido executado e o novo tier exige (ex: protótipo → MVP exige hosting gerenciado), executar agora.

Se alvo mudou (ex: protótipo local → mvp em hosting gerenciado), redeploy pra novo alvo. Ver `skills/sdd-workflow/references/alvos-deploy.md`.

---

## Outputs

- Constitution atualizada (histórico de tier expandido na seção 9)
- `specs/plans/<feature>-tier-upgrade.md` pra features novas (ver `skills/sdd-workflow/templates/plan-feature.md`)
- `specs/audit-<data>-tier-upgrade.md` focada nas dimensões novas obrigatórias

---

## Quality Gate Promoção

**Quality Gate Promoção**: Constitution atualizada com histórico | Deltas de Stack decididos (aplicar / débito) | Deltas de Design decididos | Features novas planejadas (`specs/plans/`) | Reauditoria executada | Achados críticos zerados | Ship.Deploy executado se aplicável | `progress.md` atualizado | Aprovação do usuário.

---

## Skills usadas

- `superpowers:writing-plans` — pra cada feature nova do upgrade
- `superpowers:dispatching-parallel-agents` — na reauditoria focada (paraleliza dimensões)
- Subagentes do Audit (mesmo padrão do Ship.Audit normal)
