# O que você encontra aqui

- Guias opinativos sobre Claude Code Desktop, `prompts` e workflows de AI

> Playbook pessoal do André Junges sobre Claude Code, workflows de AI e produtividade com LLMs. Notas organizadas e opinativas, em pt-BR com termos técnicos em inglês.

## Contexto

Este repo é mantido por André Junges, CRO do Grupo Supero. **Não sou desenvolvedor** — todo o código deste repositório (`marketplace.json`, plugins próprios, scripts, configs) é escrito por IA via Claude Code. Uso este espaço como playbook pessoal de trabalho com LLMs e, agora, para distribuir minha curadoria de plugins.

Não é um projeto de engenharia profissional — é um workbook público de alguém aprendendo e documentando em público como dirigir IA para produzir software.

## Guias

### Claude Code Desktop — Performance e boas práticas

[guias/claude-code-desktop-performance.md](guias/claude-code-desktop-performance.md)

Referência em 15 seções numeradas cobrindo gestão de `context window`, memória persistente (`CLAUDE.md` + Auto Memory), escolha de modelo e `/effort`, workflow Explore → Plan → Implement → Commit, `prompts` efetivos, `subagents`/`skills`/`plugins`, diff review e `/rewind`, gestão de sessões, remote/dispatch/parallelism, `MCP servers` e `hooks`, `permissions` e Auto Mode, env vars úteis, anti-patterns oficiais e quick reference de comandos.

### Claude Prompting Guide — pt-BR

[guias/claude-prompting-guide.md](guias/claude-prompting-guide.md)

Tradução e adaptação editorial do **Prompt Engineering Guide** da Anthropic, estruturado como playbook pessoal. Cobre fundamentos, controle de output, `tool use`, `thinking`, sistemas agênticos e guidance específica por modelo (Opus 4.7 / 4.6, Sonnet 4.6, Haiku 4.5). Termos técnicos preservados em inglês. Sincronizado com a fonte oficial em 2026-04-17.

## Marketplace

### aj-openworkspace — plugins curados do Claude Code

[marketplace/README.md](marketplace/README.md) — guia de uso (instalar, desinstalar, escopos, atualizar, troubleshooting)

[marketplace/ADMIN.md](marketplace/ADMIN.md) — guia de administração (adicionar plugins, atualizar SHAs, criar plugins próprios, sanitização, regras)

Curadoria pessoal de 29 plugins do Claude Code (7 Level 2 com SHA pin, 18 Level 1 em HEAD, 4 Level 3 próprios) com sistema de classificação em 3 dimensões (nível de controle, status, tags). Instalável via `/plugin marketplace add ajunges/aj-openworkspace`.

Plugins próprios (Level 3):

- `marketplace-tools` — toolkit de manutenção do marketplace: `/check-marketplace-updates`, `/validate`, `/publish-plugin`, `/marketplace-qa`, `/restart-desktop`.
- `sdd-workflow` — playbook de Spec-Driven Development pra solo devs gerando código 100% via IA.
- `humanizador` — remove sinais de escrita gerada por IA em textos pt-BR (36 padrões, calibração de voz e registro).
- `portfolio-docs` — playbook de gestão de portfólio de produtos (dossiê canônico em 10 camadas + artefatos downstream).

## Licença / uso

- Playbook pessoal. Use por conta própria.
- Sem garantia. Adaptar ao próprio contexto.
