# SDD Workflow v3.0 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Evoluir plugin `sdd-workflow` de v0.1.1/SKILL 2.1.0 pra v0.2.0/SKILL 3.0.0 — playbook SDD com 4 estágios nomeados (Pré-spec/Spec/Build/Ship), tier projetado em 5 níveis, catálogo de tipo_projeto (web-saas/claude-plugin/hubspot/outro), inventário formal de dependências, integração com superpowers (Modo 2) e demais skills (Modo 1), auditoria expandida 13×5, sub-skill dedicada de Promoção de Tier, 5 slash commands (start/status/gate/audit/promote-tier), templates extraídos, references com progressive disclosure, EARS pra Requirements + BDD pra Tasks 🔒, princípio TDD canônico Red/Green/Refactor (incluindo Refactor adaptado pra markdown — 5.1.2 do spec).

**Architecture:** Plugin Claude Code Level 3 (próprio do marketplace `aj-openworkspace`). 1 skill principal coesa (orquestra fluxo end-to-end) + 1 sub-skill dedicada (Promoção de Tier) + 5 commands + diretório `templates/` (8 arquivos preenchíveis pelo SDD em projetos) + diretório `references/` (8 arquivos de progressive disclosure pra detalhe sob demanda). Spec em `docs/superpowers/specs/2026-04-29-sdd-workflow-evolucao-design.md` (commit `87efaaf`).

**Tech Stack:** Markdown + JSON + YAML frontmatter. Bash via `git`, `grep`, `wc`, `jq`, `yq`/python-yaml, `claude plugin validate`, `find`. Sem código executável (sem testes unit clássicos — ver Convenções abaixo).

---

## Convenções deste plano

### Ciclo TDD canônico adaptado pra arquivos não-código

Esse plugin é primariamente markdown + JSON sem código executável. O ciclo TDD canônico (Red/Green/Refactor) aplica universalmente conforme princípio 5 + sub-seção 5.1.2 do spec, com adaptações:

1. **Red (define check + run-fail)** — bash command que verifica estrutura/conteúdo esperado. Roda antes do arquivo existir → FAIL esperado.
2. **Green (write file)** — criar/editar arquivo com primeiro draft, "committing sins necessárias" (foco em estrutura passar no check).
3. **Verify Green (run check passes)** — mesmo bash command roda → PASS.
4. **Refactor** — revisar arquivo: eliminar redundância, condensar prosa verbosa em listas/tabelas, padronizar tom imperativo, reordenar seções pra coerência. Pra JSON: ordem canônica de campos, validação `jq .`. Pra frontmatter YAML: padronizar quoting, ordem de campos. Refactor pode ser declarado **noop** explicitamente quando Green saiu limpo — mas decisão é consciente, não pulada.
5. **Re-verify (run check still passes)** — mesmo bash command → PASS (Refactor não pode quebrar contrato).
6. **Commit** — git add + git commit com mensagem descritiva.

### Padrões de check de validação por tipo de arquivo

| Tipo | Check de validação |
|---|---|
| Markdown skill (`SKILL.md`) | `head -1 <path> = "---"` (frontmatter inicia) + `grep -E "^name:" <path>` + `grep -E "^description:" <path>` + `wc -l <path> > 50` |
| Markdown template/reference | `test -f <path>` + `grep -E "^# " <path>` (tem H1) + `wc -l <path> > 10` |
| Markdown command | `head -1 <path> = "---"` + `grep -E "^description:" <path>` |
| JSON | `jq . <path>` (parse válido) |
| Frontmatter YAML | `python3 -c "import yaml; yaml.safe_load(open('<path>').read().split('---')[1])"` |

### Mensagens de commit

- Em pt-BR (preferência global do user)
- Sem `Co-Authored-By: Claude` (preferência global do user)
- Padrão: `sdd-workflow: <ação curta em verbo imperativo>` (ex: `sdd-workflow: criar references/tiers.md`)
- Pra commits intermediários: ok ter PR scope
- Commit final da v0.2.0: bumpa version + descreve evolução

### Convenções específicas do repo `aj-openworkspace`

- Worktree atual: `claude/great-booth-3117c5` (já criado pela brainstorming skill)
- Branch padrão do repo: `main` (commits vão direto a menos que abrir PR)
- Repo público — não commitar dados profissionais sensíveis
- `.claude/` está no `.gitignore` — não tentar commitar settings
- Plugin Level 3: version vive em `marketplace.json` (não em `plugin.json`); workaround dos bugs de cache do Desktop é encapsulado em `/marketplace-tools:publish-plugin` (mas execução do publish está fora do escopo deste plano — ver Fase 9)

### Princípio absoluto pra esta implementação

A SKILL.md principal nova **substitui** a v2.1.0 atual (16K, 500 linhas). A v2.1.0 era auto-contida; a v3.0.0 delega progressive disclosure aos `references/` e templates extraídos pros `templates/`. **Não preservar conteúdo da v2.1.0** por nostalgia — o conteúdo válido foi absorvido (e expandido) na v3.0.0 conforme spec.

---

## File Structure

Mapa completo de arquivos a criar/modificar/deletar (relativo ao worktree `/Users/andrejunges/repos/aj-openworkspace/.claude/worktrees/great-booth-3117c5/`):

### Criar (novos arquivos — 24 no total)

```
plugins/sdd-workflow/
├── commands/
│   ├── start.md                                          (1)
│   ├── status.md                                         (2)
│   ├── gate.md                                           (3)
│   ├── audit.md                                          (4)
│   └── promote-tier.md                                   (5)
└── skills/
    ├── sdd-workflow/
    │   ├── templates/
    │   │   ├── constitution.md                           (6)
    │   │   ├── requirements.md                           (7)
    │   │   ├── design.md                                 (8)
    │   │   ├── tasks.md                                  (9 — plano-mestre, índice de features)
    │   │   ├── plan-feature.md                           (10 — template writing-plans)
    │   │   ├── progress.md                               (11)
    │   │   ├── spike.md                                  (12)
    │   │   └── audit.md                                  (13)
    │   └── references/
    │       ├── tipos-projeto.md                          (14)
    │       ├── tiers.md                                  (15)
    │       ├── stacks.md                                 (16)
    │       ├── inventario-dependencias.md                (17)
    │       ├── audit-dimensoes.md                        (18)
    │       ├── integracao-skills.md                      (19)
    │       ├── alvos-deploy.md                           (20)
    │       └── linguagens-especificacao.md               (21)
    └── sdd-promote-tier/
        └── SKILL.md                                      (22)
```

### Modificar (3 arquivos existentes)

```
plugins/sdd-workflow/
├── .claude-plugin/plugin.json                            (23 — atualizar description)
├── README.md                                             (24 — atualizar com v3.0)
└── skills/sdd-workflow/SKILL.md                          (25 — REESCREVER de 2.1.0 pra 3.0.0)
.claude-plugin/marketplace.json                           (26 — bump 0.1.1 → 0.2.0)
```

### Total

- 24 novos arquivos
- 4 arquivos modificados (3 do plugin + 1 marketplace.json no root)
- 0 deletados (a SKILL.md é reescrita, não deletada)

---

## Plano global — 9 fases, 33 tasks

| Fase | Escopo | Tasks |
|---|---|---|
| 1 | Estrutura de diretórios | Task 1 |
| 2 | References (8 arquivos) | Tasks 2-9 |
| 3 | Templates (8 arquivos) | Tasks 10-17 |
| 4 | SKILL.md principal (reescrita em 6 partes) | Tasks 18-23 |
| 5 | Sub-skill `sdd-promote-tier` | Task 24 |
| 6 | Commands (5 arquivos) | Tasks 25-29 |
| 7 | Metadata (`plugin.json`, `README.md`) | Tasks 30-31 |
| 8 | Bump version no marketplace | Task 32 |
| 9 | Validação final + commit | Task 33 |

**Ordem importa**: References (Fase 2) são pré-requisito porque a SKILL.md (Fase 4) referencia elas. Templates (Fase 3) também são pré-requisito porque a SKILL.md instrui copiar deles. Commands (Fase 6) podem vir depois da SKILL.md porque dependem da skill estar pronta. Bump (Fase 8) sempre antes da validação final.

---

## Fase 1 — Estrutura de diretórios

### Task 1: Criar diretórios novos

**Files:**
- Create dir: `plugins/sdd-workflow/commands/`
- Create dir: `plugins/sdd-workflow/skills/sdd-workflow/templates/`
- Create dir: `plugins/sdd-workflow/skills/sdd-workflow/references/`
- Create dir: `plugins/sdd-workflow/skills/sdd-promote-tier/`

- [ ] **Step 1.1: Define check (Red)**

```bash
test -d plugins/sdd-workflow/commands && \
test -d plugins/sdd-workflow/skills/sdd-workflow/templates && \
test -d plugins/sdd-workflow/skills/sdd-workflow/references && \
test -d plugins/sdd-workflow/skills/sdd-promote-tier && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 1.2: Run check (FAIL esperado)**

Run: comando acima
Expected output: `FAIL` (nenhum dos diretórios existe ainda)

- [ ] **Step 1.3: Criar diretórios (Green)**

```bash
mkdir -p plugins/sdd-workflow/commands
mkdir -p plugins/sdd-workflow/skills/sdd-workflow/templates
mkdir -p plugins/sdd-workflow/skills/sdd-workflow/references
mkdir -p plugins/sdd-workflow/skills/sdd-promote-tier
```

- [ ] **Step 1.4: Verify Green**

Run: comando do step 1.1
Expected output: `PASS`

- [ ] **Step 1.5: Refactor**

**Decisão**: noop. Estrutura plana e sem redundância. Não há nada a refatorar.

- [ ] **Step 1.6: Commit**

```bash
git add plugins/sdd-workflow/commands plugins/sdd-workflow/skills/sdd-workflow/templates plugins/sdd-workflow/skills/sdd-workflow/references plugins/sdd-workflow/skills/sdd-promote-tier
git commit -m "sdd-workflow: criar estrutura de diretórios pra v3.0 (commands, templates, references, sub-skill)"
```

Nota: `git add <dir>` em diretório vazio não funciona (git não rastreia diretórios vazios). Como vamos popular cada diretório nas próximas tasks, este step pode ser combinado com a primeira task de cada Fase. **Ajuste prático**: pular o commit standalone aqui — a Fase 2 (Task 2) vai criar arquivo dentro de `references/` e o `git add` daquela task implicitamente registra o diretório. Se preferir commit standalone, criar `.gitkeep` em cada dir vazio.

**Recomendação**: pular commit standalone, deixar o primeiro arquivo de cada Fase fazer o commit. Step 1.6 vira noop. Steps 1.1-1.5 ainda valem como verificação de que o `mkdir -p` funcionou.

---

## Fase 2 — References (8 arquivos)

References vivem em `plugins/sdd-workflow/skills/sdd-workflow/references/` e implementam progressive disclosure: a SKILL.md aponta pra elas pra detalhe sob demanda. Tom: imperativo, opinativo (house style do repo). H2 numerados separados por `---`. Tabelas pra comparações.

### Task 2: `references/tiers.md` — escala de 5 níveis + matriz Audit + princípio "tier projetado"

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md`

- [ ] **Step 2.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md
test -f $F && \
grep -q "prototipo_descartavel" $F && \
grep -q "uso_interno" $F && \
grep -q "mvp" $F && \
grep -q "beta_publico" $F && \
grep -q "producao_real" $F && \
grep -q "tier projetado" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 2.2: Run check (FAIL esperado)**

Expected: `FAIL` (arquivo não existe).

- [ ] **Step 2.3: Write file (Green)**

Conteúdo completo:

````markdown
# Tiers — escala de maturidade do produto

Reference do plugin `sdd-workflow` (v3.0). A escolha do tier determina dimensões obrigatórias da Audit, recursos mínimos da stack, e rigor do Ship.Deploy.

## 1. Princípio: tier projetado, não estado atual

O tier é a **visão final** do desenvolvimento, não o estado atual. Se eu começo um sistema sabendo que será MVP em 3 meses, o tier é `mvp` desde o dia 1 — mesmo que hoje o código seja só protótipo. Os gates da Audit são executados pra esse tier alvo.

Mudança de tier = decisão consciente, registrada via Promoção de Tier (sub-skill `sdd-promote-tier`).

---

## 2. Os 5 níveis

| # | Tier | Significado |
|---|---|---|
| 1 | `prototipo_descartavel` | Validar conceito, depois jogar fora |
| 2 | `uso_interno` | Eu/equipe pequena, não vai pra fora |
| 3 | `mvp` | Primeiros usuários reais, escopo pequeno |
| 4 | `beta_publico` | Público maior, ainda em validação |
| 5 | `producao_real` | Sistema sério, manutenção contínua |

**Default quando não declarado**: pedir explicitamente sempre. Sem fallback silencioso.

---

## 3. Matriz de obrigatoriedade da Audit (13 dimensões × 5 tiers)

| Dimensão | protótipo | interno | MVP | beta púb. | prod real |
|---|---|---|---|---|---|
| 1. Segurança | — | obrigatório | obrigatório | obrigatório | obrigatório |
| 2. Isolamento dados | — | obrigatório | obrigatório | obrigatório | obrigatório |
| 3. Integridade dados | perguntar | obrigatório | obrigatório | obrigatório | obrigatório |
| 4. Performance | — | perguntar | perguntar | obrigatório | obrigatório |
| 5. Responsividade | — | perguntar | obrigatório | obrigatório | obrigatório |
| 6. UX/Layout | — | perguntar | obrigatório | obrigatório | obrigatório |
| 7. Código | perguntar | obrigatório | obrigatório | obrigatório | obrigatório |
| 8. Lógica de negócio | obrigatório | obrigatório | obrigatório | obrigatório | obrigatório |
| 9. Acessibilidade | — | — | perguntar | perguntar | perguntar |
| 10. Observabilidade | — | — | opcional | obrigatório | obrigatório |
| 11. Conformidade legal | — | — | opcional | obrigatório | obrigatório |
| 12. Documentação operacional | perguntar | obrigatório | obrigatório | obrigatório | obrigatório |
| 13. Manutenibilidade | — | — | perguntar | perguntar | obrigatório |

**Legenda**:
- `obrigatório`: gate falha sem cobertura. Achados 🔴 bloqueiam Delivery.
- `opcional`: IA recomenda e roda; achados informativos, não bloqueiam.
- `perguntar`: IA pergunta no início da Audit; resposta registrada na constitution.
- `—`: dimensão não rodada nesse tier; explicitamente pulada.

---

## 4. Impactos em outras fases

| Fase | Como o tier impacta |
|---|---|
| Pré-spec.Stack | Define recursos mínimos (DB gerenciado vs SQLite, etc.) |
| Spec.Design | Define rate limiting, escalabilidade, observabilidade |
| Build.Implementation | Define cobertura mínima de testes |
| Ship.Audit | Define dimensões obrigatórias (matriz acima) |
| Ship.Deploy | Define rollback, monitoramento, alertas |

---

## 5. Promoção de Tier

Mudar de tier ao longo do projeto = decisão consciente registrada na constitution. Sub-skill `sdd-promote-tier` orquestra os 11 passos da promoção (incremental, não recomeça do zero).

Ver `references/audit-dimensoes.md` pra detalhe das dimensões e `sdd-promote-tier/SKILL.md` pro fluxo.
````

- [ ] **Step 2.4: Verify Green**

Run: check do step 2.1
Expected: `PASS`

- [ ] **Step 2.5: Refactor**

Revisar:
- Tom imperativo consistente? OK (usa "É a visão final", "pedir explicitamente sempre")
- Redundância entre seções? Seções 2 e 3 referenciam tiers — não há redundância, são níveis diferentes (significado vs matriz)
- Links cruzados funcionando? `references/audit-dimensoes.md` e `sdd-promote-tier/SKILL.md` serão criados em tasks futuras (Tasks 6 e 24) — links válidos no estado final
- **Decisão**: noop substantivo. Estrutura clara, sem redundância.

- [ ] **Step 2.6: Re-verify**

Run: check do step 2.1
Expected: `PASS` (mesmo, refactor não mudou conteúdo)

- [ ] **Step 2.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md
git commit -m "sdd-workflow: criar references/tiers.md (5 níveis + matriz Audit + princípio tier projetado)"
```

---

### Task 3: `references/tipos-projeto.md` — catálogo + características por tipo

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/tipos-projeto.md`

- [ ] **Step 3.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/tipos-projeto.md
test -f $F && \
grep -q "web-saas" $F && \
grep -q "claude-plugin" $F && \
grep -q "hubspot" $F && \
grep -q "outro" $F && \
grep -q "Critério.*adicionar.*tipo" $F && \
[ $(wc -l < $F) -gt 60 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 3.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 3.3: Write file (Green)**

Conteúdo completo:

````markdown
# Tipos de projeto — catálogo curado

Reference do plugin `sdd-workflow` (v3.0). O `tipo_projeto` registrado na constitution determina stack default sugerida e quais skills domain-específicas (Família B) entram em cena.

## 1. Catálogo (4 tipos)

| Tipo | Resumo |
|---|---|
| `web-saas` | Sistema web full-stack com UI rica |
| `claude-plugin` | Plugin para Claude Code (markdown + JSON, sem build system) |
| `hubspot` | Extensão HubSpot (CLI, custom objects, UI extensions, serverless) |
| `outro` | Stack Decision livre (research na Pré-spec.Stack obrigatório) |

---

## 2. Override sempre permitido

Override é permitido em todos os tipos. O **checkpoint da Pré-spec.Stack** força reflexão crítica sobre particularidades antes de aceitar a default — não é confirmação automática.

---

## 3. Detalhe por tipo

### 3.1 `web-saas`

- **Stack default**: ver `references/stacks.md#web-saas`
- **Skills B**: `frontend-design` (Spec.Design — UI distintiva); condicional: `claude-api`, `agent-sdk-dev:new-sdk-app`
- **Particularidades**:
  - Spec.Design tem seção Mobile-first obrigatória (375/768/1440)
  - Build.Implementation segue ordem típica Infra → Auth+Layout → CRUDs → Lógica → Dashboards → Polish
  - Brand colors definidas na constitution e refletidas no Tailwind config

### 3.2 `claude-plugin`

- **Stack default**: ver `references/stacks.md#claude-plugin`
- **Skills B**: `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin`
- **Particularidades**:
  - Pré-spec.Stack pergunta Level 1, 2 ou 3 (HEAD, SHA pin, local)
  - Spec.Design define quais componentes (commands, skills, hooks, agents, MCP)
  - Build.Implementation TDD = instalar local + testar manualmente; testes automatizados raros, validação via `plugin-validator`
  - **Ship.Audit substitui dimensões 1-7** pelo checklist do `plugin-dev:plugin-validator`. Mantém dimensões 8 (lógica = comportamento do plugin) e 12 (doc operacional = README)

### 3.3 `hubspot`

- **Stack default**: ver `references/stacks.md#hubspot`
- **Skills B**: nenhuma nativa no marketplace — usar guia interno do plugin SDD; `plugin:context7:context7` recomendado pra docs HubSpot atualizadas
- **Particularidades**:
  - Pré-spec.Constitution **exige seção Scopes** (princípio do menor privilégio)
  - Pré-spec.Stack faz inventário explícito de ferramentas (CLI + MCP + acesso a sandbox/prod) e ajusta fluxo conforme disponibilidade
  - Spec.Design tem seções dedicadas: Custom Objects schemas, UI Extensions hierarchy, Serverless endpoints, Webhooks payload contracts
  - Build.Implementation segue padrão HubSpot CLI (`hs project upload`, `hs project deploy`)
  - **Ship.Audit eleva dimensão Segurança ao máximo** — vazamento de token compromete CRM inteiro. Checks específicos: nenhum `hs` token versionado, scopes documentados, sandbox testado antes de prod

### 3.4 `outro`

- **Stack default**: N/A — Pré-spec.Stack faz Stack Decision livre baseada nas particularidades
- **Skills B**: caso a caso, decididas baseado em pesquisa do tipo
- **Particularidades**:
  - Pré-spec.Stack **obrigatoriamente** faz pesquisa de stack/padrões usando `plugin:context7:context7` (docs atualizadas) e/ou WebSearch antes de propor stack
  - Se durante a pesquisa identificar tipo conhecido (ex: "ah, é um MCP server"), oferece adicionar ao catálogo formal e migrar pra ele

---

## 4. Critério pra adicionar tipo novo ao catálogo

**2+ projetos do mesmo tipo nos últimos 6 meses.**

Adição vira tarefa de manutenção do plugin SDD: editar este arquivo, atualizar `references/stacks.md`, atualizar SKILL.md principal, eventualmente novo `references/tipo-X.md` se complexo.
````

- [ ] **Step 3.4: Verify Green**

Run: check do step 3.1
Expected: `PASS`

- [ ] **Step 3.5: Refactor**

Revisar:
- Tom imperativo: OK
- Redundância: cada subseção 3.1-3.4 cobre tipo distinto; sem repetição
- Links cruzados: `references/stacks.md` será criado na Task 4 — link válido no estado final
- **Decisão**: noop. Estrutura limpa.

- [ ] **Step 3.6: Re-verify**

Expected: `PASS`

- [ ] **Step 3.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/tipos-projeto.md
git commit -m "sdd-workflow: criar references/tipos-projeto.md (catálogo: web-saas, claude-plugin, hubspot, outro)"
```

---

### Task 4: `references/stacks.md` — stack default por tipo + alternativas

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/stacks.md`

- [ ] **Step 4.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/stacks.md
test -f $F && \
grep -q "## .*web-saas" $F && \
grep -q "## .*claude-plugin" $F && \
grep -q "## .*hubspot" $F && \
grep -q "React" $F && \
grep -q "PostgreSQL" $F && \
grep -q "HubSpot CLI" $F && \
[ $(wc -l < $F) -gt 70 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 4.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 4.3: Write file (Green)**

Conteúdo completo:

````markdown
# Stacks — catálogo por tipo de projeto

Reference do plugin `sdd-workflow` (v3.0). Stack default sugerida por `tipo_projeto`. **Override é permitido em todos** — o checkpoint da Pré-spec.Stack força reflexão crítica antes de aceitar default.

## 1. Princípio: stack varia também por tier

A stack default escala com o tier. Exemplo `web-saas`: `uso_interno` aceita Postgres em Docker local; `mvp` puxa PG gerenciado leve (Supabase free, Neon free); `beta_publico+` exige PG gerenciado com backup, CDN, error tracking.

---

## 2. `web-saas`

| Camada | uso_interno | mvp | beta_publico+ |
|---|---|---|---|
| Frontend | React + Vite + Tailwind + shadcn/ui | (mesmo) | (mesmo) + CDN |
| Backend | Node.js + Express + Prisma | (mesmo) | (mesmo) + rate limiting |
| Banco | PostgreSQL Docker | PG gerenciado (Supabase/Neon/RDS) | + backup + replicas |
| Auth | JWT caseiro | (mesmo) ou Auth0/Clerk | Auth0/Clerk/Supabase Auth |
| Gráficos | Recharts | (mesmo) | (mesmo) |
| Brand colors | definir na constitution | (mesmo) | (mesmo) |

---

## 3. `claude-plugin`

| Camada | Default |
|---|---|
| Skill files | Markdown + frontmatter YAML |
| Commands | Markdown + frontmatter YAML |
| Hooks | Shell scripts |
| Plugin manifest | `.claude-plugin/plugin.json` (JSON) |
| Marketplace entry | `.claude-plugin/marketplace.json` (JSON, no marketplace que vai hospedar) |
| Validação | `claude plugin validate .` |
| Versionamento | SemVer no `marketplace.json` (Level 3) ou `plugin.json` (Level 1/2) |

**Sem build system, sem test runner**. TDD adaptado pra markdown — ver `references/linguagens-especificacao.md` e a seção 5.1.2 do spec do plugin SDD pra detalhe.

---

## 4. `hubspot`

| Camada | Default |
|---|---|
| CLI | HubSpot CLI (`hs`) |
| Auth | Private App com scopes mínimos (preferir API key sobre OAuth quando viável) |
| Custom Objects | Schema JSON (em `src/objects/`) |
| UI Extensions | React + HubSpot Extensions SDK (em `src/extensions/`) |
| Serverless Functions | Node.js (em `src/serverless/`) |
| Webhooks | Endpoints registrados na app config |
| Secrets | `.env` ou `hs auth` (NUNCA versionados) |

---

## 5. `outro`

Sem default. Pré-spec.Stack obrigatoriamente:
1. Pesquisa via `plugin:context7:context7` ou WebSearch + WebFetch
2. Avalia padrões da comunidade pra tipo identificado
3. Propõe stack com justificativa
4. Se durante pesquisa identificar tipo conhecido, oferece migrar pra catálogo formal

---

## 6. Override por particularidade

Mesmo nos tipos com default, o checkpoint da Pré-spec.Stack pergunta:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Override é decisão registrada na constitution com justificativa. Skipping da pergunta = anti-pattern.
````

- [ ] **Step 4.4: Verify Green**

Run: check do step 4.1
Expected: `PASS`

- [ ] **Step 4.5: Refactor**

Revisar:
- Tom OK
- Tabela `web-saas` por tier é mais densa que prosa equivalente — boa transformação
- **Decisão**: noop substantivo.

- [ ] **Step 4.6: Re-verify**

Expected: `PASS`

- [ ] **Step 4.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/stacks.md
git commit -m "sdd-workflow: criar references/stacks.md (stack default por tipo + variação por tier)"
```

---

### Task 5: `references/inventario-dependencias.md` — 4 categorias + comportamento se faltar

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/inventario-dependencias.md`

- [ ] **Step 5.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/inventario-dependencias.md
test -f $F && \
grep -q "CLI" $F && \
grep -q "MCP" $F && \
grep -q "credenciais" $F && \
grep -q "bloquear" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 5.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 5.3: Write file (Green)**

Conteúdo completo:

````markdown
# Inventário de dependências — checagem na Pré-spec.Stack

Reference do plugin `sdd-workflow` (v3.0). Princípio inviolável 3: **defensividade sobre dependências externas** — não pressupor CLI/MCP/skill/credencial sem inventário formal.

## 1. Quando acontece

Durante a Pré-spec.Stack, junto com a decisão técnica e o alvo de deploy. **3 sub-componentes obrigatórios**:

1. Inventário de dependências (este reference)
2. Stack técnica (`references/stacks.md`)
3. Alvo de deploy (`references/alvos-deploy.md`)

Tudo registrado na constitution como contrato versionado.

---

## 2. Categorias inventariadas

| Categoria | Exemplos | Comportamento se faltar |
|---|---|---|
| **CLI do sistema** | `gh`, `hs` (HubSpot CLI), `docker`, `node`, `python`, `claude` (Claude Code) | Avisar e orientar instalação. Bloquear se essencial pra fase atual; senão registrar e continuar com alternativa |
| **MCP servers** | HubSpot MCP, GitHub MCP, browser MCPs (`mcp__Claude_in_Chrome__*`) | Avisar e oferecer alternativa (ex: WebFetch no lugar de browser MCP) |
| **Skills do marketplace** | `superpowers:*`, `plugin-dev:*`, `marketplace-tools:*`, `frontend-design`, `claude-api`, etc. | Família A (Modo 2) bloqueia se essencial faltar; Famílias B/C/D (Modo 1) registram ausência mas continuam |
| **Acesso a serviços externos** | API keys, tokens, contas (HubSpot portal, OpenAI, etc.) | Bloquear avanço se essencial; registrar como pré-requisito |

---

## 3. Família A é exigência (Modo 2)

A IA inventaria todas as skills da Família A no início da Pré-spec e bloqueia se essenciais faltarem:

- `superpowers:brainstorming` (essencial — Pré-spec.Discovery)
- `superpowers:writing-plans` (essencial — Build.Tasks)
- `superpowers:test-driven-development` (essencial — Build.Implementation)
- `superpowers:executing-plans` ou `superpowers:subagent-driven-development` (pelo menos uma — Build.Implementation)
- `superpowers:verification-before-completion` (essencial)
- `superpowers:systematic-debugging` (essencial)

Opcionais (avisar se faltar mas continuar):
- `superpowers:using-git-worktrees`
- `superpowers:dispatching-parallel-agents`
- `superpowers:requesting-code-review`
- `superpowers:finishing-a-development-branch`

---

## 4. Famílias B/C/D são sugestões (Modo 1)

Famílias B (domain-específicas), C (qualidade/finalização sem `humanizador`) e D (situacionais) são sugeridas conforme contexto. Ausência registrada na constitution como item opcional não atendido. Não bloqueia.

Ver `references/integracao-skills.md` pra detalhe completo das famílias.

---

## 5. Formato de registro na constitution

Bloco YAML adicional ou seção textual no `specs/constitution.md`:

```yaml
inventario:
  cli_essencial:
    - gh         # disponível
    - docker     # disponível
  cli_opcional: []
  mcp_essencial:
    - github-mcp # disponível
  mcp_opcional:
    - hubspot-mcp # AUSENTE — usando API direta como alternativa
  skills_familia_a:
    - superpowers:brainstorming    # disponível
    - superpowers:writing-plans    # disponível
    # ... etc
  servicos_externos:
    - github_token    # disponível em env
    - openai_api_key  # AUSENTE — bloqueado pra feature X
```

---

## 6. Mudança no inventário ao longo do projeto

Inventário evolui conforme o projeto cresce (novas dependências entram, outras saem). Mudança = decisão registrada com data e motivação no histórico de decisões da constitution.
````

- [ ] **Step 5.4: Verify Green**

Run: check do step 5.1
Expected: `PASS`

- [ ] **Step 5.5: Refactor**

Revisar:
- Tom imperativo OK
- YAML exemplo é didático e mostra estado misto (disponível/ausente)
- **Decisão**: noop.

- [ ] **Step 5.6: Re-verify**

Expected: `PASS`

- [ ] **Step 5.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/inventario-dependencias.md
git commit -m "sdd-workflow: criar references/inventario-dependencias.md (4 categorias + Família A bloqueia)"
```

---

### Task 6: `references/audit-dimensoes.md` — 13 dimensões + override por tipo + skills + output

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md`

- [ ] **Step 6.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md
test -f $F && \
grep -q "Segurança" $F && \
grep -q "Isolamento" $F && \
grep -q "Observabilidade" $F && \
grep -q "Acessibilidade" $F && \
grep -q "Manutenibilidade" $F && \
grep -q "claude-plugin" $F && \
grep -q "hubspot" $F && \
[ $(wc -l < $F) -gt 80 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 6.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 6.3: Write file (Green)**

Conteúdo completo:

````markdown
# Auditoria — 13 dimensões × 5 tiers

Reference do plugin `sdd-workflow` (v3.0). Detalhe das dimensões da Ship.Audit. Matriz de obrigatoriedade vive em `references/tiers.md` seção 3.

## 1. As 13 dimensões

### 1.1 Segurança
Senhas hardcoded, tokens expostos, CORS mal configurado, rotas desprotegidas, variáveis sensíveis no código, rate limiting, headers HTTP (helmet em Node).

### 1.2 Isolamento de dados
Confirmar que um perfil/tenant NÃO consegue acessar dados de outro via API. Testar com curl direto na API (não só via UI).

### 1.3 Integridade de dados
Validações de input no backend: valores negativos onde não deveria, campos obrigatórios, tipos errados, ranges (year/month, etc.).

### 1.4 Performance
Queries N+1, `await` em loop (usar `Promise.all`), imports desnecessários, bundle size do frontend, índices faltando no banco.

### 1.5 Responsividade
Testar em 375px (mobile), 768px (tablet), 1440px (desktop). Touch targets mínimo 20px. Tabelas com scroll horizontal. Drawer fecha ao navegar.

### 1.6 UX/Layout
Brand colors do projeto (constitution), loading states (Skeleton), empty states, toast para feedback (nunca `alert()`), consistência visual, espaçamentos.

### 1.7 Código
Imports errados ou não usados, `console.log` esquecidos, TODOs pendentes não trackados, try/catch em route handlers, error boundaries no React.

### 1.8 Lógica de negócio
Conferir cálculos e regras de negócio contra **dados reais** dos documentos de referência. Validar que resultados batem. **Esta dimensão é obrigatória em todos os tiers** porque é o coração do princípio inviolável 1.

### 1.9 Acessibilidade (a11y)
Contraste WCAG AA (4.5:1 pra texto normal), labels em inputs, alt em imagens, foco visível, navegação teclado, ARIA em componentes complexos.

### 1.10 Observabilidade
Logs estruturados (não só console.log), error tracking (Sentry-style), logs em boundaries críticos (auth, transações, integrações externas), health check endpoint, métricas básicas (latência, error rate).

### 1.11 Conformidade legal
LGPD se manipula dados pessoais (consentimento, opt-out, retenção, exportação), termos de uso/privacy policy, cookies com consentimento.

### 1.12 Documentação operacional
README cobre setup/run/deploy/troubleshooting, CHANGELOG, ADRs (Architecture Decision Records) se houve decisão arquitetural relevante.

### 1.13 Manutenibilidade
TODO/FIXME órfãos sem issue, duplicação significativa, arquivos/funções muito grandes, cobertura de teste mínima.

---

## 2. Override por `tipo_projeto`

### `claude-plugin`

Dimensões 1-7 (Segurança, Isolamento, Integridade, Performance, Responsividade, UX, Código) **substituídas** pelo checklist do `plugin-dev:plugin-validator`. Markdown não tem isolamento de dados nem queries N+1. Mantém:
- Dimensão 8 (Lógica de negócio = comportamento do plugin)
- Dimensão 12 (Documentação operacional = README do plugin)

### `hubspot`

- Dimensão 1 (Segurança) **eleva ao máximo** — checks específicos de tokens HubSpot vazados, scopes documentados, sandbox testado antes de prod
- Dimensão 2 (Isolamento) verifica não-vazamento entre portais

---

## 3. Skills usadas na Audit

- `superpowers:dispatching-parallel-agents` — paraleliza dimensões independentes (todas as obrigatórias rodam em paralelo)
- `superpowers:requesting-code-review` — review humana antes da Audit, se aplicável
- `code-review:code-review` — sub-agente pra dimensão Código
- `security-review` (built-in) — pra dimensão Segurança
- `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`

---

## 4. Output da Audit

`specs/audit-<YYYY-MM-DD>.md`. Estrutura:

```markdown
# Audit — [Projeto] — [Tier] — [Data]

## Dimensões executadas
[lista com 🟢/🟡/🔴 por dimensão]

## Achados 🔴 críticos (bloqueiam Delivery)
- [achado] em [arquivo:linha] — [recomendação de fix]

## Achados 🟡 importantes
[...]

## Achados 🟢 melhorias
[...]

## Dimensões puladas (com motivação)
- [dimensão] — [motivo: tier não exige / pergunta do usuário negou / etc.]
```

Audit é **repetível** — múltiplos audits ao longo do projeto preservam histórico. Promoção de Tier dispara nova Audit focada nas dimensões novas obrigatórias.
````

- [ ] **Step 6.4: Verify Green**

Run: check do step 6.1
Expected: `PASS`

- [ ] **Step 6.5: Refactor**

Revisar:
- Cada dimensão tem 1-2 frases — densidade boa
- Override por tipo_projeto separado em seção própria
- **Decisão**: noop.

- [ ] **Step 6.6: Re-verify**

Expected: `PASS`

- [ ] **Step 6.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md
git commit -m "sdd-workflow: criar references/audit-dimensoes.md (13 dimensões + override por tipo)"
```

---

### Task 7: `references/integracao-skills.md` — mapa Família A/B/C/D + modos de integração

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/integracao-skills.md`

- [ ] **Step 7.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/integracao-skills.md
test -f $F && \
grep -q "Família A" $F && \
grep -q "Família B" $F && \
grep -q "Família C" $F && \
grep -q "Família D" $F && \
grep -q "Modo 2" $F && \
grep -q "humanizador" $F && \
[ $(wc -l < $F) -gt 80 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 7.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 7.3: Write file (Green)**

Conteúdo completo:

````markdown
# Integração com skills externas

Reference do plugin `sdd-workflow` (v3.0). Foco principal da evolução v3.0 (eixo 3 do brainstorming). Modo híbrido por família — A em **Modo 2** (instrução imperativa), demais em **Modo 1** (referência condicional/informativa).

## 1. Modos de integração

| Modo | Significado |
|---|---|
| **Modo 2** (imperativo) | A SKILL.md instrui "agora invoque X". Skill é passo padrão do fluxo. Se essencial não está instalada, IA bloqueia |
| **Modo 1** (referencial) | A SKILL.md sugere "considere usar X aqui". Skill é opcional. Ausência registrada mas não bloqueia |

---

## 2. Família A — Superpowers universais (Modo 2)

| Fase | Skills A invocadas |
|---|---|
| Pré-spec.Discovery | `superpowers:brainstorming` |
| Spec.Spike | `superpowers:test-driven-development`, `superpowers:systematic-debugging` |
| Build.Tasks | `superpowers:writing-plans` (com 5 ajustes de convenção SDD — ver SKILL.md principal) |
| Build.Implementation | `superpowers:executing-plans` ou `:subagent-driven-development` (escolha por quantidade/independência); `:test-driven-development`; `:systematic-debugging`; `:verification-before-completion`; `:using-git-worktrees` (quando feature precisa isolamento); `:dispatching-parallel-agents` (quando subtasks independem) |
| Ship.Audit | `superpowers:requesting-code-review`; `:dispatching-parallel-agents` |
| Ship.Delivery | `superpowers:finishing-a-development-branch` |

---

## 3. Família B — Domain-específicas (Modo 1, condicional por `tipo_projeto`)

Mencionadas como referência quando o tipo se manifesta. Detalhe completo em `references/tipos-projeto.md`.

| `tipo_projeto` | Skills B referenciadas |
|---|---|
| `web-saas` | `frontend-design` (Spec.Design); condicional: `claude-api`, `agent-sdk-dev:new-sdk-app` |
| `claude-plugin` | `plugin-dev:create-plugin`, `:plugin-structure`, `:command-development`, `:hook-development`, `:skill-development`, `:agent-development`, `:mcp-integration`, `:plugin-validator`; `marketplace-tools:validate`, `:publish-plugin` |
| `hubspot` | (sem skill nativa) — guia próprio dentro do plugin SDD; `plugin:context7:context7` recomendado pra docs HubSpot atualizadas |
| `outro` | livre — usuário invoca o que fizer sentido |

---

## 4. Família C — Qualidade/finalização (Modo 1, **sem `humanizador`**)

| Ponto do fluxo | Skills C referenciadas |
|---|---|
| Build.Implementation | `commit-commands:commit` (substituir commits manuais); `simplify` (depois de bloco grande) |
| Ship.Audit | `code-review:code-review`; `security-review` (dimensão Segurança); `review` |
| Ship.Delivery | `commit-commands:commit-push-pr`; `pr-review-toolkit:review-pr` (se PR aberto) |
| Final de sessão | `claude-md-management:revise-claude-md`; `remember:remember`; `session-report:session-report` |
| Manutenção periódica | `claude-md-management:claude-md-improver` |

**Por que `humanizador` está fora**: o usuário invoca quando quer (skill global). Não faz parte do workflow SDD.

---

## 5. Família D — Situacionais (Modo 1, condicional)

| Quando | Skills D / ferramentas |
|---|---|
| Discovery/Requirements/Design precisam buscar info externa | **1ª escolha (free)**: `WebSearch` + `WebFetch` (built-in). **Páginas dinâmicas/JS**: browser MCPs (`mcp__Claude_in_Chrome__*` / `Kapture` / `Control_Chrome`). **Fallback (pago)**: `firecrawl` (`firecrawl-search`, `:scrape`, `:map`, `:crawl`, `:interact`) — só quando free não resolve |
| Stack ou Design precisam docs atualizadas de lib | `plugin:context7:context7` |
| Documento de referência é PDF | `anthropic-skills:pdf` |
| Documento de referência é Excel | `anthropic-skills:xlsx` |
| Documento de referência é Word | `anthropic-skills:docx` |
| Documento de referência é PowerPoint | `anthropic-skills:pptx` |
````

- [ ] **Step 7.4: Verify Green**

Run: check do step 7.1
Expected: `PASS`

- [ ] **Step 7.5: Refactor**

Revisar:
- Tabelas densas e legíveis
- "Por que `humanizador` está fora" deixa explícito (anti-pattern: omitir sem justificativa)
- **Decisão**: noop.

- [ ] **Step 7.6: Re-verify**

Expected: `PASS`

- [ ] **Step 7.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/integracao-skills.md
git commit -m "sdd-workflow: criar references/integracao-skills.md (4 famílias + 2 modos)"
```

---

### Task 8: `references/alvos-deploy.md` — alvos por tipo + tier

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/alvos-deploy.md`

- [ ] **Step 8.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/alvos-deploy.md
test -f $F && \
grep -q "decisão explícita" $F && \
grep -q "web-saas" $F && \
grep -q "claude-plugin" $F && \
grep -q "hubspot" $F && \
grep -q "marketplace" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 8.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 8.3: Write file (Green)**

Conteúdo completo:

````markdown
# Alvos de deploy — catálogo por tipo + tier

Reference do plugin `sdd-workflow` (v3.0). Alvo de deploy é **decisão explícita do projeto**, perguntada na Pré-spec.Stack e registrada na constitution. Tipo+tier nunca determinam alvo automaticamente — eles **sugerem** opções.

## 1. Princípio: alvo é decisão, não derivação

Mesmo dois projetos `web-saas` no tier `mvp` podem ter alvos completamente diferentes:
- Um deploya em Vercel + Supabase (full managed)
- Outro deploya em VPS DigitalOcean com Docker (mais controle)

A IA pergunta na Pré-spec.Stack:

> "Onde esse projeto vai viver? [opções típicas pra <tipo>+<tier>]"

E registra a escolha na constitution.

---

## 2. `web-saas`

| Tier | Alvos típicos |
|---|---|
| `prototipo_descartavel` | Roda local, sem deploy |
| `uso_interno` | Docker compose local, ou VPS pequeno |
| `mvp` | Hosting gerenciado: Vercel/Netlify (frontend), Railway/Render (backend), Supabase/Neon (DB) |
| `beta_publico` | Mesmo do `mvp` + rollback plan + error tracking + CDN |
| `producao_real` | Hosting com replicas, backup, alertas, on-call ou processo de incidente |

---

## 3. `claude-plugin`

Pré-spec.Stack pergunta explicitamente:

| Opção | Significado |
|---|---|
| **Local apenas** | Instalado via `claude plugin install /path/to/plugin`, sem repo nem marketplace |
| **Repo próprio sem marketplace** | Clonar e instalar via path do clone |
| **Marketplace privado** | Publicar em marketplace próprio ou da equipe (com bump de version) |
| **Marketplace público/comunitário** | Publicar pra distribuição ampla (com bump de version) |

Se a opção é "marketplace privado" ou "público" e o usuário tiver `marketplace-tools:publish-plugin` instalado, esse plugin é citado como atalho (automatiza o fluxo dos 6 passos com workaround dos bugs de cache documentados). Se não tiver, a SKILL.md descreve o fluxo manual: bump version → commit → push → invalidar cache.

---

## 4. `hubspot`

| Tier | Alvos típicos |
|---|---|
| `uso_interno` | Portal próprio (sandbox + prod do user) |
| `mvp+` | App publicado privadamente em portal de cliente |
| `producao_real` | App no marketplace HubSpot (se distribuível) |

Sandbox SEMPRE antes de prod. Pré-spec.Stack registra **portal IDs** (sandbox + prod) e **scopes** mínimos.

---

## 5. `outro`

Alvo decidido caso a caso na Pré-spec.Stack, junto com a Stack Decision livre.

---

## 6. Skills usadas no Ship.Deploy

- `superpowers:finishing-a-development-branch` — fechamento da branch
- `commit-commands:commit-push-pr` — abrir PR final se aplicável
- Skills domain-específicas pro alvo (ex: `marketplace-tools:publish-plugin` pra `claude-plugin` em marketplace)
````

- [ ] **Step 8.4: Verify Green**

Run: check do step 8.1
Expected: `PASS`

- [ ] **Step 8.5: Refactor**

Revisar:
- Princípio explícito ("alvo é decisão, não derivação") deixa claro
- **Decisão**: noop.

- [ ] **Step 8.6: Re-verify**

Expected: `PASS`

- [ ] **Step 8.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/alvos-deploy.md
git commit -m "sdd-workflow: criar references/alvos-deploy.md (alvo é decisão explícita por projeto)"
```

---

### Task 9: `references/linguagens-especificacao.md` — EARS + BDD + GEARS no radar

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md`

- [ ] **Step 9.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md
test -f $F && \
grep -q "EARS" $F && \
grep -q "Ubiquitous" $F && \
grep -q "Event-driven" $F && \
grep -q "Given.*When.*Then" $F && \
grep -q "GEARS" $F && \
grep -q "Mavin" $F && \
[ $(wc -l < $F) -gt 80 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 9.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 9.3: Write file (Green)**

Conteúdo completo:

````markdown
# Linguagens de especificação — EARS + BDD

Reference do plugin `sdd-workflow` (v3.0). Duas linguagens controladas operam em camadas diferentes do fluxo, cada uma no que faz melhor.

## 1. EARS — Easy Approach to Requirements Syntax

**Origem**: Alistair Mavin, Rolls-Royce, 2009. 15+ anos de uso em sistemas críticos (aerospace, defesa). Em consideração pra integração no SDD canônico ([Spec Kit Issue #1356](https://github.com/github/spec-kit/issues/1356)).

**Quando usar**: Spec.Requirements (definir o que o sistema deve fazer/não fazer).

### 1.1 Os 5 padrões EARS

| Padrão | Keyword | Estrutura |
|---|---|---|
| Ubiquitous | (nenhuma) | `O <sujeito> deve <comportamento>` |
| State-driven | `Enquanto` | `Enquanto <estado>, o <sujeito> deve <comportamento>` |
| Event-driven | `Quando` | `Quando <evento>, o <sujeito> deve <comportamento>` |
| Optional Feature | `Onde` | `Onde <feature presente>, o <sujeito> deve <comportamento>` |
| Unwanted Behavior | `Se / então não` | `Se <condição>, então o <sujeito> não deve <comportamento>` |
| Complex | combinação | `Enquanto X, quando Y, o <sujeito> deve Z` |

### 1.2 Exemplos

```ears
Ubiquitous:
  O sistema deve operar em pt-BR para textos de UI.

State-driven:
  Enquanto não houver sessão autenticada, o sistema deve redirecionar para /login.

Event-driven:
  Quando um pedido for fechado com valor maior que R$ 1000, o sistema deve aplicar
  desconto progressivo de 5% sobre o valor excedente.

Optional Feature:
  Onde o módulo de exportação estiver habilitado, o sistema deve oferecer botão
  "Exportar XLSX" na tela de relatórios.

Unwanted Behavior:
  Se o token JWT estiver expirado, então o sistema não deve processar a requisição
  e deve retornar HTTP 401.

Complex:
  Enquanto o usuário tiver perfil "admin", quando ele clicar em "Promover Tier",
  o sistema deve abrir o sub-fluxo de promoção registrando a ação no histórico.
```

### 1.3 Vantagens vs prosa

- Reduz ambiguidade drasticamente (linguagem controlada com gramática rígida)
- LLMs parseiam confiavelmente (sintaxe regular)
- Curva de aprendizado mínima (5-6 keywords)
- Validação humana fica trivial (cada requirement é uma frase verificável)

### 1.4 Anti-patterns EARS

- Misturar 2 padrões na mesma frase sem usar "Complex" (vira frase ambígua)
- Usar "deve" + "deveria" + "precisa" como sinônimos (escolher um e padronizar — recomendo `deve`)
- Sujeito implícito ("aplica desconto" sem dizer "o sistema deve aplicar") — sempre ser explícito

---

## 2. BDD — Behavior-Driven Development (Given-When-Then / Gherkin)

**Origem**: Dan North, ~2006. Mainstream em testing há quase 20 anos.

**Quando usar**: Build.Tasks 🔒 (cenários de teste com dados específicos), e Ship.Audit dimensão 8 (Lógica de negócio).

### 2.1 Estrutura

- **Given** — estado do mundo antes do comportamento
- **When** — comportamento sendo especificado
- **Then** — mudanças esperadas
- **And** — condições adicionais em qualquer dos blocos acima

### 2.2 Exemplo (Build.Tasks 🔒 — validação contra dados reais)

```gherkin
Cenário: Cálculo bate com planilha de referência (fevereiro 2026)
  Dado os dados reais da planilha "pedidos-fev-2026.xlsx"
  Quando recalculo total com a nova regra de desconto progressivo
  Então cada linha bate com a coluna "Total Final" da planilha
  E a soma total bate com a célula F999 da planilha
```

### 2.3 Por que BDD aqui em vez de EARS

EARS é otimizado pra requirements (o que o sistema deve fazer). Given-When-Then é otimizado pra cenários de teste executáveis com dados específicos. **Complementares**, não competem.

### 2.4 Anti-patterns BDD

- Cenários longos (>5 steps) — quebrar em cenários menores
- Abstração demais ("Dado um usuário válido" — qual usuário?) — usar dados reais específicos
- "Then" sem dados verificáveis ("Então funciona corretamente") — sempre asserção concreta

---

## 3. GEARS — possível evolução pra v4.0 (não adotado em v3.0)

**GEARS (Generalized EARS)** foi publicado em janeiro/2026 como extensão do EARS otimizada pra IA. Promete unificar specs e tests numa sintaxe só (substituindo a separação EARS+BDD adotada aqui).

**Decisão atual (v3.0)**: não adotar. GEARS é muito novo (3 meses), pouca tração comprovada, pode mudar de forma. EARS e BDD são maduros e LLMs modernos parseiam ambos sem dificuldade.

GEARS fica no radar pra revisão na v4.0 (6-12 meses), quando tiver sinais de adoção mainstream e o Spec Kit eventualmente posicionar-se sobre o tema.

---

## 4. Fontes

- [Alistair Mavin — EARS](https://alistairmavin.com/ears/)
- [Jama Software — Adopting EARS](https://www.jamasoftware.com/requirements-management-guide/writing-requirements/adopting-the-ears-notation-to-improve-requirements-engineering/)
- [Cucumber — History of BDD](https://cucumber.io/docs/bdd/history/)
- [Martin Fowler — Given When Then](https://martinfowler.com/bliki/GivenWhenThen.html)
- [GEARS — DEV Community](https://dev.to/sublang/gears-the-spec-syntax-that-makes-ai-coding-actually-work-4f3f)
````

- [ ] **Step 9.4: Verify Green**

Run: check do step 9.1
Expected: `PASS`

- [ ] **Step 9.5: Refactor**

Revisar:
- Anti-patterns EARS e BDD adicionados pra prevenir uso errado
- Fontes no fim seguem house style do repo
- **Decisão**: noop.

- [ ] **Step 9.6: Re-verify**

Expected: `PASS`

- [ ] **Step 9.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md
git commit -m "sdd-workflow: criar references/linguagens-especificacao.md (EARS + BDD + GEARS no radar)"
```

---

## Fase 3 — Templates (8 arquivos)

Templates vivem em `plugins/sdd-workflow/skills/sdd-workflow/templates/`. São esqueletos que a IA copia + preenche pro `specs/` do projeto-alvo. Tom: imperativo (instruções pra IA + placeholders claros pro usuário). Headers numerados, ordem de campos canônica.

### Task 10: `templates/constitution.md` — bloco YAML + identidade + princípios + stack + restrições + quality + inventário + alvo deploy + decisões

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/constitution.md`

- [ ] **Step 10.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/constitution.md
test -f $F && \
grep -q "tipo_projeto:" $F && \
grep -q "tier:" $F && \
grep -q "tier_decidido_em:" $F && \
grep -q "Identidade" $F && \
grep -q "Stack" $F && \
grep -q "Inventário" $F && \
grep -q "Alvo de deploy" $F && \
grep -q "Decisões Registradas" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 10.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 10.3: Write file (Green)**

Conteúdo completo:

````markdown
---
tipo_projeto: <web-saas | claude-plugin | hubspot | outro>
tier: <prototipo_descartavel | uso_interno | mvp | beta_publico | producao_real>
tier_decidido_em: YYYY-MM-DD
---

# Constitution — [Nome do Projeto]

## 1. Identidade

- **O que o projeto faz** (1 frase): [...]
- **Para quem é**: [...]
- **Que problema resolve**: [...]

## 2. Tier — justificativa

[Por que esse tier? Captura a intenção, não só a tag. Importante pra promoções futuras saberem se a justificativa original ainda vale.]

## 3. Princípios de Desenvolvimento

Herdados do `/CLAUDE.md` raiz + específicos deste projeto:

- Dados reais, nunca fictícios (princípio inviolável 1 do SDD)
- [Princípio específico 1]
- [Princípio específico 2]
- [...]

## 4. Stack

Stack default sugerida (ver `references/stacks.md` da skill SDD):

| Camada | Tecnologia |
|--------|-----------|
| [Camada] | [Tecnologia + justificativa se override] |

**Override de default** (se aplicável): [justificativa]

## 5. Inventário de dependências

```yaml
inventario:
  cli_essencial:
    - <ferramenta>   # disponível | AUSENTE
  cli_opcional: []
  mcp_essencial:
    - <mcp>          # disponível | AUSENTE
  mcp_opcional: []
  skills_familia_a:
    - superpowers:brainstorming    # disponível
    - superpowers:writing-plans    # disponível
    # ... (ver references/inventario-dependencias.md pra lista completa)
  servicos_externos:
    - <serviço>      # disponível em env | AUSENTE
```

## 6. Alvo de deploy

[Decisão explícita perguntada na Pré-spec.Stack — ver `references/alvos-deploy.md`]

- **Alvo**: [...]
- **Justificativa**: [...]

## 7. Restrições e Limites (v1)

- O que o sistema **NÃO** faz: [...]
- Limites de escopo: [...]
- Dependências externas: [...]

## 8. Quality Standards

Conforme tier definido:

- [Standards específicos pro tier — ver `references/tiers.md` pra obrigatoriedades]
- Mobile-first quando UI: 375px / 768px / 1440px (apenas se `tipo_projeto: web-saas`)
- Toast para feedback (nunca `alert()`) (apenas se UI)
- Empty states e loading states em todas as telas (apenas se UI)
- Isolamento de dados entre perfis (se aplicável)

## 9. Decisões Registradas

| Data | Decisão | Contexto |
|------|---------|----------|
| YYYY-MM-DD | Tier inicial: <tier> | <motivação> |
| YYYY-MM-DD | tipo_projeto: <tipo> | <motivação> |

(Promoções de Tier registradas automaticamente pela sub-skill `sdd-promote-tier` ao executar.)
````

- [ ] **Step 10.4: Verify Green**

Run: check do step 10.1
Expected: `PASS`

- [ ] **Step 10.5: Refactor**

Revisar:
- Bloco YAML inicial registra tipo_projeto + tier + data — fonte da verdade do plugin
- Seção 9 Decisões: tabela pronta pra histórico de tier
- Comentários `# disponível | AUSENTE` no inventário guiam preenchimento
- **Decisão**: noop.

- [ ] **Step 10.6: Re-verify**

Expected: `PASS`

- [ ] **Step 10.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/constitution.md
git commit -m "sdd-workflow: criar templates/constitution.md (YAML + 9 seções incluindo inventário + tier)"
```

---

### Task 11: `templates/requirements.md` — formato EARS por módulo

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/requirements.md`

- [ ] **Step 11.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/requirements.md
test -f $F && \
grep -q "EARS" $F && \
grep -q "Módulo" $F && \
grep -q "Ubiquitous" $F && \
grep -q "Event-driven" $F && \
grep -q "dados reais" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 11.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 11.3: Write file (Green)**

Conteúdo completo:

````markdown
# Requirements — [Nome do Projeto]

> **Formato**: EARS (Easy Approach to Requirements Syntax). Ver `references/linguagens-especificacao.md` da skill SDD pros 5 padrões. Cada requirement é uma frase precisa, sem ambiguidade.

## 1. Visão geral do sistema

[Resumo do que o sistema faz — 2-3 frases]

## 2. Usuários e perfis de acesso

| Perfil | Permissões | Exemplos de ações |
|---|---|---|
| [perfil] | [permissões] | [ações] |

## 3. Dados de referência

[Lista de documentos reais analisados — planilhas, PDFs, processos manuais. Linkar paths/URLs. **Princípio inviolável 1**: todos os dados de seed/teste vêm desses documentos, nunca fictícios.]

- [Documento 1]: [path] — [resumo do conteúdo]
- [Documento 2]: [path] — [resumo do conteúdo]

## 4. Módulos do sistema

### 4.1 [Nome do Módulo]

**Propósito**: [1 frase]

**Requirements (formato EARS)**:

```ears
Ubiquitous:
  O <sujeito> deve <comportamento>.

State-driven:
  Enquanto <estado>, o <sujeito> deve <comportamento>.

Event-driven:
  Quando <evento>, o <sujeito> deve <comportamento>.

Optional Feature:
  Onde <feature presente>, o <sujeito> deve <comportamento>.

Unwanted Behavior:
  Se <condição>, então o <sujeito> não deve <comportamento>.
```

**Regras de negócio críticas** (com exemplos de dados reais):

- [Regra 1] — exemplo: [valor da planilha X linha Y]
- [Regra 2] — exemplo: [...]

### 4.2 [Próximo módulo]

[...]

## 5. Requisitos não-funcionais

(Conforme tier — ver `references/tiers.md` da skill SDD)

- Performance: [...]
- Segurança: [...]
- Acessibilidade: [...]
- [...]

## 6. Dados iniciais (seed)

**Princípio inviolável**: NUNCA dados fictícios. Sempre extrair dos documentos de referência (seção 3).

- [Tabela X]: extraída de [documento Y]
- [...]

## 7. Fora do escopo V1

[O que NÃO está no V1 — defere pra V2 ou descarta]

- [...]
````

- [ ] **Step 11.4: Verify Green**

Run: check do step 11.1
Expected: `PASS`

- [ ] **Step 11.5: Refactor**

Revisar:
- Os 5 padrões EARS exemplificados no template guiam preenchimento
- Seção 3 (dados de referência) e seção 6 (seed) reforçam princípio 1
- **Decisão**: noop.

- [ ] **Step 11.6: Re-verify**

Expected: `PASS`

- [ ] **Step 11.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/requirements.md
git commit -m "sdd-workflow: criar templates/requirements.md (formato EARS por módulo)"
```

---

### Task 12: `templates/design.md` — schema + APIs + arquitetura

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/design.md`

- [ ] **Step 12.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/design.md
test -f $F && \
grep -q "Schema" $F && \
grep -q "API" $F && \
grep -q "Arquitetura" $F && \
grep -q "Spike" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 12.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 12.3: Write file (Green)**

Conteúdo completo:

````markdown
# Design Técnico — [Nome do Projeto]

> Stack base definida na `constitution.md` seção 4. Este doc detalha **como** implementar os requirements (`requirements.md`).

## 1. Stack confirmada

[Reproduzir tabela da constitution + qualquer ajuste decidido nesta fase]

## 2. Schema do banco (se aplicável)

### 2.1 Tabelas

```sql
-- Exemplo
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  -- ...
);
```

### 2.2 Relações e constraints

[Diagramas/listas de FKs, índices, constraints únicos]

### 2.3 Índices

[Quais índices criar e por quê]

## 3. API Routes

### 3.1 Endpoints

| Método | Path | Auth | Descrição |
|---|---|---|---|
| GET | /api/... | JWT/admin | [...] |
| POST | /api/... | JWT | [...] |

### 3.2 Payloads (request/response)

```typescript
// POST /api/...
interface RequestBody {
  field: string;
}

interface ResponseBody {
  id: string;
  field: string;
}
```

### 3.3 Autenticação e autorização

[JWT? OAuth? Como rotas admin diferem de rotas públicas]

## 4. Arquitetura de componentes (frontend, se aplicável)

[Hierarquia de componentes principais. Mobile-first se `tipo_projeto: web-saas`.]

## 5. Organização de pastas

```
src/
├── ...
```

## 6. Estratégia de seed

[Como popular o banco com dados reais (princípio 1). Scripts? SQL? Migrations?]

## 7. Bounded contexts (opcional — DDD parcial)

(Apenas se `tier: producao_real` com domínio complexo, ou `hubspot` extension grande)

[Identificar áreas com modelos distintos. Context map.]

Se não aplicável: noop, declarar "modelo único, sem bounded contexts".

## 8. Spike técnico requerido?

(Decisão da Spec.Design — entra na Fase Spec.Spike opcional)

- [ ] Sim — risco identificado: [descrição]. Cria `specs/spike.md`.
- [ ] Não — todas as tecnologias/integrações são conhecidas e validadas.

## 9. Decisões importantes

[Decisões arquiteturais relevantes — registrar também na constitution seção 9]

- [Decisão] — Por quê: [justificativa] — Alternativas consideradas: [...]
````

- [ ] **Step 12.4: Verify Green**

Run: check do step 12.1
Expected: `PASS`

- [ ] **Step 12.5: Refactor**

Revisar:
- Seção 7 (bounded contexts) condicional — guia decisão
- Seção 8 (Spike) checkbox — força decisão consciente
- Seção 9 (decisões) cross-link com constitution
- **Decisão**: noop.

- [ ] **Step 12.6: Re-verify**

Expected: `PASS`

- [ ] **Step 12.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/design.md
git commit -m "sdd-workflow: criar templates/design.md (schema + APIs + arquitetura + spike opcional)"
```

---

### Task 13: `templates/tasks.md` — plano-mestre (índice de features)

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md`

- [ ] **Step 13.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md
test -f $F && \
grep -q "plano-mestre" $F && \
grep -q "Feature" $F && \
grep -q "specs/plans" $F && \
grep -q "🔒" $F && \
[ $(wc -l < $F) -gt 30 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 13.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 13.3: Write file (Green)**

Conteúdo completo:

````markdown
# Tasks — plano-mestre

> Este arquivo é o **índice** das features. Cada feature tem seu próprio plano detalhado em `specs/plans/<feature>.md` (formato `superpowers:writing-plans` com 5 ajustes de convenção SDD — ver SKILL.md principal seção 5.1.1).

## 1. Visão geral

| # | Feature | Plano detalhado | 🔒 (validação dados reais) | Dependências | Status |
|---|---|---|---|---|---|
| 1 | [Nome da feature] | `specs/plans/01-<slug>.md` | sim/não | — | ⏸️ Aguardando |
| 2 | [Nome da feature] | `specs/plans/02-<slug>.md` | sim | Feature 1 | ⏸️ Aguardando |
| 3 | [...] | `specs/plans/03-<slug>.md` | não | Feature 2 | ⏸️ Aguardando |

**Legenda de status**: ⏸️ Aguardando · 🔄 Em andamento · ✅ Concluída · ❌ Bloqueada

## 2. Ordem de execução

(Ordem típica pra `web-saas` — adaptar conforme tipo de projeto)

1. **Infra e Setup** — Docker, scripts, banco
2. **Auth + Layout** — login, JWT, sidebar, mobile drawer (se UI)
3. **CRUDs administrativos** — entidades base
4. **Lógica de negócio 🔒** — cálculos, validações (validação obrigatória contra dados reais)
5. **Dashboards e visualizações** (se aplicável)
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** — isolamento, validações, responsividade

## 3. Marcação 🔒 — features de validação contra dados reais

Features marcadas 🔒 exigem validação obrigatória contra dados reais dos documentos de referência (princípio inviolável 1). Quality Gate por feature inclui mostrar comparativo ao usuário antes de avançar.

Exemplos típicos: cálculos financeiros, motor de regras de negócio, importadores/exportadores que devem replicar comportamento de planilha existente.

## 4. Gate por feature

Cada feature concluída exige:

- [ ] Todos os steps do plano detalhado executados
- [ ] Testes da feature passando (output mostrado)
- [ ] Se 🔒: comparativo contra dados reais mostrado e aprovado
- [ ] Aprovação humana antes de marcar ✅ e avançar pra próxima

## 5. Próximos passos

Cada feature segue ciclo individual via `superpowers:executing-plans` ou `superpowers:subagent-driven-development` no plano detalhado.
````

- [ ] **Step 13.4: Verify Green**

Run: check do step 13.1
Expected: `PASS`

- [ ] **Step 13.5: Refactor**

Revisar:
- Tabela com colunas claras (slug, plano, 🔒, deps, status)
- Seção 3 explica 🔒 explicitamente
- Seção 4 gate por feature reforça princípio
- **Decisão**: noop.

- [ ] **Step 13.6: Re-verify**

Expected: `PASS`

- [ ] **Step 13.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md
git commit -m "sdd-workflow: criar templates/tasks.md (plano-mestre — índice de features com 🔒)"
```

---

### Task 14: `templates/plan-feature.md` — template writing-plans com 5 ajustes SDD

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md`

- [ ] **Step 14.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md
test -f $F && \
grep -q "Implementation Plan" $F && \
grep -q "Refactor" $F && \
grep -q "🔒" $F && \
grep -q "Given.*When.*Then" $F && \
grep -q "writing-plans" $F && \
[ $(wc -l < $F) -gt 60 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 14.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 14.3: Write file (Green)**

Conteúdo completo:

````markdown
# [Nome da Feature] Implementation Plan

> **Para agentic workers**: REQUIRED SUB-SKILL — Use `superpowers:subagent-driven-development` (recomendado) ou `superpowers:executing-plans` pra executar este plano task-by-task. Steps usam checkbox (`- [ ]`).
>
> **Convenção SDD**: este plano segue o template do `superpowers:writing-plans` com **5 ajustes** de convenção SDD (ver SKILL.md principal seção 5.1.1):
> 1. Marcação 🔒 em tasks de validação contra dados reais (princípio inviolável 1)
> 2. Quebra por feature acontece no nível superior (`tasks.md` plano-mestre)
> 3. Quality Gate por feature absorve gates SDD antigos
> 4. Localização: `specs/plans/<feature>.md` no projeto
> 5. **Refactor explícito** no ciclo TDD canônico (Red/Green/**Refactor**)

**Goal:** [Uma frase descrevendo o que essa feature constrói]

**Architecture:** [2-3 frases sobre a abordagem]

**Tech Stack:** [Tecnologias-chave usadas nesta feature]

---

## Task N: [Nome do componente]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext:linhas`
- Test: `tests/exact/path/test.ext`

- [ ] **Step 1: Write the failing test (Red)**

```python
def test_specific_behavior():
    result = function(input_real_data)
    assert result == expected_real_value
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL com "function not defined" ou similar

- [ ] **Step 3: Write minimal implementation (Green)**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Refactor**

Improve design without changing behavior. Run tests novamente após cada mudança.

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS (mesmo comportamento)

**Decisão de noop**: se o código já saiu limpo no Step 3, declarar "Refactor: noop — Green saiu limpo, sem duplicação ou complexidade pra resolver". Decisão consciente, não pulada.

- [ ] **Step 6: Commit**

```bash
git add tests/path/test.py src/path/file.ext
git commit -m "feat: <descrição da task>"
```

---

## Task N+1: [Componente seguinte] 🔒 (se exige validação contra dados reais)

**Files:**
- [...]

**Cenário BDD de validação 🔒** (formato Given-When-Then — ver `references/linguagens-especificacao.md`):

```gherkin
Cenário: [Nome do cenário]
  Dado os dados reais da [planilha/PDF/sistema] "<arquivo>.xlsx"
  Quando [ação executada pelo sistema]
  Então [resultado bate com dados de referência]
  E [asserção adicional]
```

- [ ] **Step 1-5**: ciclo TDD canônico (mesmo padrão da Task N acima)

- [ ] **Step 6: Validação 🔒 contra dados reais**

Run: script que executa o cenário BDD acima contra dados reais
Expected: cada asserção bate com `<arquivo>.xlsx`. Mostrar comparativo ao usuário.

- [ ] **Step 7: Commit**

(Após aprovação humana do comparativo)

```bash
git add tests/path/test.py src/path/file.ext
git commit -m "feat: <descrição> 🔒 validado contra <arquivo>"
```

---

## Self-Review (após escrever o plano completo)

1. **Spec coverage**: cada requirement EARS de `requirements.md` tem task que implementa? Listar gaps.
2. **Placeholder scan**: nenhum "TBD"/"TODO"/"fill in"/"add validation"/"similar to Task N"
3. **Type consistency**: tipos, signatures, property names batem entre tasks?

Fix inline. Sem re-review.

---

## Execution Handoff

Após salvar este plano:

> "Plan complete and saved to `specs/plans/<feature>.md`. Two execution options:
> 1. **Subagent-Driven** (recommended) — fresh subagent per task, review between tasks
> 2. **Inline Execution** — executar nesta sessão usando `superpowers:executing-plans`
>
> Which approach?"
````

- [ ] **Step 14.4: Verify Green**

Run: check do step 14.1
Expected: `PASS`

- [ ] **Step 14.5: Refactor**

Revisar:
- Step 5 Refactor explícito + decisão de noop documentada
- Task 🔒 com Cenário BDD inline + Step 6 de validação
- **Decisão**: noop. Template fica completo.

- [ ] **Step 14.6: Re-verify**

Expected: `PASS`

- [ ] **Step 14.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md
git commit -m "sdd-workflow: criar templates/plan-feature.md (writing-plans + 5 ajustes SDD + Refactor explícito + 🔒 BDD)"
```

---

### Task 15: `templates/progress.md` — visão geral, features, status line

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md`

- [ ] **Step 15.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md
test -f $F && \
grep -q "Visão Geral" $F && \
grep -q "Features" $F && \
grep -q "Status Line" $F && \
grep -q "Pré-spec" $F && \
grep -q "Ship" $F && \
[ $(wc -l < $F) -gt 40 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 15.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 15.3: Write file (Green)**

Conteúdo completo:

````markdown
# Progresso — [Nome do Projeto]

Atualizado em: YYYY-MM-DD

## 1. Visão Geral

| Estágio | Fase | Status | Gate |
|---|---|---|---|
| Pré-spec | Discovery | ✅ | ✅ |
| Pré-spec | Constitution (com Setup) | ✅ | ✅ |
| Pré-spec | Stack | ✅ | ✅ |
| Spec | Requirements | ✅ | ✅ |
| Spec | Design | 🔄 Em andamento | — |
| Spec | Spike (opcional) | ⏸️ Aguardando | — |
| Build | Tasks | ⏸️ Aguardando | — |
| Build | Implementation | ⏸️ Aguardando | — |
| Ship | Audit | ⏸️ Aguardando | — |
| Ship | Delivery | ⏸️ Aguardando | — |
| Ship | Deploy | ⏸️ Aguardando | — |

## 2. Features

| # | Feature | Plano | 🔒 | Status | Progresso | Bloqueios |
|---|---|---|---|---|---|---|
| 1 | [Feature 1] | `specs/plans/01-...md` | não | ✅ | 100% | — |
| 2 | [Feature 2] | `specs/plans/02-...md` | sim | 🔄 | 60% | — |
| 3 | [Feature 3] | `specs/plans/03-...md` | não | ⏸️ | 0% | Depende: Feature 2 |

## 3. Status Line

(Inclui no final de cada resposta da IA durante implementação)

```
📊 [Feature Atual] ([Estágio.Fase]) → Próxima: [Feature Seguinte]
   Progresso: [●●●○○] X% | Concluídas: N/Total | Bloqueios: [Status]
```

## 4. Cálculo de Progresso

| Estágio | % |
|---|---|
| Pré-spec completo | 15% |
| Spec completo (Requirements + Design + Spike opcional) | 30% |
| Build.Tasks pronto | 35% |
| Build.Implementation (proporcional às features) | 35-90% |
| Ship.Audit concluído | 95% |
| Ship.Delivery validada | 98% |
| Ship.Deploy concluído | 100% |

## 5. Histórico de Promoções de Tier

(Atualizado pela sub-skill `sdd-promote-tier`)

| Data | De → Para | Motivação |
|---|---|---|
| YYYY-MM-DD | (inicial) → <tier> | Tier inicial decidido na Pré-spec |
````

- [ ] **Step 15.4: Verify Green**

Run: check do step 15.1
Expected: `PASS`

- [ ] **Step 15.5: Refactor**

Revisar:
- Tabela 1 cobre 11 fases dos 4 estágios (Pré-spec.{Discovery,Constitution,Stack} + Spec.{Requirements,Design,Spike} + Build.{Tasks,Implementation} + Ship.{Audit,Delivery,Deploy})
- Status Line inclui estágio + fase
- Histórico de tier preserva log
- **Decisão**: noop.

- [ ] **Step 15.6: Re-verify**

Expected: `PASS`

- [ ] **Step 15.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md
git commit -m "sdd-workflow: criar templates/progress.md (4 estágios × fases + status line + histórico tier)"
```

---

### Task 16: `templates/spike.md` — hipóteses, investigação, decisão

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/spike.md`

- [ ] **Step 16.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/spike.md
test -f $F && \
grep -q "Hipóteses" $F && \
grep -q "Investigação" $F && \
grep -q "Decisão" $F && \
grep -q "Risco técnico" $F && \
[ $(wc -l < $F) -gt 30 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 16.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 16.3: Write file (Green)**

Conteúdo completo:

````markdown
# Spike Técnico — [Nome do Risco]

> Spike é fase **opcional** entre Spec.Design e Build.Tasks. Entra quando o Design identificou risco técnico (integração externa nova, lib desconhecida, dependência crítica). Objetivo: validar hipótese antes de quebrar tasks. Box temporal sugerido: 1-3 dias.

## 1. Risco identificado

[O que faz esse spike necessário? Qual incerteza estamos resolvendo? Vir do Spec.Design seção 8.]

## 2. Hipóteses

### 2.1 Hipótese principal

[Frase clara: "Acreditamos que X funciona porque Y"]

### 2.2 Hipóteses alternativas

[Outras possibilidades caso a principal não se sustente]

## 3. Critérios de sucesso

[Como saberemos que a hipótese se confirmou? Métrica/comportamento concreto.]

- [ ] [Critério 1]
- [ ] [Critério 2]

## 4. Investigação

### 4.1 Setup mínimo

[Código/configuração mínima pra testar a hipótese. NÃO é production code — é prova de conceito.]

```
[código de prova]
```

### 4.2 Resultados

[O que aconteceu na prática? Logs, screenshots, medições.]

### 4.3 Surpresas

[Algo inesperado? Pode invalidar a hipótese ou apontar caminho diferente.]

## 5. Decisão

- [ ] **Hipótese confirmada** — seguir com a stack/abordagem original. Build.Tasks pode ser quebrada baseado no Design.
- [ ] **Hipótese parcialmente confirmada** — pivot menor: [descrever mudança].
- [ ] **Hipótese não confirmada** — pivot maior: [stack alternativa, abordagem diferente]. Atualizar Constitution e Spec.Design antes de avançar.

## 6. Próximo passo

→ Build.Tasks (com decisão acima absorvida)

## 7. Aprendizados pra registrar na Constitution

[Conhecimento técnico adquirido que vale ser registrado nas decisões da constitution]

- [Aprendizado 1]
- [Aprendizado 2]
````

- [ ] **Step 16.4: Verify Green**

Run: check do step 16.1
Expected: `PASS`

- [ ] **Step 16.5: Refactor**

Revisar:
- Seção 5 (Decisão) com 3 opções checkbox força decisão consciente
- Seção 7 conecta spike ao histórico de decisões da constitution
- **Decisão**: noop.

- [ ] **Step 16.6: Re-verify**

Expected: `PASS`

- [ ] **Step 16.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/spike.md
git commit -m "sdd-workflow: criar templates/spike.md (hipótese + investigação + decisão tripartite)"
```

---

### Task 17: `templates/audit.md` — relatório de auditoria

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md`

- [ ] **Step 17.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md
test -f $F && \
grep -q "Dimensões executadas" $F && \
grep -q "🔴" $F && \
grep -q "🟡" $F && \
grep -q "🟢" $F && \
grep -q "Dimensões puladas" $F && \
[ $(wc -l < $F) -gt 30 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 17.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 17.3: Write file (Green)**

Conteúdo completo:

````markdown
# Audit — [Projeto] — [Tier] — [YYYY-MM-DD]

> Output da Ship.Audit. Referência pras 13 dimensões: `references/audit-dimensoes.md` da skill SDD. Matriz de obrigatoriedade por tier: `references/tiers.md` seção 3.

## 1. Contexto

- **Tier alvo**: [tier]
- **tipo_projeto**: [tipo]
- **Audit anterior**: [link pra audit anterior se houver, ou "primeira audit"]

## 2. Dimensões executadas

| # | Dimensão | Obrigatório no tier? | Status | Achados |
|---|---|---|---|---|
| 1 | Segurança | obrigatório | 🟢 | 0 |
| 2 | Isolamento dados | obrigatório | 🟢 | 0 |
| 3 | Integridade dados | obrigatório | 🟡 | 2 |
| 4 | Performance | perguntar (sim) | 🟡 | 1 |
| 5 | Responsividade | obrigatório | 🟢 | 0 |
| 6 | UX/Layout | obrigatório | 🔴 | 1 |
| 7 | Código | obrigatório | 🟢 | 0 |
| 8 | Lógica de negócio | obrigatório | 🟢 | 0 |
| 9 | Acessibilidade | perguntar (não) | — | (pulado) |
| 10 | Observabilidade | opcional | 🟡 | 3 |
| 11 | Conformidade legal | opcional | 🟢 | 0 |
| 12 | Documentação operacional | obrigatório | 🟡 | 1 |
| 13 | Manutenibilidade | perguntar (não) | — | (pulado) |

(Se `tipo_projeto: claude-plugin`, dimensões 1-7 são substituídas pelo checklist do `plugin-dev:plugin-validator`. Mantém 8 e 12.)

## 3. Achados 🔴 críticos (bloqueiam Delivery)

### 3.1 [Título do achado]

- **Dimensão**: [#]
- **Onde**: [arquivo:linha]
- **Recomendação**: [fix concreto]
- **Status**: ❌ pendente

## 4. Achados 🟡 importantes

### 4.1 [Título]

- **Dimensão**: [#]
- **Onde**: [arquivo:linha]
- **Recomendação**: [fix concreto]
- **Status**: ❌ pendente | ✅ corrigido | 📋 aceito com justificativa

## 5. Achados 🟢 melhorias (nice-to-have)

[Lista de melhorias opcionais]

## 6. Dimensões puladas (com motivação)

- Dimensão 9 (Acessibilidade) — pergunta do usuário negou: "ferramenta interna, sem requisito de a11y"
- Dimensão 13 (Manutenibilidade) — pergunta do usuário negou: "projeto curto, manutenção mínima esperada"

## 7. Resumo

- 🔴 críticos: 1 — **bloqueia Delivery**
- 🟡 importantes: 7 (1 corrigido, 6 pendentes)
- 🟢 melhorias: 0

## 8. Próximo passo

→ Corrigir 🔴 críticos antes de Ship.Delivery. 🟡 podem ser aceitos com justificativa registrada na constitution.
````

- [ ] **Step 17.4: Verify Green**

Run: check do step 17.1
Expected: `PASS`

- [ ] **Step 17.5: Refactor**

Revisar:
- Tabela seção 2 mostra todas as 13 dimensões com status — visão de pássaro do audit
- Achados separados por severidade com paths/recomendações
- Seção 6 documenta puladas com motivação (transparência)
- **Decisão**: noop.

- [ ] **Step 17.6: Re-verify**

Expected: `PASS`

- [ ] **Step 17.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md
git commit -m "sdd-workflow: criar templates/audit.md (13 dimensões × tier + achados 🔴🟡🟢 + puladas)"
```

---

## Fase 4 — SKILL.md principal (reescrita em 6 partes)

A SKILL.md principal nova **substitui** a v2.1.0 atual. Tasks 18-23 são edits incrementais no mesmo arquivo. Task 18 substitui (Write) o arquivo antigo, Tasks 19-22 fazem append (Edit), Task 23 finaliza com Como Invocar + Apêndice + Refactor global + commit final consolidado.

**Importante**: cada task aqui é um Write/Edit incremental no mesmo arquivo, então o ciclo TDD adaptado roda contra o **estado parcial** do arquivo. O check de cada task verifica que aquela seção foi adicionada (sem quebrar as anteriores).

### Task 18: SKILL.md — Frontmatter + Princípios invioláveis + Visão geral

**Files:**
- Modify (substitui completamente): `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`

- [ ] **Step 18.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^name: sdd-workflow$" $F && \
grep -q "^version: 3.0.0$" $F && \
grep -q "^disable-model-invocation: true$" $F && \
grep -q "Princípios invioláveis" $F && \
grep -q "Pré-spec" $F && \
grep -q "Spec" $F && \
grep -q "Build" $F && \
grep -q "Ship" $F && \
grep -q "Linguagem ubíqua" $F && \
[ $(wc -l < $F) -gt 60 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 18.2: Run check (FAIL esperado)**

Expected: `FAIL` (arquivo atual é v2.1.0, não tem `version: 3.0.0` nem "Linguagem ubíqua").

- [ ] **Step 18.3: Write file completo da Task 18 (substitui v2.1.0)**

Use Write tool com este conteúdo (substitui completamente o arquivo atual). As seções subsequentes (Pré-spec, Spec, Build, Ship, Como invocar, Apêndice) serão adicionadas via Edit nas Tasks 19-23.

````markdown
---
name: sdd-workflow
description: >
  Workflow Spec-Driven Development v3.0 pra projetos solo gerados por IA.
  Use quando o usuário disser "novo projeto", "criar um sistema", "quero desenvolver",
  "use o workflow SDD", "promover este projeto pra <tier>", ou variações.
  Audiência: não-programadores (executivos, etc.) dirigindo Claude Code pra construir
  software completo. 4 estágios (Pré-spec → Spec → Build → Ship), 5 níveis de tier,
  catálogo de tipo_projeto, EARS pra Requirements + BDD pra Tasks 🔒, integração com
  superpowers (Modo 2), TDD canônico Red/Green/Refactor.
disable-model-invocation: true
version: 3.0.0
triggers:
  - sdd
  - novo projeto
  - criar um sistema
  - quero desenvolver
  - workflow sdd
  - nova feature
  - status do projeto
  - promover este projeto
  - evoluir tier
tags:
  - development-methodology
  - project-management
  - spec-driven
  - workflow
  - tier-projetado
  - ears-bdd
---

# Spec-Driven Development Workflow — v3.0

Workflow completo pra desenvolvimento de novos projetos solo gerados 100% por IA. Cada estágio produz artefatos que devem ser aprovados antes de avançar. **Princípios invioláveis** abaixo são contrato: violação = STOP.

> **Origem**: aplica os princípios canônicos do **GitHub Spec Kit** (`Constitution → Specify → Plan → Tasks → Verify`) com extensões opinativas pra audiência específica (não-dev dirigindo IA). Ver spec do plugin pra detalhe.

---

## Princípios invioláveis

| # | Princípio | Origem |
|---|---|---|
| 1 | **Dados reais sempre, nunca fictícios** — em seed, testes, exemplos, demos | herdado |
| 2 | **Tier é projetado** (visão final do desenvolvimento), não observado (estado atual) | v3.0 |
| 3 | **Defensividade sobre dependências externas** — não pressupor CLI/MCP/skill/credencial sem inventário formal | v3.0 |
| 4 | **Gates explícitos por fase** — pausa obrigatória, aprovação humana antes de avançar | herdado |
| 5 | **TDD canônico Red/Green/Refactor** — write test que falha, fazer passar com mínimo de código, refatorar mantendo o teste passando, só então commitar. Aplica universalmente, incluindo arquivos não-código (markdown/JSON com Refactor adaptado — ver `references/linguagens-especificacao.md` e seção sobre Build.Implementation) | herdado/v3.0 |
| 6 | **Decisões registradas** — toda escolha estrutural (tipo_projeto, tier, stack, alvo deploy, inventário) vai pra constitution com data e motivação | v3.0 |
| 7 | **Promoção de tier é decisão consciente, registrada, incremental** — nunca recomeço do zero | v3.0 |
| 8 | **Linguagem ubíqua** — vocabulário compartilhado entre IA, usuário, documentos de referência, código e UI. Termos definidos em Pré-spec.Discovery e Pré-spec.Constitution propagam pra requirements, design, tasks, código e UI sem traduções intermediárias | v3.0 (DDD/BDD) |

---

## Visão geral do fluxo — 4 estágios nomeados

```
I.  Pré-spec  →  Discovery  →  Constitution (com setup)  →  Stack (3 sub-componentes)
II. Spec      →  Requirements (EARS)  →  Design  →  [Spike opcional]
III. Build    →  Tasks (plano-mestre)  →  Implementation (loop por feature, gate por feature)
IV. Ship      →  Audit (13 dim. × 5 tier)  →  Delivery  →  Deploy
```

Cada estágio tem fases internas com **gates explícitos**. Cada gate é pausa obrigatória — IA apresenta resumo e aguarda aprovação antes de avançar.

| Estágio | Fases | Saídas |
|---|---|---|
| **I. Pré-spec** | Discovery, Constitution (absorve setup), Stack | `specs/constitution.md` (com YAML + inventário + alvo deploy) |
| **II. Spec** | Requirements, Design, Spike (opcional) | `specs/requirements.md` (EARS), `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks (plano-mestre), Implementation (loop por feature) | `specs/tasks.md` (índice), `specs/plans/<feature>.md` (writing-plans), código entregue |
| **IV. Ship** | Audit, Delivery, Deploy | `specs/audit-<data>.md`, sistema rodando, sistema em produção |

**References disponíveis** (progressive disclosure — IA carrega sob demanda):

- `references/tiers.md` — 5 níveis + matriz Audit + princípio "tier projetado"
- `references/tipos-projeto.md` — catálogo: web-saas, claude-plugin, hubspot, outro
- `references/stacks.md` — stack default por tipo + variação por tier
- `references/inventario-dependencias.md` — 4 categorias + Família A bloqueia
- `references/audit-dimensoes.md` — 13 dimensões + override por tipo
- `references/integracao-skills.md` — 4 famílias + 2 modos de integração
- `references/alvos-deploy.md` — alvos típicos por tipo + tier
- `references/linguagens-especificacao.md` — EARS + BDD + GEARS no radar

**Templates disponíveis** (em `templates/` — IA copia + preenche pro `specs/` do projeto-alvo):

- `constitution.md`, `requirements.md`, `design.md`, `tasks.md`, `plan-feature.md`, `progress.md`, `spike.md`, `audit.md`

---
````

- [ ] **Step 18.4: Verify Green**

Run: check do step 18.1
Expected: `PASS`

- [ ] **Step 18.5: Refactor**

Revisar:
- Frontmatter no topo, ordem canônica dos campos
- Princípio 5 cita "Refactor adaptado" + ref pra `linguagens-especificacao.md`
- Tabela "References disponíveis" + "Templates disponíveis" lista TUDO que será criado nas Fases 2-3
- **Decisão**: noop. Estrutura clara.

- [ ] **Step 18.6: Re-verify**

Expected: `PASS`

- [ ] **Step 18.7: Commit (parcial — SKILL.md ainda em construção)**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: SKILL.md v3.0 — frontmatter + princípios + visão geral (parcial, Tasks 19-23 continuam)"
```

Nota: SKILL.md fica num estado intermediário entre Tasks 18-23. Cada task commita parcial pra rastreabilidade. Task 23 faz commit final consolidado.

---

### Task 19: SKILL.md — Pré-spec (Discovery + Constitution + Stack)

**Files:**
- Modify (append): `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`

- [ ] **Step 19.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
grep -q "## Estágio I — Pré-spec" $F && \
grep -q "Pré-spec.Discovery" $F && \
grep -q "Pré-spec.Constitution" $F && \
grep -q "Pré-spec.Stack" $F && \
grep -q "tipo_projeto" $F && \
grep -q "tier" $F && \
grep -q "Inventário" $F && \
grep -q "Quality Gate" $F && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 19.2: Run check (FAIL esperado)**

Expected: `FAIL` (Estágio I ainda não escrito).

- [ ] **Step 19.3: Append seção Pré-spec via Edit (Green)**

Adicionar ao final do arquivo (depois do `---` que fecha a Visão geral):

````markdown
## Estágio I — Pré-spec

### Pré-spec.Discovery

Faça perguntas ao usuário pra entender:

1. **Problema**: que dor operacional este projeto resolve?
2. **Usuários**: quem vai usar? quantas pessoas? em que dispositivo?
3. **Dados**: que dados entram, como são processados, o que sai?
4. **Referência**: existe planilha, documento ou processo manual que será substituído?
5. **Escopo V1**: o que é essencial vs. nice-to-have?
6. **`tipo_projeto`** (decisão estrutural — ver `references/tipos-projeto.md`):
   - `web-saas` — sistema web full-stack com UI rica
   - `claude-plugin` — plugin para Claude Code
   - `hubspot` — extensão HubSpot
   - `outro` — Stack Decision livre
7. **`tier` projetado** (visão final — ver `references/tiers.md`):
   - `prototipo_descartavel` | `uso_interno` | `mvp` | `beta_publico` | `producao_real`
   - **Tier é projetado**, não estado atual. Pedir explicitamente.

Se documentos de referência foram fornecidos (Excel, PDF, etc.), analisar antes de avançar:
- PDF → `anthropic-skills:pdf`
- Excel → `anthropic-skills:xlsx`
- Word → `anthropic-skills:docx`
- PowerPoint → `anthropic-skills:pptx`

Use `superpowers:brainstorming` pra explorar problema/requisitos quando útil.

**Quality Gate Discovery** ✅:
```
□ Problema, usuários, dados, referência, escopo entendidos
□ tipo_projeto e tier respondidos com justificativa
□ Documentos de referência analisados (se houver)
□ Aprovação verbal do usuário
```

### Pré-spec.Constitution (com Setup absorvido)

Após Discovery aprovada, executar:

1. **Criar estrutura de pastas e commit init**:
```bash
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/specs"
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/src"
cd "$PROJECTS_DIR/$PROJECT_NAME"
git init  # se aplicável
```

2. **Escrever `specs/constitution.md`** copiando + preenchendo `templates/constitution.md`. Bloco YAML inicial obrigatório:

```yaml
---
tipo_projeto: <da Discovery>
tier: <da Discovery>
tier_decidido_em: YYYY-MM-DD
---
```

Mais bloco textual obrigatório explicando **por que** esse tier.

3. **Escrever `CLAUDE.md` do projeto** com referência aos padrões universais (`/CLAUDE.md` raiz). Use `claude-md-management:revise-claude-md`.

4. **Escrever `README.md` inicial**.

5. **Commit inicial**:
```bash
git add .
git commit -m "init: $PROJECT_NAME — setup + constitution"
```

**Quality Gate Constitution** ✅:
```
□ Bloco YAML preenchido
□ Stack default (ou override) justificada
□ Princípios não conflitam com /CLAUDE.md raiz
□ Brand colors definidos (se UI)
□ progress.md criado (template)
□ Commit init feito
□ Aprovação do usuário
```

### Pré-spec.Stack — checkpoint explícito (3 sub-componentes)

**Não é confirmação automática**. Pausa real onde a IA pergunta criticamente:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Os 3 sub-componentes a registrar na constitution:

1. **Inventário de dependências** — ver `references/inventario-dependencias.md`. Categorias: CLI do sistema, MCP servers, skills do marketplace, acesso a serviços externos. Família A (`superpowers:*` essenciais) bloqueia se faltar.

2. **Stack técnica** — ver `references/stacks.md`. Default sugerida por `tipo_projeto`. Override permitido sempre, com justificativa.

3. **Alvo de deploy** — ver `references/alvos-deploy.md`. **Decisão explícita do projeto**, não derivada de tipo+tier. IA pergunta "onde o produto vai viver?".

**Quality Gate Stack** ✅:
```
□ Inventário registrado (todas as categorias)
□ Stack confirmada ou override registrado com justificativa
□ Alvo de deploy registrado (decisão explícita)
□ Particularidades de Discovery foram consideradas (anti-pattern: aceitar default sem reflexão)
□ Aprovação do usuário
```

---
````

- [ ] **Step 19.4: Verify Green**

Run: check do step 19.1
Expected: `PASS`

- [ ] **Step 19.5: Refactor**

Revisar:
- 3 fases internas (Discovery, Constitution, Stack) seguem ordem do estágio
- Pré-spec.Constitution absorveu o "setup" antigo (item 1: criar pastas + commit init)
- Pré-spec.Stack tem 3 sub-componentes explícitos
- Cada fase tem Quality Gate dedicado
- **Decisão**: noop.

- [ ] **Step 19.6: Re-verify**

Expected: `PASS`

- [ ] **Step 19.7: Commit (parcial)**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: SKILL.md v3.0 — Estágio I Pré-spec (Discovery + Constitution + Stack)"
```

---

### Task 20: SKILL.md — Spec (Requirements + Design + Spike opcional)

**Files:**
- Modify (append): `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`

- [ ] **Step 20.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
grep -q "## Estágio II — Spec" $F && \
grep -q "Spec.Requirements" $F && \
grep -q "EARS" $F && \
grep -q "Spec.Design" $F && \
grep -q "Spec.Spike" $F && \
grep -q "opcional" $F && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 20.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 20.3: Append seção Spec via Edit (Green)**

````markdown
## Estágio II — Spec

### Spec.Requirements (formato EARS)

Escreva `specs/requirements.md` copiando + preenchendo `templates/requirements.md`. **Formato EARS** (ver `references/linguagens-especificacao.md`) pra cada regra de negócio:

```ears
Ubiquitous:    O <sujeito> deve <comportamento>.
State-driven:  Enquanto <estado>, o <sujeito> deve <comportamento>.
Event-driven:  Quando <evento>, o <sujeito> deve <comportamento>.
Optional:      Onde <feature presente>, o <sujeito> deve <comportamento>.
Unwanted:      Se <condição>, então o <sujeito> não deve <comportamento>.
Complex:       Enquanto X, quando Y, o <sujeito> deve Z.
```

Conteúdo obrigatório do `requirements.md`:

- Visão geral do sistema
- Usuários e perfis de acesso
- Dados de referência (linkar paths/URLs dos documentos reais)
- Módulos do sistema com requirements EARS
- Regras de negócio críticas com exemplos de **dados reais** (princípio 1)
- Requisitos não-funcionais conforme tier (ver `references/tiers.md`)
- Dados iniciais (seed) — extraídos dos documentos reais
- Fora do escopo V1

**Quality Gate Requirements** ✅:
```
□ Cada módulo tem requirements EARS bem-formados
□ Regras de negócio com exemplos de dados reais
□ Documentos de referência analisados e linkados
□ Isolamento de dados entre perfis definido (se aplicável)
□ Aprovação do usuário
```

### Spec.Design

Escreva `specs/design.md` copiando + preenchendo `templates/design.md`. Conteúdo:

- Stack confirmada (da constitution + ajustes desta fase)
- Schema do banco (tabelas, relações, constraints, índices) se aplicável
- API Routes (rotas, payloads, autenticação, autorização)
- Arquitetura de componentes frontend (mobile-first se `web-saas`)
- Organização de pastas
- Estratégia de seed com dados reais
- **Bounded contexts** opcional (DDD parcial — apenas se `tier: producao_real` complexo ou `hubspot` extension grande). Senão noop declarado.
- **Decisão Spike**: este Design identificou risco técnico? Sim → cria `specs/spike.md`; Não → segue direto pra Build.Tasks.
- Decisões importantes (cross-link com constitution)

Skills sugeridas:
- `frontend-design` se UI distintiva (web-saas)
- `claude-api` se usa API Anthropic
- `plugin:context7:context7` pra docs atualizadas de libs
- `plugin-dev:*` se `tipo_projeto: claude-plugin`

**Quality Gate Design** ✅:
```
□ Schema cobre todos os módulos dos requirements
□ APIs têm autenticação e autorização definidas
□ Stack bate com constitution
□ Brand colors do projeto configurados (Tailwind, se UI)
□ Mobile-first documentado (sidebar, tabelas, cards) se UI
□ Decisão Spike registrada (sim/não)
□ Aprovação do usuário
```

### Spec.Spike (opcional)

Entra **apenas** se Spec.Design identificou risco técnico (integração externa nova, lib desconhecida, dependência crítica). Box temporal sugerido: 1-3 dias.

Escreva `specs/spike.md` copiando + preenchendo `templates/spike.md`. Estrutura:

1. Risco identificado (origem: Spec.Design seção 8)
2. Hipóteses (principal + alternativas)
3. Critérios de sucesso
4. Investigação (setup mínimo, resultados, surpresas)
5. **Decisão tripartite**: confirmada / parcialmente confirmada / não confirmada
6. Próximo passo
7. Aprendizados pra registrar na Constitution

Skills usadas:
- `superpowers:test-driven-development` (validar hipóteses com testes)
- `superpowers:systematic-debugging` (quando spike der erro)

**Quality Gate Spike** ✅:
```
□ Hipóteses validadas (ou negadas com pivot decidido)
□ Riscos resolvidos ou aceitos com justificativa
□ Decisão registrada (constitution histórico)
□ Aprendizados extraídos pra constitution
□ Aprovação do usuário
```

---
````

- [ ] **Step 20.4: Verify Green**

Run: check do step 20.1
Expected: `PASS`

- [ ] **Step 20.5: Refactor**

Revisar:
- Spec.Requirements explicitamente EARS — alinhado com decisão do spec
- Spec.Design tem decisão Spike (checkbox)
- Spec.Spike tem decisão tripartite explícita
- Skills B/D listadas onde aplicável
- **Decisão**: noop.

- [ ] **Step 20.6: Re-verify**

Expected: `PASS`

- [ ] **Step 20.7: Commit (parcial)**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: SKILL.md v3.0 — Estágio II Spec (Requirements EARS + Design + Spike opcional)"
```

---

### Task 21: SKILL.md — Build (Tasks + Implementation)

**Files:**
- Modify (append): `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`

- [ ] **Step 21.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
grep -q "## Estágio III — Build" $F && \
grep -q "Build.Tasks" $F && \
grep -q "Build.Implementation" $F && \
grep -q "writing-plans" $F && \
grep -q "Refactor" $F && \
grep -q "🔒" $F && \
grep -q "Given.*When.*Then" $F && \
grep -q "5 ajustes" $F && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 21.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 21.3: Append seção Build via Edit (Green)**

````markdown
## Estágio III — Build

### Build.Tasks (plano-mestre)

Escreva `specs/tasks.md` copiando + preenchendo `templates/tasks.md`. **Plano-mestre** = índice de features. Cada feature terá seu próprio plano detalhado em `specs/plans/<feature>.md`.

Quebra típica de features (adaptar conforme `tipo_projeto`):

1. **Infra e Setup** (Docker, scripts, banco)
2. **Auth + Layout** (login, JWT, sidebar, mobile drawer) se UI
3. **CRUDs** (entidades administrativas)
4. **Lógica de negócio 🔒** (cálculos, validações — validação obrigatória contra dados reais)
5. **Dashboards e visualizações** (se aplicável)
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** (isolamento, validações, responsividade)

Cada feature do plano-mestre deve:
- Ser testável independentemente
- Ter critério claro de done
- Indicar dependências
- Indicar 🔒 se exige validação contra dados reais

**Quality Gate Tasks** ✅:
```
□ Cada feature tem plano detalhado planejado em specs/plans/<feature>.md
□ Dependências entre features claras
□ Features 🔒 identificadas
□ Plano-mestre revisado e aprovado
□ progress.md atualizado com features
```

### Build.Implementation — loop por feature

Pra cada feature do plano-mestre:

1. **Escrever plano detalhado** em `specs/plans/<feature>.md` usando `superpowers:writing-plans` com **5 ajustes de convenção SDD**:

   1. **Marcação 🔒** — header de task `### Task N: [Component] 🔒` ou step extra `- [ ] **Step X: 🔒 Validar contra dados reais**` antes do commit
   2. **Quebra por fase típica** absorvida no nível superior (`tasks.md` plano-mestre)
   3. **Quality Gate por feature** absorve gates antigos
   4. **Localização**: `specs/plans/<feature>.md` no projeto (autocontido)
   5. **Refactor explícito no ciclo TDD canônico**:

      ```
      write test → run (FAIL) → implement → run (PASS) →
      REFACTOR (improve design, run tests, mantém PASS) → commit
      ```

      Refactor pode ser noop conscientemente declarado (não pulado silenciosamente). Pra arquivos não-código (markdown, JSON), Refactor adapta semântica — ver `references/linguagens-especificacao.md` ou seção 5.1.2 do spec do plugin.

2. **Cenário BDD pra tasks 🔒** (validação contra dados reais):

   ```gherkin
   Cenário: Cálculo bate com planilha de referência
     Dado os dados reais da planilha "<arquivo>.xlsx"
     Quando recalculo total com a regra de negócio
     Então cada linha bate com a coluna "Total Final" da planilha
   ```

3. **Executar plano detalhado** com:
   - `superpowers:executing-plans` — execução inline com checkpoints, OU
   - `superpowers:subagent-driven-development` — fresh subagent per task com review entre tasks (recomendado pra features grandes)

4. **Skills durante Implementation**:
   - `superpowers:test-driven-development` — TDD canônico Red/Green/Refactor
   - `superpowers:systematic-debugging` — em erros (reproduzir → isolar → diagnosticar → corrigir)
   - `superpowers:verification-before-completion` — antes de declarar task pronta
   - `superpowers:using-git-worktrees` — quando feature precisa isolamento
   - `superpowers:dispatching-parallel-agents` — quando subtasks independem
   - `commit-commands:commit` — substituir commits manuais
   - `simplify` — depois de bloco grande de implementação

5. **Quality Gate por feature** (NOVO — gate além do gate por task):
   ```
   □ Todos os steps do plano detalhado executados
   □ Testes da feature passando (output mostrado)
   □ Se 🔒: comparativo contra dados reais mostrado e aprovado
   □ Refactor declarado (executado ou noop justificado)
   □ Aprovação humana antes de marcar ✅ no progress.md
   ```

6. **Atualizar `specs/progress.md`** ao concluir feature.

### Final de sessão (não é fase, é evento)

Quando a sessão de trabalho encerrar (mesmo no meio da Implementation):

1. **Atualizar `specs/progress.md`** com estado atual
2. **Revisar `CLAUDE.md` do projeto** com aprendizados (`claude-md-management:revise-claude-md`)
3. **Salvar na memória**: `remember:remember`
4. **Relatório de sessão** (opcional): `session-report:session-report`

---
````

- [ ] **Step 21.4: Verify Green**

Run: check do step 21.1
Expected: `PASS`

- [ ] **Step 21.5: Refactor**

Revisar:
- Build.Tasks claramente apresenta plano-mestre (não tasks individuais)
- Build.Implementation tem 5 ajustes SDD listados explicitamente
- Refactor canônico mostrado em ciclo de 6 passos (write test → run-fail → implement → run-pass → refactor → commit)
- Cenário BDD inline pra tasks 🔒
- Quality Gate por feature explícito (item 5) — separado do gate por task
- Final de sessão como evento separado
- **Decisão**: noop.

- [ ] **Step 21.6: Re-verify**

Expected: `PASS`

- [ ] **Step 21.7: Commit (parcial)**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: SKILL.md v3.0 — Estágio III Build (Tasks plano-mestre + Implementation com 5 ajustes SDD + Refactor)"
```

---

### Task 22: SKILL.md — Ship (Audit + Delivery + Deploy)

**Files:**
- Modify (append): `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`

- [ ] **Step 22.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
grep -q "## Estágio IV — Ship" $F && \
grep -q "Ship.Audit" $F && \
grep -q "Ship.Delivery" $F && \
grep -q "Ship.Deploy" $F && \
grep -q "13 dimensões" $F && \
grep -q "rollback" $F && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 22.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 22.3: Append seção Ship via Edit (Green)**

````markdown
## Estágio IV — Ship

### Ship.Audit — 13 dimensões × 5 tiers

Auditoria expandida. Detalhe completo das 13 dimensões: `references/audit-dimensoes.md`. Matriz de obrigatoriedade por tier: `references/tiers.md` seção 3.

Fluxo da Audit:

1. **Pergunta dimensões `perguntar`** ao usuário no início (registra resposta na constitution)
2. **Roda dimensões `obrigatório` e `opcional`** em paralelo via `superpowers:dispatching-parallel-agents`
3. **Sub-agentes especializados**:
   - `code-review:code-review` — dimensão Código
   - `security-review` (built-in) — dimensão Segurança
   - `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`
4. **Compila relatório** em `specs/audit-<YYYY-MM-DD>.md` copiando + preenchendo `templates/audit.md`. Achados classificados 🔴 (críticos — bloqueiam Delivery), 🟡 (importantes), 🟢 (melhorias).
5. **`superpowers:requesting-code-review`** — review humana antes da Audit começar, se aplicável

**Quality Gate Audit** ✅:
```
□ Todas as dimensões `obrigatório` do tier executadas
□ Dimensões `perguntar` decididas e registradas na constitution
□ Achados 🔴 zerados ou tratados antes de avançar
□ Achados 🟡 corrigidos ou aceitos com justificativa registrada
□ Lógica de negócio validada contra dados reais (dimensão 8 sempre obrigatória)
□ progress.md atualizado
□ Aprovação do usuário
```

### Ship.Delivery

Sistema rodando em ambiente de avaliação. Pré-deploy.

1. **Aplicar fixes** dos achados 🔴 e 🟡 da Audit
2. **Commit final** das correções
3. **Subir o sistema**: Docker compose ou equivalente conforme `tipo_projeto`
4. **Validar fluxos principais** com o usuário
5. **`superpowers:finishing-a-development-branch`** se branch isolada
6. **`commit-commands:commit-push-pr`** se PR aberto
7. **`pr-review-toolkit:review-pr`** se aplicável

**Quality Gate Delivery** ✅:
```
□ Zero 🔴 da Audit
□ Seeds funcionando do zero (limpar banco + popular com dados reais)
□ Sistema rodando e acessível em ambiente de avaliação
□ README.md atualizado com instruções de setup e uso
□ Usuário validou fluxos principais
□ progress.md atualizado
```

### Ship.Deploy — parametrizado por tier

Decisão do alvo foi tomada na Pré-spec.Stack (registrada na constitution). Esta fase **executa o deploy** conforme tier.

Comportamento por tier (ver `references/alvos-deploy.md` pra detalhe):

- **`prototipo_descartavel`**: não tem deploy. Roda local apenas. Ship.Deploy é noop declarado.
- **`uso_interno`**: deploy simples (Docker compose num servidor, Vercel free, hosting básico). Sem rollback formal.
- **`mvp`**: hosting gerenciado, deploy manual, monitoramento básico.
- **`beta_publico`**: rollback plan obrigatório, observabilidade obrigatória, error tracking.
- **`producao_real`**: rollback automático, alertas, on-call ou processo de incidente, monitoramento avançado.

Pra `claude-plugin` no marketplace:

- Se `marketplace-tools:publish-plugin` está instalado, usar o plugin (automatiza fluxo dos 6 passos com workaround dos bugs de cache)
- Senão, fluxo manual: bump version no `marketplace.json` → commit → push → invalidar cache local

**Quality Gate Deploy** ✅:
```
□ Env de prod separado (secrets fora do código)
□ Rollback plan documentado (mvp+) ou declarado noop (prototipo/uso_interno)
□ Monitoramento básico configurado (mvp+) ou declarado noop
□ Domínio configurado (se aplicável)
□ Fluxos validados em prod (smoke test pelo menos)
□ progress.md em 100%
```

### Promoção de Tier (sub-fluxo dedicado)

Quando o usuário expressar intenção de mudar tier ("promover esse projeto pra MVP", "agora vai virar prod real"), invocar a sub-skill **`sdd-promote-tier`** ou usar o command `/sdd-workflow:promote-tier`. 11 passos incrementais — não recomeça do zero.

---
````

- [ ] **Step 22.4: Verify Green**

Run: check do step 22.1
Expected: `PASS`

- [ ] **Step 22.5: Refactor**

Revisar:
- Ship.Audit referencia audit-dimensoes.md e tiers.md (progressive disclosure)
- Ship.Deploy parametrizado por tier — comportamento explícito por tier
- Cláusula sobre `marketplace-tools:publish-plugin` (se instalado vs senão)
- Cross-link com sub-skill sdd-promote-tier no fim
- **Decisão**: noop.

- [ ] **Step 22.6: Re-verify**

Expected: `PASS`

- [ ] **Step 22.7: Commit (parcial)**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: SKILL.md v3.0 — Estágio IV Ship (Audit 13×5 + Delivery + Deploy por tier)"
```

---

### Task 23: SKILL.md — Como invocar + Apêndice + Refactor global + commit final consolidado

**Files:**
- Modify (append + revisar global): `plugins/sdd-workflow/skills/sdd-workflow/SKILL.md`

- [ ] **Step 23.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
grep -q "## Como invocar" $F && \
grep -q "## Apêndice" $F && \
grep -q "Migração de projetos v2.x" $F && \
grep -q "/sdd-workflow:start" $F && \
grep -q "/sdd-workflow:status" $F && \
grep -q "/sdd-workflow:gate" $F && \
grep -q "/sdd-workflow:audit" $F && \
grep -q "/sdd-workflow:promote-tier" $F && \
[ $(wc -l < $F) -gt 250 ] && \
[ $(wc -l < $F) -lt 500 ] && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 23.2: Run check (FAIL esperado)**

Expected: `FAIL` (Como invocar e Apêndice ainda não escritos).

- [ ] **Step 23.3: Append seção final via Edit (Green)**

````markdown
## Como invocar

A SKILL.md tem `disable-model-invocation: true` — só ativa por triggers explícitos (frase ou slash command).

### Triggers naturais (frase em pt-BR)

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "Use o workflow SDD"
- "Status do projeto"
- "Promover este projeto pra [tier]"

### Slash commands (em `commands/`)

| Command | Função |
|---|---|
| `/sdd-workflow:start` | Atalho pra invocar a skill principal |
| `/sdd-workflow:status` | Lê `specs/progress.md` e mostra resumo |
| `/sdd-workflow:gate` | Verifica gate da fase atual; lista pendências |
| `/sdd-workflow:audit` | Dispara Ship.Audit standalone (`--dimensoes <lista>` opcional) |
| `/sdd-workflow:promote-tier` | Invoca sub-skill `sdd-promote-tier` (`--alvo <tier>` opcional) |

### Migração de projetos v2.x → v3.0

Quando invocada num projeto que tem `specs/constitution.md` mas **falta o bloco YAML novo** (`tipo_projeto`, `tier`), perguntar:

> "Este projeto está no fluxo SDD antigo (v2.x). Migrar pra v3.0?
> - Adiciona bloco YAML na constitution (perguntar tipo_projeto, tier, inventário, alvo deploy)
> - Mantém requirements.md, design.md, progress.md como estão (compatíveis)
> - Reformata tasks.md pra plano-mestre + cria specs/plans/ pras features futuras
> - Tasks já implementadas ficam no histórico, novas features usam writing-plans"

Aceitar → migração executada. Pular → continua na v2.x conceitualmente, sem feature nova. Cancelar → não invoca a skill.

**Compatibilidade**: projetos que não migrarem continuam funcionando. Mas Spike, Promoção de Tier, Build.Implementation por feature exigem migração.

---

## Apêndice — references e templates

### References (progressive disclosure — IA carrega sob demanda)

| Reference | Conteúdo |
|---|---|
| `references/tiers.md` | 5 níveis + matriz Audit + princípio "tier projetado" |
| `references/tipos-projeto.md` | Catálogo: web-saas, claude-plugin, hubspot, outro |
| `references/stacks.md` | Stack default por tipo + variação por tier |
| `references/inventario-dependencias.md` | 4 categorias + Família A bloqueia |
| `references/audit-dimensoes.md` | 13 dimensões + override por tipo |
| `references/integracao-skills.md` | 4 famílias + 2 modos de integração |
| `references/alvos-deploy.md` | Alvos típicos por tipo + tier |
| `references/linguagens-especificacao.md` | EARS + BDD + GEARS no radar |

### Templates (IA copia + preenche pro `specs/` do projeto-alvo)

| Template | Vai virar |
|---|---|
| `templates/constitution.md` | `specs/constitution.md` (YAML + 9 seções) |
| `templates/requirements.md` | `specs/requirements.md` (EARS por módulo) |
| `templates/design.md` | `specs/design.md` (schema + APIs + arquitetura + spike opcional) |
| `templates/tasks.md` | `specs/tasks.md` (plano-mestre — índice de features) |
| `templates/plan-feature.md` | `specs/plans/<feature>.md` (writing-plans + 5 ajustes SDD) |
| `templates/progress.md` | `specs/progress.md` (4 estágios × fases + status line + histórico tier) |
| `templates/spike.md` | `specs/spike.md` (hipótese + investigação + decisão tripartite) |
| `templates/audit.md` | `specs/audit-<data>.md` (13 dimensões × tier + achados) |

### Sub-skill

`sdd-promote-tier` — fluxo de 11 passos pra promoção/regressão de tier. Acionada por trigger natural ("promover este projeto pra X") ou `/sdd-workflow:promote-tier`.
````

- [ ] **Step 23.4: Verify Green parcial (após append)**

Run: check do step 23.1
Expected: `PASS`

- [ ] **Step 23.5: Refactor global da SKILL.md**

Pegando o arquivo inteiro com fresh eyes. Verificações:

- **Tom imperativo consistente** entre seções? Pré-spec, Spec, Build, Ship usam mesma voz? Verificar e ajustar inconsistências
- **Hierarquia de headers** coerente? `##` pra estágios, `###` pra fases, `####` pra sub-tópicos
- **Links cruzados** funcionando? Cada `references/X.md` mencionado existe (sim, criados em Tasks 2-9)
- **Cross-links** com `templates/X.md`? Cada referência a template existe (sim, criados em Tasks 10-17)
- **Princípios são aplicados**? Princípio 5 (Refactor) mencionado em Build.Implementation? Princípio 8 (linguagem ubíqua) refletido na ordem dos artefatos? Sim
- **Quality Gates** consistentes em estrutura? Cada um tem checkboxes □ no formato padrão
- **Triggers do frontmatter** batem com triggers naturais documentados em "Como invocar"? Verificar lista
- **Comandos slash** mencionados em "Como invocar" são todos os 5 documentados na seção 9.2 do spec? Verificar
- **Tamanho final**: entre 250 e 500 linhas? (check do step 23.1 já cobre)

Aplicar correções inline conforme necessário.

**Decisão de noop ou refactor**: documentar no commit final.

- [ ] **Step 23.6: Re-verify (após Refactor)**

Run: check completo:

```bash
F=plugins/sdd-workflow/skills/sdd-workflow/SKILL.md

# Frontmatter
head -1 $F | grep -q "^---$" && \
grep -q "^name: sdd-workflow$" $F && \
grep -q "^version: 3.0.0$" $F && \

# Princípios (8)
grep -c "^| [1-8] |" $F | xargs -I{} test {} -ge 8 && \

# 4 Estágios + fases internas
grep -q "Estágio I — Pré-spec" $F && \
grep -q "Estágio II — Spec" $F && \
grep -q "Estágio III — Build" $F && \
grep -q "Estágio IV — Ship" $F && \
grep -q "Pré-spec.Discovery" $F && \
grep -q "Pré-spec.Constitution" $F && \
grep -q "Pré-spec.Stack" $F && \
grep -q "Spec.Requirements" $F && \
grep -q "Spec.Design" $F && \
grep -q "Spec.Spike" $F && \
grep -q "Build.Tasks" $F && \
grep -q "Build.Implementation" $F && \
grep -q "Ship.Audit" $F && \
grep -q "Ship.Delivery" $F && \
grep -q "Ship.Deploy" $F && \

# Conceitos novos
grep -q "tipo_projeto" $F && \
grep -q "tier" $F && \
grep -q "EARS" $F && \
grep -q "Refactor" $F && \

# Slash commands
grep -q "/sdd-workflow:start" $F && \
grep -q "/sdd-workflow:status" $F && \
grep -q "/sdd-workflow:gate" $F && \
grep -q "/sdd-workflow:audit" $F && \
grep -q "/sdd-workflow:promote-tier" $F && \

# Refs e templates
grep -q "references/tiers.md" $F && \
grep -q "templates/constitution.md" $F && \

# Tamanho razoável
[ $(wc -l < $F) -gt 250 ] && \
[ $(wc -l < $F) -lt 500 ] && \
echo "PASS" || echo "FAIL"
```

Expected: `PASS`

- [ ] **Step 23.7: Commit final consolidado da SKILL.md**

```bash
git add plugins/sdd-workflow/skills/sdd-workflow/SKILL.md
git commit -m "sdd-workflow: SKILL.md v3.0 — Como invocar + Apêndice + Refactor global

SKILL.md v3.0 completa com:
- Frontmatter v3.0.0 + triggers expandidos
- 8 princípios invioláveis (princípio 5 com Refactor canônico, princípio 8 linguagem ubíqua)
- 4 estágios nomeados (Pré-spec / Spec / Build / Ship) com 11 fases internas
- tipo_projeto + tier (5 níveis) como conceitos da Pré-spec
- Inventário de dependências + alvo de deploy explícito
- EARS pra Requirements + BDD pra Tasks 🔒
- 5 ajustes SDD sobre superpowers:writing-plans incluindo Refactor explícito
- Auditoria 13 dimensões × 5 tiers
- 5 slash commands documentados
- Migração v2.x → v3.0 auto-detectada
- Apêndice com índice de references + templates

Substitui SKILL.md v2.1.0 (16K, 500 linhas) — conteúdo válido absorvido
e expandido. Tamanho estimado: 300-400 linhas com progressive disclosure
delegada a 8 references + 8 templates."
```

---

## Fase 5 — Sub-skill `sdd-promote-tier`

### Task 24: `skills/sdd-promote-tier/SKILL.md` — sub-fluxo de 11 passos

**Files:**
- Create: `plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md`

- [ ] **Step 24.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^name: sdd-promote-tier$" $F && \
grep -q "^version: 1.0.0$" $F && \
grep -q "Reconfirma" $F && \
grep -q "Pergunta novo tier" $F && \
grep -q "Reaviva" $F && \
grep -q "Reauditoria" $F && \
grep -q "incremental" $F && \
[ $(wc -l < $F) -gt 80 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 24.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 24.3: Write file (Green)**

Conteúdo completo:

````markdown
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

> **Ver também**: `skills/sdd-workflow/references/tiers.md` (5 níveis + matriz Audit), `references/audit-dimensoes.md` (13 dimensões), `references/stacks.md` (variação de stack por tier), `references/alvos-deploy.md` (variação de alvo por tier).

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

Pra cada delta entre stack atual e stack esperada do novo tier (consultar `references/stacks.md`):

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

Comparar matriz do tier antigo vs novo (consultar `references/tiers.md` seção 3). Dimensões que mudaram de `—`/`opcional`/`perguntar` pra `obrigatório` entram na reauditoria.

Output: `specs/audit-<YYYY-MM-DD>-tier-upgrade.md`.

### Passo 10 — Aplica fixes

Com base nos achados 🔴/🟡 da reauditoria:

- 🔴 críticos: corrigir antes de avançar (bloqueiam Ship.Delivery)
- 🟡 importantes: corrigir ou aceitar com justificativa registrada na constitution

### Passo 11 — Ship.Deploy (se aplicável)

Se Ship.Deploy ainda não tinha sido executado e o novo tier exige (ex: protótipo → MVP exige hosting gerenciado), executar agora.

Se alvo mudou (ex: protótipo local → mvp em hosting gerenciado), redeploy pra novo alvo. Ver `references/alvos-deploy.md`.

---

## Outputs

- Constitution atualizada (histórico de tier expandido na seção 9)
- `specs/plans/<feature>-tier-upgrade.md` pra features novas (ver `templates/plan-feature.md` da skill SDD principal)
- `specs/audit-<data>-tier-upgrade.md` focada nas dimensões novas obrigatórias

---

## Quality Gate da Promoção

```
□ Constitution atualizada com histórico
□ Deltas de Stack decididos (aplicar / débito)
□ Deltas de Design decididos
□ Features novas planejadas (specs/plans/)
□ Reauditoria executada
□ Achados 🔴 zerados
□ Ship.Deploy executado se aplicável
□ progress.md atualizado
□ Aprovação do usuário
```

---

## Skills usadas

- `superpowers:writing-plans` — pra cada feature nova do upgrade
- `superpowers:dispatching-parallel-agents` — na reauditoria focada (paraleliza dimensões)
- Subagentes do Audit (mesmo padrão do Ship.Audit normal)
````

- [ ] **Step 24.4: Verify Green**

Run: check do step 24.1
Expected: `PASS`

- [ ] **Step 24.5: Refactor**

Revisar:
- 11 passos numerados em ordem clara
- Cada passo tem ação concreta + opção de decisão (aplicar/débito)
- Princípios no topo evitam recomeço
- Cross-links com references da skill principal
- **Decisão**: noop.

- [ ] **Step 24.6: Re-verify**

Expected: `PASS`

- [ ] **Step 24.7: Commit**

```bash
git add plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md
git commit -m "sdd-workflow: criar sub-skill sdd-promote-tier (sub-fluxo de 11 passos, incremental)"
```

---

## Fase 6 — Commands (5 arquivos)

Commands ficam em `plugins/sdd-workflow/commands/`. Cada arquivo é markdown com frontmatter YAML descrevendo descrição + uso. Slash command resultante segue padrão `/sdd-workflow:<arquivo-sem-extensão>`.

### Task 25: `commands/start.md` — invoca skill principal

**Files:**
- Create: `plugins/sdd-workflow/commands/start.md`

- [ ] **Step 25.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/commands/start.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^description:" $F && \
grep -q "sdd-workflow" $F && \
[ $(wc -l < $F) -gt 5 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 25.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 25.3: Write file (Green)**

Conteúdo completo:

````markdown
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
````

- [ ] **Step 25.4: Verify Green**

Run: check do step 25.1
Expected: `PASS`

- [ ] **Step 25.5: Refactor**

Revisar:
- Frontmatter com `description` (campo obrigatório pro Claude Code mostrar no picker)
- Conteúdo explica o que o command faz
- **Decisão**: noop.

- [ ] **Step 25.6: Re-verify**

Expected: `PASS`

- [ ] **Step 25.7: Commit**

```bash
git add plugins/sdd-workflow/commands/start.md
git commit -m "sdd-workflow: criar /sdd-workflow:start (atalho pra invocar skill principal)"
```

---

### Task 26: `commands/status.md` — lê progress.md

**Files:**
- Create: `plugins/sdd-workflow/commands/status.md`

- [ ] **Step 26.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/commands/status.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^description:" $F && \
grep -q "progress.md" $F && \
[ $(wc -l < $F) -gt 10 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 26.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 26.3: Write file (Green)**

Conteúdo completo:

````markdown
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
````

- [ ] **Step 26.4: Verify Green**

Run: check do step 26.1
Expected: `PASS`

- [ ] **Step 26.5: Refactor**

Revisar:
- Read-only declarado explicitamente
- Pré-requisitos documentados (caso não tenha projeto SDD)
- **Decisão**: noop.

- [ ] **Step 26.6: Re-verify**

Expected: `PASS`

- [ ] **Step 26.7: Commit**

```bash
git add plugins/sdd-workflow/commands/status.md
git commit -m "sdd-workflow: criar /sdd-workflow:status (lê progress.md, read-only)"
```

---

### Task 27: `commands/gate.md` — verifica gate atual

**Files:**
- Create: `plugins/sdd-workflow/commands/gate.md`

- [ ] **Step 27.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/commands/gate.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^description:" $F && \
grep -q "gate" $F && \
grep -q "aprovação humana" $F && \
[ $(wc -l < $F) -gt 10 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 27.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 27.3: Write file (Green)**

Conteúdo completo:

````markdown
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
````

- [ ] **Step 27.4: Verify Green**

Run: check do step 27.1
Expected: `PASS`

- [ ] **Step 27.5: Refactor**

Revisar:
- "Não libera automaticamente" reforçado pra evitar mau uso
- Output formato definido (✅/❌/📋)
- **Decisão**: noop.

- [ ] **Step 27.6: Re-verify**

Expected: `PASS`

- [ ] **Step 27.7: Commit**

```bash
git add plugins/sdd-workflow/commands/gate.md
git commit -m "sdd-workflow: criar /sdd-workflow:gate (diagnóstico de gate, não libera automaticamente)"
```

---

### Task 28: `commands/audit.md` — Audit standalone

**Files:**
- Create: `plugins/sdd-workflow/commands/audit.md`

- [ ] **Step 28.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/commands/audit.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^description:" $F && \
grep -q "Ship.Audit" $F && \
grep -q "dimensoes" $F && \
[ $(wc -l < $F) -gt 15 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 28.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 28.3: Write file (Green)**

Conteúdo completo:

````markdown
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

Dimensões aceitas (correspondem às 13 dimensões da Ship.Audit):

`seguranca, isolamento, integridade, performance, responsividade, ux, codigo, logica-negocio, acessibilidade, observabilidade, conformidade, doc-operacional, manutenibilidade`

## Output

`specs/audit-<YYYY-MM-DD>.md` (formato do `templates/audit.md` da skill principal)

Achados classificados 🔴 / 🟡 / 🟢. 🔴 bloqueiam Delivery se a Audit é parte do fluxo principal.

## Pré-requisitos

- Projeto SDD com `specs/constitution.md` (pra ler tier alvo)
- Sistema rodando ou disponível pra inspeção
- Skills da Família A (`superpowers:dispatching-parallel-agents` recomendado)

## Skills usadas

- `superpowers:dispatching-parallel-agents` — paraleliza dimensões
- `code-review:code-review` — sub-agente pra dimensão Código
- `security-review` (built-in) — pra dimensão Segurança
- `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`
````

- [ ] **Step 28.4: Verify Green**

Run: check do step 28.1
Expected: `PASS`

- [ ] **Step 28.5: Refactor**

Revisar:
- Argumento `--dimensoes` documentado com lista exaustiva
- Skills usadas listadas
- **Decisão**: noop.

- [ ] **Step 28.6: Re-verify**

Expected: `PASS`

- [ ] **Step 28.7: Commit**

```bash
git add plugins/sdd-workflow/commands/audit.md
git commit -m "sdd-workflow: criar /sdd-workflow:audit (Audit standalone com --dimensoes opcional)"
```

---

### Task 29: `commands/promote-tier.md` — invoca sub-skill

**Files:**
- Create: `plugins/sdd-workflow/commands/promote-tier.md`

- [ ] **Step 29.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/commands/promote-tier.md
test -f $F && \
head -1 $F | grep -q "^---$" && \
grep -q "^description:" $F && \
grep -q "sdd-promote-tier" $F && \
grep -q "alvo" $F && \
[ $(wc -l < $F) -gt 15 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 29.2: Run check (FAIL esperado)**

Expected: `FAIL`.

- [ ] **Step 29.3: Write file (Green)**

Conteúdo completo:

````markdown
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

- Projeto SDD existente com `specs/constitution.md` válida (bloco YAML com `tipo_projeto` e `tier` atual)
- Se v2.x sem bloco YAML, oferece migração v2.x → v3.0 antes
````

- [ ] **Step 29.4: Verify Green**

Run: check do step 29.1
Expected: `PASS`

- [ ] **Step 29.5: Refactor**

Revisar:
- Argumento `--alvo` com tiers aceitos
- Lista dos 11 passos resume sub-skill
- Outputs explicitados
- **Decisão**: noop.

- [ ] **Step 29.6: Re-verify**

Expected: `PASS`

- [ ] **Step 29.7: Commit**

```bash
git add plugins/sdd-workflow/commands/promote-tier.md
git commit -m "sdd-workflow: criar /sdd-workflow:promote-tier (invoca sub-skill com --alvo opcional)"
```

---

## Fase 7 — Metadata atualizada

### Task 30: `plugin.json` — atualizar description pra v3.0

**Files:**
- Modify: `plugins/sdd-workflow/.claude-plugin/plugin.json`

- [ ] **Step 30.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/.claude-plugin/plugin.json
jq -e '.description | contains("v3")' $F > /dev/null && \
jq -e '.description | contains("4 estágios")' $F > /dev/null && \
jq -e '.description | contains("13 dimensões")' $F > /dev/null && \
jq -e '.description | contains("tier projetado")' $F > /dev/null && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 30.2: Run check (FAIL esperado)**

Expected: `FAIL` (description atual não tem "v3", "4 estágios", "13 dimensões", "tier projetado").

- [ ] **Step 30.3: Modify file (Green)**

Use Edit tool com:

```
old_string:
{
  "name": "sdd-workflow",
  "description": "Workflow de Spec-Driven Development para desenvolvedores solo gerando software 100% por IA. 7 fases (Discovery → Entrega) com quality gates explícitos, TDD e auditoria em 8 dimensões. Escrito por um CRO não-dev dirigindo Claude Code.",
  "author": {
    "name": "André Junges"
  },
  "homepage": "https://github.com/ajunges/aj-openworkspace/tree/main/plugins/sdd-workflow"
}

new_string:
{
  "name": "sdd-workflow",
  "description": "Workflow Spec-Driven Development v3 pra projetos solo gerados por IA. 4 estágios nomeados (Pré-spec → Spec → Build → Ship) com gates explícitos, tier projetado em 5 níveis (prototipo_descartavel → producao_real), catálogo de tipo_projeto (web-saas / claude-plugin / hubspot / outro), inventário formal de dependências, EARS pra Requirements + BDD pra Tasks 🔒, integração com superpowers (Modo 2) e demais skills (Modo 1), TDD canônico Red/Green/Refactor, auditoria expandida 13 dimensões × 5 tiers, sub-skill dedicada de Promoção de Tier, 5 slash commands.",
  "author": {
    "name": "André Junges"
  },
  "homepage": "https://github.com/ajunges/aj-openworkspace/tree/main/plugins/sdd-workflow"
}
```

- [ ] **Step 30.4: Verify Green**

Run:
```bash
jq . plugins/sdd-workflow/.claude-plugin/plugin.json
```
Expected: JSON parseado corretamente, description nova visível.

Mais o check do step 30.1:
Expected: `PASS`

- [ ] **Step 30.5: Refactor**

Revisar:
- Description tem todos os elementos-chave da v3.0 (4 estágios, 5 tiers, tipos, EARS+BDD, integração, TDD, audit 13×5, sub-skill, 5 commands)
- Ordem de campos no JSON canônica: name, description, author, homepage (mantida)
- **Decisão**: noop. JSON limpo.

- [ ] **Step 30.6: Re-verify**

Run: check do step 30.1
Expected: `PASS`

- [ ] **Step 30.7: Commit**

```bash
git add plugins/sdd-workflow/.claude-plugin/plugin.json
git commit -m "sdd-workflow: atualizar plugin.json description (v3.0 completa)"
```

---

### Task 31: `README.md` — reescrever pra v3.0

**Files:**
- Modify (substituir): `plugins/sdd-workflow/README.md`

- [ ] **Step 31.1: Define check (Red)**

```bash
F=plugins/sdd-workflow/README.md
grep -q "v3.0" $F && \
grep -q "Pré-spec" $F && \
grep -q "Spec" $F && \
grep -q "Build" $F && \
grep -q "Ship" $F && \
grep -q "tier projetado" $F && \
grep -q "EARS" $F && \
grep -q "13 dimensões" $F && \
grep -q "/sdd-workflow:" $F && \
[ $(wc -l < $F) -gt 50 ] && echo "PASS" || echo "FAIL"
```

- [ ] **Step 31.2: Run check (FAIL esperado)**

Expected: `FAIL` (README atual é v0.1.0, não tem "v3.0" nem "EARS").

- [ ] **Step 31.3: Write file (Green) — substitui completamente o README atual**

Use Write tool com:

````markdown
# sdd-workflow — v3.0

Plugin Claude Code com playbook **Spec-Driven Development** completo. 4 estágios nomeados, tier projetado, integração com superpowers, EARS pra Requirements + BDD pra Tasks 🔒, auditoria expandida 13 dimensões × 5 tiers.

## Audiência

Não-programadores (executivos, etc.) e programadores iniciantes que dirigem o Claude Code pra construir sistemas completos. O workflow compensa a falta de conhecimento técnico direto com:

- **Gates explícitos** em cada fase — nada avança sem aprovação
- **TDD canônico** Red/Green/Refactor — testes antes do código, refactor obrigatório
- **EARS** (Easy Approach to Requirements Syntax) — requirements precisos sem ambiguidade
- **BDD** (Given-When-Then) — cenários de teste com dados reais
- **Auditoria expandida** em 13 dimensões com obrigatoriedade variável por tier
- **Tier projetado** — visão final do desenvolvimento, não estado atual
- **Princípio inviolável**: dados reais, nunca fictícios

## 4 estágios × 11 fases

| Estágio | Fases | Saídas |
|---|---|---|
| **I. Pré-spec** | Discovery → Constitution (com setup) → Stack | `specs/constitution.md` |
| **II. Spec** | Requirements (EARS) → Design → Spike (opcional) | `specs/requirements.md`, `specs/design.md`, eventual `specs/spike.md` |
| **III. Build** | Tasks (plano-mestre) → Implementation (loop por feature) | `specs/tasks.md`, `specs/plans/<feature>.md`, código entregue |
| **IV. Ship** | Audit → Delivery → Deploy | `specs/audit-<data>.md`, sistema rodando, sistema em produção |

## 5 níveis de tier

`prototipo_descartavel` → `uso_interno` → `mvp` → `beta_publico` → `producao_real`

Tier determina dimensões obrigatórias da Audit, recursos mínimos da stack, e rigor do Ship.Deploy. **Tier é projetado** (visão final), não observado (estado atual). Mudança = decisão consciente registrada via Promoção de Tier (sub-skill dedicada).

## 4 tipos de projeto suportados

- `web-saas` — sistema web full-stack (React/Vite/Tailwind/shadcn/Express/Prisma/PG)
- `claude-plugin` — plugin Claude Code (markdown + JSON, sem build)
- `hubspot` — extensão HubSpot (CLI, custom objects, UI extensions, serverless)
- `outro` — Stack Decision livre

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install sdd-workflow@aj-openworkspace
```

## Slash commands

| Command | Função |
|---|---|
| `/sdd-workflow:start` | Atalho pra invocar a skill principal |
| `/sdd-workflow:status` | Lê `specs/progress.md` (read-only) |
| `/sdd-workflow:gate` | Verifica gate da fase atual; lista pendências |
| `/sdd-workflow:audit` | Dispara Ship.Audit standalone (`--dimensoes <lista>` opcional) |
| `/sdd-workflow:promote-tier` | Invoca sub-skill de promoção de tier (`--alvo <tier>` opcional) |

## Triggers naturais (frase em pt-BR)

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "Status do projeto"
- "Promover este projeto pra [tier]"

## Migração v2.x → v3.0

Projetos no fluxo antigo (sem bloco YAML `tipo_projeto`/`tier` na constitution) são detectados automaticamente. A skill oferece migração que adiciona campos novos sem perder histórico.

## Status

`em-testes` — primeira versão pública pós-evolução estrutural. Promove pra `recomendado` após uso real e feedback.

## Autor

André Junges (@ajunges). Playbook desenvolvido na prática, 100% via Claude Code. Sem garantia — use por conta e risco.
````

- [ ] **Step 31.4: Verify Green**

Run: check do step 31.1
Expected: `PASS`

- [ ] **Step 31.5: Refactor**

Revisar:
- README cobre os elementos-chave: 4 estágios, 5 tiers, 4 tipos, slash commands, triggers, migração
- Tom amigável (não puramente técnico) — apropriado pra README público
- Status `em-testes` mantido (alinhado com Task 32 que mantém tag)
- **Decisão**: noop.

- [ ] **Step 31.6: Re-verify**

Expected: `PASS`

- [ ] **Step 31.7: Commit**

```bash
git add plugins/sdd-workflow/README.md
git commit -m "sdd-workflow: reescrever README.md pra v3.0 (4 estágios, 5 tiers, 5 commands, migração)"
```

---

## Fase 8 — Bump version no marketplace

### Task 32: `marketplace.json` — bump 0.1.1 → 0.2.0 + atualizar description

**Files:**
- Modify: `.claude-plugin/marketplace.json` (no root do worktree, não dentro do plugin)

- [ ] **Step 32.1: Define check (Red)**

```bash
F=.claude-plugin/marketplace.json
jq -e '.plugins[] | select(.name == "sdd-workflow") | .version == "0.2.0"' $F > /dev/null && \
jq -e '.plugins[] | select(.name == "sdd-workflow") | .description | contains("v3")' $F > /dev/null && \
jq -e '.plugins[] | select(.name == "sdd-workflow") | .tags | index("em-testes")' $F > /dev/null && \
echo "PASS" || echo "FAIL"
```

- [ ] **Step 32.2: Run check (FAIL esperado)**

Expected: `FAIL` (version ainda é "0.1.1", description antiga).

- [ ] **Step 32.3: Modify entry no marketplace.json (Green)**

Use Edit tool. Localizar entrada do `sdd-workflow` (atualmente):

```json
{
  "name": "sdd-workflow",
  "description": "Playbook pessoal de Spec-Driven Development para projetos solo gerados 100% por IA. Primeira versão pública sanitizada do workflow privado do autor.",
  "source": "./plugins/sdd-workflow",
  "category": "development",
  "tags": [
    "em-testes",
    "proprio",
    "workflow",
    "meta-skills",
    "solo-dev"
  ],
  "author": {
    "name": "André Junges"
  },
  "version": "0.1.1"
}
```

Substituir por:

```json
{
  "name": "sdd-workflow",
  "description": "Playbook Spec-Driven Development v3 pra projetos solo gerados 100% por IA. 4 estágios (Pré-spec/Spec/Build/Ship) com gates, tier projetado em 5 níveis, catálogo de tipo_projeto, inventário de dependências, EARS pra Requirements + BDD pra Tasks 🔒, integração com superpowers, TDD canônico Red/Green/Refactor, auditoria 13×5, sub-skill de Promoção de Tier, 5 commands.",
  "source": "./plugins/sdd-workflow",
  "category": "development",
  "tags": [
    "em-testes",
    "proprio",
    "workflow",
    "meta-skills",
    "solo-dev"
  ],
  "author": {
    "name": "André Junges"
  },
  "version": "0.2.0"
}
```

(Tags mantidas — `em-testes` permanece até validação em projeto real conforme spec seção 10.1.)

- [ ] **Step 32.4: Verify Green**

Run: check do step 32.1
Expected: `PASS`

Mais validação JSON:
```bash
jq . .claude-plugin/marketplace.json > /dev/null && echo "JSON VÁLIDO"
```
Expected: `JSON VÁLIDO`

- [ ] **Step 32.5: Refactor**

Revisar:
- Version `0.2.0` — bump minor conforme spec seção 10.1
- Description sumariza v3.0 em 1 frase densa (refleciar `plugin.json` em maior detalhe)
- Tags: `em-testes` mantida (não promove pra `recomendado` nesta versão)
- Ordem de campos canônica do schema marketplace
- **Decisão**: noop.

- [ ] **Step 32.6: Re-verify**

Expected: `PASS`

- [ ] **Step 32.7: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "marketplace: sdd-workflow 0.1.1 → 0.2.0 (evolução v3.0 — 4 estágios, tier, EARS+BDD, sub-skill, 5 commands)"
```

---

## Fase 9 — Validação final

### Task 33: `claude plugin validate` + commit final consolidado

**Files:**
- Validate only: todo o plugin

- [ ] **Step 33.1: Define check (Red)**

```bash
# Verifica que TODOS os arquivos foram criados
test -f plugins/sdd-workflow/commands/start.md && \
test -f plugins/sdd-workflow/commands/status.md && \
test -f plugins/sdd-workflow/commands/gate.md && \
test -f plugins/sdd-workflow/commands/audit.md && \
test -f plugins/sdd-workflow/commands/promote-tier.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/SKILL.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/constitution.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/requirements.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/design.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/tasks.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/plan-feature.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/progress.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/spike.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/templates/audit.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/tipos-projeto.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/tiers.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/stacks.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/inventario-dependencias.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/audit-dimensoes.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/integracao-skills.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/alvos-deploy.md && \
test -f plugins/sdd-workflow/skills/sdd-workflow/references/linguagens-especificacao.md && \
test -f plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md && \
echo "TODOS OS ARQUIVOS PRESENTES" || echo "ARQUIVO FALTANDO"
```

- [ ] **Step 33.2: Run check (deve PASS após Tasks 1-32)**

Expected: `TODOS OS ARQUIVOS PRESENTES`

- [ ] **Step 33.3: Validar plugin com `claude plugin validate`**

```bash
cd plugins/sdd-workflow
claude plugin validate .
cd ../..
```

Expected: validação sem erros. Avisos minor são aceitáveis (mas devem ser registrados).

- [ ] **Step 33.4: Validar marketplace.json**

```bash
claude plugin validate .
```

(Comando rodado no root do worktree, valida marketplace.json + plugins listados.)

Expected: validação sem erros.

- [ ] **Step 33.5: Verificar consistência cruzada**

```bash
# Version do marketplace.json bate com description?
jq -r '.plugins[] | select(.name == "sdd-workflow") | "\(.version) | \(.description)"' .claude-plugin/marketplace.json

# SKILL.md principal tem version 3.0.0?
grep "^version:" plugins/sdd-workflow/skills/sdd-workflow/SKILL.md

# Sub-skill tem version 1.0.0?
grep "^version:" plugins/sdd-workflow/skills/sdd-promote-tier/SKILL.md

# 5 commands existem?
ls plugins/sdd-workflow/commands/*.md | wc -l
# Expected: 5

# 8 templates existem?
ls plugins/sdd-workflow/skills/sdd-workflow/templates/*.md | wc -l
# Expected: 8

# 8 references existem?
ls plugins/sdd-workflow/skills/sdd-workflow/references/*.md | wc -l
# Expected: 8
```

Expected: tudo bate com o spec.

- [ ] **Step 33.6: Refactor — review final passada**

Pegar o output do `claude plugin validate` e ajustar qualquer warning:

- Schema warnings → ajustar JSON
- Frontmatter warnings → ajustar campos
- Path warnings → ajustar referências

Aplicar fixes em commits adicionais com `git commit -m "sdd-workflow: fix validate warning [descrição]"` se necessário.

- [ ] **Step 33.7: Commit final consolidado da v3.0**

(Não há novo conteúdo pra commitar — todos os commits intermediários cobrem isso. Este step é simbólico — verifica histórico.)

```bash
git log --oneline | head -40
```

Expected: ~30+ commits desde o início, todos no padrão `sdd-workflow: ...` ou `marketplace: sdd-workflow ...`.

```bash
echo "v3.0 implementação completa. Próximo passo: validação em projeto real (etapa 5 do plano de release do spec)."
```

---

## Self-Review (executada pelo plan author)

### 1. Spec coverage

Verificar que cada seção do spec tem task implementando:

- [ ] **Spec 1 (Contexto)** — informacional, não exige task
- [ ] **Spec 1.3 (Relação SDD canônico)** — cobertura: SKILL.md frontmatter cita Spec Kit, princípios refletem SDD canônico (Tasks 18, 23). ✅
- [ ] **Spec 2 (8 princípios invioláveis)** — Task 18 escreve seção Princípios na SKILL.md com os 8. ✅
- [ ] **Spec 3 (Estrutura de fases)** — Tasks 19-22 escrevem os 4 estágios. ✅
- [ ] **Spec 4.1 (tipo_projeto)** — Task 14 (`references/tipos-projeto.md`), Task 19 (Pré-spec.Discovery pergunta), Task 30 (`templates/constitution.md` YAML). ✅
- [ ] **Spec 4.2 (tier)** — Task 15 (`references/tiers.md`), Tasks 19, 30. ✅
- [ ] **Spec 4.3 (Bloco YAML)** — Task 30 (template constitution). ✅
- [ ] **Spec 4.4 (Inventário)** — Task 17 (`references/inventario-dependencias.md`), Task 19 (Pré-spec.Stack 3 sub-componentes). ✅
- [ ] **Spec 4.5 (EARS + BDD)** — Task 21 (`references/linguagens-especificacao.md`), Task 31 (`templates/requirements.md` EARS), Task 14 (`templates/plan-feature.md` BDD). ✅
- [ ] **Spec 4.6 (DDD opcional)** — Task 32 (`templates/design.md` seção 7 Bounded contexts opcional). ✅
- [ ] **Spec 5 (Mapa de integração com skills)** — Task 19 (`references/integracao-skills.md`), Tasks 19-22 mencionam skills nas fases. ✅
- [ ] **Spec 5.1.1 (5 ajustes SDD sobre writing-plans)** — Task 21 (Build.Implementation lista 5 ajustes), Task 14 (`templates/plan-feature.md`). ✅
- [ ] **Spec 5.1.2 (Refactor markdown)** — Task 21 + Task 21 referencia 5.1.2. ✅
- [ ] **Spec 6 (Catálogo de tipos)** — Tasks 14, 15, 16 (references) + Tasks 19-22 (SKILL.md). ✅
- [ ] **Spec 7 (Audit 13×5)** — Task 18 (`references/audit-dimensoes.md`), Task 22 (Ship.Audit). ✅
- [ ] **Spec 8 (Promoção de Tier)** — Task 24 (sub-skill SKILL.md). ✅
- [ ] **Spec 9 (Estrutura de arquivos)** — File Structure deste plano cobre. Tasks 1-32 implementam. ✅
- [ ] **Spec 9.2 (5 commands)** — Tasks 25-29. ✅
- [ ] **Spec 10.1 (Bump version)** — Task 32. ✅
- [ ] **Spec 10.2 (Migração v2.x → v3.0)** — Task 23 (SKILL.md "Como invocar" → seção Migração). ✅
- [ ] **Spec 10.3 (Plano de release de 7 etapas)** — Etapa 1-2 cobertas neste plano (implementação + validate); etapas 3-7 (publicação, rodar em projeto real, estabilização, promoção pra recomendado) ficam fora do escopo deste plano e exigem ações pós-merge. **Documentado em "Etapas pós-merge" no fim deste plano.**

### 2. Placeholder scan

Verificar com grep:

```bash
grep -nE "TBD|TODO|FIXME|fill in|implement later|placeholder" docs/superpowers/plans/2026-04-30-sdd-workflow-v3-implementation.md || echo "NO PLACEHOLDERS"
```

Expected: `NO PLACEHOLDERS`

### 3. Type consistency

- [ ] Nomes de fases consistentes em todo o plano:
  - Pré-spec.{Discovery, Constitution, Stack}
  - Spec.{Requirements, Design, Spike}
  - Build.{Tasks, Implementation}
  - Ship.{Audit, Delivery, Deploy}
- [ ] Nomes de slash commands consistentes:
  - `/sdd-workflow:start`, `:status`, `:gate`, `:audit`, `:promote-tier`
- [ ] Nomes de campos no YAML consistentes:
  - `tipo_projeto`, `tier`, `tier_decidido_em`
- [ ] Nomes de skills externas consistentes:
  - `superpowers:brainstorming`, `:writing-plans`, `:test-driven-development`, `:executing-plans`, `:subagent-driven-development`, `:systematic-debugging`, `:verification-before-completion`, `:using-git-worktrees`, `:dispatching-parallel-agents`, `:requesting-code-review`, `:finishing-a-development-branch`
  - `plugin-dev:plugin-validator`, etc.
  - `marketplace-tools:validate`, `:publish-plugin`
- [ ] Nomes de arquivos (templates/references/commands) consistentes entre Tasks e SKILL.md ref tabelas

Aplicar correções inline se inconsistências encontradas.

### 4. Etapas pós-merge (fora do escopo deste plano)

Conforme spec seção 10.3:

3. Bump version no marketplace.json (✅ feito na Task 32)
4. Aplicar fluxo de publicação Level 3 (`/marketplace-tools:publish-plugin`) — pós-merge na main
5. Rodar v3.0 em projeto real (sugerido: novo, do zero) — uso real
6. Coletar achados, ajustar, bump pra 0.2.1 ou 0.3.0 — iteração
7. Quando estável, promover tag `em-testes` → `recomendado` e bump pra 1.0.0 — release final

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-30-sdd-workflow-v3-implementation.md`. Two execution options:

**1. Subagent-Driven (recommended)** — dispatch a fresh subagent per task, review between tasks, fast iteration. Recomendado pra plano grande (33 tasks). Use `superpowers:subagent-driven-development`.

**2. Inline Execution** — execute tasks in this session usando `superpowers:executing-plans`, batch execution with checkpoints for review. Recomendado pra debugging fino ou se preferir manter contexto único.

**Which approach?**
