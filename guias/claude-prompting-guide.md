# Guia de Prompting do Claude

> Tradução e adaptação editorial em português do **Prompt Engineering Guide** da Anthropic, estruturado como playbook pessoal.
> Fonte canônica: [Prompting best practices — Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices). Conteúdo técnico original © Anthropic, PBC.
> Tradução, reorganização e anexo didático (seção 10, preservado da versão anterior do guia oficial): André Junges ([@ajunges](https://github.com/ajunges)).
> Termos técnicos (`prompt`, `context window`, `tool use`, `thinking`, `subagent`, `effort`, `XML tags`, `prefill`, `chain-of-thought`, etc.) preservados em inglês. Code samples em Python mantidos no idioma original. Prompt samples traduzidos ou adaptados quando necessário para leitura.
> Última sincronização com a fonte oficial: 2026-04-17.

---

## 1. Visão geral

Playbook de prompting para os modelos atuais: **Claude Opus 4.7**, **Claude Opus 4.6**, **Claude Sonnet 4.6** e **Claude Haiku 4.5**. Cobre fundamentos, controle de output, tool use, thinking, sistemas agênticos e guidance específica por modelo.

### 1.1 Quando fazer prompt engineering

Prompt engineering resolve critérios de sucesso que são controláveis pelo prompt. Não resolve tudo:

- **Latência e custo**: geralmente melhor resolver trocando de modelo ou ajustando `effort`/`max_tokens`.
- **Capacidade fundamental**: se o modelo simplesmente não consegue a tarefa, nenhum prompt resolve — reavaliar escolha de modelo.

### 1.2 Pré-requisitos

Antes de iterar em prompts:

1. Critérios de sucesso definidos explicitamente
2. Um caminho empírico para testar contra esses critérios
3. Um primeiro rascunho de prompt para melhorar

### 1.3 Regra de ouro

Mostre seu prompt para um colega com contexto mínimo da tarefa e peça que ele siga. Se o colega ficar confuso, Claude também fica.

---

## 2. Princípios fundamentais

### 2.1 Seja claro e direto

Claude responde melhor a instruções explícitas. Ser específico sobre o output desejado aumenta a qualidade. Se quer comportamento "acima e além", peça explicitamente — não espere que o modelo infira de um prompt vago.

Pense no Claude como um funcionário brilhante mas novo, sem contexto sobre suas normas e workflows. Quanto mais preciso você for sobre o que quer, melhor o resultado.

- Seja específico sobre formato de saída e restrições
- Use listas numeradas ou bullets quando a ordem ou completude dos passos importar

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Crie um dashboard de analytics" | "Crie um dashboard de analytics. Inclua o máximo de features e interações relevantes possível. Vá além do básico para criar uma implementação completa." |

### 2.2 Adicione contexto para melhorar performance

Explicar o **porquê** de uma instrução ajuda o modelo a entender a meta e responder de forma mais direcionada. Claude generaliza bem a partir da explicação.

| Menos eficaz | Mais eficaz |
| --- | --- |
| "NUNCA use reticências" | "Sua resposta será lida em voz alta por um text-to-speech engine, então nunca use reticências porque o engine não sabe pronunciá-las." |

### 2.3 Use exemplos (multishot prompting)

Exemplos são uma das formas mais confiáveis de dirigir formato, tom e estrutura do output. Poucos exemplos bem construídos (few-shot / multishot) melhoram acurácia e consistência drasticamente.

Ao adicionar exemplos, garanta que sejam:

- **Relevantes**: espelhem seu caso de uso real
- **Diversos**: cubram edge cases e variem o suficiente para que Claude não capte padrões indesejados
- **Estruturados**: envolva cada exemplo em `<example>` tags (ou `<examples>` para o conjunto)

Ideal: 3–5 exemplos. Você pode pedir ao próprio Claude para avaliar seus exemplos quanto a relevância/diversidade, ou para gerar novos a partir do set inicial.

### 2.4 Estruture prompts com XML tags

XML tags ajudam Claude a parsear prompts complexos sem ambiguidade, especialmente quando o prompt mistura instruções, contexto, exemplos e inputs variáveis. Envolva cada tipo de conteúdo em sua própria tag (`<instructions>`, `<context>`, `<input>`) para reduzir má interpretação.

Boas práticas:

- Use nomes de tag consistentes e descritivos
- Aninhe tags quando há hierarquia natural (documentos dentro de `<documents>`, cada um em `<document index="n">`)

### 2.5 Dê um papel ao Claude

Definir um papel no system prompt foca o comportamento e tom para seu caso de uso. Mesmo uma única frase faz diferença:

```python
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    system="You are a helpful coding assistant specializing in Python.",
    messages=[
        {"role": "user", "content": "How do I sort a list of dictionaries by key?"}
    ],
)
print(message.content)
```

### 2.6 Refinamento iterativo

Se a primeira resposta não estiver certa, peça ajustes específicos. "Melhore" é vago demais. Aponte exatamente o que mudar.

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Melhore isso." | "Bom começo, mas refine: 1) tom mais casual, 2) adicione um exemplo concreto de como o produto ajudou um cliente, 3) encurte o segundo parágrafo focando em benefícios e não features." |

### 2.7 Long context prompting

Trabalhando com documentos grandes ou inputs ricos em dados (20k+ tokens), estruture com cuidado:

- **Coloque os dados longos no topo** do prompt, acima da query, instruções e exemplos. Melhora significativa em todos os modelos. Queries no final podem melhorar a qualidade da resposta em até 30% em testes com inputs multi-documento complexos.
- **Estruture documentos e metadata com XML tags**. Ao usar múltiplos documentos, envolva cada um em `<document>` com subtags `<document_content>` e `<source>` (e outra metadata que importe):

```xml
<documents>
  <document index="1">
    <source>annual_report_2023.pdf</source>
    <document_content>
      {{ANNUAL_REPORT}}
    </document_content>
  </document>
  <document index="2">
    <source>competitor_analysis_q2.xlsx</source>
    <document_content>
      {{COMPETITOR_ANALYSIS}}
    </document_content>
  </document>
</documents>

Analyze the annual report and competitor analysis. Identify strategic advantages and recommend Q3 focus areas.
```

- **Ancore respostas em quotes**: para tarefas com documentos longos, peça que Claude primeiro cite trechos relevantes antes de executar a tarefa. Isso ajuda o modelo a filtrar o ruído do restante do documento:

```xml
You are an AI physician's assistant. Your task is to help doctors diagnose possible patient illnesses.

<documents>
  <document index="1">
    <source>patient_symptoms.txt</source>
    <document_content>{{PATIENT_SYMPTOMS}}</document_content>
  </document>
  <document index="2">
    <source>patient_records.txt</source>
    <document_content>{{PATIENT_RECORDS}}</document_content>
  </document>
</documents>

Find quotes from the patient records relevant to the reported symptoms. Place these in <quotes> tags. Then, based on these quotes, list diagnostic information in <info> tags.
```

### 2.8 Autoconhecimento do modelo

Para que Claude se identifique corretamente na sua aplicação ou use model strings específicas:

```text
The assistant is Claude, created by Anthropic. The current model is Claude Opus 4.7.
```

Para apps que precisam especificar model strings:

```text
When an LLM is needed, please default to Claude Opus 4.7 unless the user requests otherwise. The exact model string for Claude Opus 4.7 is claude-opus-4-7.
```

---

## 3. Controle de output e formatação

### 3.1 Estilo de comunicação e verbosidade

Os modelos atuais têm estilo mais conciso e natural do que gerações anteriores:

- **Mais direto e factual**: reportam progresso com fatos, sem updates autoelogiosos
- **Mais conversacional**: menos robótico
- **Menos verboso**: podem pular summaries a menos que solicitados

Se quiser mais visibilidade do raciocínio:

```text
After completing a task that involves tool use, provide a quick summary of the work you've done.
```

### 3.2 Controlar o formato das respostas

Quatro alavancas eficazes:

1. **Diga o que fazer, não o que não fazer**

   Em vez de: "Não use markdown na resposta"
   Prefira: "Componha sua resposta em parágrafos fluidos de prosa."

2. **Use XML format indicators**

   "Escreva as seções em prosa dentro de tags `<smoothly_flowing_prose_paragraphs>`."

3. **Case o estilo do prompt com o estilo desejado**

   O formato do seu prompt influencia o formato da resposta. Se ainda tiver problemas de steerability, aproxime ao máximo o estilo do prompt ao estilo do output desejado. Ex.: remover markdown do prompt reduz markdown no output.

4. **Prompts detalhados para preferências específicas**

   Para minimizar markdown e bullets:

```text
<avoid_excessive_markdown_and_bullet_points>
When writing reports, documents, technical explanations, analyses, or any long-form content, write in clear, flowing prose using complete paragraphs and sentences. Use standard paragraph breaks for organization and reserve markdown primarily for `inline code`, code blocks (```...```), and simple headings (###). Avoid using **bold** and *italics*.

DO NOT use ordered lists (1. ...) or unordered lists (*) unless: a) you're presenting truly discrete items where a list format is the best option, or b) the user explicitly requests a list or ranking.

Instead of listing items with bullets or numbers, incorporate them naturally into sentences. This guidance applies especially to technical writing. Using prose instead of excessive formatting will improve user satisfaction. NEVER output a series of overly short bullet points.
</avoid_excessive_markdown_and_bullet_points>
```

### 3.3 Output em LaTeX

Claude Opus 4.6 usa LaTeX por padrão para expressões matemáticas. Se quiser texto simples:

```text
Format your response in plain text only. Do not use LaTeX, MathJax, or any markup notation such as \( \), $, or \frac{}{}. Write all math expressions using standard text characters (e.g., "/" for division, "*" for multiplication, and "^" for exponents).
```

### 3.4 Criação de documentos

Os modelos atuais são excelentes criando apresentações, animações e documentos visuais, com strong instruction following. Usualmente produzem output polido já na primeira tentativa.

```text
Create a professional presentation on [topic]. Include thoughtful design elements, visual hierarchy, and engaging animations where appropriate.
```

### 3.5 Migração do prefill

A partir dos modelos Claude 4.6 e no **Claude Mythos Preview**, prefills na última mensagem do assistant **não são mais suportados**. No Mythos Preview, requests com prefill retornam erro 400. Modelos existentes continuam suportando, mas a recomendação é migrar.

Prefill existente → alternativa atual:

| Caso de uso | Migração |
| --- | --- |
| Forçar formato JSON/YAML ou classificação | Use [Structured Outputs](https://platform.claude.com/docs/en/build-with-claude/structured-outputs), ou tools com enum field, ou simplesmente peça o schema (os modelos novos cumprem com retries) |
| Eliminar preâmbulos tipo `Here is...` | Instrua direto no system prompt: "Respond directly without preamble. Do not start with phrases like 'Here is...'". Pós-processa se vazar |
| Evitar refusals ruins | Claude hoje refusa melhor; prompting limpo no `user` resolve |
| Continuações de respostas interrompidas | Mova para o user message: "Your previous response was interrupted and ended with `[previous_response]`. Continue from where you left off." |
| Hidratação de contexto / role consistency | Injete o contexto no user turn, ou via tools, ou durante compaction |

---

## 4. Tool use

### 4.1 Instrução explícita para agir

Os modelos atuais seguem instruções de forma literal. "Can you suggest some changes" pode resultar em sugestões em vez de execução, mesmo que o intento fosse execução. Para tomar ação, seja explícito:

| Menos eficaz (só sugere) | Mais eficaz (executa) |
| --- | --- |
| "Can you suggest some changes to improve this function?" | "Change this function to improve its performance." |
| | "Make these edits to the authentication flow." |

Para tornar Claude proativo por padrão:

```text
<default_to_action>
By default, implement changes rather than only suggesting them. If the user's intent is unclear, infer the most useful likely action and proceed, using tools to discover any missing details instead of guessing. Try to infer the user's intent about whether a tool call (e.g., file edit or read) is intended or not, and act accordingly.
</default_to_action>
```

Para comportamento oposto — mais hesitante:

```text
<do_not_act_before_instructions>
Do not jump into implementation or changing files unless clearly instructed to make changes. When the user's intent is ambiguous, default to providing information, doing research, and providing recommendations rather than taking action. Only proceed with edits, modifications, or implementations when the user explicitly requests them.
</do_not_act_before_instructions>
```

Atenção: Claude Opus 4.5 e 4.6 são mais responsivos ao system prompt. Se seus prompts antigos usavam linguagem agressiva ("CRITICAL: You MUST use this tool"), pode estar **overtriggering**. Suavize para "Use this tool when...".

### 4.2 Parallel tool calling

Os modelos atuais executam tool calls paralelos nativamente:

- Rodam múltiplas buscas especulativas simultâneas
- Leem vários arquivos ao mesmo tempo para construir contexto
- Executam bash em paralelo (pode inclusive gargalar o sistema)

Já funciona bem por padrão, mas pode ser reforçado a ~100%:

```text
<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between the tool calls, make all of the independent tool calls in parallel. Prioritize calling tools simultaneously whenever the actions can be done in parallel rather than sequentially. For example, when reading 3 files, run 3 tool calls in parallel to read all 3 files into context at the same time. Maximize use of parallel tool calls where possible to increase speed and efficiency. However, if some tool calls depend on previous calls to inform dependent values like the parameters, do NOT call these tools in parallel and instead call them sequentially. Never use placeholders or guess missing parameters in tool calls.
</use_parallel_tool_calls>
```

Para reduzir paralelismo:

```text
Execute operations sequentially with brief pauses between each step to ensure stability.
```

---

## 5. Thinking e raciocínio

### 5.1 Overthinking

Claude Opus 4.6 faz muito mais exploração upfront do que versões anteriores, especialmente em `effort` altos. Em geral isso melhora o resultado final, mas o modelo pode ir atrás de contexto ou seguir múltiplas threads sem ser solicitado. Se seus prompts antigos encorajavam thoroughness, é hora de ajustar:

- **Troque defaults gerais por guidance pontual**: em vez de "Default to using [tool]", use "Use [tool] when it would enhance your understanding of the problem"
- **Remova over-prompting**: tools que subtriggevam antes hoje triggam bem. "If in doubt, use [tool]" agora causa overtriggering
- **Use `effort` como fallback**: se ainda agressivo demais, baixe o nível de `effort`

Para conter thinking excessivo:

```text
When you're deciding how to approach a problem, choose an approach and commit to it. Avoid revisiting decisions unless you encounter new information that directly contradicts your reasoning. If you're weighing two approaches, pick one and see it through. You can always course-correct later if the chosen approach fails.
```

Se precisar de teto rígido em custo de thinking, `budget_tokens` em extended thinking ainda funciona em Opus 4.6 e Sonnet 4.6, mas está deprecated. Prefira baixar `effort` ou usar `max_tokens` como hard limit com [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking).

### 5.2 Adaptive thinking e interleaved thinking

Os modelos atuais oferecem thinking capabilities especialmente úteis para reflexão pós-tool-use ou raciocínio multi-step complexo. Opus 4.6/Sonnet 4.6 usam **adaptive thinking** (`thinking: {type: "adaptive"}`): Claude decide dinamicamente quando e quanto pensar, calibrando por dois fatores — parâmetro `effort` e complexidade da query. Em queries simples, responde direto. Em evals internas, adaptive thinking entrega melhor performance que extended thinking.

Use adaptive thinking em workloads agentic: tool use multi-step, coding complexo, agent loops longos. Modelos antigos usam modo manual com `budget_tokens`.

Para guiar thinking:

```text
After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.
```

Se o modelo pensa demais (comum com system prompts grandes):

```text
Extended thinking adds latency and should only be used when it will meaningfully improve answer quality — typically for problems that require multi-step reasoning. When in doubt, respond directly.
```

Migrando de extended thinking com `budget_tokens`:

```python
# Antes (extended thinking, modelos antigos)
client.messages.create(
    model="claude-sonnet-4-5-20250929",
    max_tokens=64000,
    thinking={"type": "enabled", "budget_tokens": 32000},
    messages=[{"role": "user", "content": "..."}],
)

# Depois (adaptive thinking)
client.messages.create(
    model="claude-opus-4-7",
    max_tokens=64000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},  # ou "max", "xhigh", "medium", "low"
    messages=[{"role": "user", "content": "..."}],
)
```

Se não usa extended thinking, sem mudanças — thinking é off por default.

### 5.3 Chain-of-thought manual

Quando thinking está off, ainda é possível obter raciocínio step-by-step instruindo diretamente. Boas práticas:

- **Prefira instruções gerais a steps prescritivos**: "think thoroughly" costuma produzir raciocínio melhor do que plano passo-a-passo escrito à mão. O raciocínio do Claude muitas vezes excede o que um humano prescreveria
- **Multishot com `<thinking>` funciona**: em exemplos few-shot, envolva o raciocínio em `<thinking>` para o Claude generalizar o padrão
- **Peça self-check**: "Before you finish, verify your answer against [test criteria]" pega erros de forma confiável, principalmente em coding e matemática

Com extended thinking desativado, Claude Opus 4.5 é particularmente sensível à palavra "think". Use alternativas como "consider", "evaluate", "reason through".

---

## 6. Sistemas agênticos

### 6.1 Long-horizon reasoning e state tracking

Os modelos atuais lidam excepcionalmente bem com tarefas de horizonte longo e state tracking. Mantêm orientação em sessões estendidas focando em progresso incremental — avançam pouco por vez em vez de tentar tudo simultaneamente. A capacidade se destaca em múltiplos context windows: Claude pode trabalhar numa tarefa, salvar estado e continuar com contexto fresco.

### 6.2 Context awareness e multi-context-window

Claude 4.5 e 4.6 têm [context awareness](https://platform.claude.com/docs/en/build-with-claude/context-windows) — conseguem rastrear quanto do context window resta. Isso permite gerenciar contexto e tarefas de forma mais efetiva.

**Gerenciando limites**: em harnesses que compactam ou salvam contexto externamente (como Claude Code), informe isso no prompt:

```text
Your context window will be automatically compacted as it approaches its limit, allowing you to continue working indefinitely from where you left off. Therefore, do not stop tasks early due to token budget concerns. As you approach your token budget limit, save your current progress and state to memory before the context window refreshes. Always be as persistent and autonomous as possible and complete tasks fully, even if the end of your budget is approaching. Never artificially stop any task early regardless of the context remaining.
```

A [memory tool](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool) combina naturalmente com context awareness para transições limpas.

**Workflows multi-window**:

1. **Prompt diferente no primeiro context window**: use a primeira janela para setup (escrever testes, criar scripts), janelas seguintes iteram sobre uma to-do list
2. **Testes em formato estruturado**: peça que Claude crie testes antes de começar e rastreie em `tests.json`. Reforce: "It is unacceptable to remove or edit tests because this could lead to missing or buggy functionality"
3. **QoL tools**: encoraje Claude a criar `init.sh` para iniciar servers, rodar suites, linters. Evita retrabalho em context windows novos
4. **Começar fresco vs. compactar**: quando uma janela é limpa, considere começar com janela nova em vez de compactar. Os modelos atuais são excelentes em descobrir estado do filesystem. Seja prescritivo no start: "Call pwd; you can only read and write files in this directory", "Review progress.txt, tests.json, and the git logs"
5. **Ferramentas de verificação**: Playwright MCP ou computer use para UIs ajudam Claude a verificar correção sem feedback humano contínuo
6. **Encourage uso completo do contexto**:

```text
This is a very long task, so it may be beneficial to plan out your work clearly. It's encouraged to spend your entire output context working on the task — just make sure you don't run out of context with significant uncommitted work. Continue working systematically until you have completed this task.
```

**State management**:

- **Formatos estruturados (JSON) para dados estruturados**: schemas claros ajudam o modelo
- **Texto livre para progress notes**: freeform funciona bem para progresso geral
- **Git como tracking**: log + checkpoints restauráveis. Modelos atuais usam git para state tracking muito bem
- **Enfatize incremental**: peça explicitamente que rastreie progresso e foque incremental

Exemplo de dupla `tests.json` + `progress.txt`:

```json
{
  "tests": [
    { "id": 1, "name": "authentication_flow", "status": "passing" },
    { "id": 2, "name": "user_management", "status": "failing" },
    { "id": 3, "name": "api_endpoints", "status": "not_started" }
  ],
  "total": 200,
  "passing": 150,
  "failing": 25,
  "not_started": 25
}
```

```text
Session 3 progress:
- Fixed authentication token validation
- Updated user model to handle edge cases
- Next: investigate user_management test failures (test #2)
- Note: Do not remove tests as this could lead to missing functionality
```

### 6.3 Autonomia vs. segurança

Sem guidance, Claude Opus 4.6 pode tomar ações difíceis de reverter ou que afetam sistemas compartilhados — deletar arquivos, force-push, postar em serviços externos. Para exigir confirmação:

```text
Consider the reversibility and potential impact of your actions. You are encouraged to take local, reversible actions like editing files or running tests, but for actions that are hard to reverse, affect shared systems, or could be destructive, ask the user before proceeding.

Examples of actions that warrant confirmation:
- Destructive operations: deleting files or branches, dropping database tables, rm -rf
- Hard to reverse operations: git push --force, git reset --hard, amending published commits
- Operations visible to others: pushing code, commenting on PRs/issues, sending messages, modifying shared infrastructure

When encountering obstacles, do not use destructive actions as a shortcut. For example, don't bypass safety checks (e.g. --no-verify) or discard unfamiliar files that may be in-progress work.
```

### 6.4 Research e coleta de informação

Os modelos atuais têm capacidade excepcional de agentic search. Para resultados ótimos:

1. **Critérios de sucesso claros**: defina o que caracteriza uma resposta bem-sucedida
2. **Verificação cruzada**: peça para confirmar em múltiplas fontes
3. **Abordagem estruturada para research complexo**:

```text
Search for this information in a structured way. As you gather data, develop several competing hypotheses. Track your confidence levels in your progress notes to improve calibration. Regularly self-critique your approach and plan. Update a hypothesis tree or research notes file to persist information and provide transparency. Break down this complex research task systematically.
```

### 6.5 Subagent orchestration

Os modelos atuais reconhecem quando uma tarefa se beneficia de delegação para subagents e o fazem proativamente, sem instrução explícita.

Para aproveitar:

1. **Tools de subagent bem definidas**: descrições claras nas tool definitions
2. **Deixe orquestrar naturalmente**: Claude delega apropriadamente sem precisar mandar
3. **Vigie overuse**: Claude Opus 4.6 tem predileção forte por subagents e pode spawnar onde uma abordagem direta seria mais simples. Ex.: spawnar subagent para explorar código quando um `grep` direto bastaria

Para conter:

```text
Use subagents when tasks can run in parallel, require isolated context, or involve independent workstreams that don't need to share state. For simple tasks, sequential operations, single-file edits, or tasks where you need to maintain context across steps, work directly rather than delegating.
```

### 6.6 Chain complex prompts

Com adaptive thinking e subagent orchestration, Claude lida com multi-step reasoning internamente. Chaining explícito (quebrar tarefa em chamadas sequenciais de API) ainda faz sentido quando você quer inspecionar outputs intermediários ou forçar uma pipeline específica.

Padrão mais comum: **self-correction** — gerar rascunho → Claude revisa contra critérios → Claude refina com base na revisão. Cada passo é uma API call separada, permitindo log, evaluation ou branching em qualquer ponto.

### 6.7 Reduzir criação de arquivos em agentic coding

Os modelos atuais podem criar arquivos temporários para testing e iteração — usando arquivos como "scratchpad" antes de salvar output final. Ajuda em agentic coding, mas se quer minimizar:

```text
If you create any temporary new files, scripts, or helper files for iteration, clean up these files by removing them at the end of the task.
```

### 6.8 Overeagerness e overengineering

Claude Opus 4.5 e 4.6 tendem a overengineer: criar arquivos extras, adicionar abstrações desnecessárias, construir flexibilidade não pedida. Para evitar:

```text
Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused:

- Scope: Don't add features, refactor code, or make "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up. A simple feature doesn't need extra configurability.

- Documentation: Don't add docstrings, comments, or type annotations to code you didn't change. Only add comments where the logic isn't self-evident.

- Defensive coding: Don't add error handling, fallbacks, or validation for scenarios that can't happen. Trust internal code and framework guarantees. Only validate at system boundaries (user input, external APIs).

- Abstractions: Don't create helpers, utilities, or abstractions for one-time operations. Don't design for hypothetical future requirements. The right amount of complexity is the minimum needed for the current task.
```

### 6.9 Evitar foco em passar testes / hard-coding

Claude pode focar demais em fazer testes passarem em vez de soluções gerais, ou usar workarounds (helper scripts) para refatorações complexas em vez das ferramentas padrão. Para forçar soluções robustas:

```text
Please write a high-quality, general-purpose solution using the standard tools available. Do not create helper scripts or workarounds to accomplish the task more efficiently. Implement a solution that works correctly for all valid inputs, not just the test cases. Do not hard-code values or create solutions that only work for specific test inputs. Instead, implement the actual logic that solves the problem generally.

Focus on understanding the problem requirements and implementing the correct algorithm. Tests are there to verify correctness, not to define the solution. Provide a principled implementation that follows best practices and software design principles.

If the task is unreasonable or infeasible, or if any of the tests are incorrect, please inform me rather than working around them. The solution should be robust, maintainable, and extendable.
```

### 6.10 Minimizar hallucinations em agentic coding

Os modelos atuais hallucinam menos e dão respostas mais grounded baseadas no código. Para reforçar:

```text
<investigate_before_answering>
Never speculate about code you have not opened. If the user references a specific file, you MUST read the file before answering. Make sure to investigate and read relevant files BEFORE answering questions about the codebase. Never make any claims about code before investigating unless you are certain of the correct answer — give grounded and hallucination-free answers.
</investigate_before_answering>
```

---

## 7. Capacidades específicas

### 7.1 Vision

Claude Opus 4.5 e 4.6 melhoraram vision — especialmente com múltiplas imagens em contexto. Ganho estende-se para computer use (interpretação mais confiável de screenshots e UI). Para análise de vídeo, quebrar em frames.

Técnica eficaz: dar ao Claude uma **crop tool** ou [skill](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview). Testes mostram uplift consistente quando o modelo pode "zoom in" em regiões relevantes. Veja o [cookbook de crop tool](https://platform.claude.com/cookbook/multimodal-crop-tool).

### 7.2 Frontend design

Claude Opus 4.5 e 4.6 constroem aplicações web complexas reais com forte design. Mas sem guidance podem cair em padrões genéricos — o estilo que usuários chamam de "AI slop". Para produzir frontends distintivos:

```text
<frontend_aesthetics>
You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight.

Focus on:
- Typography: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics.
- Color & Theme: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes. Draw from IDE themes and cultural aesthetics for inspiration.
- Motion: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions.
- Backgrounds: Create atmosphere and depth rather than defaulting to solid colors. Layer CSS gradients, use geometric patterns, or add contextual effects that match the overall aesthetic.

Avoid generic AI-generated aesthetics:
- Overused font families (Inter, Roboto, Arial, system fonts)
- Clichéd color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

Interpret creatively and make unexpected choices that feel genuinely designed for the context. Vary between light and dark themes, different fonts, different aesthetics. You still tend to converge on common choices (Space Grotesk, for example) across generations. Avoid this: it is critical that you think outside the box!
</frontend_aesthetics>
```

Referência completa: [frontend-design skill no claude-code](https://github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md) e post [improving frontend design through skills](https://www.claude.com/blog/improving-frontend-design-through-skills).

---

## 8. Guidance específica por modelo

### 8.1 Claude Opus 4.7

Modelo de generally-available mais capaz da Anthropic, com pontos fortes em trabalho agentic de longo horizonte, knowledge work, vision e memory. Funciona bem out-of-the-box com prompts do Opus 4.6. Os ajustes abaixo cobrem comportamentos que mais precisam de tuning.

#### 8.1.1 Response length e verbosidade

Opus 4.7 calibra comprimento da resposta pela complexidade da tarefa, não por verbosidade fixa. Respostas mais curtas em lookups simples, mais longas em análises abertas.

Se seu produto depende de verbosidade específica, tune o prompt. Para encurtar:

```text
Provide concise, focused responses. Skip non-essential context, and keep examples minimal.
```

Exemplos positivos mostrando o nível correto de concisão funcionam melhor que instruções negativas.

#### 8.1.2 Calibrando effort e thinking depth

O [parâmetro `effort`](https://platform.claude.com/docs/en/build-with-claude/effort) balanceia inteligência vs. token spend. Níveis disponíveis:

| Effort | Quando usar |
| --- | --- |
| `max` | Tarefas que exigem máxima inteligência. Pode overthinking e diminishing returns. Testar antes de usar em produção |
| `xhigh` (novo) | Melhor opção para a maioria de coding e agentic use cases |
| `high` | Balanceia tokens e inteligência. Mínimo recomendado para casos intelligence-sensitive |
| `medium` | Cost-sensitive com trade-off de inteligência aceitável |
| `low` | Tarefas curtas, escopo estreito, latency-sensitive não-intelligence-sensitive |

Diferente do 4.6, Opus 4.7 respeita strict os níveis de `effort`, especialmente nos baixos. Em `low`/`medium`, escopo do trabalho = o que foi pedido, não mais. Risco: under-thinking em tarefas moderadamente complexas rodando em `low`.

Se observar raciocínio raso em problemas complexos, **suba o effort** para `high` ou `xhigh` em vez de contornar via prompt. Se precisa manter `low` por latência, adicione guidance pontual:

```text
This task involves multi-step reasoning. Think carefully through the problem before responding.
```

Em `max` ou `xhigh`, configure `max_tokens` grande (recomendado 64k) para espaço de thinking e subagent calls.

#### 8.1.3 Tool use triggering

Opus 4.7 tende a usar tools menos e raciocinar mais. Resulta melhor na maioria dos casos. Para aumentar uso de tools:

- Subir `effort` para `high` ou `xhigh`
- Descrever explicitamente quando e como usar a tool

Se o modelo não está usando sua web search, descreva claramente **por que** e **como** deveria.

#### 8.1.4 User-facing progress updates

Opus 4.7 fornece updates mais regulares e de qualidade durante agentic traces longos. Se você tinha scaffolding forçando status messages periódicas ("Summarize every 3 tool calls"), pode remover. Se os updates do modelo não se encaixam no seu produto, descreva explicitamente como devem ser e forneça exemplos.

#### 8.1.5 Instruction following literal

Opus 4.7 interpreta prompts mais literalmente que 4.6, principalmente em `effort` baixo. Não generaliza silenciosamente de um item para outro nem infere requests não feitos. Upside: precisão, menos thrash, melhor em API com prompts tunados e pipelines de extração estruturada.

Se precisa aplicação ampla, declare o escopo: "Apply this formatting to every section, not just the first one".

#### 8.1.6 Tom e writing style

Como em qualquer modelo novo, prosa pode mudar. Opus 4.7 é mais direto e opinativo, menos validação, menos emoji que o 4.6. Se produto depende de voz específica, reavalie prompts de estilo.

Para tom mais caloroso:

```text
Use a warm, collaborative tone. Acknowledge the user's framing before answering.
```

#### 8.1.7 Controle de subagent spawning

Opus 4.7 spawna menos subagents por padrão. Para aumentar quando desejado:

```text
Do not spawn a subagent for work you can complete directly in a single response (e.g. refactoring a function you can already see).

Spawn multiple subagents in the same turn when fanning out across items or reading multiple files.
```

#### 8.1.8 Design defaults e frontend

Opus 4.7 tem design instincts fortes e um house style padrão persistente: backgrounds cream/off-white (~`#F4F1EA`), tipografia serif (Georgia, Fraunces, Playfair), acentos italic, terracota/âmbar. Lê bem para editorial/hospitality/portfolio — mas fica deslocado em dashboards, dev tools, fintech, healthcare, enterprise. Aparece também em decks.

O default é persistente: instruções genéricas ("don't use cream", "make it clean") apenas trocam por outro palette fixo, não produzem variedade. Duas abordagens funcionam:

**Opção 1 — Especifique alternativa concreta**. O modelo segue specs explícitas com precisão:

```text
Design a desktop landing page for a supplement brand called AEFRM.

The visual direction should come from a cold monochrome atmosphere using pale silver-gray tones that gradually deepen into blue-gray and near-black, similar to a misted metallic surface.

The page should feel sharp and controlled, with a strong sense of structure and restraint.

Use this tonal system across the full page instead of introducing bright accent colors.

Use the uploaded image on the hero design in black and white.

The layout should be built with clear horizontal sections and a centered max-width container. Use 4px corner radius consistently across cards, buttons, inputs, and media frames. Margins should feel generous, with enough empty space around each section so the page breathes.

Typography should use a square, angular sans-serif with wider letter spacing than usual, especially in headings and navigation, so the text feels more engineered and less compressed.

Color palette should stay within this range:
#E9ECEC, #C9D2D4, #8C9A9E, #44545B, #11171B.
```

**Opção 2 — Peça opções antes de construir**. Quebra o default e dá controle. Se antes você usava `temperature` para variedade de design, use isto — gera direções genuinamente diferentes entre runs:

```text
Before building, propose 4 distinct visual directions tailored to this brief (each as: bg hex / accent hex / typeface — one-line rationale). Ask the user to pick one, then implement only that direction.
```

Opus 4.7 requer menos prompting para evitar AI slop do que modelos anteriores. Snippet mínimo que funciona bem:

```text
<frontend_aesthetics>
NEVER use generic AI-generated aesthetics like overused font families (Inter, Roboto, Arial, system fonts), cliched color schemes (particularly purple gradients on white or dark backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character. Use unique fonts, cohesive colors and themes, and animations for effects and micro-interactions.
</frontend_aesthetics>
```

#### 8.1.9 Interactive coding products

Opus 4.7 usa mais tokens em coding interativo (multi-turn) do que autônomo (single-turn) porque raciocina mais após user turns. Melhora coerência de longo horizonte, instruction following e capability em sessões interativas longas, ao custo de tokens.

Para maximizar performance e eficiência em coding products:

- `xhigh` ou `high` effort
- Features autônomas tipo **auto mode**
- Reduzir número de interações humanas requeridas
- Especificar tarefa, intenção e constraints upfront no primeiro human turn

Prompts ambíguos conveyed progressivamente em múltiplos turns reduzem eficiência e às vezes performance.

#### 8.1.10 Code review harnesses

Opus 4.7 é significativamente melhor encontrando bugs — +11pp de recall em um dos evals mais difíceis da Anthropic sobre PRs reais. Mas se seu harness foi tunado para modelo anterior, pode ver recall inicial mais baixo. Provavelmente efeito de harness, não regressão de capability.

Quando um prompt de review diz "only report high-severity", "be conservative" ou "don't nitpick", Opus 4.7 segue mais fielmente que modelos anteriores — pode investigar o código com mesma profundidade, achar os bugs e **não reportar** findings que julga abaixo do bar declarado. Resultado: mesma profundidade de investigação convertida em menos findings, principalmente em bugs de baixa severidade. Precision sobe, recall medido pode cair mesmo com capability melhor.

Prompt recomendado:

```text
Report every issue you find, including ones you are uncertain about or consider low-severity. Do not filter for importance or confidence at this stage — a separate verification step will do that. Your goal here is coverage: it is better to surface a finding that later gets filtered out than to silently drop a real bug. For each finding, include your confidence level and an estimated severity so a downstream filter can rank them.
```

Pode ser usado sem segundo step real, mas mover filtro de confidence para fora da etapa de finding costuma ajudar. Se quiser self-filter em passe único, seja concreto sobre onde fica o bar em vez de termos qualitativos: "report any bugs that could cause incorrect behavior, a test failure, or a misleading result; only omit nits like pure style or naming preferences".

#### 8.1.11 Computer use

Opus 4.7 funciona em resoluções até 2576px / 3.75MP (novo máximo). Em testes, 1080p dá bom balance performance-custo. Para workloads cost-sensitive, 720p ou 1366×768 são opções mais baratas com performance forte.

### 8.2 Migração Claude Sonnet 4.5 → 4.6

Sonnet 4.6 tem effort default `high`, diferente do 4.5 que não tinha `effort`. Ajuste explicitamente ao migrar — senão pode ter latência maior que o esperado.

**Effort recomendado**:

- `medium` para maioria das aplicações
- `low` para high-volume ou latency-sensitive
- `max_tokens` grande (64k recomendado) em `medium` ou `high` para espaço de think + act

**Quando usar Opus 4.7 em vez**: problemas mais difíceis e de horizonte mais longo (migrations grandes, deep research, autonomous work estendido). Sonnet 4.6 é otimizado para fast turnaround e cost efficiency.

**Sem extended thinking**: se não usava extended thinking no 4.5, pode continuar sem no 4.6. Defina `effort` explicitamente. Em `low` com thinking disabled, performance similar ou melhor que 4.5:

```python
client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=8192,
    thinking={"type": "disabled"},
    output_config={"effort": "low"},
    messages=[{"role": "user", "content": "..."}],
)
```

**Com extended thinking**: `budget_tokens` ainda funciona no 4.6 mas está deprecated. Migre para adaptive thinking:

```python
client.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=64000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},
    messages=[{"role": "user", "content": "..."}],
)
```

Adaptive thinking é especialmente adequado para:

- **Agents autônomos multi-step**: coding agents, data pipelines, bug finding — o modelo calibra raciocínio por step, mantendo caminho em trajetórias longas. Comece em `high`; escale para `medium` se latência/tokens apertarem
- **Computer use agents**: Sonnet 4.6 atingiu best-in-class em computer use evals usando adaptive
- **Workloads bimodais**: mix de tarefas fáceis e difíceis — adaptive pula thinking em queries simples e raciocina fundo nas complexas

---

## 9. Considerações gerais de migração

Migrando para modelos Claude 4.6 de gerações anteriores:

1. **Seja específico sobre comportamento desejado**: descreva exatamente o que quer ver no output
2. **Modifiers para qualidade**: adicionar modifiers que encorajam qualidade e detalhe ajuda. Ex.: em vez de "Create an analytics dashboard", use "Create an analytics dashboard. Include as many relevant features and interactions as possible. Go beyond the basics to create a fully-featured implementation"
3. **Peça features específicas explicitamente**: animações e elementos interativos devem ser solicitados quando desejados
4. **Atualize thinking config**: modelos 4.6 usam [adaptive thinking](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) no lugar de `budget_tokens`. Controle profundidade via [`effort`](https://platform.claude.com/docs/en/build-with-claude/effort)
5. **Migre prefilled responses**: prefills na última assistant turn são deprecated em 4.6. Veja seção 3.5
6. **Tune anti-laziness prompting**: se seus prompts antigos encorajavam thoroughness agressiva ou uso forte de tools, dial back. Modelos 4.6 são mais proativos e podem overtriggering com guidance antigo

Referência completa: [Migration guide — Anthropic](https://platform.claude.com/docs/en/about-claude/models/migration-guide).

---

## 10. Anexo: exemplos clássicos de prompting conversacional

Material preservado de uma versão anterior do guia oficial da Anthropic, com exemplos longos de prompting conversacional que não figuram no guia atual. Útil para ilustrar técnicas fundamentais (público, tom, estrutura, role-playing) em tarefas de negócio e comunicação. Exemplos originalmente em inglês, traduzidos/adaptados para pt-BR.

### 10.1 Criação de conteúdo

**Especifique o público**

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Escreva algo sobre cibersegurança." | "Preciso escrever um post de blog sobre boas práticas de cibersegurança para donos de pequenas empresas. O público não é muito técnico, então o conteúdo deve ser: 1) fácil de entender, evitando jargão quando possível; 2) prático, com dicas acionáveis; 3) envolvente e levemente bem-humorado. Forneça um outline para um post de 1.000 palavras cobrindo as 5 principais práticas que esses empresários devem adotar." |

**Defina tom e estilo**

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Escreva uma descrição de produto." | "Me ajude a escrever uma descrição de produto para nossa nova cadeira de escritório ergonômica. Tom profissional mas envolvente. Voz da marca: amigável, inovadora, preocupada com saúde. A descrição deve: 1) destacar as principais funcionalidades ergonômicas; 2) explicar os benefícios para saúde e produtividade do usuário; 3) mencionar materiais sustentáveis utilizados; 4) terminar com call-to-action. Mire em 200 palavras." |

**Defina estrutura do output**

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Crie uma apresentação sobre resultados da empresa." | "Preciso criar uma apresentação sobre resultados do Q2. Estruture com as seções: 1) Visão Geral; 2) Desempenho de Vendas; 3) Aquisição de Clientes; 4) Desafios; 5) Perspectivas para Q3. Para cada seção, sugira 3-4 pontos-chave com base em apresentações de negócios típicas. Recomende um tipo de visualização de dados (gráfico, chart) eficaz para cada seção." |

### 10.2 Resumo e Q&A sobre documentos

Combina três técnicas: ser específico sobre o que se quer, usar o nome do documento, pedir citações.

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Resuma esse relatório." | "Anexei um relatório de pesquisa de mercado de 50 páginas chamado 'Tendências da Indústria Tech 2023'. Forneça resumo de 2 parágrafos focando em tendências de IA e machine learning. Depois responda: 1) Quais são as 3 principais aplicações de IA em negócios este ano? 2) Como machine learning está impactando papéis profissionais na indústria tech? 3) Quais riscos ou desafios o relatório menciona sobre adoção de IA? Cite seções específicas ou números de página nas respostas." |

### 10.3 Análise de dados e visualização

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Analise nossos dados de vendas." | "Anexei a planilha 'Dados de Vendas 2023'. Analise e apresente no formato: 1) Resumo Executivo (2-3 frases); 2) Métricas-chave (total de vendas por trimestre, categoria top, região com maior crescimento); 3) Tendências (3 tendências notáveis com breve explicação cada); 4) Recomendações (3 recomendações baseadas em dados com justificativa). Depois sugira três tipos de visualização que comunicariam essas descobertas eficazmente." |

### 10.4 Brainstorming estruturado

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Me dê ideias de team building." | "Atividades de team building para equipe remota de 20 pessoas. Me ajude a: 1) sugerir 10 atividades virtuais que promovam colaboração; 2) para cada atividade, explicar como promove trabalho em equipe; 3) indicar quais são melhores para ice-breakers, comunicação e resolução de problemas; 4) sugerir uma opção de baixo custo e uma premium." |

Comparação em formato tabela:

| Menos eficaz | Mais eficaz |
| --- | --- |
| "Compare opções de software de gestão de projetos." | "Compare Asana, Trello e Microsoft Project em tabela usando: 1) funcionalidades principais; 2) facilidade de uso; 3) escalabilidade; 4) preços (inclua planos específicos se possível); 5) capacidades de integração; 6) mais indicado para (equipes pequenas, enterprise, setores específicos)." |

### 10.5 Exemplo combinado: estratégia de marketing

Prompt bom (combina role-playing, task breakdown, output estruturado, brainstorming e pedido de raciocínio):

```text
Como consultor sênior de marketing, ajude a desenvolver uma estratégia de marketing abrangente para nossa nova linha de acessórios ecológicos para smartphones. Público-alvo: consumidores millennials e Gen Z ambientalmente conscientes. Estruture:

1. Análise de Mercado
   - Tendências atuais em acessórios tech ecológicos
   - 2-3 concorrentes-chave e suas estratégias
   - Tamanho potencial do mercado e projeções de crescimento

2. Persona do Público-Alvo
   - Descrição detalhada do cliente ideal
   - Pain points e como nossos produtos os resolvem

3. Marketing Mix
   - Produto: funcionalidades-chave a destacar
   - Preço: estratégia sugerida com justificativa
   - Praça: canais de distribuição recomendados
   - Promoção:
     a) 5 canais de marketing com prós e contras de cada
     b) 3 ideias criativas de campanha para o lançamento

4. Estratégia de Conteúdo
   - 5 temas que ressoariam com o público
   - Tipos de conteúdo sugeridos (blog, vídeo, infográficos)

5. KPIs e Mensuração
   - 5 métricas-chave para acompanhar
   - Ferramentas sugeridas para medir

Apresente em formato estruturado com cabeçalhos e bullets. Explique seu raciocínio onde relevante. Ao final, identifique desafios ou riscos potenciais e sugira mitigações.
```

### 10.6 Exemplo combinado: análise de relatório financeiro

Prompt bom (role-playing como CFO, análise estruturada, perguntas antecipadas, sumário final):

```text
Anexei o relatório financeiro do Q2 'Q2_2023_Financial_Report.pdf'. Atue como CFO experiente e prepare um briefing para o conselho. Estruture:

1. Resumo Executivo (3-4 frases destacando pontos-chave)

2. Visão Geral de Desempenho Financeiro
   a) Receita: compare com trimestre anterior e mesmo trimestre do ano passado
   b) Margens (bruta e líquida) com explicação de mudanças significativas
   c) Fluxo de caixa: destaque preocupações ou desenvolvimentos positivos

3. KPIs
   - 5 principais KPIs em formato de tabela
   - Para cada, breve explicação de importância e tendências

4. Análise por Segmento
   - Desempenho dos 3 principais segmentos de negócio
   - Melhor e pior performance com possíveis razões

5. Balanço Patrimonial
   - Mudanças significativas em ativos, passivos, patrimônio
   - Índices-chave (liquidez corrente, endividamento) e interpretação

6. Declarações Prospectivas
   - 3 previsões-chave para Q3
   - 2-3 movimentos estratégicos recomendados

7. Avaliação de Riscos
   - 3 riscos financeiros potenciais com estratégias de mitigação

8. Comparação com Pares
   - Compare com 2-3 concorrentes (dados publicamente disponíveis)
   - Áreas onde superamos e áreas de melhoria

Use charts ou tabelas onde apropriado. Declare suposições explicitamente com raciocínio.

Após a análise, gere 5 perguntas que membros do conselho podem fazer, com respostas sugeridas. Por fim, resuma tudo em um parágrafo único para usar como declaração de abertura da reunião.
```

---

## 11. Troubleshooting rápido

| Problema | Primeira alavanca |
| --- | --- |
| Resposta vaga ou genérica | Especifique formato, público e constraints (seção 2.1) |
| Resposta erra o tom | Dê papel explícito no system prompt (seção 2.5) ou especifique tom (seção 8.1.6) |
| Resposta ignora parte do input | Envolva partes do prompt em XML tags distintas (seção 2.4) |
| Não encontra informação em documento grande | Reordene: documento no topo, query no final (seção 2.7) |
| Modelo alucina sobre código | Force leitura antes de responder (seção 6.10) |
| Modelo não toma ação (só sugere) | Instrução imperativa: "Change", "Make", "Implement" (seção 4.1) |
| Modelo over-engineer | Prompt anti-overengineering (seção 6.8) |
| Thinking excessivo | Baixar `effort` ou constrain explicitamente (seção 5.1) |
| Subagents spawnando demais | Prompt de uso seletivo (seção 6.5) |
| Tests passando mas solução frágil | Prompt de solução geral (seção 6.9) |
| Output muito verboso | "Provide concise, focused responses" (seção 8.1.1) |
| Output com markdown pesado demais | Prompt anti-markdown (seção 3.2) |
| LaTeX indesejado em matemática | Forçar plain text (seção 3.3) |
| Frontend caindo em AI slop | Prompt `<frontend_aesthetics>` (seção 7.2) |

---

## 12. Fontes

Fonte canônica única (substitui as subpáginas antigas):

- [Prompting best practices — Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)

Complementos oficiais:

- [Prompt engineering overview — Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview)
- [Migration guide — Anthropic](https://platform.claude.com/docs/en/about-claude/models/migration-guide)
- [Effort parameter — Anthropic](https://platform.claude.com/docs/en/build-with-claude/effort)
- [Adaptive thinking — Anthropic](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking)
- [Extended thinking — Anthropic](https://platform.claude.com/docs/en/build-with-claude/extended-thinking)
- [Context windows — Anthropic](https://platform.claude.com/docs/en/build-with-claude/context-windows)
- [Memory tool — Anthropic](https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool)
- [Computer use tool — Anthropic](https://platform.claude.com/docs/en/agents-and-tools/tool-use/computer-use-tool)
- [Structured outputs — Anthropic](https://platform.claude.com/docs/en/build-with-claude/structured-outputs)

Tutoriais interativos:

- [Prompt engineering interactive tutorial (GitHub) — anthropics/prompt-eng-interactive-tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
- [Prompt engineering interactive tutorial (Google Sheets) — Anthropic](https://docs.google.com/spreadsheets/d/19jzLgRruG9kjUQNKtCg1ZjdD6l6weA6qRXG5zLIAhC8)

Referências técnicas citadas:

- [Frontend design skill — anthropics/claude-code](https://github.com/anthropics/claude-code/blob/main/plugins/frontend-design/skills/frontend-design/SKILL.md)
- [Crop tool cookbook — Anthropic](https://platform.claude.com/cookbook/multimodal-crop-tool)
- [Improving frontend design through skills — Anthropic blog](https://www.claude.com/blog/improving-frontend-design-through-skills)
