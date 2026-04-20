# Performance e Boas Práticas — Claude Code Desktop App

> Guia pessoal de otimização e referência rápida.
> Atualizado em abril/2026.

---

## 1. Gestão de Contexto — O Fator #1

A qualidade das respostas degrada conforme o context window enche. Isso não é um bug — é uma propriedade fundamental de LLMs. Gerenciar contexto é a skill mais importante.

### `/context` — monitorar antes de agir

Mostra em tempo real quanto do context window está ocupado. Olhar **antes** de cada tarefa complexa.

- Abaixo de 50%: zona segura, raciocínio de alta qualidade
- 50–80%: performance aceitável, considerar `/compact`
- Acima de 80%: compactar imediatamente ou iniciar sessão nova

### `/compact` — usar proativamente

Sumariza a conversa preservando decisões-chave. **Não esperar** o auto-compact (que dispara a ~83% do contexto). Ao rodar, especificar o que preservar:

```
/compact Preservar lista de arquivos modificados, decisões de arquitetura e comandos de teste
```

Customizar comportamento padrão no CLAUDE.md:
```markdown
# Compact instructions
When compacting, always preserve the full list of modified files and test commands
```

### `/clear` — reset entre tarefas

Usar ao mudar de tema completamente. Contexto irrelevante acumulado degrada qualidade mesmo que haja espaço sobrando.

### `@file` — referência direta

Usar `@src/auth/oauth.ts` em vez de descrever o caminho. Claude pula Grep/Glob e vai direto ao conteúdo — economiza tokens e tempo.

### Side Chat — perguntas sem poluir contexto

Abrir pela sidebar para perguntas rápidas que não precisam ficar no histórico da sessão principal.

### Sessões separadas por tarefa

Cada sessão paralela (sidebar) tem contexto e Git worktree próprios. Não acumular tarefas não relacionadas na mesma sessão.

### Context window de 1M tokens

Com Opus 4.6 e Sonnet 4.6, o context window de 1M tokens está disponível para planos Max, Team e Enterprise — sem custo adicional. Ativado por padrão. Para desabilitar: `CLAUDE_CODE_DISABLE_1M_CONTEXT=true`.

Mesmo com 1M, a disciplina de gestão de contexto continua importante — accuracy degrada com contextos muito grandes (context rot).

---

## 2. Memória Persistente

Dois sistemas complementares carregam conhecimento entre sessões.

### CLAUDE.md — suas instruções para o Claude

Carregado em toda sessão. É o lugar para regras que se aplicam a qualquer tarefa.

**Regras práticas:**

- Manter abaixo de **200 linhas**
- Para cada linha: "Se eu remover isso, o Claude vai errar?" — se não, cortar
- Mover conhecimento especializado para **skills** (carregadas sob demanda)
- Tratar como código: revisar quando algo der errado, podar regularmente
- Ênfase para regras críticas: usar "IMPORTANT" ou "YOU MUST" para melhorar aderência
- Commitar no git para o time contribuir

**O que incluir vs. excluir:**

| Incluir | Não incluir |
|---|---|
| Comandos bash que Claude não adivinha | O que Claude descobre lendo o código |
| Regras de estilo que diferem do padrão | Convenções padrão da linguagem |
| Instruções de teste e runners | Documentação detalhada de API (linkar) |
| Convenções git (branch naming, PR) | Info que muda frequentemente |
| Decisões arquiteturais do projeto | Descrições file-by-file do codebase |
| Quirks do ambiente dev | Óbvios como "write clean code" |

**Estrutura de arquivos:**

| Local | Escopo |
|---|---|
| `~/.claude/CLAUDE.md` | Global — todas as sessões |
| `./CLAUDE.md` | Projeto — compartilhado via git |
| `./CLAUDE.local.md` | Pessoal — adicionar ao .gitignore |
| Subdiretórios | Sob demanda quando Claude trabalha naquele path |
| Parents (monorepo) | root/CLAUDE.md + root/foo/CLAUDE.md carregados juntos |

**Imports:** usar `@path` para referenciar outros arquivos:
```markdown
See @README.md for project overview
Git workflow: @docs/git-instructions.md
```

**Setup inicial:** `/init` analisa o codebase e gera um CLAUDE.md starter. Refinar a partir dele. Para fluxo interativo que também guia `skills`, `hooks` e memory files, ativar `CLAUDE_CODE_NEW_INIT=1` no ambiente.

### Auto Memory — caderno de notas do Claude

O Claude escreve notas para si mesmo: build commands, preferências, decisões, bugs resolvidos. Persiste automaticamente entre sessões.

- Ativado por padrão (toggle via `/memory`)
- Diretório: `~/.claude/projects/<projeto>/memory/`
- Primeiras 200 linhas do MEMORY.md carregadas em toda sessão
- Notas detalhadas em arquivos de tópico (debugging.md, patterns.md) — carregados sob demanda

**Uso explícito:**
- `"lembre que usamos pnpm, não npm"` — salva imediatamente
- `/memory` — abre seletor e toggle

**Manutenção:** são arquivos markdown editáveis. O **Auto Dream** (consolidação automática) roda em background — converte datas relativas para absolutas, remove contradições, prune entradas de arquivos deletados.

---

## 3. Modelo, Effort e Thinking

### Escolha de modelo

Selecionar pelo dropdown ao lado do botão de envio, ou via `/model`.

| Modelo | Quando usar |
|---|---|
| **Sonnet 4.6** | ~80% das tarefas — implementação, edições, rotina |
| **Opus 4.6** | Decisões arquiteturais, debugging complexo, análise profunda |
| **Opus Plan Mode** | Opus para planejar, Sonnet para executar — melhor custo-benefício |
| **Haiku** | Subagents de exploração, tarefas simples e rápidas |

### `/effort` — profundidade de raciocínio

| Nível | Quando usar |
|---|---|
| `low` | Edições triviais, formatação, tasks mecânicas |
| `medium` | Default — tarefas rotineiras |
| `high` | Debugging complexo, decisões arquiteturais |
| `max` | Análises profundas, problemas multi-camada |

### Extended Thinking

Ativado por padrão. Com Opus 4.6 e Sonnet 4.6, o thinking é **adaptativo** — aloca tokens dinamicamente conforme o `/effort`. Palavras como "think hard" no prompt são instrução regular, não controlam thinking tokens.

Para desativar pontualmente na CLI: `Option+T` (macOS). No Desktop app, não há atalho documentado equivalente.

---

## 4. Workflow: Explore → Plan → Implement → Commit

Workflow oficial de 4 fases da Anthropic. Evita resolver o problema errado.

**Ativar Plan Mode:**

- **CLI:** `Shift+Tab` cicla entre permission modes inline (inclui Plan Mode)
- **Desktop app:** acessar via menu de permission modes na UI — `Shift+Tab` é feature exclusiva da CLI e não funciona no Desktop
- **Ambos:** slash command `/plan`

Plan Mode é read-only — Claude analisa e propõe sem editar arquivos.

**1. Explore** (Plan Mode) — Claude lê arquivos e responde perguntas, sem modificar nada.
```
Leia /src/auth e entenda como lidamos com sessions e login.
Também veja como gerenciamos variáveis de ambiente.
```

**2. Plan** (Plan Mode) — Pedir plano de implementação detalhado.
```
Quero adicionar Google OAuth. Que arquivos precisam mudar?
Qual é o fluxo de sessão? Crie um plano.
```

**3. Implement** (Normal Mode) — Executar o plano com verificação.
```
Implemente o OAuth flow do seu plano. Escreva testes para
o callback handler, rode a suite de testes e corrija falhas.
```

**4. Commit** — Claude commita e cria PR.
```
Commite com mensagem descritiva e abra um PR.
```

**Quando pular o plano:** se a mudança cabe em uma frase ("corrigir typo em X"), vá direto. Plan Mode tem overhead; usar quando há incerteza ou mudanças em múltiplos arquivos.

---

## 5. Prompts e Comunicação Efetiva

### Dar meios de verificação

A prática de maior impacto segundo a Anthropic. Incluir testes, screenshots ou outputs esperados para o Claude se auto-verificar.

| Antes | Depois |
|---|---|
| "implemente validação de email" | "escreva validateEmail. Casos: user@test.com → true, invalid → false. Rode os testes depois" |
| "melhore o dashboard" | "[colar screenshot] implemente este design. Tire screenshot do resultado e compare com o original" |
| "o build está falhando" | "o build falha com este erro: [colar]. Corrija e verifique que o build passa. Trate a causa raiz" |

### Ser específico

| Antes | Depois |
|---|---|
| "adicione testes para foo.py" | "escreva teste para foo.py cobrindo o edge case de user deslogado, sem mocks" |
| "corrija o bug de login" | "login falha após session timeout. Cheque auth flow em src/auth/, especialmente token refresh" |
| "adicione um widget" | "veja como widgets existentes são implementados na home (HotDogWidget.php). Siga o padrão para um calendar widget" |

### Agrupar tarefas relacionadas
```
No componente UserProfile:
1. Adicionar loading state
2. Tratar o caso de erro
3. Adicionar botão de upload de avatar
```

### Entrevista reversa

Para features grandes, pedir ao Claude para entrevistar você antes de começar:
```
Quero construir [descrição breve]. Me entreviste em detalhe
usando AskUserQuestion. Pergunte sobre implementação técnica,
UX, edge cases e tradeoffs. Quando tivermos coberto tudo,
escreva a spec completa em SPEC.md.
```

Depois, iniciar sessão nova para implementar (contexto limpo + spec escrita).

---

## 6. Subagents, Skills, Plugins e Custom Agents

### Subagents — contexto separado

Rodam em context window próprio e retornam resumo. Preservam o contexto principal.

```
Use subagents para investigar como nosso sistema de auth
lida com token refresh e se temos utilitários OAuth.
```

Usar também para verificação pós-implementação:
```
Use um subagent para revisar este código em busca de edge cases.
```

### Skills — workflows reutilizáveis

Arquivos em `.claude/skills/` com SKILL.md. Carregados sob demanda — não inflam contexto. Acessar via `/`.

Exemplo de skill com workflow:
```markdown
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
---
Analise e corrija a issue: $ARGUMENTS
1. Use `gh issue view` para detalhes
2. Busque arquivos relevantes
3. Implemente as mudanças
4. Escreva e rode testes
5. Commit descritivo e crie PR
```

Invocar: `/fix-issue 1234`. `disable-model-invocation: true` = só dispara manualmente.

### Custom Subagents — especialistas

Definir em `.claude/agents/`:
```markdown
---
name: security-reviewer
description: Reviews code for security vulnerabilities
tools: Read, Grep, Glob, Bash
model: opus
---
Você é um engenheiro de segurança sênior. Revise:
- Injection (SQL, XSS, command)
- Falhas de auth/authorization
- Secrets no código
- Manipulação insegura de dados
Forneça referências de linha e correções sugeridas.
```

### Plugins

Bundles de `skills` + `hooks` + `agents` + `MCP servers` reutilizáveis. Instalar sem configuração manual.

- **Desktop app:** `/plugin` (slash command built-in) abre a UI tabbed de marketplaces/instalados. Alternativa visual: botão **+** → **Plugins** na UI da sessão.
- **CLI:** `/plugin` funciona dentro de sessão interativa. Fora da sessão, `claude plugin <install|list|enable|disable|update|uninstall>` gerencia via shell (útil pra scripts).
- **Caveat Desktop (2.1.109+):** autocomplete do `/` tem regressão que pode ocultar `/plugin` built-in quando há skills custom com "plugin" no nome (issues [#49087](https://github.com/anthropics/claude-code/issues/49087), [#49454](https://github.com/anthropics/claude-code/issues/49454)). Workaround: digitar `/plugin` → **Esc** pra dispensar picker → **Enter**. Ou usar `claude plugin …` no terminal.

Para linguagens tipadas, instalar um plugin de code intelligence para navegação de símbolos e detecção de erros.

---

## 7. Diff Review, Undo e Checkpoints

### Diff Visual

Indicador `+12 -1` após edições. Clicar para:
- Revisar arquivo por arquivo
- Comentar linhas específicas — Claude lê e revisa
- "Review code" para Claude auto-avaliar os diffs

### Desfazer com checkpoint

Cada ação do Claude cria checkpoint. Checkpoints persistem entre sessões.

- **CLI:** `/rewind` abre menu para restaurar conversa, código, ou ambos. Alternativa: `Esc` duas vezes
- **Desktop app:** `/rewind` não funciona como slash command; acessar checkpoints via UI do app

Quando Claude errar a direção: **não tentar corrigir no mesmo contexto poluído**. Reiniciar com prompt melhor via checkpoint disponível. Depois de 2 correções falhas, `/clear` e reescrever o prompt incorporando o aprendizado.

### `Esc` — interromper mid-action

Pressionar `Esc` para parar Claude durante execução. Contexto preservado — redirecionar imediatamente.

---

## 8. Gestão de Sessões

### Nomear sessões

- **CLI:** usar `/rename` + novo nome:

```
/rename apipass-auth-refactor
```

- **Desktop app:** `/rename` não funciona como slash command; renomear via UI da sidebar

Nomear cedo. Muito mais fácil encontrar "payment-integration" do que "explain this function".

### `/resume` — retomar sessões

- **CLI:** `/resume` abre seletor de sessões recentes inline
- **Desktop app:** `/resume` **não funciona**; retomar sessões clicando na sessão desejada na sidebar

```
/resume            # CLI apenas: seletor de sessões recentes
```

Tratar sessões como branches: diferentes workstreams com contextos persistentes e separados.

### Handoff entre sessões

Quando contexto saturado e `/compact` insuficiente:

1. Pedir HANDOFF.md: objetivo, progresso, o que funcionou/falhou, próximos passos
2. Nova sessão: `Leia @HANDOFF.md e continue de onde paramos`

---

## 9. Sessões Cloud, Dispatch e Parallelismo

### Remote Sessions

Selecionar **Remote** ao iniciar sessão. Execução na infra Anthropic:
- Continua se fechar o app
- Sem consumo de CPU/RAM local
- Acessível via claude.ai/code ou mobile

### Dispatch — controle pelo celular

Disparar e monitorar tarefas pelo app mobile. Workflow CRO: iniciar análise entre reuniões → Claude executa na cloud → resultado pronto ao voltar ao Mac.

### Padrão Writer/Reviewer

Usar duas sessões paralelas para qualidade superior:

| Sessão A (Writer) | Sessão B (Reviewer) |
|---|---|
| "Implemente rate limiter para API" | |
| | "Revise o rate limiter em @src/middleware/rateLimiter.ts. Edge cases, race conditions, consistência" |
| "Feedback do reviewer: [output B]. Corrija." | |

Funciona também com testes: uma sessão escreve testes, outra escreve código para passar.

---

## 10. MCP Servers, Connectors e Hooks

### MCP Servers

Cada server adiciona definições de tools ao contexto. Desabilitar inativos:

- **CLI:** `/` → MCP → Manage MCP Servers via slash command
- **Desktop app:** sem slash command ou UI dedicada — gerenciar manualmente editando `~/.claude/settings.json` (ou via botão **+** → Plugins quando o server vem empacotado como plugin)

Ferramentas MCP são diferidas por padrão — só nomes entram no contexto até Claude usar uma tool específica.

### Connectors para workflows de negócio

Os connectors do Cowork (HubSpot, Gmail, Confluence, Google Calendar) funcionam no Code tab sem reconfiguração:
- HubSpot → Confluence → relatório
- Gmail → action items → tasks
- Google Calendar → briefing de reunião

### Hooks — ações determinísticas

Diferente de instruções em CLAUDE.md (que são advisory), hooks são garantidos. Executam scripts em pontos específicos do workflow do Claude.

```
"Escreva um hook que rode eslint após cada edição de arquivo"
"Escreva um hook que bloqueie writes na pasta migrations"
```

Configurar em `.claude/settings.json`. Verificar com `/hooks`.

### CLI Tools

Dizer ao Claude para usar ferramentas CLI quando disponíveis: `gh`, `aws`, `gcloud`, etc. São a forma mais eficiente em tokens de interagir com serviços externos.

---

## 11. Permissions e Auto Mode

### Permission allowlists

Pré-aprovar comandos seguros para reduzir interrupções:

```json
{
  "permissions": {
    "allow": [
      "Bash(npm run *)",
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  }
}
```

### Auto Mode

Classifier AI que aprova automaticamente operações seguras (reads, git status, test runs) e bloqueia riscos (force push, rm -rf, deploys em produção).

- **CLI:** `Shift+Tab` cicla entre permission modes (inclui Auto Mode) inline
- **Desktop app:** acessar via menu de permission modes na UI (`Shift+Tab` não funciona no Desktop)
- Também pode fixar um permission mode default em `~/.claude/settings.json`

### Sandboxing

Isolamento em nível de OS — restringe filesystem e rede. Permite ao Claude trabalhar mais livremente dentro de limites definidos.

- **CLI:** `/sandbox` slash command para ativar/configurar
- **Desktop app:** sem slash command equivalente — configurar via `~/.claude/settings.json`

---

## 12. Configurações de Ambiente

### Variáveis de ambiente úteis

Adicionar ao `~/.zshrc` ou ao bloco `"env"` em `~/.claude/settings.json`:

| Variável | Efeito |
|---|---|
| `BASH_DEFAULT_TIMEOUT_MS=1800000` | Timeout padrão de comandos Bash: 30min (default 2min) — cobre builds, tests e debugging longos |
| `BASH_MAX_TIMEOUT_MS=3600000` | Cap máximo de timeout Bash: 1h (default 10min) — cobre tarefas longas sem virar runaway |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=70` | Compacta mais cedo (default ~83%) — mais espaço de trabalho |
| `CLAUDE_CODE_NO_FLICKER=1` | Rendering suave no terminal (aplica-se ao CLI; Desktop app tem renderer próprio) |

### Vars que parecem úteis mas evite

Testadas e consideradas subótimas ou problemáticas:

- **`MAX_THINKING_TOKENS=N`** — Opus 4.6 e Sonnet 4.6 têm adaptive thinking que aloca tokens dinamicamente conforme complexidade da tarefa. Hard cap corta raciocínio em tarefas complexas (debug, arquitetura, code review) sem economia real em tarefas simples (que já usam pouco). Deixar sem setar.
- **`CLAUDE_CODE_SUBAGENT_MODEL=haiku`** — Força Haiku em todos os subagents. Comportamento incerto em relação ao `model:` declarado no frontmatter de custom agents (pode ou não override). Economia marginal (~$0.05/sessão) não compensa risco de degradar agents sofisticados como `code-architect` ou `security-reviewer`. Deixar sem setar — cada agent usa seu `model:` ou o default inteligente.
- **`DISABLE_NON_ESSENTIAL_MODEL_CALLS=1`** — Não aparece na doc oficial atual. Tem bug conhecido ([anthropics/claude-code#5025](https://github.com/anthropics/claude-code/issues/5025)) que impede supressão completa de status spinners. Economia marginal. Deixar sem setar.

### Settings.json recomendado

Arquivo: `~/.claude/settings.json`

```json
{
  "$schema": "https://json-schema.org/claude-code-settings.json",
  "permissions": {
    "allow": [
      "Bash(git status)",
      "Bash(git diff *)",
      "Bash(git log *)"
    ],
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(~/.ssh/**)",
      "Bash(rm -rf *)",
      "Bash(git push --force *)"
    ]
  },
  "showTurnDuration": true,
  "env": {
    "BASH_DEFAULT_TIMEOUT_MS": "1800000",
    "BASH_MAX_TIMEOUT_MS": "3600000",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "70"
  }
}
```

### Hierarquia de settings

Precedência (maior para menor): Managed Policy → Local (`.claude/settings.local.json`) → Project (`.claude/settings.json`) → User (`~/.claude/settings.json`)

Managed Policy é imposto pelo admin da organização e sobrepõe tudo. No macOS fica em `/Library/Application Support/ClaudeCode/`. Os outros três escopos são editáveis pelo usuário.

---

## 13. Anti-patterns Oficiais

A Anthropic documenta esses erros comuns:

**Kitchen Sink Session** — Misturar tarefas não relacionadas na mesma sessão. Contexto fica cheio de lixo.
→ **Fix:** `/clear` entre tarefas diferentes.

**Correção em loop** — Claude erra, você corrige, erra de novo, corrige. Contexto poluído com abordagens falhadas.
→ **Fix:** Depois de 2 correções falhas, `/clear` e reescrever o prompt incorporando o que aprendeu.

**CLAUDE.md inchado** — Arquivo longo demais faz Claude ignorar metade das regras.
→ **Fix:** Podar implacavelmente. Se Claude já faz algo corretamente sem a instrução, deletar.

**Trust-then-verify gap** — Claude produz implementação plausível que não cobre edge cases.
→ **Fix:** Sempre fornecer meios de verificação (testes, scripts, screenshots).

**Exploração infinita** — Pedir Claude para "investigar" sem escopo. Ele lê centenas de arquivos, enchendo o contexto.
→ **Fix:** Escopar ou delegar para subagents.

---

## 14. Quick Reference — Comandos Essenciais

| Comando / Ação | Efeito |
|---|---|
| `/context` | Mostra ocupação do context window |
| `/compact` | Sumariza contexto, acelera respostas |
| `/compact [instrução]` | Sumariza preservando o que especificar |
| `/clear` | Reset total do contexto |
| `/effort low/medium/high/max` | Ajusta profundidade de raciocínio |
| `/plan` | Ativa Plan Mode (read-only + análise) |
| `/model` | Troca modelo mid-session |
| `/memory` | Gerencia auto-memory |
| `/init` | Gera CLAUDE.md starter do projeto |
| `/cost` | Consumo de tokens da sessão |
| `/hooks` | Visualiza hooks configurados |
| `/sandbox` | Configura isolamento OS-level |
| `@arquivo` | Referência direta (economiza tokens) |
| `Esc` | Interrompe Claude mid-action |
| `Option+T` | Toggle extended thinking (CLI; pode requerer terminal config) |
| Side Chat (sidebar) | Pergunta sem poluir contexto |
| Sessões paralelas (sidebar) | Tarefas com contexto separado |
| Remote session | Execução cloud, sem consumo local |
| Dispatch (mobile) | Dispara/monitora pelo celular |
| Diff indicator (+N -N) | Review visual de mudanças |

---

## 15. Fontes

- [Best Practices — Anthropic](https://code.claude.com/docs/en/best-practices)
- [Memory — Anthropic](https://code.claude.com/docs/en/memory)
- [Common Workflows — Anthropic](https://code.claude.com/docs/en/common-workflows)
- [Context Window — Anthropic](https://code.claude.com/docs/en/context-window)
- [Manage Costs — Anthropic](https://code.claude.com/docs/en/costs)
- [Desktop Quickstart — Anthropic](https://code.claude.com/docs/en/desktop-quickstart)
- [Environment Variables — Anthropic](https://code.claude.com/docs/en/env-vars)
- [Permission Modes — Anthropic](https://code.claude.com/docs/en/permission-modes)
- [45 Tips — ykdojo/claude-code-tips](https://github.com/ykdojo/claude-code-tips)
- [Best Practice Repo — shanraisshan](https://github.com/shanraisshan/claude-code-best-practice)
- [Claude Code Cheat Sheet — computingforgeeks](https://computingforgeeks.com/claude-code-cheat-sheet/)
