# O que você encontra aqui

- Guias opinativos sobre Claude Code Desktop, `prompts` e workflows de AI

> Playbook pessoal do André Junges sobre Claude Code, workflows de AI e produtividade com LLMs. Notas organizadas e opinativas, em pt-BR com termos técnicos em inglês.

## Contexto

Este repo é mantido por André Junges, CRO do Grupo Supero. **Não sou desenvolvedor** — todo o código deste repositório (`marketplace.json`, plugins próprios, scripts, configs) é escrito por IA via Claude Code. Uso este espaço como playbook pessoal de trabalho com LLMs e, agora, para distribuir minha curadoria de plugins.

Não é um projeto de engenharia profissional — é um workbook público de alguém aprendendo e documentando em público como dirigir IA para produzir software.

## Guias

### Claude Code Desktop — Performance e boas práticas

[guias/claude-code-desktop-performance.md](guias/claude-code-desktop-performance.md)

Referência em 15 seções numeradas cobrindo gestão de `context window`, memória persistente (`CLAUDE.md` + Auto Memory), escolha de modelo e `/effort`, workflow Explore → Plan → Implement → Commit, `prompts` efetivos, `subagents`/`skills`/`plugins`, diff review e `/rewind`, gestão de sessões, remote/dispatch/parallelism, `MCP servers` e `hooks`, `permissions` e Auto Mode, env vars úteis, anti-patterns oficiais e quick reference de comandos. Atualizado em abril/2026.

## Marketplace

### aj-openworkspace — plugins curados do Claude Code

[marketplace/README.md](marketplace/README.md)

Curadoria pessoal de 15 plugins do Claude Code com sistema de classificação em 3 dimensões (nível de controle, status, tags). Instalável via `/plugin marketplace add ajunges/aj-openworkspace`. Inclui dois plugins próprios: `marketplace-tools` (verifica updates dos SHAs pinnados) e `sdd-workflow` (playbook de Spec-Driven Development para solo devs não-programadores).

## Roadmap

## Referências externas

## Licença / uso

- Playbook pessoal. Use por conta própria.
- Sem garantia. Adaptar ao próprio contexto.
