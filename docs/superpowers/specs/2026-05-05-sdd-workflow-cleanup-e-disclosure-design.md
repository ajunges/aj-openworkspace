# sdd-workflow — cleanup de emojis + progressive disclosure (design)

**Data**: 2026-05-05
**Plugin**: `sdd-workflow` (Level 3, marketplace `aj-openworkspace`)
**Versão alvo**: plugin `1.0.3` (cleanup) + `1.0.4` (refactor)
**Tag mantida**: `em-testes`
**Origem**: itens 1.1 e 1.2 do `plugins/sdd-workflow/BACKLOG.md`

---

## 1. Contexto e motivação

### 1.1 Itens do backlog endereçados

| # | Item | Decisão pendente no BACKLOG |
|---|---|---|
| 1.1 | Cleanup de emojis no plugin alinhado a preferência global "zero emojis" | Cleanup completo vs. só decorativos |
| 1.2 | Otimizar `SKILL.md` principal (480 linhas) via progressive disclosure | 1 reference único vs. 4 references por estágio vs. status quo |

Ambos modificam `skills/sdd-workflow/SKILL.md` — ordem de execução matters.

### 1.2 Motivação consolidada

- **1.1**: preferência global do autor (`~/.claude/CLAUDE.md`) é "zero emojis". O README do plugin foi reescrito sem emojis no commit `3426b65` sem perda de função semântica. Resta aplicar o mesmo padrão ao resto do plugin.
- **1.2**: a SKILL principal carregada por trigger explícito (`disable-model-invocation: true`) consome ~480 linhas de tokens em cada invocação. Aritmética real do ganho com progressive disclosure (3 cenários):

| Cenário | Antes | Depois (estimado) | Δ |
|---|---|---|---|
| Status check (`/sdd-workflow:status`, diagnóstico) | 480 linhas | ~315 linhas (só SKILL principal) | **−34%** |
| Trabalho numa fase específica (Discovery, Implementation, etc.) | 480 | 315 + ~80 (reference da fase) = ~395 | **−18%** |
| Workflow do início ao fim em uma sessão (todos os 4 estágios consultados) | 480 | 315 + ~270 (4 references) = ~585 | **+22%** |

O ganho de tokens é real apenas pra **invocações de diagnóstico** (frequentes via slash commands de status). Pra workflow contínuo, o refactor **piora** a contagem de tokens. **A justificativa principal não é tokens — é manutenibilidade**: cada arquivo fica mais focado, mais fácil de ler isoladamente, mais fácil de evoluir sem cascata de edits cruzados.

---

## 2. Inventário de emojis no plugin

Levantamento via `grep` em todos os arquivos do plugin (commit `50946ab`):

| Categoria | Função semântica | Ocorrências | Arquivos afetados |
|---|---|---|---|
| `🔒` | Marca feature/task que exige validação contra dados reais (heurística H1) | ~15 | `SKILL.md` principal, templates `plan-feature`, `progress`, `tasks`, reference `linguagens-especificacao` |
| `🔴/🟡/🟢` | Severity de achados na Ship.Audit | ~16 | `SKILL.md`, references `audit-dimensoes`, `disciplinas-tier`, `tiers`, sub-skill `sdd-promote-tier`, commands `audit`/`promote-tier` |
| `✅/❌/📋/⏸️/🔄` | Status de gate/feature/promoção | ~12 | `SKILL.md` (8x em Quality Gates), command `gate`, sub-skills `sdd-promote-tier` e `sdd-migrate-v1` |
| `📊` e `●●●○○` | Decoração de status line | ~4 | template `progress`, command `status` |
| `🟢🔵🟣` | Cabeçalhos de seção | 4 | `BACKLOG.md` (resíduo) |

Total: ~50 ocorrências.

---

## 3. Decisões de design

### 3.1 Item 1.1 — cleanup completo

**Decisão**: cleanup completo de todos os emojis (semânticos + decorativos), com convenções textuais estáveis para os semânticos.

**Razão**: alinhamento com preferência global "zero emojis"; IA moderna parseia tokens textuais com a mesma eficiência que emojis (ou superior, em contextos onde tokenizer fragmenta emojis em múltiplos sub-tokens).

**Alternativa rejeitada**: cleanup só dos decorativos, mantendo semânticos como convenção interna do plugin. Rejeitada porque mantém inconsistência com o restante do workspace e exige nota explicativa em cada arquivo onde aparecem.

### 3.2 Item 1.2 — split em 4 references por estágio

**Decisão**: criar 4 references novos em `skills/sdd-workflow/references/`:

- `fluxo-pre-spec.md` (Discovery, Constitution, Stack)
- `fluxo-spec.md` (Requirements, Design, Spike)
- `fluxo-build.md` (Tasks, Implementation, Final de sessão)
- `fluxo-ship.md` (Audit, Delivery, Deploy, Promoção de Tier)

A SKILL principal mantém, para cada fase: **resumo + listas críticas + Quality Gate inline + pointer para o reference correspondente**. Detalhe operacional (procedimentos, comandos shell, listagens extensas de skills, exemplos longos) move para os references.

**Razão**: o ganho de tokens é modesto e situacional (ver tabela em 1.2 acima). O ganho real é **estrutural** — cada arquivo fica mais focado e fácil de manter, e a SKILL principal passa a ser navegável como playbook auto-suficiente em alto nível, com detalhe operacional acessível sob demanda.

**Método pra decidir o que vive onde** (aplicado em 5.1 abaixo):

| Tipo de conteúdo | Vive em | Razão |
|---|---|---|
| Listas estruturadas críticas (perguntas Discovery, sub-componentes Stack, ajustes de convenção SDD, fases típicas, critérios de feature) | **SKILL principal** | IA precisa do checklist à mão sem fetch extra; perder a lista = risco de IA improvisar |
| Quality Gates | **SKILL principal** | Curtos, dão estrutura, anchor de fim de fase |
| Tabelas comparativas curtas (ex: comportamento de Deploy por tier) | **SKILL principal** | Decisão crítica, scanning rápido |
| Comandos shell (mkdir, git init, etc.) | **reference** | Procedimento, não decisão |
| Listagem extensa de skills auxiliares (5+ skills) | **reference** | Operacional, IA carrega quando precisa |
| Exemplos extensos (YAML completo, BDD scenarios, comandos de build) | **reference** | Detalhe não-essencial pra entender o fluxo em alto nível |
| Casos especiais (ex: claude-plugin no marketplace usa publish-plugin) | **reference** | Não aplica universalmente |

**Alternativas rejeitadas**:

| Opção | Motivo da rejeição |
|---|---|
| 1 reference único `fluxo-detalhado.md` | Carrega ~270 linhas mesmo quando IA está em uma única fase. Perde a vantagem do progressive disclosure. |
| Status quo (manter 480 linhas inline) | SKILL principal continua inflado; tokens crescem linearmente conforme adicionarmos fluxo (ex: brownfield, bugfix do roadmap Spec Kit). |

### 3.3 Ordem de execução

**Decisão**: 1.1 antes de 1.2, em commits e bumps separados.

**Razão**: cleanup é mecânico (substituições textuais estáveis aplicadas via `grep`/`sed` ou edits cirúrgicos). Aplicar cleanup primeiro estabiliza o conteúdo antes do refactor estrutural. Se 1.2 viesse primeiro, o cleanup teria que ser aplicado em 5 arquivos (SKILL principal reduzido + 4 references novos), aumentando superfície de erro.

---

## 4. Convenções textuais (mapeamento detalhado)

### 4.1 `🔒` (valida dados reais)

Aparece em vários contextos. Regra geral: **`[H1]` quando é metadata explícita** (header de task/feature, step de plano, mensagem de commit, instrução de marcação) — anchor textual estável que IA reconhece como referência à heurística H1. **Texto natural quando é prosa contínua** ("exige validação contra dados reais") — lê melhor sem prefixo.

| Contexto | Antes | Depois | Justificativa |
|---|---|---|---|
| Header de task (template) | `### Task N: [Component] 🔒` | `### Task N: [Component] [H1]` | Prefixo `[H1]` é referência direta à heurística e mantém scanning visual via colchetes |
| Coluna de tabela | Cabeçalho `🔒` | `H1` (sem colchetes em cabeçalho) | Mais conciso em tabelas |
| Step de plano (template) | `**Step X: 🔒 Validar contra dados reais**` | `**Step X: validar contra dados reais [H1]**` | Texto natural com sufixo `[H1]` |
| Prosa narrativa | "exige validação 🔒" | "exige validação contra dados reais" | Texto natural lê melhor |
| Mensagem de commit (template) | `feat: <descrição> 🔒 validado contra <arquivo>` | `feat: <descrição> [H1] validado contra <arquivo>` | Mantém marcador identificável em git log |
| Item de bullet em descrição | `- Indicar 🔒 se exige validação contra dados reais` | `- Marcar com [H1] se exige validação contra dados reais` | Anchor textual |

### 4.2 `🔴/🟡/🟢` (severity de achados na Audit)

| Contexto | Antes | Depois |
|---|---|---|
| Lista/resumo de achados | `🔴 críticos`, `🟡 importantes`, `🟢 melhorias` | `[crítico]`, `[importante]`, `[melhoria]` |
| Prosa narrativa | "Achados 🔴 zerados antes de Delivery" | "Achados críticos zerados antes de Delivery" |
| Tabela de Quality Gate | "Achados 🔴 zerados ou tratados" | "Achados críticos zerados ou tratados" |
| Header em template | `## Achados 🔴 críticos` | `## Achados críticos` |

### 4.3 `✅/❌/📋/⏸️/🔄` (status)

| Contexto | Antes | Depois |
|---|---|---|
| Cabeçalho de Quality Gate | `**Quality Gate Discovery** ✅:` | `**Quality Gate Discovery**:` (remover — o nome do gate já é o anchor; os critérios em si seguem o padrão `\| separados`) |
| Lista no command `gate` | `✅ [item] — atendido` | `[atendido] [item]` |
| Lista no command `gate` | `❌ [item] — pendente` | `[pendente] [item]` |
| Lista no command `gate` | `📋 [item] — aceito com justificativa` | `[aceito] [item]` |
| Status de feature em progress | `✅ feature` / `🔄 em-andamento` / `⏸️ aguardando` | `[atendido]` / `[em-andamento]` / `[aguardando]` |

### 4.4 Decorativos (remover sem substituição)

| Antes | Depois |
|---|---|
| `📊 [Feature Atual]` (em status line) | `[Feature Atual]` |
| `[●●●○○] X%` (em progress bar) | `X%` (manter só o número — barra ASCII era ornamento) |
| `## 1. Polish (🟢 — patches v1.0.x)` | `## 1. Polish (patches v1.0.x)` |
| `## 2. Roadmap v4.0 (🔵 — minor/major bumps)` | `## 2. Roadmap v4.0 (minor/major bumps)` |
| `## 4. Inspirações do Spec Kit a digerir (🟣 — pesquisa, não TODO ativo)` | `## 4. Inspirações do Spec Kit a digerir (pesquisa, não TODO ativo)` |

### 4.5 Convenção registrada formalmente

Adicionar ao final de `references/heuristicas.md` (ou novo `references/convencoes-textuais.md` se ficar denso) uma seção curta documentando:

- `[H1]` em headers de task/feature = exige validação contra dados reais (heurística H1)
- `[crítico]` / `[importante]` / `[melhoria]` = severity de achados na Audit
- `[atendido]` / `[pendente]` / `[aceito]` / `[aguardando]` / `[em-andamento]` = status

Decisão: **registrar em `heuristicas.md`** (1 seção nova ao final), não criar reference nova só pra isso. Convenção é minimal e relacionada à H1 (que já é a origem do `[H1]`).

---

## 5. Estrutura proposta da SKILL.md pós-refactor (item 1.2)

### 5.1 SKILL.md principal (~315 linhas)

Aplicando o método de classificação (3.2):

```
Frontmatter (33 linhas)                                    # mantém
Header (4 linhas)                                          # mantém

## Premissa fundadora (15 linhas)                          # mantém

## Governança em 3 camadas (46 linhas)                     # mantém — é o frame conceitual

## Gates configuráveis (11 linhas)                         # mantém

## Visão geral do fluxo (21 linhas)                        # mantém — ASCII art + tabela

## Estágio I — Pré-spec (~35 linhas)                       # listas críticas preservadas
   - Discovery: prosa + 7 perguntas (lista) + skills doc-analysis + Quality Gate
   - Constitution: prosa enxugada + Quality Gate (comandos shell movidos)
   - Stack: prosa + 3 sub-componentes (lista) + Quality Gate
   > Pointer pra references/fluxo-pre-spec.md (procedimentos, exemplo YAML)

## Estágio II — Spec (~35 linhas)                          # listas críticas preservadas
   - Requirements: prosa + 8 itens obrigatórios (lista) + Quality Gate
   - Design: prosa + 9 itens obrigatórios (lista) + Quality Gate (skills sugeridas movidas)
   - Spike: prosa + 7 itens da estrutura (lista) + Quality Gate
   > Pointer pra references/fluxo-spec.md (skills, MCP, BDD examples)

## Estágio III — Build (~45 linhas)                        # listas críticas preservadas
   - Tasks: prosa + 7 features típicas + 4 critérios de feature + Quality Gate
   - Implementation: prosa + 5 ajustes de convenção SDD (lista crítica) + Quality Gate por feature
   - Final de sessão: 4 passos curtos
   > Pointer pra references/fluxo-build.md (lista de skills durante Implementation, exemplos)

## Estágio IV — Ship (~35 linhas)                          # listas críticas preservadas
   - Audit: prosa + 5 passos do fluxo + Quality Gate
   - Delivery: prosa + 7 passos pré-deploy (lista) + Quality Gate
   - Deploy: prosa + comportamento por 5 tiers (tabela) + Quality Gate
   - Promoção de Tier: ponteiro curto pra sub-skill
   > Pointer pra references/fluxo-ship.md (sub-agentes, caso especial claude-plugin)

## Como invocar (30 linhas)                                # mantém

## Apêndice (atualizado: ~50 linhas)                       # mantém + adiciona 4 entries
   - Adicionar fluxo-pre-spec, fluxo-spec, fluxo-build, fluxo-ship à tabela de references
```

**Total estimado**: 33 + 4 + 15 + 46 + 11 + 21 + 35 + 35 + 45 + 35 + 30 + 50 = **~360 linhas**. Acima da meta inicial de 270, mas **35% menor que 480 atuais** e **preserva listas críticas** que são checkpoint mental — perdê-las forçaria IA a sempre carregar o reference, perdendo robustez do playbook.

A meta revisada é **300-360 linhas**, não 250-300. A redução real de 25% (vs 44% original) é o trade-off honesto de manter as listas críticas inline.

### 5.2 4 references novos

Cada um carrega o detalhe operacional **completo** das fases do estágio (passo-a-passo, comandos shell, listagem de skills sugeridas, exemplos, ponteiros para outros references temáticos):

| Reference | Estágio coberto | Tamanho estimado |
|---|---|---|
| `fluxo-pre-spec.md` | Discovery + Constitution (com setup) + Stack (3 sub-componentes) | ~80 linhas |
| `fluxo-spec.md` | Requirements (EARS) + Design + Spike (opcional) | ~65 linhas |
| `fluxo-build.md` | Tasks (plano-mestre) + Implementation (loop por feature) + Final de sessão | ~70 linhas |
| `fluxo-ship.md` | Audit (14×5) + Delivery + Deploy + Promoção de Tier | ~60 linhas |

### 5.3 Formato proposto: prosa + lista crítica + Quality Gate + pointer

Exemplo aplicando o método de 3.2 a Pré-spec.Discovery:

```markdown
### Pré-spec.Discovery

Faça perguntas ao usuário pra entender:

1. **Problema**: que dor operacional este projeto resolve?
2. **Usuários**: quem vai usar? quantas pessoas? em que dispositivo?
3. **Dados**: que dados entram, como são processados, o que sai?
4. **Referência**: existe planilha, documento ou processo manual que será substituído?
5. **Escopo V1**: o que é essencial vs. nice-to-have?
6. **`tipo_projeto`**: `web-saas` | `claude-plugin` | `hubspot` | `outro` (ver `references/tipos-projeto.md`)
7. **`tier` projetado** (visão final, não estado atual): `prototipo_descartavel` | `uso_interno` | `mvp` | `beta_publico` | `producao_real` (ver `references/tiers.md`)

Documentos de referência (Excel/PDF/Word/PowerPoint) analisados via skills `anthropic-skills:*` antes de avançar. Pode usar `superpowers:brainstorming`.

**Quality Gate Discovery**: Problema/usuários/dados/referência/escopo entendidos | tipo_projeto e tier respondidos com justificativa | Documentos de referência analisados (se houver).

> Detalhe operacional (incluindo mapeamento de skills por tipo de documento e exemplos): `references/fluxo-pre-spec.md` seção 1.
```

A lista das 7 perguntas é **preservada** — é o checklist crítico de Discovery. Perdê-la força IA a sempre carregar o reference, e introduz risco de "improvisar perguntas" se o pointer for ignorado.

Aproximadamente 13-18 linhas por fase. Para 11 fases, ~145-200 linhas total para a parte por-estágio.

---

## 6. Plano de bumps

### v1.0.3 — cleanup completo (item 1.1)

- Substituir ~50 emojis pelas convenções da seção 4 deste design
- Adicionar seção de convenções textuais ao `references/heuristicas.md`
- Atualizar `BACKLOG.md` removendo o item 1.1 da tabela (renumerar 1.2 → 1.1)
- Bump via `/marketplace-tools:publish-plugin sdd-workflow patch`

### v1.0.4 — refactor estrutural (item 1.2)

- Criar 4 references novos com o conteúdo dos estágios extraído
- Reescrever as seções "Estágio I/II/III/IV" da SKILL principal aplicando o método de 3.2 (preservar listas críticas, mover procedimentos)
- Atualizar tabela do Apêndice com as 4 references novas
- **Bumpar `version: 1.0.0` → `version: 1.1.0` no frontmatter da SKILL** (interface da skill mudou — 4 references novos. Frontmatter estava em drift desde v1.0.0 do plugin; consolidamos agora)
- Atualizar `BACKLOG.md` removendo o item 1.1 (ex-1.2) renumerado
- Bump do plugin via `/marketplace-tools:publish-plugin sdd-workflow patch` (1.0.3 → 1.0.4)

**Por que dois patches do plugin, não um minor `1.1.0` batched**: cleanup e refactor têm escopos disjuntos e taxas de risco diferentes. Cleanup é mecânico (baixo risco). Refactor é estrutural (médio risco — IA pode falhar em encontrar a fase ativa se a navegação SKILL → reference quebrar). Bumps separados do plugin permitem revert do refactor sem perder o cleanup. O frontmatter da SKILL bumpa só na v1.0.4 do plugin porque é onde a interface da skill (lista de references) muda.

---

## 7. Riscos e mitigações

| Risco | Severidade | Mitigação |
|---|---|---|
| Substituição mecânica de emojis quebra contexto em prosa (ex: substituir "Achados 🔴" por "[crítico] Achados" produz frase agramatical) | Médio | Usar edits cirúrgicos por contexto (tabela 4.1-4.4), não `sed` global. Validar com leitura de cada arquivo após substituição. |
| 4 references novos criam carga de manutenção | Baixo | Convenção clara (1 reference por estágio); cross-references via texto explícito ("ver `references/fluxo-build.md`"). |
| IA falha em carregar o reference da fase ativa após refactor (regressão funcional) | Médio | Manter na SKILL principal pointer explícito ao final de cada resumo de estágio: `> Detalhe operacional em "references/fluxo-X.md"`. Validar com smoke test: invocar a skill em projeto fictício e confirmar que IA carrega o reference correto. |
| Quality Gates sem `✅` perdem visibilidade no scanning rápido | Baixo | Manter formatação `**Quality Gate X**:` em negrito; o nome do gate já é anchor visual suficiente. |
| Cache do Claude Code Desktop não invalida entre v1.0.2 → v1.0.3 → v1.0.4 (bugs #14061/#46081) | Médio | Usar `/marketplace-tools:publish-plugin` que aplica workaround de re-cache automático. |

---

## 8. Out of scope

- Mudanças nos templates (`templates/*.md`) além das substituições de emoji da seção 4
- Mudanças nas sub-skills `sdd-promote-tier` e `sdd-migrate-v1` além de cleanup de emojis nelas
- Reorganização da governança em 3 camadas (mantida intacta na SKILL principal)
- Refactor das references temáticas existentes (`heuristicas`, `tiers`, `tipos-projeto`, etc.) além da seção nova em `heuristicas.md` documentando as convenções textuais
- Itens do roadmap v4.0 ou inspirações do Spec Kit (seções 2 e 4 do `BACKLOG.md`)

---

## 9. Critério de done

### Para v1.0.3 (cleanup)

- `grep -rE "🔒|🔴|🟡|🟢|✅|❌|📋|⏸️|🔄|📊|●●●○○|🔵|🟣" plugins/sdd-workflow/` retorna zero resultados
- `references/heuristicas.md` tem nova seção documentando as convenções `[H1]`, `[crítico/importante/melhoria]`, `[atendido/pendente/aceito/aguardando/em-andamento]`
- `BACKLOG.md` atualizado (item 1.1 removido, 1.2 renumerado pra 1.1)
- Plugin publicado via `/marketplace-tools:publish-plugin sdd-workflow patch` → cache mostra v1.0.3
- Smoke test: invocar `/sdd-workflow:status` em projeto fictício; verificar que output não contém emojis e mantém legibilidade

### Para v1.0.4 (refactor)

- 4 references criados em `skills/sdd-workflow/references/fluxo-{pre-spec,spec,build,ship}.md` (já criados em commits c13f20c, cd3ef23, 3507ed6, 6ef10cb)
- SKILL.md principal entre 300 e 360 linhas (validar com `wc -l`)
- Cada seção de estágio na SKILL principal tem o pointer `> Detalhe operacional em "references/fluxo-X.md"` ao final
- Listas críticas preservadas inline (validar): 7 perguntas Discovery, 3 sub-componentes Stack, 8 itens Requirements, 9 itens Design, 7 itens Spike, 7 features típicas Tasks, 5 ajustes convenção SDD Implementation, 5 passos fluxo Audit, 7 passos Delivery, comportamento Deploy por 5 tiers
- Apêndice da SKILL atualizado com as 4 references novas
- Frontmatter `version: 1.0.0` → `version: 1.1.0` na SKILL principal
- `BACKLOG.md` atualizado (item ex-1.2 / agora 1.1 removido)
- Plugin publicado via `/marketplace-tools:publish-plugin sdd-workflow patch` → cache mostra v1.0.4
- **Smoke test factual nesta sessão**: `wc -l` da SKILL principal entre 300-360, 4 pointers presentes (`grep -c "references/fluxo-"`), 4 entries novos no Apêndice, contagem de listas críticas preservadas
- **Smoke test comportamental como follow-up do user pós-restart do Desktop**: invocar trigger natural ("novo projeto") em projeto fictício, observar carregamento dos references corretos por fase

---

## 10. Próximos passos

1. Aprovação do spec (este documento)
2. Implementation plan via `superpowers:writing-plans` cobrindo as duas fases (v1.0.3 e v1.0.4)
3. Execução das duas fases em commits separados, com publicação após cada uma
