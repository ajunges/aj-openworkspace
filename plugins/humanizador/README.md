# humanizador

Skill para remover sinais de escrita gerada por IA em **textos em português brasileiro**. Detecta 24 padrões adaptados ao pt-BR a partir do guia [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) da Wikipedia.

## Upstream

Plugin vendorizado (Level 3) a partir do repo original:

- **Autor**: [@Argentoni](https://github.com/Argentoni)
- **Repo**: https://github.com/Argentoni/humanizador
- **Versão vendorizada**: v2.2.0
- **SHA**: `6a3edc938546cae46d8a0cf21d7fb1d7fb12269f` (2026-03-16)
- **Licença**: MIT (ver `skills/humanizador/LICENSE`)

O Argentoni derivou sua skill do `blader/humanizer` v2.2.0, adaptando os padrões para pt-BR (exemplos com Folha, O Globo, BBC Brasil, Embrapa; vocabulário e estruturas sintáticas de pt-BR).

## Relação com `humanizer`

Este repo também distribui [`humanizer`](../humanizer) (blader, inglês). Os dois não se sobrepõem:

- **humanizer** (inglês) — padrões lexicais de AI writing em inglês (`delve`, `navigate`, `tapestry`, etc.)
- **humanizador** (pt-BR) — padrões de pt-BR ("é importante destacar", "no cenário atual", "alavancar")

Invocar o humanizador correto pro idioma do texto.

## Como usar

Invocar via frase natural ("humanize este texto em português", "remover padrões de IA em pt-BR") ou `/humanizador` em texto selecionado.

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install humanizador@aj-openworkspace
```

## Status

`em-testes` — vendorizado pra avaliação. O autor original fez **1 commit só** e está baseado em blader v2.2.0 (enquanto o blader já está em v2.5.1). Se provar útil, considerar:

1. Upgrade incorporando padrões da v2.5 do blader (persuasive framing, signposting, fragmented headers, tailing negations)
2. Customização pra casos do CRO (vendas, marketing, comunicações executivas em pt-BR)

Roadmap pessoal — ver README principal do marketplace.

## Manutenção

Para atualizar para uma versão mais recente do upstream Argentoni:

1. `gh api repos/Argentoni/humanizador/commits/main --jq .sha` — pegar SHA atual
2. Comparar com o SHA acima
3. Re-baixar SKILL.md e LICENSE
4. Atualizar `version` e `SHA` neste README
5. Commit `bump humanizador to <short-sha>`

Quando você customizar a skill (fork ativo), remover a seção "Upstream" e tratar como plugin próprio.

## Crédito

- Skill pt-BR: [@Argentoni](https://github.com/Argentoni)
- Skill base (inglês): [@blader](https://github.com/blader)
- Guia conceitual: Wikipedia [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing)
