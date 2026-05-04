# Relatório de Evolução do Plugin sdd-workflow (v0.2.4)

> Análise estratégica e comparativa em duas janelas (30 dias / 6 meses) com base nos artefatos descritos pelo autor (não foi possível acessar diretamente os arquivos do repositório `ajunges/aj-openworkspace` durante a pesquisa — todas as recomendações fundadas no plugin partem das premissas inegociáveis fornecidas no briefing; quando preciso, sinalizo que a recomendação requer leitura cirúrgica posterior).

---

## 1. Resumo executivo

**Posicionamento competitivo em uma frase.** O sdd-workflow ocupa uma posição rara e defensável: um plugin Claude Code opinativo, em pt-BR, que combina o esqueleto do GitHub Spec Kit (Constitution → Specify → Plan → Tasks → Verify) com um modelo de qualidade tier-aware (5 níveis de "tier projetado") e um Audit dimensional fixo de 13 eixos — algo que nem Spec Kit, nem Kiro, nem BMAD oferecem prontos para solo-dev não-programador.

**Top-3 recomendações em 30 dias (v0.3.x — incrementais).**

1. **Adotar GEARS como notação opcional dentro de Requirements, mantendo EARS como default.** A onda de adoção é jovem (paper publicado em jan/2026 no SubLang, repo IterOn em GitHub) mas resolve dores reais relatadas pela comunidade Spec Kit (issue #1356 do `github/spec-kit` pede integração EARS; Kiro já usa EARS por default). Custo baixo — um arquivo `references/gears-patterns.md` e uma flag em template — e abre porta para spec-as-test que já é citada como diferencial pela própria documentação GEARS.
2. **Criar protocolo formal de exceção a princípios invioláveis ("Constitution Amendment").** A literatura sobre constitutions em Spec Kit mostra que princípios "imutáveis" sem mecanismo de exceção viram fricção (issue #287, issue #366) ou são silenciosamente ignorados pelo agente (Martin Fowler: "fui ver a constituição e o agente ignorou as notas"). Replicar o padrão "Article + Override Record + Justification" dos ADRs tradicionais e do 12-Factor App.
3. **Introduzir um "spike skill" (sdd-spike) e um modo `light` para tier `prototipo_descartavel`.** O ataque mais consistente a workflows opinativos na revisão de Birgitta Böckeler (Martin Fowler) e Scott Logic é "sledgehammer to crack a nut" — 11 fases × gate humano para corrigir um typo é sobrecarga letal. Um spike isolado (15 min, sem gate, sem audit) é o que Shape Up, Devin e Claude Code Plan Mode oferecem nativamente.

**Top-3 recomendações em 6 meses (rumo a 1.0 — estratégicas).**

1. **Tornar tier_projeto e tipo_projeto extensíveis via plugin-of-plugin (catálogo aberto).** A demanda por mobile native, MCP server, agente autônomo, ML pipeline, game dev e CLI tool é evidente em Spec Kit (issue #366 "constitution catalog and hub"), Kiro (steering files), BMAD (expansion packs) e cc-sdd (kiro-discovery routing). O sdd-workflow precisa decidir cedo se será catálogo fechado (4 tipos) ou framework — fechado limita TAM, framework dilui opinião. Recomendo "catálogo curado + fork-friendly".
2. **FinOps nativo: model routing por fase + cache de constituição/templates + budget por tier.** O custo real de rodar 11 fases × 13 dimensões com Opus + thinking MAX em projeto pequeno é da ordem de US$10–50 por end-to-end (extrapolando dos números do Anthropic Code Docs: $13/dia/dev em uso enterprise, e relatos de 10B tokens em 8 meses). Para audiência leiga em assinatura Pro/Max, isso queima o limite em horas. Spec Kit não trata; Kiro segregou Spec vs Vibe requests precisamente por causa desse problema (post oficial Kiro pricing de ago/2025). É diferencial competitivo decisivo.
3. **Living specs + drift detection automatizado (spec ↔ code).** O risco de "spec theater" é a falha-mãe de toda metodologia formal aplicada a IA, e a indústria já se posicionou: Tessl, Augment Intent, OpenSpec e cc-sdd v3 viram nessa direção em 2025–2026 (Augment Code 2026, blog Tessl). Sem isso, em 6 meses o sdd-workflow vira "outro Spec Kit em pt-BR".

**Top-3 riscos de obsolescência (12–24 meses).**

1. **Anthropic abrir Agent Skills como padrão e o ecossistema se uniformizar em torno dele.** Já aconteceu em dez/2025 (anúncio oficial Anthropic) e jan/2026 (open standard agentskills.io). MCP virou padrão de fato em 2025. Plugin que vive no formato Claude Code mas não é portável para Cursor/Codex/Copilot/Goose/Amp (que adotaram Skills) é um nicho fechando.
2. **Convergência de SDD em IDE-nativo (Kiro, Antigravity, Codex apps) tornando plugin-CLI um vetor secundário.** Kiro (AWS), Antigravity (Google), e Devin 2.0 já oferecem SDD como afford âncora do IDE, com integração que plugin-CLI não consegue alcançar. O sdd-workflow precisa decidir se é "guardião da disciplina" (e aceita ser nicho premium) ou se persegue paridade de UX (e aceita esforço enorme).
3. **Audit de 13 dimensões fica datado em 12 meses.** A indústria adicionou prompt injection (OWASP LLM Top 10 2025), AI safety/alignment, FinOps por workload (FinOps Foundation 2026 State report) e carbon-aware scheduling como dimensões obrigatórias em 2025–2026. As 13 dimensões fixas precisam ser modulares e versionadas, ou viram passivo.

---

## 2. Análise comparativa por comparável

### 2.1 GitHub Spec Kit

**O que faz.** Toolkit CLI distribuído via `uvx`/`pipx` que cria scaffolding `.specify/` com slash commands `/speckit.{constitution,specify,clarify,plan,tasks,implement,analyze,checklist}` em qualquer agente compatível (Claude Code, Cursor, Copilot, Gemini CLI, Pi, Antigravity). Cada feature tem branch dedicada, spec.md, plan.md, tasks.md em `specs/[###-feature]/`. Constituição vive em `.specify/memory/constitution.md` com "nine articles" (library-first, CLI-first, test-first, etc.).

**Onde é melhor que sdd-workflow.** (a) Multi-agent: roda em 8+ agentes, sdd-workflow é Claude-Code-only. (b) Maturidade da comunidade: 1k+ issues, debate público, contribuições constantes. (c) Branching automático por feature evita conflito entre specs paralelas. (d) Documentação operacional rica (Microsoft Dev Blog, GitHub Blog, codestandup.com tutoriais oficiais). (e) `/speckit.analyze` é um quality-gate cross-artefato pronto.

**Onde é pior.** (a) Sem tiering — uma constituição por projeto, sem distinção entre protótipo e produção (issue #287, #366 reclamam disso). (b) Audit dimensional não existe — `/speckit.checklist` é genérico. (c) Em inglês, sem opinião sobre audiência leiga. (d) "Spec theater" denunciado em primeira pessoa por Birgitta Böckeler (Martin Fowler) e Scott Logic: para mudanças pequenas, "sledgehammer to crack a nut". (e) Sem protocolo de exceção — agente ignora ou exagera princípios silenciosamente. (f) Greenfield bias — issue #806 e discussão #746 reclamam que brownfield exige tunagem manual pesada.

**Lições portáveis.** Adotar `/sdd-analyze` cross-artefato; estudar mecanismo de branch-per-feature; aprender com falhas observadas (constituição-overwrite no reinit, issue #1541) para não cometer os mesmos erros; observar como issue #1149 ("o que vai em constituição vs. spec") já foi fonte de confusão real — sdd-workflow precisa documentar essa fronteira.

### 2.2 AWS Kiro

**O que faz.** IDE fork de VS Code (Code OSS) lançado em jul/2025, com Spec Mode e Vibe Mode segregados, EARS como notação default em acceptance criteria, steering files (product.md, structure.md, tech.md), agent hooks (file-change triggers), MCP nativo. Roda em Claude Sonnet 4.5 ou Auto (multi-model routing).

**Onde é melhor.** (a) Pricing model maduro — separa "spec request" de "vibe request" e cobra diferente, oferece dashboard de uso (post oficial Kiro 15/ago/2025). É a única ferramenta no mercado que tornou FinOps de SDD um produto. (b) IDE-nativo elimina friction de "rodar comando, copiar arquivo". (c) EARS pronto. (d) Hooks são ortogonais ao workflow (auto-generate tests on save, etc.). (e) Spec/Vibe split é didaticamente claro para audiência leiga ("aqui você dirige, aqui você vibrou").

**Onde é pior.** (a) Lock-in em fork de IDE; quebra para quem usa Claude Code/CLI. (b) Sem tiering explícito (mesmo audit para protótipo e produção). (c) Sem auditoria dimensional — InfoQ ago/2025 reportou que "developers feel like PMs, not engineers" sem rigor de qualidade pós-spec. (d) Sem opinião sobre tipo_projeto. (e) Closed-source na essência (Kiro IDE) limita customização profunda.

**Lições portáveis.** O modelo Spec/Vibe + dashboard de uso é a referência para a recomendação 30-dias #3 (modo light) e a recomendação 6-meses #2 (FinOps). EARS por default é validado por Kiro como aceitável a audiência mista. Steering files são equivalentes funcionais à constituição mas mais leves — vale estudar.

### 2.3 BMAD Method

**O que faz.** Framework multi-agent com personas ("Analyst", "PM", "Architect", "Scrum Master", "Developer", "QA", "Orchestrator") definidas em arquivos Markdown+YAML. Workflows greenfield/brownfield. v6 reescrita em alpha. Suporta Claude Code, Cursor, Windsurf, VS Code. 19k+ stars.

**Onde é melhor.** (a) Domain intelligence por persona: PM agent simula uso real, faz "day in the life" — útil para audiência que não sabe especificar. (b) BMad Quick (single spec) vs BMad Full (PRD + Architecture + Stories) — tiering implícito por profundidade. (c) Expansion packs por domínio (game dev, ML, etc.) — modelo de catálogo aberto que sdd-workflow precisa estudar. (d) `.customize.yaml` que sobrevive upgrades — solução elegante para o problema de overwrite.

**Onde é pior.** (a) Multi-persona é fricção real para solo-dev (premissa que sdd-workflow rejeita conscientemente — e bem). (b) Heavy artifact set: PRD + Architecture + Stories é overkill para projetos pequenos. (c) Onboarding curve longo. (d) Sem tier_projeto explícito (gradação é por método, não por nível de risco). (e) Sem audit dimensional. (f) Cost engineering: o autor (Mathivanan Mani, Medium) explicitamente notou que BMAD Full produz "artifact set heavy and hard to review".

**Lições portáveis.** Expansion pack model é o caminho para extensibilidade de tipo_projeto. `.customize.yaml` que sobrevive upgrades é prática fundamental. PM persona "day in the life" é técnica útil para extrair requirements de não-devs sem usar EARS frio direto.

### 2.4 Cognition Devin

**O que faz.** Agente autônomo cloud-based ("AI software engineer"). Devin 2.0 (mar/2025) introduziu Interactive Planning, Devin Search, Devin Wiki, paralelismo, plano $20 self-serve. Cognition usa Devin internamente para construir Devin (busca, integrações, dashboards, PRs revisados por humanos).

**Onde é melhor.** (a) Plan Mode explícito antes de execução — usuário aprova plano, depois solta. (b) Indexação automática do repo + Devin Wiki gerada automaticamente é tipo de "living spec" que sdd-workflow não tem. (c) ACU budget (Autonomous Compute Unit) é primitivo de FinOps por sessão. (d) Tag-Devin-from-Slack/Linear/Jira é UX que sdd-workflow nem cogita. (e) "Tratar como junior engineer com tarefa testável em horas" é pattern empírico bem documentado (docs.devin.ai "When to Use Devin").

**Onde é pior.** (a) Não é spec-first — é task-scoped, sem constituição persistente. (b) Caixa-preta: usuário não vê/controla as fases internas. (c) Caro a partir de US$ 500/mês para teams; o plano $20 individual é limitado. (d) Não opinativo sobre disciplina — é "junior contratado", você define o método. (e) Não há catálogo de tipos.

**Lições portáveis.** Plan Mode antes de implement (Anthropic Claude Code copiou a primitiva). ACU budget como modelo mental para tier-aware budget. Pattern "size to testable in hours" como guideline operacional para escopo de spec, e padrão "good vs bad instructions" como conteúdo educativo para audiência leiga.

### 2.5 Anthropic — Claude Code, Skills, Agent SDK, Plan Mode

**O que faz.** Claude Code é o terminal/IDE-bridge da Anthropic. Skills (out/2025, padronizadas como open standard em jan/2026 em agentskills.io) são folders com `SKILL.md` + scripts + recursos com progressive disclosure (metadata em system prompt, full body só quando relevante). Plan Mode (built-in) prepara uma sequência aprovável antes de executar. Agent SDK programático.

**Onde é melhor.** (a) Skills é o substrato natural sobre o qual sdd-workflow já está construído — vantagem é estar dentro do padrão. (b) Plan Mode resolve um problema (planejamento) que sdd-workflow trata em fases inteiras (Specify+Plan+Tasks). (c) Hooks (PreToolUse, PostToolUse, SessionStart) permitem instrumentar fases sem escrita de prompt extra. (d) Marketplaces oficiais e auto-update de plugins (mar–abr/2026) são canal de distribuição maduro. (e) Em out/2025, Anthropic publicou Skills como **open standard** — Microsoft (VS Code, GitHub), Cursor, Goose, Amp e OpenCode aderiram, OpenAI Codex CLI replicou estruturalmente o formato (VentureBeat fev/2026).

**Onde é pior.** (a) Não é opinativo — é primitivo. Define a forma, não a metodologia. (b) Plan Mode é genérico, sem disciplina cross-fase. (c) Skills oficiais não cobrem SDD — há lacuna. (d) Hooks funcionam mas exigem scripting. (e) Sem audit dimensional embutido.

**Lições portáveis.** O sdd-workflow deve preparar `SKILL.md` + frontmatter compatível com agentskills.io (padrão portável) e considerar exposição a outras plataformas como `--target codex`, `--target cursor`, espelhando o que `cc-sdd@latest` já faz. Hooks devem ser exploradas para automatizar Quality Gates simples (lint+test antes de marcar fase concluída). O timing é crítico: a janela para se posicionar como SDD opinativo dentro do padrão Skills é 2026.

### 2.6 Cursor / Windsurf / Aider (bloco)

**O que fazem.** Cursor Rules (`.cursor/rules/*.mdc` ou `.cursorrules`) e Windsurf Rules (`.windsurf/rules/`) + Memories + AGENTS.md são sistemas de "regras persistentes" — não SDD, mas project-aware steering. Aider é coding agent terminal-first com `CONVENTIONS.md`. Cursor Background Agents (paralelismo). Windsurf Cascade Workflows (multi-step).

**Onde são melhores.** (a) Densidade de adoção: 10x+ usuários ativos vs qualquer plugin SDD (Cursor + Copilot dominam). (b) Activation modes (always-on, manual, glob, model-decision) são granularidade que sdd-workflow não tem. (c) Memories captura aprendizado contínuo automaticamente. (d) AGENTS.md auto-discovery por diretório resolve "como aplicar regra X só em /backend?".

**Onde são piores.** (a) Não são SDD: regras não são spec. Drift é problema permanente (Augment Code dez/2025: "CLAUDE.md is a capable spec-delivery mechanism for single-agent, multi-session workflows; Effectiveness depends on how well the spec is written and maintained, not the tool"). (b) Sem fases. Sem gates. Sem audit. (c) Cursor Rules tornam-se "spec theater" facilmente — markdown que ninguém lê.

**Lições portáveis.** Activation modes (glob, always-on, agent-requested, manual) são primitiva valiosa para reduzir fricção. AGENTS.md compatível pode ser passe livre para aderência ao padrão emergente que Cursor, Windsurf e Anthropic todos suportam. Memories como "diário de aprendizado por projeto" é gancho útil para reduzir custo de re-prompting.

---

## 3. Análise por dimensão (questões-mãe e seções 16–19)

### Q1. Posicionamento de mercado

**Resposta direta.** Sim, ocupa espaço único, mas pequeno. Triangulando: Spec Kit é tool-agnostic e em inglês; Kiro é IDE fork pago; BMAD é multi-persona pesado. Nenhum oferece simultaneamente: (a) tier-aware quality, (b) audit fixo de 13 dimensões, (c) audiência leiga executiva, (d) pt-BR. **O risco é que o nicho seja pequeno demais e/ou que cada eixo individual fique para trás dos comparáveis genéricos** — Spec Kit em inglês continuará evoluindo mais rápido que sdd-workflow em pt-BR; Kiro adicionará tier interno em algum momento; algum fork da comunidade fará pt-BR genérico.

**O que faz que ninguém faz.** Tier projetado como contrato explícito sobre o nível de rigor exigido. Audit dimensional fixo como "definition of done" estruturado. Princípios invioláveis numerados (8) com TDD canônico forçado em markdown/JSON.

**O que ninguém faz que ele faz.** Branching automático por feature (Spec Kit faz). Multi-agent execution paralela (Devin/Cursor Background). Drift detection (Augment Intent, Tessl). Living specs (cc-sdd v3, OpenSpec). PR/FAQ + 5 questions (Working Backwards). Spec/Vibe split com pricing visibility (Kiro). Open standard agentskills.io compliance (Anthropic + parceiros).

### Q2. Audiência — não-programador executivo dirigindo IA

**Evidência empírica disponível.** A premissa tem suporte empírico crescente, com a ressalva de que "executivo dirigindo IA" é um padrão real mas a maioria não usa workflows estruturados — usa Lovable/v0/Claude direto. Fonte primária: The New Stack, abr/2026, "I was tired of explaining it to somebody who was supposed to build it for me" — entrevista Brad Shimmin (Futurum) cita 75% de tomadores de decisão usando ferramentas agentic, expansão "outward" entre executivos. Moshe Bar (Codenotary) descreve construir BBS para IBM 3270 via Claude sem ser programador. Tyler Robertson (Medium, "Vibe Coding with Kiro") relata explicitamente: "I am not a developer. I specialize in AWS Networking" — usou Kiro Spec Mode para refactor.

**Padrão observado.** Não-devs preferem ferramentas conversacionais leves (Lovable, v0, Bolt) para protótipo, e adotam estrutura **só quando algo dá errado**. Pessoa Donner ("Vibe Coding AI Agents for non-techies", Shane Drumm) descreve PM trajetória: ChatGPT → Lovable vibe coding → cursos de Agent SDK → migrou só quando precisou. Implicação para sdd-workflow: **o ponto de entrada não pode ser "11 fases"**. Tem que haver onramp leve (recomendação 30-dias #3).

**Não encontrei evidência clara** de programa formal ensinando 13 dimensões de audit a executivos. Recomendo **levantamento direto via teste com 5 executivos brasileiros** (1h cada) usando o plugin como está e medindo: tempo até primeira spec aprovada, abandono em qual fase, quantos termos pediram tradução.

### Q3. Vocabulário — EARS+BDD+TDD+13 dimensões assimilável?

**Evidência mista.** EARS tem track record sólido em audiência mista de engenharia (Mavin original, Jama Software, QRA Corp documentam adoção em Airbus, Bosch, Dyson, Honeywell, Intel, NASA, Rolls-Royce, Siemens). É deliberadamente lightweight; QRA explicitamente diz "easy to adopt". MAS isso é em contexto de engenheiros profissionais não-nativos em inglês, **não executivos**.

GEARS (jan/2026) explicitamente posiciona test-case-equivalence (Given-When-Then maps direto a sintaxe) como vantagem para LLMs. **Isso pode reduzir cognitivo para o autor humano também.** Comparáveis tomam abordagens diferentes:

- Kiro: EARS escondido — usuário diz "add review system", Kiro gera EARS, mostra para revisão. Não exige escrita ativa de EARS.
- BMAD: PM persona "day in the life" — extrai requirements via cenário narrativo, depois converte.
- Spec Kit: deixa formato livre por default; comunidade pede EARS explicitamente (issue #1356).
- Devin: prompt natural language, inferência interna.

**Recomendação.** Manter EARS como **output produzido pelo agente para o humano revisar**, não como linguagem que o humano precisa redigir do zero. 13 dimensões podem assustar — mostrar progressivamente, **uma dimensão por fase**, com checkbox e descrição em pt-BR. Não exigir leitura completa do audit no início.

### Q4. Tier projetado vs tier observado

**Comparáveis distinguem?** Praticamente nenhum. BMAD tem Quick vs Full (proxy informal). Kiro tem Spec vs Vibe (orthogonal a tier). Spec Kit não distingue. cc-sdd kiro-discovery faz roteamento ("extend / no-spec / one spec / multiple specs / mixed") que se aproxima de tier-aware. **Sdd-workflow é incomum nessa dimensão.**

**Onde ajuda.** Permite proporcionar gate severity ao risco. Permite manter o mesmo workflow e mexer só no rigor. Cria conversa explícita sobre intenção (essa é a ferramenta socrática).

**Onde estorva.** (a) Risco de dissonância: o autor declara `mvp` mas exige UX/Acessibilidade nível `producao_real` — gate fica vago. (b) Tier "projetado, nunca observado" cria assimetria perigosa: sem feedback loop, o autor pode estar sempre miscategorizando. (c) Tier não é binário, é gradiente — 5 níveis discretos podem ser tanto inflação artificial (4 bastariam) quanto granularidade insuficiente.

**Recomendação.** Manter 5 níveis. Adicionar **observed-tier inferido** — ao final de cada fase, o agente reporta "comportamento observado: você operou como mvp, projetado era beta". Isso transforma tier de declaração em conversa.

### Q5. Catálogo de tipo_projeto

**Como comparáveis lidam.** Spec Kit lista tipos abertos no plan-template ("library/cli/web-service/mobile-app/compiler/desktop-app or NEEDS CLARIFICATION"). Kiro tem steering files extensíveis. BMAD tem expansion packs (game dev, DevOps, etc.) que são modelo plugin-of-plugin maduro. cc-sdd usa kiro-discovery para roteamento dinâmico.

**Tipos faltantes em sdd-workflow.** Mobile native (iOS/Android), CLI tools, ML/data pipelines, game dev, MCP servers, agentes autônomos, design system, infraestrutura como código, Chrome extension, browser extension, electron desktop. Cada um exige princípios diferentes de Audit (ex.: ML pipeline precisa de "data lineage" e "model versioning" como dimensão; MCP server precisa "tool description quality" e "permission boundary").

**Recomendação 6-meses.** Migrar para "catálogo curado + extensão por skill". Modelo: `sdd-type-mobile-native` é uma sub-skill que injeta princípios e dimensões adicionais. O usuário declara em `tipo_projeto` e o plugin carrega o pacote correspondente. Catálogo de 4 → 8–12 tipos curados pelo autor + protocolo público para a comunidade contribuir. Ver BMAD expansion pack model como referência.

### Q6. Audit dimensional — estado da arte

**Dimensões obrigatórias modernas que faltam ou precisam refresh:**

- **Prompt injection / LLM01 OWASP 2025** (relevante quando tipo_projeto inclui LLM, MCP server, agente). Inclui sensitive information disclosure, supply chain (LLM03), excessive agency (LLM06).
- **AI safety/alignment dimension** quando o sistema gera output autônomo (refusal patterns, jailbreak resistance).
- **FinOps/Sustainability** — CO₂e por workload, custo por unidade de saída, model routing eficiência. State of FinOps 2026 (FinOps Foundation): 98% das equipes gerenciando AI spend, alta correlação com GreenOps.
- **Data residency / LGPD** explícita (faltava ou estava implícita em "Conformidade").
- **Cost ceiling per session** como propriedade de projeto.
- **Testabilidade adversarial** (não é só TDD; é fuzz e red-team em projetos com superfície de ataque).

**Como ficam parametrizadas por tier.** Hoje, 13 dimensões fixas × tier não permite "esta dimensão não se aplica a este tier". Em `prototipo_descartavel`, Acessibilidade WCAG completo é absurdo; em `producao_real` com público B2C, Acessibilidade é hard gate. **Recomendação:** matriz `dimensão × tier × projeto_type → severity` (ignore / informational / warning / blocker). Hoje implícita, deveria ser explícita.

### Q7. Acoplamento com plugins externos (superpowers)

**Dependência forte é aceitável?** Depende do uso. O plugin **superpowers** de Jesse Vincent (obra/superpowers) entrega TDD/spec/review/git-worktree maduro e está no marketplace oficial Anthropic. Acoplá-lo via "modos de integração" é razoável **se o sdd-workflow não duplicar funcionalidade**. Risco real: superpowers muda mais rápido que sdd-workflow consegue acompanhar; auto-update de plugins (Claude Code feature de 2026) pode quebrar pressupostos.

**Como outros tratam.** cc-sdd v3 escolheu "no external dependencies" — primitivos nativos da plataforma. rhuss/cc-sdd usa traits para overlay sobre Spec Kit (modelo aspect-oriented). BMAD declara .customize.yaml que sobrevive upgrades (mais defensivo).

**Recomendação.** Documentar matriz de compatibilidade explícita (sdd-workflow X.Y ↔ superpowers ≥ Z). Adicionar `--no-superpowers` mode para fallback nativo. Em 6 meses, considerar absorver as poucas primitivas críticas (TDD red/green, worktree management) para reduzir lock-in. Isso é o oposto do que normalmente sugiro, mas é defensável aqui porque audiência leiga não consegue fazer triagem de quebra entre plugins.

### Q8. Pivot e evolução

**Como comparáveis tratam.** Spec Kit explicitamente vê pivot como "specifications drive implementation, pivots become systematic regenerations rather than manual rewrites" (spec-driven.md). Mas a prática reportada (issue #806, #746, comentários de Birgitta Böckeler) é que brownfield e refactor de domínio quebram o fluxo greenfield. EPAM (post de mai/2026) precisou criar sub-tutoriais inteiros para brownfield. cc-sdd kiro-discovery routes para "extend existing spec" como caso explícito.

**O que sdd-workflow precisa endereçar.** (a) Mudança de tipo_projeto (saiu de claude-plugin para web-saas). (b) Refactor que quebra princípio inviolável anteriormente respeitado. (c) Ressuscitar projeto abandonado (constituição desatualizada vs código desatualizado). (d) Migração de tier (sub-skill sdd-promote-tier já trata, bom).

**Recomendação 30 dias.** Adicionar `sdd-pivot` skill (irmã de `sdd-promote-tier`) para mudança formal de tipo_projeto, com diff entre constituições e migration plan.

**Recomendação 6 meses.** Living specs com drift detection — quando código diverge da spec, plugin reporta. Isso resolve o problema "ressuscitar projeto" estruturalmente.

### Q9. Princípios invioláveis vs exceções

**Como precedentes tratam exceção.**

- **12-Factor App**: princípios sem mecanismo de exceção formal — virou diretriz, não regra. Comunidade trata como guia. Resultado: algumas equipes desviam silenciosamente, outras criam wrappers (12-Factor Agents de Dex Horthy, "what holds true for all agent implementations").
- **REST constraints**: Fielding define cinco constraints "fixos"; na prática, 90% dos APIs reais violam HATEOAS. Sem ritual de exceção, virou aspiração.
- **ADRs**: têm estrutura para "Superseded by ADR-XXX" — exceção é registrada, justificada e amarrada à decisão original. **Esse é o melhor precedente.**
- **Spec Kit constitution**: sem protocolo formal — issue #287 mostra constituição sendo ignorada na prática.

**Recomendação 30 dias (recomendação executiva #2).** Importar protocolo ADR-style: princípio fica, mas pode haver `Override Record` documentando "neste projeto, princípio 4 (TDD canônico universal) é suspendido para arquivos `.md` de marketing porque [justificativa]". Sem isso, princípios invioláveis ficam fingidos ou rebeldes.

### Q10. Multi-persona (nota breve)

Conforme premissa, manter solo-only. Em roadmap longuíssimo (>12 meses), considerar "modo asynchronous review" onde uma segunda IA atua como reviewer adversarial (não persona, função). BMAD Orchestrator + QA Agent é o caminho referência se um dia for adotado. **Não é foco, não consumir esforço de design hoje.**

### Q11. Pt-BR vs internacionalização

**Workflow técnico em idioma local — diferencial ou friction?**

**Evidência de friction.** A maior parte do ecossistema técnico de IA é em inglês. Tradutor, Tradutor pt-PT, Qwen issue #2094 reconhecem que pt-BR é under-served. Mas isso é evidência de oportunidade, não de fracasso de localização.

**Evidência de tração para localização técnica.** cc-sdd suporta 13 idiomas, incluindo pt: `npx cc-sdd@latest --lang pt`. **Isso significa que o autor de cc-sdd validou demanda suficiente para investir em tradução.** No entanto, é um fork — não há evidência de adoção massiva pt-BR.

**Workflows técnicos mantidos em idioma não-inglês com tração.** Não encontrei precedente forte. n8n, OpenSpec, Spec Kit todos disponíveis em pt mas adoção primária é em inglês. **Stack Overflow em pt-BR fechou em 2024.** Manter pt-BR como language default é uma aposta consciente que captura **mercado brasileiro de não-devs** mas exclui contribuidores internacionais.

**Recomendação.** Manter pt-BR como default. Adicionar `--lang en` em 6 meses para acessar contribuidores externos. **NÃO** traduzir nomes de comandos técnicos (`/sdd:specify` permanece — não vira `/sdd:especificar`). Tradução é da narrativa e dos templates, não da gramática operacional.

### Q12. Métricas de sucesso

**Como comparáveis instrumentam.** Spec Kit: nenhuma métrica embutida. Kiro: Vibe/Spec request count + dashboard (pricing-driven). Devin: Autonomous Compute Units. BMAD: nenhuma. cc-sdd: nenhuma.

**Métricas DORA aplicáveis a workflow solo.** Lead time for changes (idea → merged) é direto. Deployment frequency é proxy de velocidade. Change failure rate (regressão pós-merge) é proxy de qualidade. **Mas DORA está sendo questionado em era IA** (DORA Report 2025, Faros AI 2026) — agentes inflam frequency e lead time artificialmente. Métrica complementar emergente: **rework rate** (commits que voltam a uma fase já aprovada).

**Para sdd-workflow especificamente, propor:**

- Por feature: tempo do primeiro `/sdd:specify` até `Verify` aprovado.
- Abandono por fase (qual fase é onde mais projetos param?).
- Retrabalho de spec (quantas vezes a spec voltou a ser editada após "aprovada"?).
- Token spend total por end-to-end (dimensão FinOps; ver Q16).
- Satisfação subjetiva: ao final de Verify, "você usaria de novo?" 1–5.

**Como capturar.** Ver Q17 (telemetria opt-in) — sem instrumentação, métricas dependem de pesquisa qualitativa manual.

### Q13. GEARS posicionamento

**Estado de tração.** Paper publicado em 14 jan/2026 no SubLang.xyz, repo IterOn no GitHub, cobertura via Medium e DEV Community. Ainda novo. **Critério "<6 meses, <3 fontes não-promocionais"** se aplica — não classificaria como "adotar agora" puro.

**Mas o engajamento da comunidade Spec Kit é evidente** (issue #1356 abri demanda formal por EARS, e Kiro já usa EARS em produção). GEARS resolve dores documentadas: (a) generaliza "the system" para qualquer noun; (b) unifica preconditions com Where (config) vs While (state); (c) test-case-equivalence direta para Given-When-Then. **Isso casa com BDD/TDD que sdd-workflow já adota.**

**Recomendação.** "No radar com inclinação para surfar". Em 30 dias: documentar GEARS como notação alternativa em `references/gears-patterns.md`, mantendo EARS default. Em 6 meses: avaliar tração via pesquisa rápida (3 fontes não-promocionais? sim/não), e promover GEARS a default se sim. **A janela para liderar é jovem** — o primeiro plugin SDD a integrar GEARS seriamente colhe atenção da comunidade pequena que está acompanhando.

### Q14. Sub-fluxos faltantes

**Cobertos por comparáveis, não por sdd-workflow:**

- **Spike de viabilidade técnica isolada.** Devin Plan-then-act. Anthropic Plan Mode. cc-sdd `kiro-discovery → no-spec → implement directly`. **Recomendação 30 dias #3.**
- **Refactor de projeto inteiro.** Spec Kit issue #806. cc-sdd kiro-discovery "extend existing spec". Recomendado em Q8.
- **Fechamento/sunset.** Não encontrei comparável que trate explicitamente. Vale criar sub-skill `sdd-sunset` em 6 meses (lições aprendidas, decisão registrada, branch arquivado).
- **Transferência para outro time/desenvolvedor.** Devin Wiki é equivalente funcional (índice automático do repo). Para solo-dev, é "documentação de saída" — pacote que permite o próximo humano (ou IA) recuperar contexto rapidamente. Vale `sdd-handoff`.
- **Auditoria pós-deploy.** Spec Kit `/speckit.review` (issue #1323) propõe fechamento do loop com constituição. Sdd-workflow tem Audit, mas não tem revisão pós-deploy contra spec original. Vale `sdd-postmortem`.

### Q15. Risco de obsolescência (12–24 meses)

**Mudanças de ecossistema potencialmente invalidantes:**

1. **Skills como open standard portável (já rolando).** Se o sdd-workflow não suportar export para Cursor/Codex/Goose/Amp em 6 meses, vira refém de Claude Code.
2. **Living specs como expectativa baseline.** OpenSpec, Augment Intent, cc-sdd v3, Tessl convergiram em "spec se atualiza com o código". Plugins com spec estática vão parecer datados.
3. **Multi-model routing como expectativa.** Kiro Auto, Anthropic Fast Mode, Aider model selection — escolher Opus para tudo é ineficiente. Sdd-workflow precisa permitir routing por fase (Haiku para format, Sonnet para spec, Opus apenas em Audit/Verify).
4. **MCP como camada universal.** Agente já espera MCP nativo. Hoje plugin manipula só Skills + slash commands; em 12 meses, integrações via MCP serão padrão (sdd-workflow pode oferecer MCP server expondo audit dimensions como tool).
5. **Telemetria opt-in se tornará norma.** GitHub CLI fez isso (controvertido), Continue.dev faz (consensual). Se sdd-workflow nunca instrumentar, fica cego ao próprio sucesso.
6. **Anthropic mudar primitiva de plugin.** Claude Code plugins ainda têm semântica em evolução (ver CHANGELOG anthropics/claude-code com bugfixes contínuos em plugin install/dependency resolution). Hooks e skill paths mudaram em 2025–2026. Compromisso com essa primitiva é inerente ao escopo, mas vale monitor.

### Q16. FinOps do workflow

**Custo real de end-to-end típico.** Triangulando:

- Anthropic enterprise: ~US$13/dia/dev, US$150–250/mês/dev (Claude Code Docs 2026).
- Morph.ai 2026: usuário consumiu 10B tokens em 8 meses; Max plan US$100/mês economizou 93% vs API price.
- aicosts.ai: subagentes em paralelo podem gerar 887k tokens/min, US$ 8–15k/sessão complexa, US$ 47k em 3 dias para projeto sustentado.
- MindStudio 2026 ("How to Manage Claude Code Token Usage"): contexto rot a partir de 2h de sessão, redução 40-60% com `/clear` + concisão prompts.

**Implicação para sdd-workflow.** 11 fases × Audit 13 dimensões × Opus + thinking MAX em projeto pequeno consome facilmente 1–3M tokens cumulativos. No plan Pro (US$20/mês, ~225 Sonnet requests/mês) o usuário leigo estoura em **um único projeto**. No Max US$100/mês, talvez 3–5 projetos. **Isso é um gargalo de adoção, não de qualidade.**

**Como comparáveis tratam.**

- Kiro: separação Spec Request × Vibe Request com pricing visibility — modelo referência.
- Devin: ACU budget por sessão.
- BMAD: Quick mode vs Full mode é tier de gasto implícito.
- Spec Kit: nenhum tratamento.
- Cursor pós-junho/2025: pivotou para usage-based credit pool depois do desastre de junho com cobranças surpresa.

**Técnicas que valem incorporar:**

1. **Model routing por fase.** Format/lint = Haiku. Spec/Plan = Sonnet. Audit/Verify = Opus. Constitution editing = Opus. Documentação = Haiku. **Pode reduzir 40–70% sem perda de qualidade.**
2. **Cache de constituição.** Constituição muda raramente — `cache_control` da Anthropic API reduz custo de cache reads em ~90%.
3. **Token budget per tier.** `prototipo_descartavel` budget 50k. `producao_real` budget 1M. Plugin avisa antes de exceder.
4. **`/sdd:cost` como comando.** Mostra spend acumulado da sessão por fase.
5. **Auto-compaction antes de cada fase.** Limpa contexto de fase anterior, mantém apenas resumo.

**Esta é, na minha opinião, a recomendação 6-meses mais importante do plugin** porque transforma "qualidade premium" de proposta cara em proposta diferenciada e acessível.

### Q17. Telemetria e privacidade

**Como instrumentar feedback loop sem quebrar premissa "solo offline".**

**Padrões da indústria.**

- **GitHub CLI (abr/2026): opt-out, default-on.** Reação negativa intensa (The Register, issue #13263, #13260). Lição: opt-out por default é considerado hostil em CLI dev.
- **Homebrew (2016): opt-out com consent prompt explícito de primeira execução.** Considerado padrão-ouro.
- **Continue.dev: opt-out simples via setting.**
- **Kedro: opt-in, prompt de primeiro uso, UUID anonimizado em `~/.config/kedro/telemetry.conf`, `.telemetry` git-ignored, política LF Projects review.**
- **gh-copilot: opt-in com consent question explícita.**

**Recomendação.**

- **Default off.** Opt-in via `/sdd:telemetry on`.
- Esquema mínimo: anonymized install ID + comando + versão + plataforma + duração bucket + outcome category. **Nada de prompt content. Nada de file paths. Nada de project names.**
- Documentar exatamente em `references/telemetry.md`.
- Modo `--telemetry log` que mostra payload sem enviar (modelo gh CLI).
- Usar PostHog ou similar para custo zero inicial.
- Eventos prioritários: `phase.completed{phase, tier, type, duration_bucket}`, `gate.outcome{phase, approved}`, `abandon{phase}`, `pivot{from_type, to_type}`. Esses cobrem 80% das perguntas de Q12.

**Alternativa zero-tech.** Pesquisa qualitativa manual: a cada 30 instalações, autor faz convite para entrevista 30 min. Funciona até ~100 usuários, depois quebra.

### Q18. Spec theater

**Padrão observado.** A literatura é dura: Birgitta Böckeler (Martin Fowler) reportou ferramentas SDD ignorando notas explícitas e gerando duplicatas; Scott Logic concluiu que spec-kit em projeto hobby foi "lots of time spent reviewing markdown for no qualitative benefit"; Augment Code dez/2025: "more spec can produce more drift, not less"; "The Artifact Trap" (Shubham Sharma, Medium) generaliza para todo agile artifact.

**Como comparáveis mitigam.**

- Spec Kit: `/speckit.analyze` é cross-artifact consistency check; não resolve, sinaliza.
- Kiro: tasks geradas linkam de volta a requirements explicitamente. Helps mas não detecta drift de código vs spec depois.
- BMAD: planning agents validam mutuamente, mas artifact set heavy é piorado por mais artifacts para review.
- cc-sdd v3: "spec is contract, code is source of truth" — explicitamente inverte a relação para evitar spec theater.
- OpenSpec: delta specs por mudança em vez de spec global, mais reviewável.
- Augment Intent: living specs auto-updated por agente.

**O sdd-workflow herda o risco?** Sim, herda especialmente forte por ter 11 fases × audit 13 dimensões — multiplicador de artifact volume. **Antídotos arquiteturais a considerar:**

1. **Spec/code reconciliation explícita** — em cada fase Verify, comparar spec atualizada com diff de código real. Se >X% de divergência, gate humano para reconciliar antes de avançar.
2. **Spec-as-test (via GEARS).** Se a spec em GEARS mapeia direto para Given-When-Then, ela é testável — não é só prosa. Reduz dramaticamente spec theater.
3. **Living constitution** — constituição é amendada quando princípio é violado conscientemente, com Override Record (recomendação Q9). Sem isso, constituição vira ornamental.
4. **Audit-fatigue mitigation:** Q19.

### Q19. Ergonomia de Quality Gates

**11 fases × gate humano = 11 pontos de fricção.**

**Literatura sobre cognitive load em revisão sequencial.**

- Springer 2022 ("Do explicit review strategies improve code review performance? Towards understanding the role of cognitive load"): checklists reduzem cognitive load mensuravelmente; guidance estruturada melhora performance.
- ArXiv 2407.01407: decision fatigue reduz qualidade de revisão sequencial.
- CodeAnt AI ("Why Diff-Based Code Reviews Overwhelm Developers"): rubber-stamp emerge quando reviewer não tem contexto.
- Signadot: rubber-stamp com IA é "previsível" — humanos delegam validação à máquina.
- Chromium dev list: rubber-stamping aumenta com tamanho do time mas também com acumulação de aprovações sequenciais.

**Como comparáveis tratam:**

- Spec Kit: gates implícitos, pulável (scott logic relata pular `/speckit.analyze` "porque não eram críticas").
- Kiro: aprovação task-by-task em sequência (mesma fricção).
- BMAD: gates por persona handoff — múltiplos pontos. `bmad-quick-flow` reduz a 1.
- cc-sdd: per-task subagent + independent reviewer + auto-debug — descarrega cognitive load para agente de revisão.
- Devin: poucos gates explícitos, controle por interactive plan no início.

**Recomendações específicas:**

1. **Batch gates por tier.** Para `prototipo_descartavel`, fundir Constitution+Specify+Plan em um único gate "início" e Tasks+Implement+Verify em "fim". 2 gates em vez de 11.
2. **Async gates.** Em fases longas, agente continua execução em modo "vou parar antes do próximo gate", humano aprova quando voltar. Não bloqueia produtividade.
3. **Gate condicional.** Pular Audit em dimensões não-aplicáveis (matriz Q6).
4. **Rubber-stamp detection.** Se humano aprova gate em <X segundos consistently, plugin sugere "você aprovou rapidamente — quer revisar checkpoint Y?". Pequeno empurrão socrático.
5. **Independent reviewer agent (cc-sdd model).** Um sub-agente revisor adversarial, não persona, antes do humano. Reduz rubber-stamp porque humano vê dois pontos de vista.
6. **Checklists explícitos por gate.** Conforme Springer 2022 — checklists reduzem cognitive load em revisão. Hoje, "Quality Gate humano" provavelmente é prosa-livre. Padronizar.

---

## 4. Top-15 oportunidades de evolução (ranqueadas)

Critério: impacto × maturidade da evidência ÷ esforço estimado.

| # | Enunciado | Categoria | Esforço | Risco implementar mal | Horizonte | Evidência |
|---|---|---|---|---|---|---|
| 1 | Spike skill (`sdd-spike`) + modo `light` para `prototipo_descartavel`: 2 gates em vez de 11 | sub-fluxo | baixo | médio (perder rigor onde importava) | 30 dias | Scott Logic ("sledgehammer to crack a nut"), Birgitta Böckeler/Martin Fowler |
| 2 | Protocolo formal de exceção a princípios invioláveis (ADR-style Override Record) | princípio | baixo | baixo | 30 dias | Spec Kit issues #287, #1149; ADR github.io |
| 3 | Adotar GEARS opcional, EARS default; criar `references/gears-patterns.md` | linguagem/template | baixo | baixo | 30 dias | GEARS paper SubLang jan/2026; Spec Kit issue #1356 |
| 4 | Model routing por fase + cache de constituição + `/sdd:cost` | integração/FinOps | médio | médio (auto-routing errado pode degradar qualidade) | 6 meses | Anthropic pricing docs, Morph.ai 2026, Kiro pricing model |
| 5 | Living spec + drift detection automático após Verify | sub-fluxo | alto | alto (subprocesso fragil) | 6 meses | Augment Intent, OpenSpec, cc-sdd v3, Tessl |
| 6 | Catálogo de tipo_projeto extensível via plugin-of-plugin | governança | alto | alto (cisma de comunidade) | 6 meses | BMAD expansion packs; Spec Kit issue #366 |
| 7 | Audit dimensional modular: matriz `dimensão × tier × type → severity` | princípio | médio | médio (complexidade explode) | 6 meses | OWASP LLM Top 10, FinOps Foundation 2026 |
| 8 | `sdd-pivot` skill para mudança formal de tipo_projeto + brownfield bootstrap | sub-fluxo | baixo | baixo | 30 dias | Spec Kit issues #806, #746, #1436 |
| 9 | Telemetria opt-in mínima com schema documentado | observabilidade | médio | médio (risco reputacional se mal configurada) | 6 meses | GitHub CLI v2.91 backlash, Kedro/Continue patterns |
| 10 | Independent reviewer sub-agente antes de gate humano | sub-fluxo | médio | baixo | 6 meses | cc-sdd v3 per-task review pattern |
| 11 | `--target` para exportar Skills compatíveis com Cursor/Codex/Copilot | integração | médio | baixo | 6 meses | Anthropic Skills open standard jan/2026; cc-sdd@latest precedent |
| 12 | Adicionar dimensões: prompt injection, FinOps, AI safety, data residency | princípio | médio | baixo | 6 meses | OWASP LLM Top 10 2025, FinOps Foundation 2026 |
| 13 | `/sdd:status` mostra observed-tier vs declared-tier (instrumentação interna) | observabilidade | baixo | baixo | 30 dias | DORA 2025 (rework rate), Devin Wiki pattern |
| 14 | Auto-batched gates: gate condicional por tier, async approval, rubber-stamp detection | governança | médio | médio | 6 meses | Springer 2022 cognitive load study; CodeAnt AI |
| 15 | `sdd-handoff` e `sdd-postmortem` como sub-skills | sub-fluxo | baixo | baixo | 30 dias (handoff) / 6 meses (postmortem) | Devin Wiki, Spec Kit issue #1323 review |

---

## 5. Top-5 anti-patterns a evitar

1. **Constituição overwrite no upgrade.** Spec Kit issue #1541: usuários perderam customização. **Mitigar:** segregar `templates/` e `memory/` desde o design, jamais sobrescrever `memory/` em update.
2. **Rules sem activation mode.** Cursor/Windsurf comunidade testemunha: regras "always-on" inflam contexto desnecessariamente; "manual" só são ignoradas. **Mitigar:** todo princípio inviolável precisa declarar quando se ativa (sempre / por tipo / por tier).
3. **Spec theater por checklist exaustivo.** BMAD-Full caso documentado (Mathivanan Mani Medium): "artifact set heavy and hard to review". **Mitigar:** Audit dimensional progressivo, não monolítico.
4. **Multi-persona por default.** BMAD documentou pivots em projetos onde personas atrapalhavam — usuário acabou rodando bmad-quick. Solo-only é vantagem competitiva, não limitação.
5. **Telemetria opt-out por default.** GitHub CLI v2.91 backlash recente (abr/2026, The Register, Groundy.com): comunidade dev ressente coleta automática mesmo "anonimizada". **Mitigar:** opt-in explícito, payload visível, doc clara.

---

## 6. Glossário curto

- **EARS (Easy Approach to Requirements Syntax)** — Notação de Mavin et al. (2009, RE09 IEEE); five patterns (Ubiquitous, Event, State, Optional, Unwanted) + complexos.
- **GEARS (Generalized EARS)** — Extensão proposta em jan/2026 (SubLang.xyz) que generaliza subject e unifica patterns. Mapeamento direto Given-When-Then.
- **BDD/Gherkin** — Behavior-Driven Development (Dan North 2006); sintaxe Given-When-Then.
- **TDD canônico** — Red/Green/Refactor de Kent Beck.
- **ADR (Architecture Decision Record)** — Michael Nygard popularizou; documento curto de decisão técnica com contexto, decisão, consequências; pode ser "Superseded by".
- **AgDR (Agent Decision Record)** — Extensão proposta (me2resh/agent-decision-record) que registra decisões feitas por agentes IA.
- **Constitution (Spec Kit)** — Conjunto de princípios "imutáveis" do projeto.
- **Steering files (Kiro)** — Arquivos persistentes que guiam comportamento do agente (product.md, structure.md, tech.md).
- **Skills (Anthropic Agent Skills)** — Folder com SKILL.md + scripts; padronizado como open standard em agentskills.io desde jan/2026.
- **MCP (Model Context Protocol)** — Padrão Anthropic para conectar agente a ferramentas externas.
- **Living spec** — Spec que se atualiza junto com o código (Tessl, Augment Intent, OpenSpec).
- **Spec theater** — Padrão onde a spec vira fim em si, descolada do código real.
- **Brownfield project** — Projeto existente com código legado, vs greenfield (do zero).
- **Plan Mode (Anthropic)** — Modo Claude Code que prepara plano para humano aprovar antes de executar.
- **Vibe coding** — Termo de Karpathy (fev/2025); conversa natural com IA sem revisão estruturada.
- **PR/FAQ (Working Backwards)** — Press Release + FAQ escrito antes do produto, técnica Amazon.
- **DORA metrics** — Lead time, deployment frequency, change failure rate, MTTR; em 2025 adicionado rework rate.
- **FinOps** — Disciplina de governança financeira de cloud/AI spend.
- **Prompt injection** — OWASP LLM01: input que altera comportamento do modelo.
- **Rubber-stamp** — Aprovação sem revisão real; risco aumenta com cognitive overload.
- **Tier (no contexto sdd-workflow)** — Nível de rigor declarado pelo autor; 5 níveis discretos.
- **Drift (spec-code drift)** — Divergência entre spec documentada e código implementado.

---

## 7. Bibliografia comentada (fontes primárias)

**Spec Kit & SDD core:**
- `github/spec-kit` (repositório oficial). Fonte canônica do Spec Kit, comandos `/speckit.*`, templates, spec-driven.md. Issues e Discussions são oráculo da dor real da comunidade.
- `github/spec-kit/blob/main/spec-driven.md` — Manifesto oficial do SDD da GitHub. Define spec como lingua franca, código como expression.
- Spec Kit issues #287, #366, #806, #1149, #1323, #1356, #1436, #1541. Listadas explicitamente no relatório como evidência empírica de dores.
- GitHub Blog (set/2025), "Spec-driven development with AI: Get started with a new open source toolkit" — anúncio oficial.
- Microsoft Developer Blog (2025), "Diving Into Spec-Driven Development With GitHub Spec Kit" — Den Delimarsky, Principal Product Engineer GitHub.

**Kiro & AWS:**
- kiro.dev (oficial) e blog kiro.dev/blog/introducing-kiro, /understanding-kiro-pricing-specs-vibes-usage-tracking. Fonte canônica do modelo Spec/Vibe.
- aws.amazon.com/documentation-overview/kiro/ — documentação oficial AWS.
- InfoQ (ago/2025), "Beyond Vibe Coding: Amazon Introduces Kiro, the Spec-Driven Agentic AI IDE" — análise crítica externa.
- repost.aws (2025), "Kiro Agentic AI IDE: Beyond a Coding Assistant" — feedback de não-dev (AWS Networking specialist).

**BMAD:**
- `bmad-code-org/BMAD-METHOD` e `docs.bmad-method.org` — fontes oficiais.
- redreamality.com (jan/2026), "BMAD-METHOD Guide: Breakthrough Agile AI-Driven Development" — análise técnica detalhada.
- Mathivanan Mani (Medium, 2026), "Reviving Brownfield Projects with AI: A Comparative Look at GitHub Spec Kit, OpenSpec, and BMAD" — comparativo prático.
- ranthebuilder.cloud, "I Tested Three Spec-Driven AI Tools" — comparativo 13-dimensões.

**Devin & Cognition:**
- cognition.ai/blog/introducing-devin, /devin-2, /devin-generally-available, /how-cognition-uses-devin-to-build-devin. Fontes primárias.
- docs.devin.ai — guidelines "When to Use Devin", "Good vs Bad Instructions".

**Anthropic, Skills, Plan Mode, Plugins:**
- code.claude.com/docs/en/skills, /costs, /discover-plugins. Documentação oficial.
- anthropic.com/news/skills (out/2025) e anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills. Anúncios oficiais.
- agentskills.io (jan/2026) — open standard.
- VentureBeat (fev/2026), "Anthropic launches enterprise 'Agent Skills' and opens the standard" — cobertura externa do open standard.
- TheNewStack (mar/2026), "Agent Skills: Anthropic's Next Bid to Define AI Standards" — análise de adoção (Microsoft, Cursor, Goose, Amp, OpenCode, OpenAI Codex).
- `anthropics/claude-code/CHANGELOG.md` — fonte canônica para entender velocidade de mudança da plataforma.

**EARS / GEARS / requisitos:**
- alistairmavin.com/ears (Mavin oficial), e Mavin et al. RE09 IEEE Xplore.
- jamasoftware.com requirements management guide, qracorp.com — referências industriais maduras.
- dev.to/sublang/gears-the-spec-syntax-that-makes-ai-coding-actually-work (jan/2026). Paper original GEARS.
- IterOn (`sublang-xyz/IterOn`) — implementação GEARS de referência.

**Multi-persona / agentic patterns / 12-Factor Agents:**
- humanlayer.dev e github.com/humanlayer/12-factor-agents (Dex Horthy). Princípios para "agents are software" — relevante para Q9 e arquitetura geral.
- Vibe Coding vs Agentic Coding paper (arXiv:2505.19443, Sapkota et al.) — taxonomia formal.

**Cognitive load, code review, rubber-stamp:**
- Springer Empirical Software Engineering (2022), "Do explicit review strategies improve code review performance? Towards understanding the role of cognitive load".
- arXiv 2407.01407, "Towards debiasing code review support".
- CodeAnt AI (2026), "Why Diff-Based Code Reviews Overwhelm Developers".
- new.signadot.com (2026), "Traditional Code Review Is Dead. What Comes Next?" — sobre rubber-stamp em era IA.
- Chromium dev list, "Please don't rubber stamp code reviews" — Google internal.

**Outras SDD-adjacent / comparáveis solo-friendly:**
- gotalab/cc-sdd (v3 com kiro-discovery) — SDD harness portável.
- Fission-AI/OpenSpec — delta specs.
- LiorCohen/sdd — outro plugin Claude Code Spec-Driven.
- rhuss/cc-sdd — traits sobre Spec Kit.
- tylerburleigh/claude-sdd-toolkit — SDD em Claude Code via JSON specs.
- sergiolindolfoferreira/shape-up-ai-native — Shape Up adaptado para AI agents.

**FinOps / token cost:**
- finout.io/blog (2026), "FinOps for AI Agents: A Four-Step Allocation Framework" e "Claude Pricing in 2026 for Individuals, Organizations, and Developers".
- aicosts.ai (2026), "The Claude Code Subagent Cost Explosion" — dados empíricos de custo.
- morphllm.com (2026), "The Real Cost of AI Coding in 2026" — análise de subscrição vs uso real.
- mindstudio.ai (2026), "How to Manage Claude Code Token Usage" e "AI Agent Token Budget Management".
- finops.org/insights/finops-sustainability-collaborate — interseção FinOps × GreenOps × IA.
- dora.dev/guides/dora-metrics-four-keys e DORA Report 2025/2026 (Faros AI, getdx.com).

**Critical reviews of spec-kit / SDD:**
- martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html (Birgitta Böckeler, 2025), "Understanding Spec-Driven-Development: Kiro, spec-kit, and Tessl" — review crítico, leitura obrigatória.
- blog.scottlogic.com (nov/2025), "Putting Spec Kit Through Its Paces: Radical Idea or Reinvented Waterfall?" — review prático negativo.
- augmentcode.com/guides/claude-code-spec-driven-development (dez/2025), "Claude Code for Spec-Driven Development: Capabilities and Limits".
- shubham sharma (Medium), "The Artifact Trap" — crítica generalizada.

**Vibe coding / non-dev audience:**
- thenewstack.io (abr/2026), "I was tired of explaining it to somebody who was supposed to build it for me" — entrevistas com executivos vibe-coding.
- shanedrumm.com, "Vibe Coding AI Agents for non-techies" — relato pessoal de PM transitionando.

**Telemetria:**
- cli.github.com/telemetry, theregister.com (abr/2026) e Groundy.com — caso GitHub CLI v2.91.
- docs.continue.dev/customize/telemetry — opt-out simples.
- docs.kedro.org (telemetry) — opt-in com consent prompt; padrão LF Projects.

**Working Backwards / PRFAQ:**
- workingbackwards.com — fonte canônica.
- davidlapsley.io (2026), "Specifications Are the New API Between Product and Engineering" — aplicação a IA agentic com EARS.

---

## Observação final ao autor

Este relatório opera dentro do briefing fornecido (premissas inegociáveis sobre estrutura do plugin). **Recomendo cruzá-lo com leitura cirúrgica direta dos artefatos atuais** — especialmente `skills/sdd-workflow/SKILL.md` e templates — para validar onde o que escrevi é diretamente aplicável vs onde é genérico-para-SDD. Em particular, a recomendação 30-dias #2 (protocolo de exceção) e 6-meses #2 (FinOps) são as duas onde tenho maior convicção independentemente do estado atual do código; a recomendação 6-meses #3 (living specs) é a mais ambiciosa estrategicamente e onde mais vale investir reflexão arquitetural antes de mexer em código.