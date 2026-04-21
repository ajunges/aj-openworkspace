# portfolio-docs

Skill de **gestão de portfólio de produtos**. Produz e mantém o dossiê canônico (documento-mãe) de cada produto — markdown estruturado que vira fonte única da verdade para posicionamento, GTM e sales enablement. Primeira versão pública (v0.1.0).

## Para quem é

PMs, CROs e líderes de portfólio que precisam de um formato consistente para documentar produtos — evitando o caos típico de materiais espalhados (decks antigos, transcrições de call, pitches desatualizados). Especialmente útil para quem conduz o trabalho via IA e precisa de um input estruturado para gerar artefatos downstream (one-pager, battlecard, pitch deck).

## As 10 camadas

| # | Camada | Obrigatória? | Público principal |
|---|---|---|---|
| 0 | Identidade | Sim | Todos |
| 1 | Sumário Universal | Sim | Todos (inclusive fora de produto/TI) |
| 2 | Posicionamento e Mercado | Sim | Comercial, Marketing, Liderança |
| 3 | Produto | Sim | Produto, Engenharia, Pré-vendas |
| 4 | Go-to-Market | Sim | Comercial, Marketing, Operações, Finance |
| 5 | Sales Enablement | Sim | AEs, SDRs, Pré-vendas, CS |
| 6 | Marketing | Progressiva | Marketing, Growth, Content |
| 7 | Operação e Economics | Progressiva | Liderança, Finance, CRO, PM |
| 8 | Riscos e Dívidas | Recomendada | Liderança, PM, CRO |
| 9 | Referências e Histórico | Opcional | Todos |
| 10 | Instruções para AI | Recomendada | Assistentes de IA |

Camadas 0-5 são núcleo comercial + GTM obrigatório. Camadas 6-10 são progressivas — ativam conforme maturidade do produto.

## Três modos de operação

**Mode A — Greenfield.** Produto novo, nenhum material escrito. A skill roda uma entrevista estruturada camada a camada, usando frameworks calibrados (Moore em Camada 2, SPIN + MEDDPICC em Camada 5). Campos desconhecidos viram `[PENDENTE — {contexto}]` — nunca inventados.

**Mode B — Consolidação.** Já existem pitches, decks e transcrições de call, mas não há fonte única. A skill ingere tudo, mapeia para as 10 camadas e marca conflitos com `[DIVERGÊNCIA: fonte A diz X; fonte B diz Y — validar]`. Nunca resolve silenciosamente.

**Mode C — Update.** Dossiê existe e precisa de revisão cirúrgica (preço novo, cliente novo, feature lançada). A skill edita só as seções afetadas, atualiza o Controle de Versão e re-roda validações.

## Validações de coerência

Antes de entregar, a skill roda 4 validações automáticas:

1. **Product Coherence** — objeções, pitches e battlecards referem-se ao produto correto? (Previne o bug clássico de copy-paste entre dossiês — objeção de outro produto migra por engano e ninguém percebe na revisão humana.)
2. **Completeness** — camadas obrigatórias preenchidas? Progressivas marcadas como "não aplicável — {motivo}" quando vazias?
3. **Numerical Consistency** — preço em Moore bate com tabela de pricing? Metas em Operação batem com sizing de pipeline?
4. **Freshness** — `Última atualização` no header. >6 meses: warning. >12 meses: bloquear como stale.

Fails críticas bloqueiam delivery até remediação. Warnings entram no relatório mas permitem entrega.

## Artefatos downstream

O dossiê em markdown é a fonte canônica. A partir dele, a skill gera sob demanda:

| Artefato | Camadas usadas | Formato | Quando |
|---|---|---|---|
| One-pager comercial | 1, 3, 5 (excerpts) | DOCX / PDF, 1 página | Handout de venda |
| Battlecard | 2.6 | DOCX / PDF, 1 por concorrente | Prep pré-call competitivo |
| Pitch deck | 1, 2, 5, 7 | PPTX | Briefings executivos, board |
| Playbook de vendas | 3, 5, 6 | Confluence | Enablement do time |
| Onboarding brief | 0, 1, 4 | MD / PDF | Context pra novos colaboradores |
| Board update | 7, 8 | PPTX / DOCX | Review trimestral |

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install portfolio-docs@aj-openworkspace
```

## Como invocar

A skill ativa por qualquer uma destas frases (ou equivalente):

- "Crie/atualize o dossiê de [produto]"
- "Consolidar material do [produto]"
- "Gerar contexto estratégico de [produto]"
- "Documentar produto [nome]"
- "Portfolio document de [produto]"

**Não trigger para:** pedidos de artefato único quando não há dossiê (one-pager solto, deck solto) — a skill vai tratar isso como downstream e perguntar se precisa gerar o dossiê primeiro. Estudos de mercado, TAM/SAM/SOM e análises de expansão são de outras skills.

## Arquivos de referência

A skill carrega os detalhes sob demanda — não inflama o contexto inicial.

- `skills/portfolio-docs/references/layer_specs.md` — especificação detalhada por camada: campos, regras, anti-patterns
- `skills/portfolio-docs/references/template.md` — template canônico pronto pra copiar e preencher
- `skills/portfolio-docs/references/validation_rules.md` — as 4 validações com exemplos e remediação
- `skills/portfolio-docs/examples/EXAMPLE_PORTFOLIO.md` — exemplo fictício curto (Camadas 0-1 preenchidas) como ilustração

## Status

`em-testes` — primeira versão pública.

## Autor

André Junges (@ajunges). Playbook desenvolvido na prática, redigido e iterado 100% via Claude Code. Sem garantia — use por conta e risco.
