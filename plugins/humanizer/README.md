# humanizer

Skill para remover sinais de escrita gerada por IA em **textos em inglês**. Detecta 29 padrões baseados no guia [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) da Wikipedia.

## Upstream

Plugin vendorizado (Level 3) a partir do repo original:

- **Autor**: [@blader](https://github.com/blader)
- **Repo**: https://github.com/blader/humanizer
- **Versão vendorizada**: v2.5.1
- **SHA**: `8b3a17889fbf12bedae20974a3c9f9de746ed754` (2026-04-01)
- **Licença**: MIT (ver `skills/humanizer/LICENSE`)

## Para texto em pt-BR

Use o plugin irmão [`humanizador`](../humanizador) — adaptação pt-BR do mesmo conceito. Os padrões lexicais do blader são específicos do inglês e não transferem.

## Como usar

Invocar via frase natural ("humanize this text", "remove AI slop", "fix AI writing patterns"), ou `/humanizer` em texto selecionado.

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install humanizer@aj-openworkspace
```

## Status

`em-testes` — vendorizado pra avaliação. Se provar útil no workflow de textos em inglês, promover para `recomendado`.

## Manutenção

Esta é uma cópia vendorizada. Para atualizar para uma versão mais recente do upstream:

1. `gh api repos/blader/humanizer/commits/main --jq .sha` — pegar SHA atual
2. Comparar com o SHA acima
3. Re-baixar SKILL.md e LICENSE do novo SHA
4. Atualizar `version` e `SHA` neste README
5. Commit com mensagem `bump humanizer to <short-sha>`

## Crédito

Todo o crédito pela skill original vai para [@blader](https://github.com/blader). Este wrapper existe apenas para integrar a skill ao marketplace curado do aj-openworkspace.
