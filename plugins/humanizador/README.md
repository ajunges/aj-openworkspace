# humanizador

Skill para remover sinais de escrita gerada por IA em **textos em português brasileiro**. Detecta **36 padrões** — 22 herdados do guia [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) da Wikipédia e 14 nativos do pt-BR.

## O que esta versão faz diferente

Fork próprio, não é tradução. Diferenças principais:

1. **Patologias nativas do pt-BR** que o guia da Wikipédia não cobre:
   - Mesóclise e ênclise artificial (`dir-se-ia`, `far-se-á`)
   - Nominalização abstrata (`a concretização`, `a operacionalização`)
   - Construções impessoais com "-se" (`observa-se que`, `percebe-se que`)
   - Calcos sintáticos do inglês (`endereçar um problema`, `performar`, `realizar que`)
   - Conectivos conclusivos empilhados (`portanto`, `dessa forma`, `assim sendo`)
   - Advérbios em "-mente" em excesso (`essencialmente`, `fundamentalmente`)
   - Conectivos de transição frios (`por sua vez`, `nesse contexto`)

2. **Substituição** do padrão "Hyphenated Word Pair Overuse" do upstream (não aplicável ao pt-BR) por **"Jargão corporativo composto"** — patologia equivalente em pt-BR (`solução ponta a ponta`, `plataforma centrada no usuário`, `abordagem orientada a dados`).

3. **Calibração de registro** — antes de humanizar, a skill identifica (ou pergunta) o contexto do texto: referencial/enciclopédico, corporativo/social, pessoal/conversacional ou acadêmico/analítico. Padrões sensíveis a registro mostram exemplos em duas variantes.

4. **Calibração de voz** — se o usuário fornecer amostra da própria escrita, a skill analisa e imita o ritmo, vocabulário e pontuação da amostra em vez de cair num padrão genérico.

5. **Passada final anti-IA** — depois do rascunho, a skill pergunta "o que ainda entrega que é IA?" e revisa uma segunda vez.

## Como usar

Invocar via frase natural ("humanize este texto em português", "remover padrões de IA em pt-BR", "tá com cara de ChatGPT") ou `/humanizador` em texto selecionado.

Para humanizar com sua voz pessoal:

```
Humanize este texto. Aqui vai uma amostra da minha escrita pra calibrar a voz: [amostra]
```

Ou apontando para um arquivo:

```
Humanize este texto. Use meu estilo em [caminho do arquivo] como referência.
```

## Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install humanizador@aj-openworkspace
```

## Histórico

- **v3.0.0** (atual) — fork próprio. Reescrita completa com 36 padrões, calibrações de voz e registro, exemplos duplos para padrões sensíveis a registro. Mantém atribuição ao blader e ao Argentoni no LICENSE, mas evolui de forma independente a partir daqui.
- **v2.2.0** — versão anterior, vendorizada do [Argentoni/humanizador](https://github.com/Argentoni/humanizador) (24 padrões, tradução do blader v2.2.0).

## Crédito

- **Fork atual** (v3.0.0): [@ajunges](https://github.com/ajunges)
- **Adaptação inicial pt-BR** (v2.2.0): [@Argentoni](https://github.com/Argentoni)
- **Skill base em inglês**: [@blader](https://github.com/blader/humanizer)
- **Guia conceitual**: Wikipedia [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), mantido pelo WikiProject AI Cleanup

Licença MIT. Ver `skills/humanizador/LICENSE`.
