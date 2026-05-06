---
name: sdd-migrate-v1
description: >
  Sub-skill do plugin sdd-workflow. Sub-fluxo de migração de projeto SDD v0.x
  pra v1.0.0. Use quando o usuário disser "migrar pra v1.0.0", "atualizar workflow
  SDD", "atualizar constitution pra nova versão", ou variações. Refunda governança
  do projeto pra estrutura de 3 camadas (heurísticas universais + princípios
  arquiteturais por tipo + disciplinas operacionais por tier) e oferece atualizar
  stack default web-saas se aplicável. Migração é opt-in — preserva conteúdo
  existente, marca propostas com `[INFERIDO — confirmar]`.
disable-model-invocation: true
version: 1.0.0
triggers:
  - migrar pra v1.0.0
  - atualizar workflow sdd
  - atualizar constitution
  - migrar workflow
  - migrate v1
  - atualizar pra nova versao do sdd
tags:
  - sdd-sub-fluxo
  - migracao
  - v1
---

# Migração v0.x → v1.0.0 — sub-fluxo do SDD Workflow

Sub-fluxo dedicado pra migrar projeto SDD existente (v0.x) pra v1.0.0. Roda **opt-in** e **incremental**: preserva conteúdo da constitution, propõe ajustes, marca tudo com `[INFERIDO — confirmar]` que o usuário pode aceitar ou rejeitar.

> **Não toca em código do projeto.** Só em `specs/constitution.md`. Migração de stack (se aceita) vira plano de feature normal pelo Build.Implementation.

> **Spec de referência**: `docs/superpowers/specs/sdd-workflow-v1.0.0.md` no repo do plugin (`ajunges/aj-openworkspace`).

---

## Princípios

1. **Preservação de conteúdo**: tudo que existe na constitution v0.x continua existindo. Adições viram seções novas; substituições explicitam o que foi substituído.
2. **Opt-in granular**: usuário pode aceitar parcialmente (ex: refunda governança em 3 camadas mas mantém stack `web-saas` v0.x).
3. **Marcadores explícitos**: cada inferência da IA vira `[INFERIDO — confirmar]`. Usuário valida antes de virar texto definitivo.
4. **Sem migração de código**: o sub-fluxo só atualiza `specs/constitution.md`. Mudanças de stack que afetam código viram features no Build.Implementation com plano dedicado.

---

## Detecção de projeto v0.x

Sinais que indicam projeto v0.x:

- `specs/constitution.md` existe **mas** falta um dos campos novos no YAML inicial: `gates:`, `audiencia:`, `gera_receita:`, `tier_confianca:`, `trade_offs:`
- Constitution menciona "Princípios invioláveis" sem mencionar "Camadas" (Camada 1, 2, 3)
- Não há seção "Emendas" na constitution
- Stack registrada é `Vite + Express + Prisma + Postgres` (stack default v0.x do plugin)
- Frontmatter da constitution não menciona `tier_decidido_em`

A IA roda detecção automaticamente quando invocada num projeto. Se detecta v0.x, oferece migração antes de prosseguir com qualquer fluxo SDD normal (Discovery, Audit, Build, etc.).

---

## Fluxo de 7 passos

### Passo 1 — Reconfirma contexto e detecção

Ler `specs/constitution.md` v0.x. Identificar:

- `tipo_projeto`, `tier`, `tier_decidido_em` (se existirem)
- Stack atual registrada
- Princípios invioláveis listados (8 do v0.x)
- Decisões registradas (seção 9 da constitution v0.x)
- Inventário de dependências
- Alvo de deploy

Apresentar resumo ao usuário e pedir confirmação:

> "Detectei que seu projeto está em SDD v0.x. Pra migrar pra v1.0.0, vou propor:
>  1. Refundar a governança em 3 camadas (heurísticas universais, princípios por tipo, disciplinas por tier)
>  2. Adicionar campos novos no YAML (gates, audiencia, gera_receita, tier_confianca, trade_offs)
>  3. Adicionar seção 'Emendas' (mecanismo de exceção formal a heurísticas)
>  4. Se for `tipo_projeto: web-saas`, oferecer revisar a stack pra default v1.0.0 (Next.js+Supabase+Prisma)
>
> Tudo opt-in. Posso aceitar parcialmente. Continuar?"

Se usuário não confirmar, abortar — projeto v0.x continua funcionando, mas algumas features de v1.0.0 (gates configuráveis, dim 14 da Audit, etc.) ficam inacessíveis.

### Passo 2 — Pergunta campos novos do YAML

Pra cada campo novo, pergunta com default sugerido:

| Campo | Pergunta | Default sugerido |
|---|---|---|
| `gates` | "Que nível de gates entre fases você quer? `explicitos` (default — pausa em todo Quality Gate), `reduzidos` (pausa só entre estágios), `minimos` (pausa só em transições críticas: pré-Build.Implementation, pré-Ship.Delivery, pré-Ship.Deploy)" | `explicitos` |
| `audiencia` | "Audiência principal do produto: `BR` (Brasil-first, Pix), `global` (mercado internacional, Stripe), ou `hibrida` (Stripe + Mercado Pago em paralelo)?" | inferir do conteúdo de Discovery; se ambíguo, perguntar |
| `gera_receita` | "Esse projeto vai gerar receita? `sim`, `nao`, ou `talvez`?" | inferir; se ambíguo, perguntar |
| `tier_confianca` | "Qual sua confiança no tier projetado atual? `alta`, `media` ou `baixa`?" | `media` |
| `trade_offs` | "Tem trade-offs operacionais já decididos? Ex: 'aceito +20% tempo por -50% custo'. Pode deixar vazio agora e preencher depois." | vazio (preencher quando houver caso real) |

Resposta do usuário vira atualização do YAML inicial da constitution.

### Passo 3 — Reescreve seção "Princípios de Desenvolvimento" como "Princípios aplicáveis"

Substituir a seção 3 da constitution v0.x ("Princípios de Desenvolvimento" listando os 8 invioláveis) por "Princípios aplicáveis (governança em 3 camadas)" com:

- Camada 1 — listar as 9 heurísticas (link pra `references/heuristicas.md`)
- Camada 2 — listar princípios do `tipo_projeto` deste projeto (link pra `references/tipos-projeto.md` seção 3.X)
- Camada 3 — listar disciplinas do tier deste projeto, herdando dos tiers anteriores (link pra `references/disciplinas-tier.md`)

Conteúdo dos 8 princípios v0.x preservado mas remapeado conforme spec:

| Princípio v0.x | Destino v1.0.0 |
|---|---|
| 1. Dados reais sempre | H1 |
| 2. Tier projetado | premissa fundadora (preâmbulo) |
| 3. Defensividade externa | H6 |
| 4. Gates explícitos | campo `gates:` no YAML |
| 5. TDD canônico | H9 |
| 6. Decisões registradas | H5 |
| 7. Promoção de tier consciente | mecânica do `sdd-promote-tier` |
| 8. Linguagem ubíqua | H8 |

Marcar a substituição com nota:

> `[INFERIDO — migração v0.x → v1.0.0]`: princípios invioláveis 1-8 mapeados pra Camada 1 (H1, H5, H6, H8, H9) + premissa fundadora (tier projetado) + campo YAML (gates) + mecânica do plugin (promoção de tier). Conteúdo preservado. Confirmar.

### Passo 4 — Adiciona seção "Emendas"

Adicionar seção 10 nova "Emendas (exceções formais a heurísticas e princípios)" com tabela vazia. H5 (Decisões registradas) embute mecanismo de exceção; toda exceção a heurística futura vira entrada aqui.

```markdown
## 10. Emendas (exceções formais a heurísticas e princípios)

H5 (Decisões registradas) embute mecanismo de exceção. Esta seção registra desvios formais a heurísticas (Camada 1), princípios (Camada 2) ou disciplinas (Camada 3).

| Data | Heurística/Princípio/Disciplina afetado | Exceção registrada | Motivação | Backwards compatibility |
|------|---|---|---|---|

(Vazia ao iniciar. Toda exceção a uma heurística vira entrada aqui.)
```

### Passo 5 — Se `tipo_projeto: web-saas`, oferece revisar stack

Apresenta ao usuário:

> "Sua stack atual é v0.x: Vite + Express + Prisma + Postgres + Tailwind + shadcn/ui.
>
> Stack default v1.0.0 (baseada em pesquisa de convergência de mercado): Next.js 16+ App Router + Supabase + Prisma + Tailwind v4 + shadcn/ui CLI v4 + MCP + Resend + Vercel Pro.
>
> Posso:
> 1. Manter stack v0.x — registro como ADR via H5 ('escolha consciente de stack legada')
> 2. Revisar pra stack v1.0.0 — vira plano de feature 'migração de stack' no Build.Implementation
> 3. Revisar parcialmente — escolher quais camadas trocar (ex: ficar com Vite mas trocar Postgres self-managed por Supabase)
>
> Qual?"

**Opção 1**: registra ADR na seção 9 da constitution justificando manutenção da stack v0.x.

**Opção 2**: marca decisão como "migração de stack pendente — criar feature em `specs/plans/migracao-stack-v1.md`". Não executa migração de código aqui.

**Opção 3**: registra ADR pra cada decisão parcial (manter X, trocar Y).

### Passo 6 — Confirma com usuário e aplica

Mostra diff conceitual da constitution antes/depois. Usuário aprova ou ajusta `[INFERIDO]` markers. IA aplica as mudanças no `specs/constitution.md`.

Após aplicação, todos os `[INFERIDO — confirmar]` viram texto definitivo (ou são removidos se usuário rejeitou).

### Passo 7 — Atualiza decisões registradas

Adicionar entrada na seção 9 da constitution:

```markdown
| YYYY-MM-DD | Migração v0.x → v1.0.0 | Refunda governança em 3 camadas; ajustes de YAML; seção Emendas adicionada. Stack: <decisão da Passo 5>. |
```

E pergunta ao usuário se quer commit da mudança no repo do projeto:

> "Constitution atualizada. Quer que eu commite a mudança no repo do projeto? Mensagem sugerida: 'spec: migrar constitution SDD pra v1.0.0 (3 camadas + emendas + ajustes YAML)'"

---

## Outputs

- `specs/constitution.md` atualizado com governança v1.0.0
- Entrada nova na seção 9 (Decisões Registradas) da constitution
- Seção 10 (Emendas) nova, vazia
- Se opção 2 ou 3 da Passo 5: linha em `specs/tasks.md` referenciando "migração de stack" como feature pendente

## Quality Gate Migração

**Quality Gate Migração**: Constitution atualizada com governança v1.0.0 | YAML inicial tem todos os campos novos | Seção 10 "Emendas" presente | Decisão sobre stack registrada (ADR ou plano de migração) | Decisão registrada na seção 9 | Aprovação do usuário no diff final.

---

## Compatibilidade

Projetos que **não migrarem** continuam funcionando com v0.x. Mas perdem acesso a:

- Gates configuráveis (default `explicitos` pra v0.x)
- Dim 14 da Audit (Defesa contra prompt injection)
- Camada 2 inline em `tipos-projeto.md`
- Camada 3 cumulativa em `disciplinas-tier.md`
- H1-H9 e H7.1/H7.2 da Camada 1

Promoção de Tier (sub-skill `sdd-promote-tier`) funciona em ambas as versões — o sub-fluxo dela detecta versão da constitution.

---

## Skills usadas

- `claude-md-management:revise-claude-md` — atualizar `CLAUDE.md` do projeto se aplicável
- `commit-commands:commit` — commit da mudança após aprovação

## Migração legada v2.x → v3.0

Sub-fluxo absorveu também a detecção e migração de projetos v2.x (sem bloco YAML `tipo_projeto`/`tier`) — primeiro migra v2.x → v3.0 (adiciona bloco YAML, reformata tasks.md), depois v3.0 → v1.0.0 (governança em 3 camadas). Salto direto v2.x → v1.0.0 também é suportado.
