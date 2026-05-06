# sdd-workflow — cleanup de emojis + progressive disclosure (implementation plan)

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Aplicar itens 1.1 (cleanup completo de ~50 emojis com convenções textuais estáveis) e 1.2 (split dos 4 estágios da SKILL.md em references por estágio, meta ~250-300 linhas) do BACKLOG do plugin sdd-workflow, em duas fases sequenciais (v1.0.3 e v1.0.4).

**Architecture:** Cleanup mecânico via edits cirúrgicos por contexto (Fase A), depois refactor estrutural movendo o detalhe operacional dos 4 estágios para 4 references novos com pointers explícitos a partir da SKILL principal (Fase B). Cada fase termina com publicação via `/marketplace-tools:publish-plugin` que aplica o workaround dos bugs de cache do Desktop.

**Tech Stack:** Markdown puro (plugin Level 3 do marketplace `aj-openworkspace`), sem build/test runner. "Testes" do plano são `grep` com expectativa de zero matches + `wc -l` para metas de tamanho + smoke test invocando a skill em projeto fictício.

**Spec de origem:** [docs/superpowers/specs/2026-05-05-sdd-workflow-cleanup-e-disclosure-design.md](../specs/2026-05-05-sdd-workflow-cleanup-e-disclosure-design.md)

---

## File structure

### Fase A (v1.0.3) — modifica arquivos existentes

| Arquivo | Tipo de mudança | Categorias de emoji presentes |
|---|---|---|
| `plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md` | Substituir 🔒 (5x) | 🔒 |
| `plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md` | Substituir 🔒 + status | 🔒 ⏸️ 🔄 ✅ ❌ |
| `plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md` | Substituir severity + status | 🔴 🟡 🟢 ❌ ✅ 📋 |
| `plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md` | Substituir status + remover decorativos + 🔒 | 🔒 ✅ 🔄 ⏸️ 📊 ●●●○○ |
| `plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md` | Substituir 🔒 (2x) | 🔒 |
| `plugins/sdd-workflow/skills/sdd-workflow/references/disciplinas-tier.md` | Substituir severity (4x) | 🔴 🟡 |
| `plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md` | Substituir severity (1x) | 🔴 |
| `plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md` | Substituir severity (4x) | 🔴 🟡 🟢 |
| `plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md` | Substituir severity + ✅ (4x) | 🔴 🟡 ✅ |
| `plugins/sdd-workflow/skills/sdd-migrate-v1/SKILL.md` | Remover ✅ Quality Gate (1x) | ✅ |
| `plugins/sdd-workflow/commands/audit.md` | Substituir severity (1x) | 🔴 🟡 🟢 |
| `plugins/sdd-workflow/commands/gate.md` | Substituir status (6x) | ✅ ❌ 📋 |
| `plugins/sdd-workflow/commands/promote-tier.md` | Substituir severity (1x) | 🔴 🟡 |
| `plugins/sdd-workflow/commands/status.md` | Remover decorativos (2x) | 📊 ●●●○○ |
| `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` | Substituir tudo + remover ✅ Quality Gates | 🔒 🔴 🟡 🟢 ✅ |
| `plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md` | Adicionar seção nova (convenções textuais) | — |
| `plugins/sdd-workflow/BACKLOG.md` | Remover decorativos + remover item 1.1 + renumerar | 🟢 🔵 🟣 |
| `plugins/sdd-workflow/.claude-plugin/marketplace.json` (via `publish-plugin`) | Bump version 1.0.2 → 1.0.3 | — |

### Fase B (v1.0.4) — cria 4 references novos + reduz SKILL principal

| Arquivo | Tipo de mudança | Tamanho estimado |
|---|---|---|
| `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-pre-spec.md` | **Criar** (extrair Estágio I) | ~80 linhas |
| `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-spec.md` | **Criar** (extrair Estágio II) | ~65 linhas |
| `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-build.md` | **Criar** (extrair Estágio III) | ~70 linhas |
| `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-ship.md` | **Criar** (extrair Estágio IV) | ~60 linhas |
| `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` | Reescrever seções de estágio (resumo + Quality Gate inline + pointer) + atualizar Apêndice | de 480 → ~270 linhas |
| `plugins/sdd-workflow/BACKLOG.md` | Remover item 1.1 (ex-1.2 antes do cleanup) | — |
| `plugins/sdd-workflow/.claude-plugin/marketplace.json` (via `publish-plugin`) | Bump version 1.0.3 → 1.0.4 | — |

---

## Convenções textuais (referência rápida)

Aplicar consistentemente em **todos** os arquivos da Fase A. Detalhe completo em `seção 4 do spec`.

| Antes | Depois |
|---|---|
| `🔒` em header de task/feature | `[H1]` |
| `🔒` em coluna de tabela (header) | `H1` (sem colchetes) |
| `🔒` em step de plano | `[H1]` ao final |
| `🔒` em prosa narrativa | "validação contra dados reais" (texto natural) |
| `🔒` em mensagem de commit (template) | `[H1]` |
| `🔒` em bullet de instrução de marcação | `[H1]` |
| `🔴 críticos` / `🔴 (críticos)` | `[crítico]` ou "críticos" (texto natural conforme contexto) |
| `🟡 importantes` / `🟡 (importantes)` | `[importante]` ou "importantes" |
| `🟢 melhorias` / `🟢 (melhorias)` | `[melhoria]` ou "melhorias" |
| Coluna de severity em tabela | Texto: `crítico`/`importante`/`melhoria` |
| `**Quality Gate X** ✅:` | `**Quality Gate X**:` (remover ✅) |
| `✅` em lista de status | `[atendido]` |
| `❌` em lista de status | `[pendente]` |
| `📋` em lista de status | `[aceito]` |
| `⏸️` em lista de status | `[aguardando]` |
| `🔄` em lista de status | `[em-andamento]` |
| `📊 [Feature Atual]` | `[Feature Atual]` (remover 📊) |
| `[●●●○○] X%` em status line | `X%` (remover barra ASCII) |
| `## 1. Polish (🟢 — patches)` | `## 1. Polish (patches)` (remover 🟢/🔵/🟣 dos headers do BACKLOG) |

---

# FASE A — v1.0.3 (cleanup completo)

### Task A1: Cleanup template `plan-feature.md`

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md` (linhas 6, 70, 75, 87, 98)

- [ ] **Step 1: Validar estado inicial (test que falha)**

Run: `grep -En "🔒" plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md`
Expected: 5 linhas (6, 70, 75, 87, 98)

- [ ] **Step 2: Aplicar substituições**

Editar o arquivo aplicando estas trocas exatas:

| Linha | Antes | Depois |
|---|---|---|
| 6 | `> 1. Marcação 🔒 em tasks de validação contra dados reais (heurística **H1** — Dados reais sempre)` | `> 1. Marcação `[H1]` em tasks de validação contra dados reais (heurística **H1** — Dados reais sempre)` |
| 70 | `## Task N+1: [Componente seguinte] 🔒 (se exige validação contra dados reais)` | `## Task N+1: [Componente seguinte] [H1] (se exige validação contra dados reais)` |
| 75 | `**Cenário BDD de validação 🔒** (formato Given-When-Then — ver `references/linguagens-especificacao.md`):` | `**Cenário BDD de validação [H1]** (formato Given-When-Then — ver `references/linguagens-especificacao.md`):` |
| 87 | `- [ ] **Step 6: Validação 🔒 contra dados reais**` | `- [ ] **Step 6: Validação contra dados reais [H1]**` |
| 98 | `git commit -m "feat: <descrição> 🔒 validado contra <arquivo>"` | `git commit -m "feat: <descrição> [H1] validado contra <arquivo>"` |

- [ ] **Step 3: Validar estado final (test que passa)**

Run: `grep -En "🔒" plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md`
Expected: zero linhas (vazio)

Run: `grep -cE "\[H1\]" plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md`
Expected: 5

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md
git commit -m "sdd-workflow: cleanup emojis em template plan-feature (item 1.1 BACKLOG)"
```

---

### Task A2: Cleanup template `tasks.md`

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md` (linhas 7, 9, 10, 11, 13, 22, 27, 29, 39, 40)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -cE "🔒|⏸️|🔄|✅|❌" plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md`
Expected: 14+ matches

- [ ] **Step 2: Aplicar substituições**

| Linha | Antes (parte relevante) | Depois |
|---|---|---|
| 7 | cabeçalho de coluna `🔒 (validação dados reais)` | `H1 (validação dados reais)` |
| 9-11 | célula `⏸️ Aguardando` em 3 linhas | `[aguardando]` |
| 13 | `**Legenda de status**: ⏸️ Aguardando · 🔄 Em andamento · ✅ Concluída · ❌ Bloqueada` | `**Legenda de status**: [aguardando] · [em-andamento] · [atendido] · [bloqueada]` |
| 22 | `**Lógica de negócio 🔒**` | `**Lógica de negócio [H1]**` |
| 27 | `## 3. Marcação 🔒 — features de validação contra dados reais` | `## 3. Marcação [H1] — features de validação contra dados reais` |
| 29 | `Features marcadas 🔒 exigem validação` | `Features marcadas [H1] exigem validação` |
| 39 | `- [ ] Se 🔒: comparativo contra dados reais mostrado e aprovado` | `- [ ] Se [H1]: comparativo contra dados reais mostrado e aprovado` |
| 40 | `- [ ] Aprovação humana antes de marcar ✅ e avançar pra próxima` | `- [ ] Aprovação humana antes de marcar [atendido] e avançar pra próxima` |

- [ ] **Step 3: Validar estado final**

Run: `grep -cE "🔒|⏸️|🔄|✅|❌" plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md`
Expected: 0

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md
git commit -m "sdd-workflow: cleanup emojis em template tasks (item 1.1 BACKLOG)"
```

---

### Task A3: Cleanup template `audit.md`

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md` (linhas 15-28, 34, 41, 43, 50, 52, 63-65, 69)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -cE "🔴|🟡|🟢|✅|❌|📋" plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md`
Expected: 20+ matches

- [ ] **Step 2: Aplicar substituições**

Coluna de severity da tabela (linhas 15-28): substituir cada `🟢` por `melhoria`, `🟡` por `importante`, `🔴` por `crítico` na coluna correspondente.

Exemplos:

| Linha | Antes | Depois |
|---|---|---|
| 15 | `\| 1 \| Segurança \| obrigatório \| 🟢 \| 0 \|` | `\| 1 \| Segurança \| obrigatório \| melhoria \| 0 \|` |
| 17 | `\| 3 \| Integridade dados \| obrigatório \| 🟡 \| 2 \|` | `\| 3 \| Integridade dados \| obrigatório \| importante \| 2 \|` |
| 20 | `\| 6 \| UX/Layout \| obrigatório \| 🔴 \| 1 \|` | `\| 6 \| UX/Layout \| obrigatório \| crítico \| 1 \|` |

Headers de seção (linhas 34, 43, 52):

| Linha | Antes | Depois |
|---|---|---|
| 34 | `## 3. Achados 🔴 críticos (bloqueiam Delivery)` | `## 3. Achados críticos (bloqueiam Delivery)` |
| 43 | `## 4. Achados 🟡 importantes` | `## 4. Achados importantes` |
| 52 | `## 5. Achados 🟢 melhorias (nice-to-have)` | `## 5. Achados melhorias (nice-to-have)` |

Status em linhas 41, 50:

| Linha | Antes | Depois |
|---|---|---|
| 41 | `- **Status**: ❌ pendente` | `- **Status**: [pendente]` |
| 50 | `- **Status**: ❌ pendente \| ✅ corrigido \| 📋 aceito com justificativa` | `- **Status**: [pendente] \| [corrigido] \| [aceito]` |

Resumo (linhas 63-65, 69):

| Linha | Antes | Depois |
|---|---|---|
| 63 | `- 🔴 críticos: 1 — **bloqueia Delivery**` | `- Críticos: 1 — **bloqueia Delivery**` |
| 64 | `- 🟡 importantes: 7 (1 corrigido, 6 pendentes)` | `- Importantes: 7 (1 corrigido, 6 pendentes)` |
| 65 | `- 🟢 melhorias: 0` | `- Melhorias: 0` |
| 69 | `→ Corrigir 🔴 críticos antes de Ship.Delivery. 🟡 podem ser aceitos com justificativa registrada na constitution.` | `→ Corrigir críticos antes de Ship.Delivery. Importantes podem ser aceitos com justificativa registrada na constitution.` |

- [ ] **Step 3: Validar estado final**

Run: `grep -cE "🔴|🟡|🟢|✅|❌|📋" plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md`
Expected: 0

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md
git commit -m "sdd-workflow: cleanup emojis em template audit (item 1.1 BACKLOG)"
```

---

### Task A4: Cleanup template `progress.md`

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md` (linhas 9-19, 23, 25-27, 34-35)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -cE "🔒|✅|🔄|⏸️|📊|●●●○○" plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md`
Expected: 18+ matches

- [ ] **Step 2: Aplicar substituições**

Tabela de fases (linhas 9-19): substituir células `✅` por `[atendido]`, `🔄 Em andamento` por `[em-andamento]`, `⏸️ Aguardando` por `[aguardando]`.

Exemplos:

| Linha | Antes | Depois |
|---|---|---|
| 9 | `\| Pré-spec \| Discovery \| ✅ \| ✅ \|` | `\| Pré-spec \| Discovery \| [atendido] \| [atendido] \|` |
| 13 | `\| Spec \| Design \| 🔄 Em andamento \| — \|` | `\| Spec \| Design \| [em-andamento] \| — \|` |
| 14 | `\| Spec \| Spike (opcional) \| ⏸️ Aguardando \| — \|` | `\| Spec \| Spike (opcional) \| [aguardando] \| — \|` |

Cabeçalho de coluna 🔒 (linha 23):

| Linha | Antes | Depois |
|---|---|---|
| 23 | `\| # \| Feature \| Plano \| 🔒 \| Status \| Progresso \| Bloqueios \|` | `\| # \| Feature \| Plano \| H1 \| Status \| Progresso \| Bloqueios \|` |

Células de status em features (linhas 25-27):

| Linha | Antes | Depois |
|---|---|---|
| 25 | `\| 1 \| [Feature 1] \| `specs/plans/01-...md` \| não \| ✅ \| 100% \| — \|` | `\| 1 \| [Feature 1] \| `specs/plans/01-...md` \| não \| [atendido] \| 100% \| — \|` |
| 26 | `\| 2 \| [Feature 2] \| `specs/plans/02-...md` \| sim \| 🔄 \| 60% \| — \|` | `\| 2 \| [Feature 2] \| `specs/plans/02-...md` \| sim \| [em-andamento] \| 60% \| — \|` |
| 27 | `\| 3 \| [Feature 3] \| `specs/plans/03-...md` \| não \| ⏸️ \| 0% \| Depende: Feature 2 \|` | `\| 3 \| [Feature 3] \| `specs/plans/03-...md` \| não \| [aguardando] \| 0% \| Depende: Feature 2 \|` |

Status line decorativa (linhas 34-35):

| Linha | Antes | Depois |
|---|---|---|
| 34 | `📊 [Feature Atual] ([Estágio.Fase]) → Próxima: [Feature Seguinte]` | `[Feature Atual] ([Estágio.Fase]) → Próxima: [Feature Seguinte]` |
| 35 | `   Progresso: [●●●○○] X% \| Concluídas: N/Total \| Bloqueios: [Status]` | `   Progresso: X% \| Concluídas: N/Total \| Bloqueios: [Status]` |

- [ ] **Step 3: Validar estado final**

Run: `grep -cE "🔒|✅|🔄|⏸️|📊|●●●○○" plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md`
Expected: 0

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md
git commit -m "sdd-workflow: cleanup emojis em template progress (item 1.1 BACKLOG)"
```

---

### Task A5: Cleanup references temáticas (4 arquivos)

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md` (linhas 69, 78)
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/references/disciplinas-tier.md` (linhas 173, 177, 178, 229)
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md` (linha 49)
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md` (linhas 102, 104, 107, 110)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -cE "🔒|🔴|🟡|🟢" plugins/sdd-workflow/skills/sdd-workflow/references/{linguagens-especificacao,disciplinas-tier,tiers,audit-dimensoes}.md`
Expected: 11 matches total

- [ ] **Step 2: Aplicar substituições em `linguagens-especificacao.md`**

| Linha | Antes | Depois |
|---|---|---|
| 69 | `**Quando usar**: Build.Tasks 🔒 (cenários de teste com dados específicos), e Ship.Audit dimensão 8 (Lógica de negócio).` | `**Quando usar**: Build.Tasks [H1] (cenários de teste com dados específicos), e Ship.Audit dimensão 8 (Lógica de negócio).` |
| 78 | `### 2.2 Exemplo (Build.Tasks 🔒 — validação contra dados reais)` | `### 2.2 Exemplo (Build.Tasks [H1] — validação contra dados reais)` |

- [ ] **Step 3: Aplicar substituições em `disciplinas-tier.md`**

| Linha | Antes | Depois |
|---|---|---|
| 173 | `Todas as dimensões obrigatórias pelo tier (matriz em `references/tiers.md`) executadas no Audit. Achados 🔴 zerados antes de Ship.Delivery.` | `Todas as dimensões obrigatórias pelo tier (matriz em `references/tiers.md`) executadas no Audit. Achados críticos zerados antes de Ship.Delivery.` |
| 177 | `- Achados 🔴 (críticos) zerados` | `- Achados críticos zerados` |
| 178 | `- Achados 🟡 (importantes) corrigidos ou aceitos via H5 (ADR)` | `- Achados importantes corrigidos ou aceitos via H5 (ADR)` |
| 229 | `Disciplina ausente sem ADR registrado vira achado 🔴 (crítico) na Audit do tier que a exige.` | `Disciplina ausente sem ADR registrado vira achado crítico na Audit do tier que a exige.` |

- [ ] **Step 4: Aplicar substituições em `tiers.md`**

| Linha | Antes | Depois |
|---|---|---|
| 49 | `- `obrigatório`: gate falha sem cobertura. Achados 🔴 bloqueiam Delivery.` | `- `obrigatório`: gate falha sem cobertura. Achados críticos bloqueiam Delivery.` |

- [ ] **Step 5: Aplicar substituições em `audit-dimensoes.md`**

| Linha | Antes | Depois |
|---|---|---|
| 102 | `[lista com 🟢/🟡/🔴 por dimensão]` | `[lista com melhoria/importante/crítico por dimensão]` |
| 104 | `## Achados 🔴 críticos (bloqueiam Delivery)` | `## Achados críticos (bloqueiam Delivery)` |
| 107 | `## Achados 🟡 importantes` | `## Achados importantes` |
| 110 | `## Achados 🟢 melhorias` | `## Achados melhorias` |

- [ ] **Step 6: Validar estado final**

Run: `grep -cE "🔒|🔴|🟡|🟢" plugins/sdd-workflow/skills/sdd-workflow/references/{linguagens-especificacao,disciplinas-tier,tiers,audit-dimensoes}.md`
Expected: 0

- [ ] **Step 7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/{linguagens-especificacao,disciplinas-tier,tiers,audit-dimensoes}.md
git commit -m "sdd-workflow: cleanup emojis em references temáticas (item 1.1 BACKLOG)"
```

---

### Task A6: Cleanup sub-skills + commands (6 arquivos)

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md` (linhas 126, 128, 129, 149)
- Modify: `plugins/sdd-workflow/skills/sdd-migrate-v1/SKILL.md` (linha 188)
- Modify: `plugins/sdd-workflow/commands/audit.md` (linha 37)
- Modify: `plugins/sdd-workflow/commands/gate.md` (linhas 21-23, 29-31)
- Modify: `plugins/sdd-workflow/commands/promote-tier.md` (linha 40)
- Modify: `plugins/sdd-workflow/commands/status.md` (linhas 27, 28)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -rcE "🔒|🔴|🟡|🟢|✅|❌|📋|⏸️|🔄|📊|●●●○○" plugins/sdd-workflow/skills/sdd-promote-tier plugins/sdd-workflow/skills/sdd-migrate-v1 plugins/sdd-workflow/commands`
Expected: agregado >= 16 matches

- [ ] **Step 2: Aplicar substituições em `sdd-promote-tier/SKILL.md`**

| Linha | Antes | Depois |
|---|---|---|
| 126 | `Com base nos achados 🔴/🟡 da reauditoria:` | `Com base nos achados críticos/importantes da reauditoria:` |
| 128 | `- 🔴 críticos: corrigir antes de avançar (bloqueiam Ship.Delivery)` | `- Críticos: corrigir antes de avançar (bloqueiam Ship.Delivery)` |
| 129 | `- 🟡 importantes: corrigir ou aceitar com justificativa registrada na constitution` | `- Importantes: corrigir ou aceitar com justificativa registrada na constitution` |
| 149 | `**Quality Gate Promoção** ✅: Constitution atualizada... Achados 🔴 zerados...` | `**Quality Gate Promoção**: Constitution atualizada... Achados críticos zerados...` |

- [ ] **Step 3: Aplicar substituição em `sdd-migrate-v1/SKILL.md`**

| Linha | Antes | Depois |
|---|---|---|
| 188 | `**Quality Gate Migração** ✅: Constitution atualizada...` | `**Quality Gate Migração**: Constitution atualizada...` |

- [ ] **Step 4: Aplicar substituição em `commands/audit.md`**

| Linha | Antes | Depois |
|---|---|---|
| 37 | `Achados classificados 🔴 / 🟡 / 🟢. 🔴 bloqueiam Delivery se a Audit é parte do fluxo principal.` | `Achados classificados como crítico / importante / melhoria. Críticos bloqueiam Delivery se a Audit é parte do fluxo principal.` |

- [ ] **Step 5: Aplicar substituições em `commands/gate.md`**

| Linha | Antes | Depois |
|---|---|---|
| 21 | `- `✅ [item]` — atendido` | `- `[atendido] [item]`` |
| 22 | `- `❌ [item]` — pendente` | `- `[pendente] [item]`` |
| 23 | `- `📋 [item]` — aceito com justificativa registrada` | `- `[aceito] [item]` — aceito com justificativa registrada` |
| 29 | `  ✅ N atendidos` | `  N atendidos` |
| 30 | `  ❌ M pendentes` | `  M pendentes` |
| 31 | `  📋 K aceitos com justificativa` | `  K aceitos com justificativa` |

- [ ] **Step 6: Aplicar substituição em `commands/promote-tier.md`**

| Linha | Antes | Depois |
|---|---|---|
| 40 | `10. Aplica fixes 🔴/🟡` | `10. Aplica fixes críticos/importantes` |

- [ ] **Step 7: Aplicar substituições em `commands/status.md`**

| Linha | Antes | Depois |
|---|---|---|
| 27 | `📊 [Feature Atual] ([Estágio.Fase]) → Próxima: [Feature Seguinte]` | `[Feature Atual] ([Estágio.Fase]) → Próxima: [Feature Seguinte]` |
| 28 | `   Progresso: [●●●○○] X% \| Concluídas: N/Total \| Bloqueios: [Status]` | `   Progresso: X% \| Concluídas: N/Total \| Bloqueios: [Status]` |

- [ ] **Step 8: Validar estado final**

Run: `grep -rcE "🔒|🔴|🟡|🟢|✅|❌|📋|⏸️|🔄|📊|●●●○○" plugins/sdd-workflow/skills/sdd-promote-tier plugins/sdd-workflow/skills/sdd-migrate-v1 plugins/sdd-workflow/commands`
Expected: 0 matches em cada arquivo

- [ ] **Step 9: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-promote-tier/ plugins/sdd-workflow/skills/sdd-migrate-v1/ plugins/sdd-workflow/commands/
git commit -m "sdd-workflow: cleanup emojis em sub-skills e commands (item 1.1 BACKLOG)"
```

---

### Task A7: Cleanup SKILL principal `sdd-workflow/SKILL.md`

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` (linhas 11, 134, 166, 202, 218, 239, 263, 283, 298, 307, 309, 317, 323, 338, 367, 370, 376, 384, 403)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -cE "🔒|🔴|🟡|🟢|✅" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 22+ matches

- [ ] **Step 2: Substituir 🔒 (frontmatter + corpo)**

| Linha | Antes | Depois |
|---|---|---|
| 11 | `Requirements + BDD pra Tasks 🔒, integração com superpowers (Modo 2), TDD canônico` | `Requirements + BDD pra Tasks [H1], integração com superpowers (Modo 2), TDD canônico` |
| 298 | `4. **Lógica de negócio 🔒** (cálculos, validações — validação obrigatória contra dados reais)` | `4. **Lógica de negócio [H1]** (cálculos, validações — validação obrigatória contra dados reais)` |
| 307 | `- Indicar 🔒 se exige validação contra dados reais` | `- Marcar com [H1] se exige validação contra dados reais` |
| 317 | `1. **Marcação 🔒** — header de task `### Task N: [Component] 🔒` ou step extra `- [ ] **Step X: 🔒 Validar contra dados reais**` antes do commit` | `1. **Marcação [H1]** — header de task `### Task N: [Component] [H1]` ou step extra `- [ ] **Step X: validar contra dados reais [H1]**` antes do commit` |
| 323 | `2. **Cenário BDD pra tasks 🔒** (validação contra dados reais) — formato Given/When/Then com dados reais específicos` | `2. **Cenário BDD pra tasks [H1]** (validação contra dados reais) — formato Given/When/Then com dados reais específicos` |
| 338 | `5. **Quality Gate por feature** ✅ ... Se 🔒: comparativo contra dados reais mostrado e aprovado ... progress.md marcado ✅.` | `5. **Quality Gate por feature** ... Se [H1]: comparativo contra dados reais mostrado e aprovado ... progress.md marcado [atendido].` |
| 309 | `**Quality Gate Tasks** ✅: ... Features 🔒 identificadas ...` | `**Quality Gate Tasks**: ... Features [H1] identificadas ...` |

- [ ] **Step 3: Remover ✅ dos cabeçalhos de Quality Gates**

Substituir em cada uma destas linhas: `**Quality Gate X** ✅:` → `**Quality Gate X**:`

Linhas afetadas: 134 (nota geral), 166 (Discovery), 202 (Constitution), 218 (Stack), 239 (Requirements), 263 (Design), 283 (Spike), 309 (Tasks — já tratada na step 2), 338 (por feature — já tratada), 370 (Audit), 384 (Delivery), 403 (Deploy).

A linha 134 tem o termo dentro de prosa: `cada gate ✅ pausa conforme o modo` → `cada Quality Gate pausa conforme o modo` (substituição contextual).

- [ ] **Step 4: Substituir severity (🔴/🟡/🟢)**

| Linha | Antes | Depois |
|---|---|---|
| 367 | `Achados classificados 🔴 (críticos — bloqueiam Delivery), 🟡 (importantes), 🟢 (melhorias).` | `Achados classificados em críticos (bloqueiam Delivery), importantes e melhorias.` |
| 370 | `Achados 🔴 zerados ou tratados antes de avançar \| Achados 🟡 corrigidos ou aceitos com justificativa registrada` | `Achados críticos zerados ou tratados antes de avançar \| Achados importantes corrigidos ou aceitos com justificativa registrada` |
| 376 | `1. **Aplicar fixes** dos achados 🔴 e 🟡 da Audit` | `1. **Aplicar fixes** dos achados críticos e importantes da Audit` |
| 384 | `**Quality Gate Delivery** ... Zero 🔴 da Audit ...` | `**Quality Gate Delivery**: Zero achados críticos da Audit ...` |

- [ ] **Step 5: Validar estado final**

Run: `grep -cE "🔒|🔴|🟡|🟢|✅" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 0

Run: `grep -cE "\[H1\]" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 7+ (frontmatter + 6 referências em prosa/headers)

- [ ] **Step 6: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: cleanup emojis em SKILL principal (item 1.1 BACKLOG)"
```

---

### Task A8: Adicionar seção de convenções textuais em `heuristicas.md`

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md` (adicionar seção ao final)

- [ ] **Step 1: Ler o arquivo atual pra identificar o ponto de inserção**

Run: `tail -20 plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md`
Confirmar onde termina o conteúdo atual (linha 166 segundo o `wc -l` original).

- [ ] **Step 2: Adicionar seção nova ao final**

Conteúdo a anexar:

```markdown

---

## Convenções textuais (anchors estáveis)

Substitutos textuais para anchors visuais que apareciam como emoji em versões anteriores do plugin (até v1.0.2). IA usa estes prefixos como marcadores estáveis em scanning rápido. Convenção é fixa — não inventar variantes.

### `[H1]` — Marcação de validação contra dados reais

Aparece em headers de task/feature, steps de plano detalhado, mensagens de commit e bullets de instrução de marcação. Referência direta à heurística H1 (Dados reais sempre).

| Contexto | Exemplo |
|---|---|
| Header de task | `### Task 5: Cálculo de comissão [H1]` |
| Step de plano | `- [ ] **Step 6: validar contra dados reais [H1]**` |
| Coluna de tabela (header) | `\| # \| Feature \| Plano \| H1 \| Status \|` (sem colchetes em cabeçalhos de tabela, por concisão) |
| Mensagem de commit | `feat: cálculo de comissão [H1] validado contra planilha-q1.xlsx` |
| Bullet de instrução | `- Marcar com [H1] se exige validação contra dados reais` |

Em prosa narrativa (sem necessidade de anchor), usar texto natural: "exige validação contra dados reais".

### `[crítico]` / `[importante]` / `[melhoria]` — Severity de achados na Audit

Aparece em listas/resumos de achados na Ship.Audit. Em prosa narrativa, usar texto natural ("Achados críticos zerados antes de Delivery").

| Contexto | Exemplo |
|---|---|
| Lista de achados | `- [crítico] UX/Layout: navegação mobile quebrada` |
| Coluna de severity em tabela | `\| 6 \| UX/Layout \| obrigatório \| crítico \| 1 \|` (texto natural em células) |
| Resumo agregado | `Críticos: 1 — bloqueia Delivery; Importantes: 7; Melhorias: 0` |

### `[atendido]` / `[pendente]` / `[aceito]` / `[aguardando]` / `[em-andamento]` — Status

Aparece em listas de status de gates, features e promoções. **Conjunto base** — contextos específicos podem usar variantes (`[bloqueada]` em features com dependência não resolvida; `[corrigido]` em fixes de achados da Audit). Variantes seguem o mesmo padrão `[palavra-curta-em-minusculas]`.

| Contexto | Exemplo |
|---|---|
| Status de feature | `\| 2 \| [Feature 2] \| sim \| [em-andamento] \| 60% \|` |
| Resultado de Quality Gate | `[atendido] Bloco YAML preenchido` |
| Status de fix de achado | `**Status**: [pendente] \| [corrigido] \| [aceito]` |
| Feature com dependência | `\| 4 \| [Feature 4] \| sim \| [bloqueada] \| 0% \| Depende: Feature 3 \|` |

### Quality Gates (sem prefixo)

Antes da v1.0.3, Quality Gates eram marcados com `✅` no cabeçalho. A partir da v1.0.3, o cabeçalho `**Quality Gate X**:` é o anchor — o nome do gate já é a referência.
```

- [ ] **Step 3: Validar estado final**

Run: `grep -c "Convenções textuais" plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md`
Expected: 1

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md`
Expected: ~210 linhas (era 166 + ~44 da seção nova)

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/heuristicas.md
git commit -m "sdd-workflow: documentar convenções textuais [H1]/[crítico]/[atendido] em heuristicas (item 1.1 BACKLOG)"
```

---

### Task A9: Cleanup BACKLOG (decorativos + remoção do item 1.1)

**Files:**
- Modify: `plugins/sdd-workflow/BACKLOG.md` (linhas 9, 20, 60 + linha 15 do item 1.1 + renumeração)

- [ ] **Step 1: Validar estado inicial**

Run: `grep -nE "## .*(🟢|🔵|🟣)" plugins/sdd-workflow/BACKLOG.md`
Expected: 3 linhas (9, 20, 60)

- [ ] **Step 2: Remover decorativos dos cabeçalhos de seção**

| Linha | Antes | Depois |
|---|---|---|
| 9 | `## 1. Polish (🟢 — patches v1.0.x)` | `## 1. Polish (patches v1.0.x)` |
| 20 | `## 2. Roadmap v4.0 (🔵 — minor/major bumps)` | `## 2. Roadmap v4.0 (minor/major bumps)` |
| 60 | `## 4. Inspirações do Spec Kit a digerir (🟣 — pesquisa, não TODO ativo)` | `## 4. Inspirações do Spec Kit a digerir (pesquisa, não TODO ativo)` |

- [ ] **Step 3: Remover linha do item 1.1 (cleanup de emojis — agora aplicado) + renumerar 1.2 → 1.1**

Localizar tabela de polish (linhas ~13-17 atualmente):

- Remover linha começando com `| 1.1 | Cleanup de emojis no plugin alinhado a preferência global "zero emojis"...`
- Mudar próxima linha de `| 1.2 | Otimizar tamanho da `SKILL.md` principal — 480 linhas...` para `| 1.1 | Otimizar tamanho da `SKILL.md` principal — 480 linhas...`

- [ ] **Step 4: Atualizar nota "Atualizado em" (linha 5)**

| Antes | Depois |
|---|---|
| `Atualizado em: 2026-05-05 (pós-v1.0.2 — polish 1.1 (refresh do README.md pós-v1.0.0) aplicado em commits 3426b65/30ef2a7 e removido da tabela; ex-polish 1.2 (cleanup de emojis) renumerado pra 1.1; ex-polish 1.3 (otimizar SKILL.md principal — 480 linhas) renumerado pra 1.2; seção 4.4 (lacunas pra brainstormar 4.1.3-4.1.6) e itens 4.1.x permanecem pendentes).` | `Atualizado em: 2026-05-05 (pós-v1.0.3 — polish 1.1 (cleanup de emojis no plugin alinhado a "zero emojis") aplicado e removido; ex-polish 1.2 (otimizar SKILL.md principal — 480 linhas) renumerado pra 1.1; convenções textuais [H1]/[crítico]/[atendido] documentadas em references/heuristicas.md; seção 4.4 e itens 4.1.x permanecem pendentes).` |

- [ ] **Step 5: Validar estado final**

Run: `grep -cE "🔒|🔴|🟡|🟢|✅|❌|📋|⏸️|🔄|📊|●●●○○|🔵|🟣" plugins/sdd-workflow/BACKLOG.md`
Expected: 0

Run: `grep -E "^\| 1\." plugins/sdd-workflow/BACKLOG.md`
Expected: 1 linha começando com `| 1.1 | Otimizar tamanho da SKILL.md...`

- [ ] **Step 6: Commit**

```bash
git add plugins/sdd-workflow/BACKLOG.md
git commit -m "sdd-workflow: cleanup emojis no BACKLOG + remover item 1.1 aplicado (renumerar 1.2 → 1.1)"
```

---

### Task A10: Smoke test global + publish v1.0.3

**Files:**
- Read-only: todo o plugin (validação)
- Modify (via publish-plugin): `.claude-plugin/marketplace.json` (bump version)

- [ ] **Step 1: Smoke test — zero emojis no plugin inteiro**

Run: `grep -rcE "🔒|🔴|🟡|🟢|✅|❌|📋|⏸️|🔄|📊|●●●○○|🔵|🟣" plugins/sdd-workflow/ | grep -v ":0$" | grep -v BACKLOG`
Expected: vazio (zero arquivos com matches)

Notar: `BACKLOG.md` já foi tratado na Task A9 e deveria também retornar 0; o filtro só serve pra debugging caso alguma linha residual escape.

- [ ] **Step 2: Smoke test — convenções `[H1]` presentes nos arquivos esperados**

Run: `grep -lE "\[H1\]" plugins/sdd-workflow/`
Expected: pelo menos `SKILL.md`, `templates/plan-feature.md`, `templates/tasks.md`, `templates/progress.md`, `references/linguagens-especificacao.md`, `references/heuristicas.md`

- [ ] **Step 3: Smoke test — invocar a skill em projeto fictício**

Criar projeto fictício temporário e invocar status:

```bash
mkdir -p /tmp/sdd-smoke-test/specs
cd /tmp/sdd-smoke-test
echo "---" > specs/progress.md
echo "Pré-spec.Discovery: [em-andamento]" >> specs/progress.md
```

Em sessão Claude Code, rodar `/sdd-workflow:status` e confirmar:
- Output mostra estado sem nenhum emoji
- `[em-andamento]` é interpretado corretamente como anchor textual

- [ ] **Step 4: Publish via marketplace-tools**

Em sessão Claude Code:

```
/marketplace-tools:publish-plugin sdd-workflow patch
```

O command vai:
1. Bumpar version 1.0.2 → 1.0.3 em `.claude-plugin/marketplace.json`
2. Commit "Bump sdd-workflow para 1.0.3"
3. Push para `origin/main`
4. Pull no clone local em `~/.claude/plugins/marketplaces/aj-openworkspace`
5. Atualizar `~/.claude/plugins/installed_plugins.json`
6. Re-cache em `~/.claude/plugins/cache/aj-openworkspace/sdd-workflow/1.0.3/`
7. Sugerir restart do Desktop

- [ ] **Step 5: Validar pós-publish**

Run: `jq '.plugins["sdd-workflow@aj-openworkspace"][0].version' ~/.claude/plugins/installed_plugins.json`
Expected: `"1.0.3"`

Run: `ls ~/.claude/plugins/cache/aj-openworkspace/sdd-workflow/`
Expected: pasta `1.0.3/` (e opcionalmente `1.0.2/` deprecada — não bloqueia)

---

# FASE B — v1.0.4 (refactor estrutural via progressive disclosure)

### Task B1: Criar `references/fluxo-pre-spec.md` (extrair Estágio I)

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-pre-spec.md`
- (referência, não modificar ainda) `skills/sdd-workflow/SKILL.md` linhas 138-218

- [ ] **Step 1: Ler conteúdo atual do Estágio I na SKILL principal**

Run: `sed -n '138,218p' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 81 linhas cobrindo Pré-spec.Discovery + Pré-spec.Constitution + Pré-spec.Stack

- [ ] **Step 2: Criar `fluxo-pre-spec.md` com o conteúdo detalhado**

Estrutura do arquivo:

```markdown
# Fluxo detalhado — Estágio I (Pré-spec)

> Reference detalhado do Estágio I do workflow SDD. Carregado pela SKILL principal `sdd-workflow/SKILL.md` quando IA está atuando em alguma das 3 fases do Pré-spec. Contém o passo-a-passo, exemplos, comandos shell, listagem completa de skills auxiliares e Quality Gates por fase.

## 1. Pré-spec.Discovery

[copiar conteúdo das linhas 140-166 da SKILL principal — perguntas estruturadas, análise de documentos, skills auxiliares, Quality Gate Discovery]

## 2. Pré-spec.Constitution (com Setup absorvido)

[copiar conteúdo das linhas 168-202 da SKILL principal — passos de criação de pasta, escrita do constitution.md, CLAUDE.md, README.md inicial, commit init, Quality Gate Constitution]

## 3. Pré-spec.Stack — checkpoint explícito (3 sub-componentes)

[copiar conteúdo das linhas 204-218 da SKILL principal — pergunta crítica, 3 sub-componentes (inventário/stack/alvo), Quality Gate Stack]
```

Preservar **integralmente** o conteúdo (não alterar texto). Apenas reformatar com novos headers `## 1.`, `## 2.`, `## 3.` e adicionar a nota inicial em blockquote.

- [ ] **Step 3: Validar criação**

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-pre-spec.md`
Expected: ~85 linhas (81 originais + nota inicial + headers)

Run: `grep -cE "Quality Gate" plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-pre-spec.md`
Expected: 3 (Discovery, Constitution, Stack)

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-pre-spec.md
git commit -m "sdd-workflow: criar reference fluxo-pre-spec extraído do Estágio I (item 1.1 BACKLOG, ex-1.2)"
```

---

### Task B2: Criar `references/fluxo-spec.md` (extrair Estágio II)

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-spec.md`

- [ ] **Step 1: Ler conteúdo atual do Estágio II na SKILL principal**

Run: `sed -n '222,283p' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 62 linhas cobrindo Spec.Requirements + Spec.Design + Spec.Spike

- [ ] **Step 2: Criar `fluxo-spec.md`**

Mesma estrutura da Task B1, com 3 fases:

```markdown
# Fluxo detalhado — Estágio II (Spec)

> Reference detalhado do Estágio II do workflow SDD. Carregado pela SKILL principal quando IA está atuando em Spec.Requirements, Spec.Design ou Spec.Spike (opcional).

## 1. Spec.Requirements (formato EARS)
[copiar linhas 224-239 da SKILL principal]

## 2. Spec.Design
[copiar linhas 241-263 da SKILL principal]

## 3. Spec.Spike (opcional)
[copiar linhas 265-283 da SKILL principal]
```

- [ ] **Step 3: Validar criação**

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-spec.md`
Expected: ~68 linhas

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-spec.md
git commit -m "sdd-workflow: criar reference fluxo-spec extraído do Estágio II (item 1.1 BACKLOG, ex-1.2)"
```

---

### Task B3: Criar `references/fluxo-build.md` (extrair Estágio III)

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-build.md`

- [ ] **Step 1: Ler conteúdo atual do Estágio III na SKILL principal**

Run: `sed -n '287,349p' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 63 linhas cobrindo Build.Tasks + Build.Implementation + Final de sessão

- [ ] **Step 2: Criar `fluxo-build.md`**

```markdown
# Fluxo detalhado — Estágio III (Build)

> Reference detalhado do Estágio III. Carregado pela SKILL principal quando IA está em Build.Tasks ou no loop de Build.Implementation por feature.

## 1. Build.Tasks (plano-mestre)
[copiar linhas 289-309 da SKILL principal]

## 2. Build.Implementation — loop por feature
[copiar linhas 311-340 da SKILL principal]

## 3. Final de sessão (não é fase, é evento)
[copiar linhas 342-349 da SKILL principal]
```

- [ ] **Step 3: Validar criação**

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-build.md`
Expected: ~70 linhas

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-build.md
git commit -m "sdd-workflow: criar reference fluxo-build extraído do Estágio III (item 1.1 BACKLOG, ex-1.2)"
```

---

### Task B4: Criar `references/fluxo-ship.md` (extrair Estágio IV)

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-ship.md`

- [ ] **Step 1: Ler conteúdo atual do Estágio IV na SKILL principal**

Run: `sed -n '353,407p' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 55 linhas cobrindo Ship.Audit + Ship.Delivery + Ship.Deploy + Promoção de Tier

- [ ] **Step 2: Criar `fluxo-ship.md`**

```markdown
# Fluxo detalhado — Estágio IV (Ship)

> Reference detalhado do Estágio IV. Carregado pela SKILL principal quando IA está em Ship.Audit, Ship.Delivery ou Ship.Deploy. Para Promoção de Tier (sub-fluxo dedicado), ver sub-skill `sdd-promote-tier`.

## 1. Ship.Audit — 14 dimensões × 5 tiers
[copiar linhas 355-370 da SKILL principal]

## 2. Ship.Delivery
[copiar linhas 372-384 da SKILL principal]

## 3. Ship.Deploy — parametrizado por tier
[copiar linhas 386-403 da SKILL principal]

## 4. Promoção de Tier (sub-fluxo dedicado)
[copiar linhas 405-407 da SKILL principal — apenas o ponteiro pra sub-skill]
```

- [ ] **Step 3: Validar criação**

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-ship.md`
Expected: ~62 linhas

- [ ] **Step 4: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-ship.md
git commit -m "sdd-workflow: criar reference fluxo-ship extraído do Estágio IV (item 1.1 BACKLOG, ex-1.2)"
```

---

### Task B5: Reescrever seções de estágio na SKILL principal (preservar listas críticas + Quality Gate inline + pointer)

**Files:**
- Modify: `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` (substituir linhas 138-407 + bumpar frontmatter + pequenas atualizações no Apêndice)

Esta é a task mais delicada — ela reduz 261 linhas a ~150 linhas (4 estágios × ~37 linhas cada). Cada seção de estágio aplica o **método de classificação do spec seção 3.2**: preserva listas estruturadas críticas (perguntas, ajustes, critérios), Quality Gates e tabelas comparativas curtas; move procedimentos longos, listagens extensas de skills e exemplos pra reference.

Padrão por fase:

```markdown
### Estágio X.[Fase]

[1 parágrafo de prosa resumindo o objetivo]

[Lista crítica preservada — numerada ou bulletada conforme original]

**Quality Gate [Fase]**: [critérios separados por |]
```

Cada estágio termina com pointer único: `> Detalhe operacional, comandos shell, exemplos e skills auxiliares: \`references/fluxo-X.md\`.`

**Bump do frontmatter**: como parte desta task, atualizar `version: 1.0.0` → `version: 1.1.0` no frontmatter da SKILL (interface da skill mudou — 4 references novos referenciados).

- [ ] **Step 1: Backup do estado atual (sanity check)**

Run: `cp plugins/sdd-workflow/skills/sdd-workflow/SKILL.md /tmp/SKILL-pre-refactor.md && wc -l /tmp/SKILL-pre-refactor.md`
Expected: ~480 linhas (após cleanup da Fase A pode ter variado em 1-2 linhas)

- [ ] **Step 2: Substituir seção do Estágio I (linhas 138-218 atuais)**

Substituir TODO o bloco `## Estágio I — Pré-spec` (incluindo as 3 sub-seções Discovery/Constitution/Stack) por:

```markdown
## Estágio I — Pré-spec

Estágio inicial: descobrir o que vai ser construído (Discovery), formalizar a constitution do projeto com decisões estruturais (Constitution), e fazer checkpoint crítico de stack/inventário/alvo de deploy (Stack).

### Pré-spec.Discovery

Faça perguntas ao usuário pra entender:

1. **Problema**: que dor operacional este projeto resolve?
2. **Usuários**: quem vai usar? quantas pessoas? em que dispositivo?
3. **Dados**: que dados entram, como são processados, o que sai?
4. **Referência**: existe planilha, documento ou processo manual que será substituído?
5. **Escopo V1**: o que é essencial vs. nice-to-have?
6. **`tipo_projeto`**: `web-saas` | `claude-plugin` | `hubspot` | `outro` (ver `references/tipos-projeto.md`)
7. **`tier` projetado** (visão final, não estado atual): `prototipo_descartavel` | `uso_interno` | `mvp` | `beta_publico` | `producao_real` (ver `references/tiers.md`)

Documentos de referência (Excel/PDF/Word/PowerPoint) analisados via skills `anthropic-skills:*` antes de avançar. Pode usar `superpowers:brainstorming` pra explorar.

**Quality Gate Discovery**: Problema/usuários/dados/referência/escopo entendidos | tipo_projeto e tier respondidos com justificativa | Documentos de referência analisados (se houver).

### Pré-spec.Constitution (com Setup absorvido)

Após Discovery aprovada: cria estrutura de pastas, escreve `specs/constitution.md` copiando + preenchendo `templates/constitution.md` (YAML inicial obrigatório com `tipo_projeto`/`tier`/`tier_decidido_em` + bloco textual explicando **por que** esse tier), escreve `CLAUDE.md` do projeto (via `claude-md-management:revise-claude-md`), `README.md` inicial e faz commit init.

**Quality Gate Constitution**: Bloco YAML preenchido | Stack default (ou override) justificada | Princípios não conflitam com `/CLAUDE.md` raiz | Brand colors definidos (se UI) | progress.md criado (template) | Commit init feito.

### Pré-spec.Stack — checkpoint explícito (3 sub-componentes)

**Não é confirmação automática**. Pausa real onde a IA pergunta criticamente se a stack default ainda faz sentido dadas as particularidades de Discovery. Os 3 sub-componentes a registrar na constitution:

1. **Inventário de dependências** (CLI do sistema, MCP servers, skills do marketplace, acesso a serviços externos). Família A (`superpowers:*` essenciais) bloqueia se faltar — ver `references/inventario-dependencias.md`.
2. **Stack técnica** — default sugerida por `tipo_projeto`. Override permitido sempre, com justificativa — ver `references/stacks.md`.
3. **Alvo de deploy** — **decisão explícita do projeto**, não derivada de tipo+tier. IA pergunta "onde o produto vai viver?" — ver `references/alvos-deploy.md`.

**Quality Gate Stack**: Inventário registrado (todas as categorias) | Stack confirmada ou override registrado com justificativa | Alvo de deploy registrado (decisão explícita) | Particularidades de Discovery consideradas (anti-pattern: aceitar default sem reflexão).

> Comandos shell, exemplo YAML completo da constitution e mapeamento de skills por tipo de documento: `references/fluxo-pre-spec.md`.
```

- [ ] **Step 3: Substituir seção do Estágio II (linhas 222-283 atuais)**

Substituir TODO o bloco `## Estágio II — Spec` por:

```markdown
## Estágio II — Spec

Estágio de especificação: requirements precisos em EARS, design técnico (schema/APIs/arquitetura) e spike opcional pra resolver risco técnico.

### Spec.Requirements (formato EARS)

Escreve `specs/requirements.md` copiando + preenchendo `templates/requirements.md`. **Formato EARS** pra cada regra de negócio — 5 padrões (Ubiquitous, State-driven, Event-driven, Optional Feature, Unwanted Behavior) + Complex pra combinações. Sintaxe e exemplos: `references/linguagens-especificacao.md` seção 1.

Conteúdo obrigatório do `requirements.md`:

- Visão geral do sistema
- Usuários e perfis de acesso
- Dados de referência (linkar paths/URLs dos documentos reais)
- Módulos do sistema com requirements EARS
- Regras de negócio críticas com exemplos de **dados reais** (heurística H1)
- Requisitos não-funcionais conforme tier (ver `references/tiers.md`)
- Dados iniciais (seed) — extraídos dos documentos reais
- Fora do escopo V1

**Quality Gate Requirements**: Cada módulo tem requirements EARS bem-formados | Regras de negócio com exemplos de dados reais | Documentos de referência analisados e linkados | Isolamento de dados entre perfis definido (se aplicável).

### Spec.Design

Escreve `specs/design.md` copiando + preenchendo `templates/design.md`. Conteúdo:

- Stack confirmada (da constitution + ajustes desta fase)
- Schema do banco (tabelas, relações, constraints, índices) se aplicável
- API Routes (rotas, payloads, autenticação, autorização)
- Arquitetura de componentes frontend (mobile-first se `web-saas`)
- Organização de pastas
- Estratégia de seed com dados reais
- **Bounded contexts** opcional (DDD parcial — apenas se `tier: producao_real` complexo ou `hubspot` extension grande); senão noop declarado
- **Decisão Spike**: este Design identificou risco técnico? Sim → cria `specs/spike.md`; Não → segue direto pra Build.Tasks
- Decisões importantes (cross-link com constitution)

**Quality Gate Design**: Schema cobre todos os módulos dos requirements | APIs têm autenticação e autorização definidas | Stack bate com constitution | Brand colors do projeto configurados (Tailwind, se UI) | Mobile-first documentado (sidebar, tabelas, cards) se UI | Decisão Spike registrada (sim/não).

### Spec.Spike (opcional)

Entra **apenas** se Spec.Design identificou risco técnico (integração externa nova, lib desconhecida, dependência crítica). Box temporal sugerido: 1-3 dias. Escreve `specs/spike.md` copiando + preenchendo `templates/spike.md`. Estrutura:

1. Risco identificado (origem: Spec.Design seção 8)
2. Hipóteses (principal + alternativas)
3. Critérios de sucesso
4. Investigação (setup mínimo, resultados, surpresas)
5. **Decisão tripartite**: confirmada / parcialmente confirmada / não confirmada
6. Próximo passo
7. Aprendizados pra registrar na Constitution

**Quality Gate Spike**: Hipóteses validadas (ou negadas com pivot decidido) | Riscos resolvidos ou aceitos com justificativa | Decisão registrada (constitution histórico) | Aprendizados extraídos pra constitution.

> Skills sugeridas (frontend-design, claude-api, plugin-dev), MCP context7, exemplos completos EARS/BDD e skills auxiliares do Spike: `references/fluxo-spec.md`.
```

- [ ] **Step 4: Substituir seção do Estágio III (linhas 287-349 atuais)**

Substituir TODO o bloco `## Estágio III — Build` por:

```markdown
## Estágio III — Build

Estágio de execução: plano-mestre quebrando o sistema em features (Tasks) e loop por feature com plano detalhado, TDD canônico e Quality Gate por feature (Implementation).

### Build.Tasks (plano-mestre)

Escreve `specs/tasks.md` copiando + preenchendo `templates/tasks.md`. **Plano-mestre** = índice de features. Cada feature terá seu próprio plano detalhado em `specs/plans/<feature>.md`.

Quebra típica de features (adaptar conforme `tipo_projeto`):

1. **Infra e Setup** (Docker, scripts, banco)
2. **Auth + Layout** (login, JWT, sidebar, mobile drawer) se UI
3. **CRUDs** (entidades administrativas)
4. **Lógica de negócio [H1]** (cálculos, validações — validação obrigatória contra dados reais)
5. **Dashboards e visualizações** (se aplicável)
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** (isolamento, validações, responsividade)

Cada feature do plano-mestre deve:
- Ser testável independentemente
- Ter critério claro de done
- Indicar dependências
- Marcar com [H1] se exige validação contra dados reais

**Quality Gate Tasks**: Cada feature tem plano detalhado planejado em `specs/plans/<feature>.md` | Dependências entre features claras | Features [H1] identificadas | Plano-mestre revisado | progress.md atualizado com features.

### Build.Implementation — loop por feature

Pra cada feature do plano-mestre, escrever plano detalhado em `specs/plans/<feature>.md` usando `superpowers:writing-plans` com **5 ajustes de convenção SDD**:

1. **Marcação [H1]** — header de task `### Task N: [Component] [H1]` ou step extra `- [ ] **Step X: validar contra dados reais [H1]**` antes do commit
2. **Quebra por fase típica** absorvida no nível superior (`tasks.md` plano-mestre)
3. **Quality Gate por feature** absorve gates antigos
4. **Localização**: `specs/plans/<feature>.md` no projeto (autocontido)
5. **Refactor explícito no ciclo TDD canônico** — `write test → run (FAIL) → implement → run (PASS) → REFACTOR → commit`. Refactor pode ser noop conscientemente declarado (não pulado silenciosamente); pra arquivos não-código (markdown, JSON) adapta semântica. Notação completa e anti-patterns: `references/linguagens-especificacao.md` seção 3.

Em seguida: cenário BDD pra tasks [H1] (validação contra dados reais — formato Given/When/Then com dados reais específicos), executar via `superpowers:executing-plans` ou `superpowers:subagent-driven-development`, atualizar `specs/progress.md` ao concluir.

**Quality Gate por feature** (gate além do gate por task): Todos os steps do plano detalhado executados | Testes da feature passando (output mostrado) | Se [H1]: comparativo contra dados reais mostrado e aprovado | Refactor declarado (executado ou noop justificado) | progress.md marcado [atendido].

### Final de sessão (não é fase, é evento)

Quando a sessão de trabalho encerrar (mesmo no meio da Implementation):

1. **Atualizar `specs/progress.md`** com estado atual
2. **Revisar `CLAUDE.md` do projeto** com aprendizados (`claude-md-management:revise-claude-md`)
3. **Salvar na memória**: `remember:remember`
4. **Relatório de sessão** (opcional): `session-report:session-report`

> Listagem completa de skills durante Implementation (test-driven-development, systematic-debugging, verification-before-completion, using-git-worktrees, dispatching-parallel-agents, commit-commands:commit, simplify) e exemplos detalhados: `references/fluxo-build.md`.
```

- [ ] **Step 5: Substituir seção do Estágio IV (linhas 353-407 atuais)**

Substituir TODO o bloco `## Estágio IV — Ship` por:

```markdown
## Estágio IV — Ship

Estágio final: auditoria dimensional (Audit), preparação pra avaliação (Delivery) e deploy parametrizado por tier (Deploy). Promoção de Tier é sub-fluxo dedicado.

### Ship.Audit — 14 dimensões × 5 tiers

Auditoria dimensional. Detalhe das 14 dimensões em `references/audit-dimensoes.md`. Matriz de obrigatoriedade por tier em `references/tiers.md` seção 3. Dim 14 (Defesa contra prompt injection) é condicional a "produto tem LLM no caminho?".

Fluxo da Audit:

1. **Pergunta dimensões `perguntar`** ao usuário no início (registra resposta na constitution)
2. **Roda dimensões `obrigatório` e `opcional`** em paralelo via `superpowers:dispatching-parallel-agents`
3. **Sub-agentes especializados** quando aplicável (Código, Segurança, plugin-validator pra claude-plugin)
4. **Compila relatório** em `specs/audit-<YYYY-MM-DD>.md` copiando + preenchendo `templates/audit.md`. Achados classificados em críticos (bloqueiam Delivery), importantes e melhorias.
5. **`superpowers:requesting-code-review`** — review humana antes da Audit começar, se aplicável

**Quality Gate Audit**: Todas as dimensões `obrigatório` do tier executadas | Dimensões `perguntar` decididas e registradas na constitution | Achados críticos zerados ou tratados antes de avançar | Achados importantes corrigidos ou aceitos com justificativa registrada | Lógica de negócio validada contra dados reais (dimensão 8 sempre obrigatória) | progress.md atualizado.

### Ship.Delivery

Sistema rodando em ambiente de avaliação. Pré-deploy:

1. **Aplicar fixes** dos achados críticos e importantes da Audit
2. **Commit final** das correções
3. **Subir o sistema**: Docker compose ou equivalente conforme `tipo_projeto`
4. **Validar fluxos principais** com o usuário
5. **`superpowers:finishing-a-development-branch`** se branch isolada
6. **`commit-commands:commit-push-pr`** se PR aberto
7. **`pr-review-toolkit:review-pr`** se aplicável

**Quality Gate Delivery**: Zero achados críticos da Audit | Seeds funcionando do zero (limpar banco + popular com dados reais) | Sistema rodando e acessível em ambiente de avaliação | README.md atualizado com instruções de setup e uso | Usuário validou fluxos principais | progress.md atualizado.

### Ship.Deploy — parametrizado por tier

Decisão do alvo foi tomada na Pré-spec.Stack (registrada na constitution). Esta fase **executa o deploy** conforme tier (ver `references/alvos-deploy.md` pra detalhe):

- **`prototipo_descartavel`**: não tem deploy. Roda local apenas. Ship.Deploy é noop declarado.
- **`uso_interno`**: deploy simples (Docker compose num servidor, Vercel free, hosting básico). Sem rollback formal.
- **`mvp`**: hosting gerenciado, deploy manual, monitoramento básico.
- **`beta_publico`**: rollback plan obrigatório, observabilidade obrigatória, error tracking.
- **`producao_real`**: rollback automático, alertas, on-call ou processo de incidente, monitoramento avançado.

**Quality Gate Deploy**: Env de prod separado (secrets fora do código) | Rollback plan documentado (mvp+) ou declarado noop (prototipo/uso_interno) | Monitoramento básico configurado (mvp+) ou declarado noop | Domínio configurado (se aplicável) | Fluxos validados em prod (smoke test pelo menos) | progress.md em 100%.

### Promoção de Tier (sub-fluxo dedicado)

Quando o usuário expressar intenção de mudar tier ("promover esse projeto pra MVP", "agora vai virar prod real"), invocar a sub-skill **`sdd-promote-tier`** ou usar o command `/sdd-workflow:promote-tier`. 11 passos incrementais — não recomeça do zero.

> Caso especial pra `claude-plugin` no marketplace (publish-plugin) e demais detalhes operacionais: `references/fluxo-ship.md`.
```

- [ ] **Step 6: Atualizar Apêndice (tabela de references)**

Localizar a tabela de references no Apêndice (linha ~448 atual). Adicionar 4 entries novos no início da tabela (antes de `references/heuristicas.md`):

```markdown
| `references/fluxo-pre-spec.md` | **Estágio I detalhado** — passo-a-passo de Discovery, Constitution, Stack |
| `references/fluxo-spec.md` | **Estágio II detalhado** — passo-a-passo de Requirements (EARS), Design, Spike |
| `references/fluxo-build.md` | **Estágio III detalhado** — passo-a-passo de Tasks, Implementation (loop por feature), Final de sessão |
| `references/fluxo-ship.md` | **Estágio IV detalhado** — passo-a-passo de Audit, Delivery, Deploy, Promoção de Tier |
```

- [ ] **Step 7: Bumpar frontmatter da SKILL pra 1.1.0**

Localizar `version: 1.0.0` no frontmatter (linha ~16) e mudar pra `version: 1.1.0`. Refletir mudança de interface da skill (4 references novos referenciados).

- [ ] **Step 8: Validar resultado final**

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 380-420 linhas (resultado real de B5: 411) (meta revisada)

Run: `grep -c "references/fluxo-" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 8+ (4 pointers no fim de cada estágio + 4 entries no Apêndice)

Run: `grep -c "Quality Gate" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 11 (1 por fase: Discovery, Constitution, Stack, Requirements, Design, Spike, Tasks, por feature, Audit, Delivery, Deploy)

Run: `grep -E "^version:" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: `version: 1.1.0`

Run validações de listas críticas preservadas:
- 7 perguntas Discovery: `grep -c "^[0-9]\." plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` ≥ 25 (somando todas as listas numeradas)
- 5 ajustes SDD: `grep -E "^[0-9]\. \*\*Marcação \[H1\]\*\*" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md` retorna 1 linha
- Comportamento Deploy por tier: `grep -E "prototipo_descartavel|uso_interno|mvp|beta_publico|producao_real" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md | wc -l` ≥ 5 (como bullets na lista de tier)

- [ ] **Step 9: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: reduzir SKILL principal preservando listas críticas + bumpar frontmatter pra 1.1.0 (item 1.1 BACKLOG, ex-1.2)"
```

---

### Task B6: Cleanup BACKLOG pós-refactor

**Files:**
- Modify: `plugins/sdd-workflow/BACKLOG.md` (remover linha do item 1.1 que agora foi aplicado)

- [ ] **Step 1: Validar estado atual**

Run: `grep -E "^\| 1\." plugins/sdd-workflow/BACKLOG.md`
Expected: 1 linha (`| 1.1 | Otimizar tamanho da SKILL.md...`)

- [ ] **Step 2: Remover linha do item 1.1 da tabela de polish**

A linha começa com `| 1.1 | Otimizar tamanho da SKILL.md principal — 480 linhas...`. Remover ela inteira.

Após remoção, a tabela de polish fica com apenas o header e separador (sem linhas de dados). Deletar também esses 2 linhas (header `| # | Item | ...` e separador `|---|---|---|---|`) e substituir por uma nota:

```markdown
> **Sem polishs ativos.** Itens 1.1 (refresh README), 1.2 (cleanup emojis) e 1.3 (otimizar SKILL.md) foram aplicados em v1.0.2/1.0.3/1.0.4.
```

- [ ] **Step 3: Atualizar nota "Atualizado em" (linha 5)**

| Antes | Depois |
|---|---|
| `Atualizado em: 2026-05-05 (pós-v1.0.3 — polish 1.1 (cleanup de emojis no plugin alinhado a "zero emojis") aplicado e removido; ex-polish 1.2 (otimizar SKILL.md principal — 480 linhas) renumerado pra 1.1; convenções textuais [H1]/[crítico]/[atendido] documentadas em references/heuristicas.md; seção 4.4 e itens 4.1.x permanecem pendentes).` | `Atualizado em: 2026-05-05 (pós-v1.0.4 — polish 1.1 (otimizar SKILL.md principal via progressive disclosure) aplicado em 4 references novos por estágio + SKILL principal reduzida pra ~270 linhas; tabela de polish vazia (todos os 3 itens aplicados em v1.0.2/1.0.3/1.0.4); seção 4.4 e itens 4.1.x permanecem pendentes).` |

- [ ] **Step 4: Validar estado final**

Run: `grep -E "^\| 1\." plugins/sdd-workflow/BACKLOG.md`
Expected: 0 linhas

Run: `grep -c "Sem polishs ativos" plugins/sdd-workflow/BACKLOG.md`
Expected: 1

- [ ] **Step 5: Commit**

```bash
git add plugins/sdd-workflow/BACKLOG.md
git commit -m "sdd-workflow: cleanup BACKLOG após aplicação do refactor (tabela de polish zerada)"
```

---

### Task B7: Smoke test global + publish v1.0.4

**Files:**
- Read-only: todo o plugin
- Modify (via publish-plugin): `.claude-plugin/marketplace.json` (bump 1.0.3 → 1.0.4)

- [ ] **Step 1: Smoke test factual — SKILL principal dentro da meta revisada**

Run: `wc -l plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 380-420 linhas (resultado real de B5: 411)

- [ ] **Step 2: Smoke test factual — pointers presentes em cada estágio**

Run: `grep -E "> .*references/fluxo-(pre-spec|spec|build|ship)\.md" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: 4 linhas, uma por estágio

- [ ] **Step 3: Smoke test factual — 4 references criados existem**

Run: `ls plugins/sdd-workflow/skills/sdd-workflow/references/fluxo-*.md`
Expected: 4 arquivos: `fluxo-pre-spec.md`, `fluxo-spec.md`, `fluxo-build.md`, `fluxo-ship.md`

- [ ] **Step 4: Smoke test factual — frontmatter bumpado**

Run: `grep -E "^version:" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`
Expected: `version: 1.1.0`

- [ ] **Step 5: Smoke test factual — listas críticas preservadas inline**

Validar presença das listas que devem permanecer na SKILL principal:
- 7 perguntas Discovery (Problema/Usuários/Dados/Referência/Escopo V1/tipo_projeto/tier)
- 3 sub-componentes Stack (Inventário/Stack técnica/Alvo de deploy)
- 8 itens conteúdo Requirements
- 9 itens conteúdo Design
- 7 itens estrutura Spike
- 7 features típicas Tasks
- 5 ajustes convenção SDD Implementation
- 5 passos fluxo Audit
- 7 passos pré-deploy Delivery
- 5 tiers Deploy (prototipo_descartavel/uso_interno/mvp/beta_publico/producao_real)

Comando agregado:
```bash
echo "Listas inline:"
echo "  7 perguntas Discovery: $(grep -c '^1\. \*\*Problema' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md)"
echo "  Trigger Spec.Spike (estrutura 7 itens): $(grep -c 'Decisão tripartite' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md)"
echo "  5 ajustes SDD: $(grep -c 'Marcação \[H1\]\*\* — header' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md)"
echo "  Comportamento Deploy por tier: $(grep -cE 'prototipo_descartavel|uso_interno|mvp|beta_publico|producao_real' plugins/sdd-workflow/skills/sdd-workflow/SKILL.md)"
```
Expected: cada um ≥ 1, com Deploy por tier ≥ 5

- [ ] **Step 6: Smoke test comportamental (FOLLOW-UP do user pós-restart)**

> **Nota**: este step não roda nesta sessão — o cache do Desktop só atualiza após restart. Marcar como follow-up:

Após restart do Desktop:
1. Em sessão Claude Code, criar projeto fictício e invocar trigger natural ("novo projeto: smoke test")
2. Observar se IA carrega SKILL principal (~315 linhas) sem fetch desnecessário
3. Quando IA entra em Pré-spec.Discovery, observar se carrega `references/fluxo-pre-spec.md` ou se as 7 perguntas inline já bastam
4. Validar que pointers não estão quebrados (paths existem)

Em caso de regressão (IA falha em achar reference), revisar Step 6 da Task B5 — pointer pode ter typo no path.

- [ ] **Step 7: Publish via marketplace-tools**

```
/marketplace-tools:publish-plugin sdd-workflow patch
```

Bumpa 1.0.3 → 1.0.4, commit, push, pull no clone, re-cache em `~/.claude/plugins/cache/aj-openworkspace/sdd-workflow/1.0.4/`.

- [ ] **Step 8: Validar pós-publish**

Run: `jq '.plugins["sdd-workflow@aj-openworkspace"][0].version' ~/.claude/plugins/installed_plugins.json`
Expected: `"1.0.4"`

Run: `ls ~/.claude/plugins/cache/aj-openworkspace/sdd-workflow/`
Expected: pasta `1.0.4/`

---

## Critério de done global (ambas fases)

- v1.0.3 publicado: zero emojis no plugin, convenções textuais documentadas em `heuristicas.md`, BACKLOG limpo
- v1.0.4 publicado: SKILL principal entre 250-300 linhas, 4 references novos criados, pointers funcionais em cada estágio, BACKLOG sem polishs ativos
- Cache do Claude Code Desktop atualizado pra 1.0.4
- Smoke tests passam em ambas fases
- Sem regressões funcionais (IA continua conseguindo executar o fluxo SDD em projeto novo)
