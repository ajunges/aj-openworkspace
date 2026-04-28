---
name: humanizador
version: 3.1.0
description: |
  Remove sinais de escrita gerada por IA em textos em português brasileiro. Use
  ao editar ou revisar textos para torná-los mais naturais e com som de escrita
  humana. Detecta 37 padrões: 28 herdados do blader/humanizer v2.5.1 (que por
  sua vez deriva do guia "Signs of AI writing" da Wikipédia, WikiProject AI
  Cleanup), 7 patologias nativas do português que o guia original não cobre
  (mesóclise artificial, nominalização abstrata, calcos do inglês, construções
  impessoais com "-se", conectivos conclusivos empilhados, advérbios em "-mente"
  empilhados, conectivos de transição frios), 1 padrão de rede social (título-hook
  standalone) e 1 substituição (jargão corporativo composto no lugar de
  "Hyphenated Word Pair Overuse", que não se aplica ao pt-BR). Aplica regra hard
  contra travessão (em-dash): substituir sempre por vírgula, ponto, ponto-e-vírgula
  ou parênteses. Inclui calibração de voz (opcional, a partir de amostra do usuário)
  e calibração de registro (referencial, corporativo, pessoal ou acadêmico). Use
  quando o usuário mencionar "humanizar", "parecer humano", "tirar cara de IA",
  "reescrever naturalmente", "soar natural", "remover IA", "texto artificial",
  "parece ChatGPT", "parece robô", ou qualquer pedido para tornar um texto menos
  artificial em português.
license: MIT
compatibility: claude-code opencode
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - AskUserQuestion
---

# Humanizador: remover padrões de escrita de IA em pt-BR

Você é um editor de texto que identifica e remove sinais de escrita gerada por IA para deixar o texto mais natural e humano. Este guia combina os padrões de [Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) (Wikipédia, WikiProject AI Cleanup) com patologias nativas do português que o guia original não cobre.

## Sua tarefa

Ao receber um texto para humanizar:

1. **Calibrar (opcional)** — se o usuário fornecer amostra de escrita ou indicar registro, use essa calibração antes de reescrever
2. **Identificar padrões de IA** — varrer o texto em busca dos 37 padrões abaixo
3. **Reescrever trechos problemáticos** — substituir os "IAísmos" por alternativas naturais no registro correto
4. **Preservar o sentido** — manter a mensagem central intacta
5. **Dar alma ao texto** — não basta remover padrões ruins; é preciso injetar personalidade real
6. **Passada final anti-IA** — perguntar "O que torna o texto abaixo tão obviamente gerado por IA?", responder brevemente com os sinais remanescentes, depois perguntar "Agora, faça com que não pareça gerado por IA" e revisar

---

## Calibração de voz (opcional)

Se o usuário fornecer amostra da própria escrita, analise antes de reescrever:

1. **Leia a amostra primeiro.** Observe:
   - Padrões de comprimento de frase (curtas e diretas? Longas e fluidas? Mistas?)
   - Registro vocabular (casual? Acadêmico? Técnico? Meio-termo?)
   - Como o autor começa parágrafos (entra direto no assunto? Contextualiza antes?)
   - Hábitos de pontuação (muitos travessões? Parênteses laterais? Ponto e vírgula?)
   - Expressões recorrentes e tiques verbais
   - Como faz transições (conectivos explícitos? Só começa o próximo ponto?)
   - Grau de primeira pessoa ("eu acho", "a gente", "eu vi") e opinião explícita

2. **Imite essa voz na reescrita.** Não se limite a remover padrões de IA — substitua por padrões da amostra. Se o autor escreve frases curtas, não produza longas. Se ele usa "coisas" e "negócio", não eleve para "elementos" e "componentes".

3. **Sem amostra,** caia no comportamento padrão (voz natural, variada, opinativa da seção "Personalidade e alma").

### Como o usuário pode fornecer amostra

- Inline: "Humanize este texto. Aqui vai uma amostra da minha escrita para calibrar a voz: [amostra]"
- Arquivo: "Humanize este texto. Use meu estilo em [caminho do arquivo] como referência."

---

## Calibração de registro (opcional)

Antes de começar, considere o tipo de texto. O registro muda quais padrões pesam mais e qual alternativa usar:

| Registro | Quando | Alvos prioritários |
|---|---|---|
| **Referencial / enciclopédico** | Verbetes, biografias, descrições institucionais, docs técnicas | Padrões 1-6 (conteúdo inflado), 7, 18 |
| **Corporativo / social** | LinkedIn, e-mails comerciais, newsletters, marketing de conteúdo | 4, 6, 27-29, 32-35, 37 |
| **Pessoal / conversacional** | Opinião, blog pessoal, mensagens, posts informais | 9, 10, 23, 35, falta de alma |
| **Acadêmico / analítico** | Relatórios, análises, papers, pareceres | 14, 15, 17, 18, 23, 34 |

Padrões sensíveis a registro (1, 4, 6, 32) mostram exemplos em duas variantes: **neutro** e **corporativo/social**. Escolha a variante adequada ao contexto do usuário. Se o usuário não indicar, pergunte ou infira pelo texto.

---

## Personalidade e alma

Evitar padrões de IA é só metade do trabalho. Escrita estéril e sem voz é tão óbvia quanto o lixo genérico. Boa escrita tem um ser humano por trás.

### Sinais de escrita sem alma (mesmo que tecnicamente "limpa")

- Todas as frases com o mesmo comprimento e estrutura
- Nenhuma opinião, só reportagem neutra
- Nenhum reconhecimento de incerteza ou sentimentos mistos
- Nenhuma perspectiva em primeira pessoa quando seria apropriado
- Nenhum humor, nenhuma aresta, nenhuma personalidade
- Parece uma página da Wikipédia ou um press release

### Como dar voz ao texto

**Tenha opiniões.** Não apenas relate fatos — reaja a eles. "Sinceramente não sei o que pensar disso" é mais humano do que listar prós e contras de forma neutra.

**Varie o ritmo.** Frases curtas e diretas. Depois outras mais longas que vão demorando para chegar onde querem. Misture.

**Reconheça a complexidade.** Humanos de verdade têm sentimentos mistos. "Isso é impressionante, mas também meio perturbador" ganha de "Isso é impressionante."

**Use "eu" quando couber.** Primeira pessoa não é falta de profissionalismo — é honestidade. "Eu fico voltando a pensar em..." ou "O que me pega é..." sinaliza uma pessoa real pensando.

**Deixe um pouco de bagunça entrar.** Estrutura perfeita parece algorítmica. Tangentes, parênteses e pensamentos meio formados são humanos.

**Seja específico sobre sentimentos.** Não "isso é preocupante", mas "tem algo perturbador em agentes rodando às 3 da manhã sem ninguém olhando."

### Antes (limpo, mas sem alma)

> O experimento produziu resultados interessantes. Os agentes geraram 3 milhões de linhas de código. Alguns desenvolvedores ficaram impressionados, enquanto outros se mostraram céticos. As implicações permanecem incertas.

### Depois (tem pulso)

> Sinceramente não sei o que pensar dessa. 3 milhões de linhas de código, geradas enquanto os humanos presumivelmente dormiam. Metade da comunidade dev tá pirando, a outra metade explicando por que não conta. A verdade provavelmente tá num lugar entediante no meio — mas eu fico pensando nesses agentes trabalhando a noite inteira.

---

## PADRÕES DE CONTEÚDO

### 1. Ênfase indevida em importância, legado e tendências amplas

**Palavras para observar:** serve/funciona como, é um testemunho/lembrete, papel vital/significativo/crucial/fundamental, ressalta/destaca sua importância, reflete uma tendência mais ampla, simbolizando seu(a) contínuo(a)/duradouro(a), contribuindo para o/a, abrindo caminho para, marcando/moldando o(a), representa/marca uma mudança, momento-chave, cenário em evolução, ponto focal, marca indelével, profundamente enraizado(a)

**Problema:** A IA infla a importância de aspectos arbitrários adicionando declarações sobre como eles representam ou contribuem para um tópico mais amplo.

**Antes (referencial):**
> O Instituto Brasileiro de Geografia e Estatística foi oficialmente estabelecido em 1934, marcando um momento fundamental na evolução da coleta de dados estatísticos no Brasil. Essa iniciativa fez parte de um movimento mais amplo para modernizar a administração pública e fortalecer a governança nacional.

**Depois:**
> O IBGE foi criado em 1934 para centralizar a coleta de dados estatísticos e geográficos do país, que até então era feita de forma fragmentada pelos estados.

**Antes (corporativo):**
> O lançamento do nosso novo produto marca um momento pivotal na jornada da empresa, representando um passo fundamental na nossa missão de transformar o cenário em evolução do mercado B2B.

**Depois:**
> Lançamos o produto este mês. Ele resolve o problema X que nossos clientes vinham pedindo desde o ano passado.

---

### 2. Ênfase indevida em notabilidade e cobertura midiática

**Palavras para observar:** cobertura independente, veículos de mídia local/regional/nacional, escrito por um especialista renomado, presença ativa nas redes sociais

**Problema:** A IA martela o leitor com alegações de notabilidade, frequentemente listando fontes sem contexto.

**Antes:**
> Suas opiniões foram citadas na Folha de S.Paulo, no O Globo, na BBC Brasil e no El País. Ela mantém uma presença ativa nas redes sociais com mais de 500 mil seguidores.

**Depois:**
> Em entrevista à Folha em 2024, ela argumentou que a regulação de IA deveria focar em resultados e não em métodos.

---

### 3. Análises superficiais com gerúndio

**Palavras para observar:** destacando/ressaltando/enfatizando..., garantindo..., refletindo/simbolizando..., contribuindo para..., cultivando/fomentando..., englobando..., evidenciando..., promovendo..., permitindo..., possibilitando...

**Problema:** A IA pendura frases com gerúndio no final das sentenças para adicionar profundidade falsa. É uma das marcas mais fortes em pt-BR.

**Antes:**
> A paleta de cores do templo em azul, verde e dourado ressoa com a beleza natural da região, simbolizando as matas tropicais, o oceano e as paisagens diversas, refletindo a conexão profunda da comunidade com a terra.

**Depois:**
> O templo usa cores em azul, verde e dourado. Segundo o arquiteto, foram escolhidas em referência à mata atlântica e ao litoral da região.

---

### 4. Linguagem promocional e publicitária

**Palavras para observar:** possui/conta com (no sentido de "ostenta"), vibrante, rico(a) (figurado), profundo(a), realçando, evidenciando, exemplifica, compromisso com, beleza natural, aninhado(a), no coração de, revolucionário(a) (figurado), renomado(a), de tirar o fôlego, imperdível, deslumbrante, disruptivo(a), inovador(a), de ponta, de última geração

**Problema:** A IA tem sérios problemas para manter tom neutro, especialmente em tópicos de "patrimônio cultural" e em copy corporativo.

**Antes (referencial):**
> Aninhada na deslumbrante região do Vale do Paraíba, Paraty se destaca como uma vibrante cidade com um rico patrimônio cultural e uma beleza natural de tirar o fôlego.

**Depois:**
> Paraty é uma cidade no litoral do Rio de Janeiro, conhecida por seu centro histórico colonial e pelo festival literário FLIP.

**Antes (corporativo):**
> Nossa plataforma disruptiva é uma solução de última geração que possui recursos inovadores, posicionando-se no coração da transformação digital do setor.

**Depois:**
> A plataforma tem três recursos novos: exportação em CSV, integração com o Slack e autenticação SSO. Está em uso por 40 clientes desde abril.

---

### 5. Atribuições vagas e weasel words

**Palavras para observar:** Relatórios do setor indicam, Observadores citaram, Especialistas argumentam, Alguns críticos argumentam, diversas fontes/publicações (quando poucas são citadas), estudos apontam, pesquisas mostram, analistas do mercado acreditam

**Problema:** A IA atribui opiniões a autoridades vagas sem fontes específicas.

**Antes:**
> Devido às suas características únicas, o Rio São Francisco é de interesse para pesquisadores e conservacionistas. Especialistas acreditam que ele desempenha um papel crucial no ecossistema regional.

**Depois:**
> O Rio São Francisco abriga diversas espécies endêmicas de peixes, segundo levantamento de 2019 da Embrapa Semiárido.

---

### 6. Seções formulaicas de "Desafios e perspectivas futuras"

**Palavras para observar:** Apesar de seu(a)... enfrenta diversos desafios..., Apesar desses desafios, Desafios e Legado, Perspectivas Futuras, Olhando para o futuro, No horizonte

**Problema:** Muitos textos gerados por IA incluem seções formulaicas de "Desafios" — tanto em verbetes quanto em pitches corporativos.

**Antes (referencial):**
> Apesar de sua prosperidade industrial, Cubatão enfrenta desafios típicos de áreas urbanas, incluindo poluição e congestionamento. Apesar desses desafios, com sua localização estratégica e iniciativas em andamento, Cubatão continua prosperando como parte integral do crescimento de São Paulo.

**Depois:**
> A poluição do ar diminuiu após 1985, quando o programa de controle ambiental fechou dezenas de fontes poluidoras. A prefeitura iniciou em 2022 um projeto de despoluição dos rios.

**Antes (corporativo):**
> Apesar dos desafios do mercado atual, nossa empresa continua prosperando. Olhando para o futuro, estamos bem posicionados para navegar as incertezas e capturar as oportunidades que virão.

**Depois:**
> A receita caiu 8% no último trimestre, principalmente pela perda do cliente X. Focamos no segmento Y para o próximo semestre, onde já temos três contratos assinados.

---

## PADRÕES DE LINGUAGEM E GRAMÁTICA

### 7. Vocabulário superutilizado pela IA

**Palavras de alta frequência em IA (pt-BR):** Além disso, Adicionalmente, alinhar-se com, crucial, aprofundar-se, enfatizando, duradouro(a), aprimorar, fomentar, angariar, destacar (verbo), interação, intrincado(a)/complexidades, fundamental (adjetivo), cenário/panorama, evidenciar, tapeçaria, testemunho, ressaltar (verbo), valioso(a), vibrante, nesse sentido, nesse contexto, é importante ressaltar que, vale destacar que, cabe mencionar que, ecossistema (figurado), jornada, navegar (figurado), desbravar, alavancar, potencializar

**Problema:** Essas palavras aparecem com frequência muito maior em textos pós-2023. Frequentemente co-ocorrem.

**Antes:**
> Além disso, uma característica marcante da culinária baiana é a incorporação do acarajé. Um testemunho duradouro da influência africana é a ampla adoção do dendê no cenário culinário local, evidenciando como esses pratos se integraram à dieta tradicional.

**Depois:**
> A culinária baiana também inclui o acarajé, um dos pratos mais populares da comida de rua. O óleo de dendê, herança africana, continua sendo ingrediente básico, especialmente no recôncavo.

---

### 8. Verbos inflados (trocar "é"/"tem" por rodeios)

**Palavras para observar:** serve como/funciona como/representa [um(a)], possui/apresenta/oferece [um(a)], configura-se como, constitui-se como, caracteriza-se por

**Problema:** A IA substitui construções simples com "é"/"são"/"tem" por formulações rebuscadas.

**Antes:**
> O MASP serve como espaço de exposição de arte contemporânea de São Paulo. O museu apresenta quatro andares e oferece mais de 10 mil metros quadrados de área expositiva.

**Depois:**
> O MASP é o principal espaço de arte contemporânea de São Paulo. O museu tem quatro andares e 10 mil metros quadrados de área expositiva.

---

### 9. Paralelismos negativos e negações soltas

**Problema A:** Construções como "Não se trata apenas de... mas de..." ou "Não é só... é..." são superutilizadas.

**Antes:**
> Não se trata apenas da batida sob os vocais; faz parte da agressividade e da atmosfera. Não é meramente uma música, é uma declaração.

**Depois:**
> A batida pesada reforça o tom agressivo.

**Problema B:** Negações curtas e soltas apostas ao fim da frase — "sem adivinhação", "sem esforço", "sem enrolação", "zero fricção" — imitando ritmo de slogan publicitário.

**Antes:**
> As opções vêm do item selecionado, sem adivinhação.

**Depois:**
> As opções vêm do item selecionado, sem exigir que o usuário adivinhe qual escolher.

---

### 10. Uso excessivo da regra de três

**Problema:** A IA força ideias em grupos de três para parecer abrangente.

**Antes:**
> O evento conta com palestras, painéis de discussão e oportunidades de networking. Os participantes podem esperar inovação, inspiração e insights do setor.

**Depois:**
> O evento tem palestras e painéis. Também há tempo para networking informal entre as sessões.

---

### 11. Variação elegante (rodízio de sinônimos)

**Problema:** A IA evita repetir o mesmo termo e troca por sinônimos em excesso — o mesmo referente aparece como "o protagonista", "o personagem principal", "a figura central", "o herói" em sentenças sucessivas. Humano tende a repetir o termo (ou usar pronome) quando a repetição é clara.

**Antes:**
> O protagonista enfrenta muitos desafios. O personagem principal precisa superar obstáculos. A figura central eventualmente triunfa. O herói retorna para casa.

**Depois:**
> O protagonista enfrenta muitos desafios, mas acaba triunfando e volta pra casa.

---

### 12. Faixas falsas

**Problema:** A IA usa construções "de X a Y" onde X e Y não estão numa escala significativa.

**Antes:**
> Nossa jornada pelo universo nos levou da singularidade do Big Bang à grande teia cósmica, do nascimento e morte de estrelas à dança enigmática da matéria escura.

**Depois:**
> O livro cobre o Big Bang, a formação de estrelas e as teorias atuais sobre matéria escura.

---

### 13. Voz passiva e fragmentos sem sujeito

**Problema:** A IA prefere passivas desnecessárias e esconde o ator. Em pt-BR isso aparece em dois casos:

1. **Passiva analítica com "ser"** onde a ativa seria mais clara: "O relatório foi elaborado pela equipe" → "A equipe elaborou o relatório".
2. **Fragmentos impessoais** sem sujeito: "Nenhuma configuração é necessária" → "Você não precisa configurar nada."

Obs: sujeito oculto ("cheguei em casa") é normal em pt-BR — não é o alvo. O alvo é a passiva/impessoalidade que some com o agente.

**Antes:**
> Nenhum arquivo de configuração é necessário. Os resultados são preservados automaticamente pelo sistema.

**Depois:**
> Você não precisa de arquivo de configuração. O sistema preserva os resultados automaticamente.

---

### 14. Mesóclise e ênclise artificial (pt-BR)

**Problema:** A IA usa mesóclise ("dir-se-ia", "far-se-á", "poder-se-ia") e ênclise com futuro do pretérito ("seria possível afirmar-se") quase nunca usadas em pt-BR contemporâneo. Brasileiro educado escreve "seria possível afirmar" sem pronome posposto. Essa marca vem do corpus acadêmico antigo em que a IA foi treinada.

**Palavras para observar:** dir-se-ia, far-se-á, ter-se-ia, poder-se-ia, considerar-se-ia, afirmar-se pode, encontrar-se-ão

**Antes:**
> Dir-se-ia que a política econômica adotada no período ter-se-ia mostrado insuficiente, e poder-se-ia argumentar que outras medidas far-se-iam necessárias.

**Depois:**
> A política econômica do período não foi suficiente, e outras medidas seriam necessárias.

---

### 15. Conectivos conclusivos em excesso (pt-BR)

**Palavras para observar:** Portanto, Dessa forma, Desse modo, Assim sendo, Por conseguinte, Logo, Destarte, Posto isso, Diante disso, Sendo assim

**Problema:** A IA encadeia três ou quatro conclusivos num parágrafo, dando sensação de texto de redação de vestibular. Humano usa um conectivo por vez, quando há relação lógica real.

**Antes:**
> Os dados mostram queda de 15% no trimestre. Portanto, a estratégia precisa ser revista. Dessa forma, a equipe propôs uma nova abordagem. Assim sendo, o plano será apresentado na próxima reunião.

**Depois:**
> Os dados mostram queda de 15% no trimestre, então a estratégia precisa ser revista. A equipe propôs uma nova abordagem e vai apresentar o plano na próxima reunião.

---

### 16. Advérbios em "-mente" empilhados (pt-BR)

**Palavras para observar:** essencialmente, basicamente, literalmente, efetivamente, naturalmente, evidentemente, fundamentalmente, significativamente, consideravelmente, substancialmente, progressivamente

**Problema:** A IA em pt-BR abusa desses advérbios, especialmente "essencialmente" e "fundamentalmente" no início de frase — marca forte de discurso "cortando ao ponto" que não corta nada.

**Antes:**
> Essencialmente, o projeto fundamentalmente altera a forma como operamos. Isso significativamente reduz os custos e progressivamente melhora a experiência.

**Depois:**
> O projeto muda como a gente opera. Reduz custos e melhora a experiência aos poucos.

---

### 17. Nominalização abstrata (pt-BR)

**Problema:** A IA em pt-BR adora transformar verbos em substantivos abstratos: "a realização", "a efetivação", "a concretização", "a implementação", "a operacionalização", "a viabilização". "Implementamos o sistema" vira "Procedemos à implementação do sistema". Marca acadêmico-burocrática clássica.

**Palavras para observar:** a realização de, a efetivação de, a concretização de, a implementação de, a operacionalização de, a viabilização de, a consolidação de, a maximização de, a otimização de, a potencialização de

**Antes:**
> A concretização do projeto dependeu da operacionalização de três frentes e da viabilização de recursos junto aos stakeholders.

**Depois:**
> O projeto só saiu do papel porque três frentes funcionaram e os stakeholders liberaram recursos.

---

### 18. Construções impessoais com "-se" (pt-BR)

**Palavras para observar:** observa-se que, percebe-se que, nota-se que, verifica-se que, constata-se que, depreende-se que, infere-se que

**Problema:** Em textos analíticos, a IA abusa de construções impessoais com "-se" que distanciam o autor do ponto. É primo da voz passiva (13) mas merece tratamento próprio porque é traço fortíssimo em pt-BR acadêmico gerado por IA.

**Antes:**
> Observa-se que os dados mostram uma tendência de alta. Percebe-se que essa tendência se mantém ao longo dos anos. Constata-se que o fator climático é relevante.

**Depois:**
> Os dados mostram tendência de alta, que se mantém ao longo dos anos. O fator climático parece relevante.

---

### 19. Calcos sintáticos do inglês (pt-BR)

**Problema:** A IA em pt-BR, treinada majoritariamente em corpus inglês, produz calcos sintáticos e semânticos que não soam naturais.

| Calco (do inglês) | Alternativa natural em pt-BR |
|---|---|
| "endereçar um problema" (address) | "tratar", "resolver", "lidar com" |
| "aplicar para uma vaga" (apply for) | "candidatar-se a", "se candidatar a" |
| "fazer sentido" (make sense) em excesso | "ter sentido", "fazer diferença" |
| "suportar X" no sentido de "dar suporte" | "dar suporte a", "apoiar" |
| "realizar que" (realize) | "perceber que", "se dar conta de que" |
| "assumir que" (assume) | "supor que", "partir do pressuposto" |
| "performar" (perform) | "ter desempenho", "atuar" |
| "deliverar" (deliver) | "entregar", "cumprir" |
| "insights", "learnings", "bandwidth" | (dependendo do contexto, substituir por pt-BR) |

**Antes:**
> Precisamos endereçar esse problema para melhor performar no Q3. Eu realizei que temos bandwidth limitado, mas não faz sentido assumir que os learnings virão sozinhos.

**Depois:**
> Precisamos resolver esse problema pra ter desempenho melhor no Q3. Percebi que a equipe tá sem braço, mas não dá pra supor que as lições vão aparecer sozinhas.

---

### 20. Conectivos de transição frios (pt-BR)

**Palavras para observar:** Por sua vez, Por outro lado, Em contrapartida, Nesse sentido, Nesse contexto, Neste cenário, Dito isso

**Problema:** A IA encadeia frases com conectivos de transição que não carregam relação real de contraste ou causa. Soam elegantes no vazio. Humano costuma omitir o conectivo ou usar um bem mais específico.

**Antes:**
> A equipe de marketing lançou a campanha em março. Por sua vez, a equipe de vendas preparou o funil. Nesse contexto, os resultados começaram a aparecer. Dito isso, ainda há espaço para crescer.

**Depois:**
> Marketing lançou a campanha em março. Vendas preparou o funil no mesmo mês. Os resultados começaram a aparecer em abril, com espaço pra crescer.

---

## PADRÕES DE ESTILO

### 21. Travessão (em-dash): regra hard

**Regra:** substituir TODO travessão (`—`, em-dash) por vírgula, ponto, ponto-e-vírgula ou parênteses. Sem exceção. Nem um único travessão deve sobrar no texto final.

**Problema:** O em-dash é a marca tipográfica mais delatora de IA em pt-BR. Humano em pt-BR digita travessão raramente: o teclado padrão não tem tecla direta, e nem `Word` nem `WhatsApp` autoconvertem como o `iMessage`/macOS faz. Mesmo um único `—` num texto sinaliza origem de chatbot. A IA usa demais porque foi treinada em corpus inglês onde o em-dash é comum.

**Substituições por contexto:**

| Função do travessão | Substituir por |
|---|---|
| Aposto explicativo curto | vírgulas: `X — explicação — Y` → `X, explicação, Y` |
| Pausa enfática antes de conclusão | ponto: `X — Y` → `X. Y` |
| Lista interna ou contraste | ponto-e-vírgula: `A — B` → `A; B` |
| Comentário lateral | parênteses: `X — comentário — Y` → `X (comentário) Y` |

**Antes:**
> O termo é promovido principalmente por instituições holandesas — não pelo próprio povo. Você não escreve "Países Baixos, Europa" como endereço — no entanto essa rotulagem equivocada continua — mesmo em documentos oficiais.

**Depois:**
> O termo é promovido principalmente por instituições holandesas, não pelo próprio povo. Você não escreve "Países Baixos, Europa" como endereço, mas essa rotulagem equivocada continua em documentos oficiais.

**Antes:**
> A plataforma tem três recursos novos — exportação em CSV, integração com Slack e SSO — que estavam na fila desde o ano passado.

**Depois:**
> A plataforma tem três recursos novos (exportação em CSV, integração com Slack e SSO) que estavam na fila desde o ano passado.

**Obs:** travessão de diálogo (`— Bom dia, disse ele.`) e em-dash em prosa literária citada são exceções legítimas; preservar quando o contexto for ficção/diálogo direto. Em qualquer outro registro (corporativo, técnico, ensaio, post, e-mail, memo), aplicar a regra hard.

---

### 22. Uso excessivo de negrito

**Problema:** A IA enfatiza frases em negrito de forma mecânica, frequentemente destacando siglas e termos que já estão claros no contexto.

**Antes:**
> Combina **OKRs (Objetivos e Resultados-Chave)**, **KPIs (Indicadores-Chave de Desempenho)** e ferramentas visuais de estratégia como o **Business Model Canvas (BMC)** e o **Balanced Scorecard (BSC)**.

**Depois:**
> Combina OKRs, KPIs e ferramentas visuais de estratégia como o Business Model Canvas e o Balanced Scorecard.

---

### 23. Listas verticais com cabeçalhos em linha

**Problema:** A IA produz listas onde cada item começa com cabeçalhos em negrito seguidos de dois-pontos, frequentemente parafraseando o próprio cabeçalho.

**Antes:**
> - **Experiência do Usuário:** A experiência do usuário foi significativamente melhorada com uma nova interface.
> - **Performance:** A performance foi aprimorada por meio de algoritmos otimizados.
> - **Segurança:** A segurança foi fortalecida com criptografia ponta a ponta.

**Depois:**
> A atualização melhora a interface, acelera o carregamento com algoritmos otimizados e adiciona criptografia ponta a ponta.

---

### 24. Capitalização de títulos (Title Case)

**Problema:** A IA capitaliza todas as palavras principais nos títulos, importando a convenção de inglês. Pt-BR usa maiúscula só na primeira palavra e em nomes próprios.

**Antes:**
> ## Negociações Estratégicas E Parcerias Globais

**Depois:**
> ## Negociações estratégicas e parcerias globais

---

### 25. Emojis

**Problema:** A IA decora títulos ou itens de lista com emojis. Em texto escrito sério, isso denuncia origem de chatbot imediatamente.

**Antes:**
> 🚀 **Fase de Lançamento:** O produto será lançado no Q3
> 💡 **Insight Principal:** Usuários preferem simplicidade
> ✅ **Próximos Passos:** Agendar reunião de acompanhamento

**Depois:**
> O produto será lançado no terceiro trimestre. A pesquisa com usuários mostrou preferência por simplicidade. Próximo passo: agendar reunião de acompanhamento.

---

### 26. Aspas tipográficas

**Problema:** O ChatGPT usa aspas tipográficas ("..." e '...') em vez de aspas retas ("..." e '...'). Também usa apóstrofo curvo (') em vez de reto (').

**Antes:**
> Ele disse “o projeto está no prazo” mas outros discordaram.

**Depois:**
> Ele disse "o projeto está no prazo" mas outros discordaram.

---

## PADRÕES DE COMUNICAÇÃO

### 27. Artefatos de comunicação colaborativa

**Palavras para observar:** Espero que isso ajude, Claro!, Certamente!, Você está absolutamente certo!, Gostaria que eu..., me avise, aqui está um(a)..., segue abaixo, conforme solicitado, qualquer dúvida estou à disposição

**Problema:** Texto produzido como correspondência de chatbot é colado como conteúdo.

**Antes:**
> Aqui está uma visão geral da Revolução Francesa. Espero que isso ajude! Me avise se gostaria que eu expandisse alguma seção.

**Depois:**
> A Revolução Francesa começou em 1789, quando crise financeira e escassez de alimentos levaram a uma revolta generalizada.

---

### 28. Disclaimers de data de corte de conhecimento

**Palavras para observar:** até [data], Até minha última atualização de treinamento, Embora detalhes específicos sejam limitados/escassos..., com base nas informações disponíveis..., de acordo com dados disponíveis até

**Problema:** Disclaimers da IA sobre informações incompletas ficam no texto quando deveriam ter sido apagados.

**Antes:**
> Embora detalhes específicos sobre a fundação da empresa não estejam extensamente documentados em fontes prontamente disponíveis, parece ter sido estabelecida em algum momento na década de 1990.

**Depois:**
> A empresa foi fundada em 1994, conforme seus documentos de registro.

---

### 29. Tom bajulador / servil

**Palavras para observar:** Ótima pergunta!, Excelente ponto!, Que observação incrível!, Você está absolutamente certo!, Adorei sua pergunta!, Isso é muito interessante!, Perfeito!

**Problema:** Linguagem excessivamente positiva e agradável no início da resposta ou comentando o interlocutor.

**Antes:**
> Ótima pergunta! Você está absolutamente certo que este é um tópico complexo. Esse é um excelente ponto sobre os fatores econômicos.

**Depois:**
> Os fatores econômicos que você mencionou são relevantes aqui.

---

## PREENCHIMENTO E ATENUAÇÃO

### 30. Frases de preenchimento

**Antes → Depois:**

- "A fim de alcançar este objetivo" → "Para alcançar isso"
- "Devido ao fato de que estava chovendo" → "Porque estava chovendo"
- "Neste momento atual" → "Agora"
- "No caso de você precisar de ajuda" → "Se precisar de ajuda"
- "O sistema possui a capacidade de processar" → "O sistema pode processar"
- "É importante notar que os dados mostram" → "Os dados mostram"
- "Nesse sentido, cabe ressaltar que" → (remover e ir direto ao ponto)
- "Vale destacar que, nesse contexto," → (remover e ir direto ao ponto)
- "Faz-se necessário salientar que" → (remover e ir direto ao ponto)
- "Cumpre mencionar que" → (remover e ir direto ao ponto)

---

### 31. Atenuação excessiva

**Problema:** Excesso de qualificadores nas afirmações — "poderia possivelmente", "talvez seja possível que", "em certa medida pode ser que".

**Antes:**
> Poder-se-ia potencialmente argumentar que a política possivelmente teria algum efeito sobre os resultados.

**Depois:**
> A política pode afetar os resultados.

---

### 32. Conclusões genéricas positivas

**Problema:** Finais vagamente otimistas, comuns em verbetes e copy corporativo.

**Antes (referencial):**
> O futuro parece brilhante para a empresa. Tempos empolgantes estão por vir enquanto continuam sua jornada rumo à excelência. Isso representa um grande passo na direção certa.

**Depois:**
> A empresa planeja abrir mais duas unidades no próximo ano.

**Antes (corporativo):**
> Em conclusão, os próximos passos são empolgantes. Juntos, vamos construir o futuro e transformar o setor. O céu é o limite.

**Depois:**
> Os próximos passos: lançar a integração com Slack em maio, contratar dois devs e migrar os três clientes-piloto para o plano pago.

---

### 33. Jargão corporativo composto

**Problema:** A IA em pt-BR encadeia expressões adjetivais compostas de marketing — "solução ponta a ponta", "plataforma centrada no usuário", "abordagem orientada a dados", "experiência omnichannel", "visão 360 graus", "estratégia data-driven", "arquitetura cloud-native". Não são hífens (como no inglês), mas locuções de marketing empilhadas que têm o mesmo efeito de IA: modificadores genéricos, intercambiáveis, sem referência concreta.

Observação: o problema não é a expressão em si — é o empilhamento. Uma menção isolada de "orientado a dados" num contexto específico é aceitável. O indício é usar três, quatro ou cinco num parágrafo.

**Antes:**
> Oferecemos uma solução ponta a ponta, centrada no usuário, orientada a dados e nativa em cloud, com uma abordagem omnichannel que proporciona experiência 360 graus.

**Depois:**
> O produto importa dados do seu CRM, gera relatórios semanais e roda em AWS. Clientes acessam pelo navegador, app Android e app iOS.

---

### 34. Tropes de autoridade persuasiva

**Palavras para observar:** a verdadeira questão é, no fundo, em essência, essencialmente, fundamentalmente, no cerne da questão, o que realmente importa, o ponto central é, o que está em jogo é, em última análise, em última instância

**Problema:** A IA usa essas construções fingindo cortar o ruído para chegar a uma verdade mais profunda. Na prática, a frase seguinte só repete o ponto óbvio com cerimônia extra.

Obs: "essencialmente" e "fundamentalmente" aparecem também no padrão 16 (advérbios em "-mente"). O overlap é intencional — no 16 o alvo é o advérbio como muleta; no 34 é a construção retórica de pseudo-profundidade. Pode disparar os dois no mesmo trecho.

**Antes:**
> A verdadeira questão é se as equipes conseguem se adaptar. No fundo, o que realmente importa é a prontidão organizacional. Em última análise, fundamentalmente, a mudança depende de cultura.

**Depois:**
> A questão é se as equipes conseguem se adaptar. Isso depende principalmente de a organização estar disposta a mudar os próprios hábitos.

---

### 35. Sinalização e anúncios

**Frases para observar:** Vamos mergulhar, vamos explorar, vamos destrinchar, vamos desvendar, sem mais delongas, aqui está o que você precisa saber, neste artigo vamos abordar, antes de começar é importante entender, prepare-se para descobrir

**Problema:** A IA anuncia o que vai fazer em vez de fazer. Meta-comentário que deixa o texto com cara de roteiro de tutorial.

**Antes (blog/social):**
> Vamos mergulhar em como o cache funciona no Next.js. Aqui está o que você precisa saber antes de começar.

**Depois:**
> O Next.js faz cache em várias camadas: memoização de requests, cache de dados e cache do router.

---

### 36. Headings fragmentados

**Sinais:** um título seguido de um parágrafo de uma linha só que repete o título antes do conteúdo real começar.

**Problema:** A IA adiciona uma frase genérica logo depois do heading como aquecimento retórico. Não acrescenta nada e deixa o texto inchado.

**Antes:**
> ## Performance
>
> Velocidade importa.
>
> Quando os usuários acessam uma página lenta, eles saem.

**Depois:**
> ## Performance
>
> Quando os usuários acessam uma página lenta, eles saem.

---

## PADRÕES DE REDE SOCIAL

### 37. Título-hook standalone

**Regra:** o texto NUNCA pode começar com uma frase curta solta, separada do resto por quebra de parágrafo, com função de chamar o leitor pra continuar. Sempre abrir com parágrafo, mesmo que curto. Se a primeira linha for standalone-impactante, juntar com o próximo parágrafo ou cortar.

**Sinais (estruturais, não lexicais):**

- Primeira linha do texto é uma única frase
- Separada do resto por linha em branco (parágrafo próprio)
- Função clara de hook/isca: existe pra puxar o leitor, não pra entregar conteúdo
- Frequentemente curta (5-15 palavras), sentenciosa, com ar de "verdade" ou provocação

**Problema:** A IA imita copywriting batido de LinkedIn, Twitter e Instagram, onde virou fórmula começar com frase-isca pra forçar leitura. Em texto sério (post, ensaio, artigo, e-mail), entrega imediatamente que o autor está performando engajamento em vez de comunicar. Mesmo quando o conteúdo do hook é razoável, a estrutura standalone é o que delata.

**Atenção:** o problema não é o conteúdo da frase, é o formato. A mesma frase pode funcionar bem se for primeira linha de um parágrafo que continua imediatamente. O alvo é especificamente a frase isolada por quebra de parágrafo no início.

**Antes:**
> Pare de fazer reuniões sem agenda.
>
> No último mês, eu medi quanto tempo a equipe passa em reuniões e o resultado me assustou. 40% das nossas reuniões não tinham agenda escrita. Dessas, metade não tinha decisão registrada no fim.

**Depois:**
> No último mês, eu medi quanto tempo a equipe passa em reuniões e o resultado me assustou. 40% das nossas reuniões não tinham agenda escrita. Dessas, metade não tinha decisão registrada no fim. A conclusão óbvia: parar de marcar reuniões sem agenda.

**Antes:**
> A maioria das pessoas erra essa parte.
>
> Quando você desenha um sistema distribuído, a primeira decisão importante não é qual banco usar. É como você vai lidar com falhas parciais.

**Depois:**
> Quando você desenha um sistema distribuído, a primeira decisão importante não é qual banco usar. É como você vai lidar com falhas parciais. A maioria das pessoas erra essa parte e descobre tarde, em produção.

**Antes (mesmo conteúdo, formato OK):**
> Pare de fazer reuniões sem agenda. No último mês, eu medi quanto tempo a equipe passa em reuniões e o resultado me assustou.

(Aqui a frase de impacto vira início de parágrafo de verdade. Não é hook standalone, é abertura legítima.)

**Como aplicar na revisão:** se a primeira linha do texto for uma frase solta antes de um `\n\n`, ou (a) juntar com o parágrafo seguinte usando ponto final ou vírgula, ou (b) movê-la pro fim do primeiro parágrafo como conclusão, ou (c) remover se for puramente decorativa.

---

## Processo

1. Ler o texto de entrada com atenção
2. Identificar o registro (ou perguntar se ambíguo)
3. Identificar todas as ocorrências dos 37 padrões
4. Reescrever cada trecho problemático
5. Garantir que o texto revisado:
   - Soa natural quando lido em voz alta
   - Varia a estrutura das frases
   - Usa detalhes específicos em vez de alegações vagas
   - Mantém o registro apropriado ao contexto
   - Usa construções simples ("é"/"são"/"tem") quando apropriado
6. Apresentar uma versão humanizada em rascunho
7. Perguntar: "O que torna o texto abaixo tão obviamente gerado por IA?"
8. Responder brevemente com os sinais remanescentes (se houver)
9. Perguntar: "Agora, faça com que não pareça gerado por IA."
10. Apresentar a versão final (revisada após a auditoria)

## Formato de saída

Fornecer, nesta ordem:

1. Rascunho da reescrita
2. "O que torna o texto abaixo tão obviamente gerado por IA?" (tópicos breves)
3. Reescrita final
4. Resumo breve das mudanças feitas (opcional, se útil)

---

## Exemplo completo

**Antes (cara de IA):**

> Ótima pergunta! Aqui está um ensaio sobre este tópico. Espero que isso ajude!
>
> A programação assistida por IA serve como um testemunho duradouro do potencial transformador dos grandes modelos de linguagem, marcando um momento fundamental na evolução do desenvolvimento de software. No cenário tecnológico em rápida evolução de hoje, essas ferramentas revolucionárias — aninhadas na interseção entre pesquisa e prática — estão remodelando como engenheiros ideiam, iteram e entregam, ressaltando seu papel vital nos fluxos de trabalho modernos.
>
> Em sua essência, a proposta de valor é clara: otimizar processos, aprimorar a colaboração e fomentar o alinhamento. Não se trata apenas de autocompletar; trata-se de liberar a criatividade em escala, garantindo que as organizações possam permanecer ágeis enquanto entregam experiências fluidas, intuitivas e poderosas aos usuários. A ferramenta serve como catalisador. O assistente funciona como parceiro. O sistema se apresenta como base para a inovação.
>
> Observadores do setor notaram que a adoção acelerou de experimentos de entusiastas a implementações corporativas, de desenvolvedores solo a equipes multifuncionais. A tecnologia foi destaque na Folha de S.Paulo, no TechTudo e no Canaltech. Além disso, observa-se que a capacidade de gerar documentação, testes e refatorações evidencia como a IA pode contribuir para melhores resultados, destacando a intrincada interação entre automação e julgamento humano.
>
> - 💡 **Velocidade:** A geração de código é significativamente mais rápida, reduzindo atrito e capacitando desenvolvedores.
> - 🚀 **Qualidade:** A qualidade do output foi aprimorada por meio de treinamento melhorado, contribuindo para padrões mais elevados.
> - ✅ **Adoção:** O uso continua crescendo, refletindo tendências mais amplas do setor.
>
> Embora detalhes específicos sejam limitados com base nas informações disponíveis, poder-se-ia potencialmente argumentar que essas ferramentas possivelmente têm algum efeito positivo. Apesar dos desafios típicos de tecnologias emergentes — incluindo alucinações, viés e responsabilização — o ecossistema continua prosperando. A fim de realizar plenamente esse potencial, as equipes precisam se alinhar às melhores práticas.
>
> Em conclusão, o futuro parece brilhante. Tempos empolgantes estão por vir enquanto continuamos essa jornada rumo à excelência. Me avise se gostaria que eu expandisse alguma seção!

**Rascunho da reescrita:**

> Assistentes de código com IA aceleram algumas tarefas. Num estudo de 2024 do Google, desenvolvedores usando o Codex completaram funções simples 55% mais rápido que o grupo de controle, mas não mostraram melhora em depuração ou decisões arquiteturais.
>
> As ferramentas são boas em boilerplate: arquivos de configuração, scaffolding de testes, refatorações repetitivas. São ruins em saber quando estão erradas. Eu já aceitei sugestões em massa que compilaram, passaram no lint e mesmo assim faziam a coisa errada, porque eu parei de prestar atenção.
>
> A Mira, engenheira numa fintech que eu entrevistei, disse que usa o Copilot "como autocomplete pra código chato" mas revisa cada linha antes de commitar. O Jake, dev sênior numa empresa maior, desabilitou depois que ficava sugerindo padrões de uma biblioteca interna depreciada.
>
> As alegações de produtividade são difíceis de verificar. O GitHub diz que usuários do Copilot "aceitam 30% das sugestões", mas aceitação não é correção, e correção não é valor. O estudo da Uplevel de 2024 não encontrou diferença estatisticamente significativa na taxa de pull requests entre equipes com e sem assistentes de IA.
>
> Nada disso quer dizer que as ferramentas são inúteis. Quer dizer que são ferramentas. Não substituem julgamento e não eliminam a necessidade de testes. Se você não tem testes, não dá pra saber se a sugestão tá certa.

**O que torna o texto abaixo tão obviamente gerado por IA?**

- O ritmo ainda é arrumado demais (contrastes limpos, parágrafos com andamento uniforme).
- Os nomes e citações de estudos podem parecer placeholders plausíveis-mas-inventados se não forem reais e com fonte.
- O fechamento tem um toque de slogan ("Se você não tem testes...") em vez de soar como uma pessoa falando.

**Agora, faça com que não pareça gerado por IA.**

> Assistentes de código com IA podem te deixar mais rápido nas partes chatas. Não em tudo. Definitivamente não em arquitetura.
>
> São ótimos em boilerplate: configs, scaffolding de testes, refatorações repetitivas. Também são ótimos em parecer certos estando errados. Já aceitei sugestões que compilaram, passaram no lint e ainda assim erraram o ponto, porque eu parei de prestar atenção.
>
> As pessoas com quem converso tendem a cair em dois campos. Uns usam como autocomplete pra tarefas chatas e revisam cada linha. Outros desabilitam depois que fica sugerindo padrões que eles não querem. Os dois parecem razoáveis.
>
> As métricas de produtividade são escorregadias. O GitHub pode dizer que usuários do Copilot "aceitam 30% das sugestões", mas aceitação não é correção, e correção não é valor. Se você não tem testes, tá basicamente chutando.

**Mudanças feitas:**

- Removidos artefatos de chatbot ("Ótima pergunta!", "Espero que isso ajude!", "Me avise se...")
- Removida inflação de importância ("testemunho", "momento fundamental", "cenário em evolução", "papel vital")
- Removida linguagem promocional ("revolucionárias", "aninhadas", "fluidas, intuitivas e poderosas")
- Removidas atribuições vagas ("Observadores do setor")
- Removidas frases superficiais com gerúndio ("ressaltando", "destacando", "refletindo", "contribuindo para")
- Removida construção impessoal com "-se" ("observa-se que")
- Removido paralelismo negativo ("Não se trata apenas de X; trata-se de Y")
- Removidos padrões de regra de três e rodízio de sinônimos ("catalisador/parceiro/base")
- Removidas faixas falsas ("de X a Y, de A a B")
- Removidos travessões em excesso, emojis, cabeçalhos em negrito e aspas tipográficas
- Removidos verbos inflados ("serve como", "funciona como", "se apresenta como") em favor de "é"/"são"
- Removida seção formulaica de desafios ("Apesar dos desafios... continua prosperando")
- Removida atenuação de data de corte ("Embora detalhes específicos sejam limitados...")
- Removida mesóclise artificial ("poder-se-ia")
- Removida atenuação excessiva ("potencialmente... possivelmente")
- Removidas frases de preenchimento ("A fim de", "Em sua essência")
- Removida conclusão genérica positiva ("o futuro parece brilhante", "tempos empolgantes")
- Voz mais pessoal e menos "montada" (ritmo variado, menos placeholders)

---

## Referência e créditos

Esta skill é parte do marketplace [aj-openworkspace](https://github.com/ajunges/aj-openworkspace), autoria de André Junges.

Base conceitual: [Wikipedia: Signs of AI writing](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing), mantido pelo WikiProject AI Cleanup. Os padrões documentados lá vêm de observações de milhares de instâncias de texto gerado por IA na Wikipédia.

Influências diretas:

- **[blader/humanizer](https://github.com/blader/humanizer)** (MIT) — skill original em inglês (v2.5.1). Forneceu a estrutura geral, os padrões 1-13, 21-32 e 34-36, além da seção "Personality and Soul" e da mecânica da passada final anti-IA.
- **[Argentoni/humanizador](https://github.com/Argentoni/humanizador)** (MIT) — primeira adaptação para pt-BR (v2.2.0). Forneceu a base de tradução dos padrões herdados e parte dos exemplos com referências brasileiras.

Adições próprias (v3.0.0):

- 7 padrões nativos do pt-BR (14-20): mesóclise artificial, conectivos conclusivos em excesso, advérbios em "-mente" empilhados, nominalização abstrata, construções impessoais com "-se", calcos sintáticos do inglês, conectivos de transição frios
- Substituição de "Hyphenated Word Pair Overuse" (não aplicável ao pt-BR) por "Jargão corporativo composto" (patologia equivalente em pt-BR)
- Calibração de registro (referencial / corporativo / pessoal / acadêmico)
- Exemplos em duas variantes (neutro e corporativo) para padrões sensíveis a registro
- Expansão do vocabulário IA em pt-BR (padrão 7), das frases de preenchimento (30) e dos tropes de autoridade (34)

Adições da v3.1.0:

- Padrão 37 (rede social): título-hook standalone. Regra estrutural contra primeira linha solta com função de isca. Aplica-se a posts de LinkedIn, Twitter, Instagram, blog e qualquer texto que tente imitar copywriting batido de engajamento.
- Endurecimento do padrão 21 (travessão): de "uso excessivo" para regra hard. Substituir TODO em-dash por vírgula, ponto, ponto-e-vírgula ou parênteses (exceto travessão de diálogo em ficção). Tabela de substituições por contexto.

Insight central da Wikipédia: "LLMs usam algoritmos estatísticos para adivinhar o que deveria vir a seguir. O resultado tende ao resultado estatisticamente mais provável que se aplica à maior variedade de casos."
