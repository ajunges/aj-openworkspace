# CLAUDE.md

Instruções específicas deste repo. Carrega junto com `~/.claude/CLAUDE.md` (preferências pessoais globais) — mantém aqui apenas o que é específico do workspace.

## O que é este repo

Workspace pessoal de notas do André Junges (`ajunges`). **Não é um projeto de código** — sem `build system`, sem testes, sem `package manager`, sem código-fonte. Apenas markdown. Não procure por `package.json`, não sugira `linters`, CI ou `test runners`.

## Estilo de documentação

House style para novas notas e edições — **overrides** o `Tom e formato` do global quando o conteúdo for nota/guia deste repo:

- Seções H2 numeradas (`## 1.`, `## 2.`, ...) separadas por horizontal rules (`---`)
- Tabelas markdown para comparações — "antes/depois", "quando usar", "incluir/não incluir"
- Fenced code blocks para comandos, JSON configs e exemplos de `prompt`
- Tom **dentro das notas**: imperativo e opinativo, hedging mínimo — é playbook pessoal, não documentação neutra (distinto do tom de conversa do global, que é profissional-amigável)
- Guias de referência terminam com uma seção **Fontes** linkando fontes primárias (Anthropic docs primeiro)

## Convenções do repo

- Branch padrão: `main`. Sem CI, sem workflow de PR obrigatório — commits vão direto para `main` a menos que o usuário peça branch/PR.
- **Repositório público** em `ajunges/aj-openworkspace` — tudo committado é world-readable.
- `.claude/` está no `.gitignore`. Não tentar committar settings locais.
- Usar o `gh` CLI para qualquer interação com GitHub — disponível e autenticado.
