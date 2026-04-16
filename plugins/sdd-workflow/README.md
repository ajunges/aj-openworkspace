# sdd-workflow

Playbook pessoal de **Spec-Driven Development** para desenvolvedores solo que geram 100% do código via IA. Primeira versão pública (v0.1.0), sanitizada a partir de um workflow privado do autor.

## Audiência

Não-programadores (ou programadores iniciantes) que usam o Claude Code pra construir sistemas completos. O workflow compensa a falta de conhecimento técnico direto com:

- **Gates explícitos** em cada fase — nada avança sem aprovação
- **TDD rigoroso** — testes escritos antes do código
- **Auditoria em 8 dimensões** — segurança, isolamento de dados, integridade, performance, responsividade, UX, código, lógica de negócio
- **Seed com dados reais** — nunca dados fictícios (regra inviolável)

## As 7 fases

| # | Fase | Output |
|---|---|---|
| 0 | Discovery | Entendimento documentado no chat |
| 0.5 | Setup | Estrutura de pastas, CLAUDE.md, README.md inicial |
| 1 | Constitution | `specs/constitution.md` com princípios, stack, quality standards |
| 2 | Requirements | `specs/requirements.md` com módulos e regras de negócio |
| 3 | Design | `specs/design.md` com schema, APIs, arquitetura |
| 4 | Tasks | `specs/tasks.md` com plano incremental |
| 5 | Implementação | Loop de task → TDD → implementar → verificar → commit |
| 6 | Auditoria | Relatório em 8 dimensões |
| 7 | Entrega | Sistema rodando + resumo final |

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install sdd-workflow@aj-openworkspace
```

## Como invocar

A skill é `disable-model-invocation: true` — só ativa por triggers explícitos. Use uma das frases:

- "Novo projeto: [nome]. Use o workflow SDD."
- "Quero criar um sistema para [X]. Me guie no desenvolvimento."
- "/sdd" ou "/sdd.status" ou "/sdd.gate"

## Status

`em-testes` — primeira versão pública. Pode virar `recomendado` após rodada de uso e feedback.

## Autor

André Junges (@ajunges). Playbook desenvolvido na prática, 100% via Claude Code. Sem garantia — use por conta e risco.
