# Guia de Prompting do Claude

> Tradução em português de uma versão anterior do **Prompt Engineering Guide** oficial da Anthropic — foco em fundamentos de conversação (clareza, exemplos, CoT, role-playing, refinamento iterativo).
> Conteúdo original © Anthropic, PBC. Fonte canônica atualizada: [Prompting best practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) — guia único que agora consolida XML tags, long context, prefill migration, tool use, adaptive thinking, subagent orchestration e guidance específico para Claude Opus 4.7 / Sonnet 4.6 / Haiku 4.5.
> Tradução e manutenção: André Junges ([@ajunges](https://github.com/ajunges)).
> Ampliações futuras (notas próprias + seções novas do guia atual) terão marcação de autoria explícita quando adicionadas.

---

## Dicas gerais para prompting eficaz

### 1. Seja claro e específico
   - Declare claramente sua tarefa ou pergunta no início da mensagem.
   - Forneça contexto e detalhes para ajudar o Claude a entender suas necessidades.
   - Divida tarefas complexas em etapas menores e gerenciáveis.

   Prompt ruim:
   <prompt>
   "Me ajude com uma apresentação."
   </prompt>

   Prompt bom:
   <prompt>
   "Preciso de ajuda para criar uma apresentação de 10 slides para nossa reunião trimestral de vendas. A apresentação deve cobrir nosso desempenho de vendas do Q2, produtos mais vendidos e metas de vendas para o Q3. Por favor, forneça um outline com pontos-chave para cada slide."
   </prompt>

   Por que é melhor: O prompt bom fornece detalhes específicos sobre a tarefa, incluindo o número de slides, o propósito da apresentação e os tópicos principais a serem cobertos.

### 2. Use exemplos
   - Forneça exemplos do tipo de output que você está buscando.
   - Se deseja um formato ou estilo específico, mostre um exemplo ao Claude.

   Prompt ruim:
   <prompt>
   "Escreva um e-mail profissional."
   </prompt>

   Prompt bom:
   <prompt>
   "Preciso escrever um e-mail profissional para um cliente sobre um atraso no projeto. Aqui está um e-mail similar que enviei antes:

   'Prezado [Cliente],
   Espero que esteja bem. Gostaria de atualizá-lo sobre o andamento do [Nome do Projeto]. Infelizmente, encontramos um problema inesperado que atrasará nossa data de conclusão em aproximadamente duas semanas. Estamos trabalhando diligentemente para resolver isso e manteremos você atualizado sobre nosso progresso.
   Por favor, me avise se tiver alguma dúvida ou preocupação.
   Atenciosamente,
   [Seu Nome]'

   Me ajude a redigir um novo e-mail seguindo tom e estrutura similares, mas para nossa situação atual, onde estamos com um atraso de um mês devido a problemas na cadeia de suprimentos."
   </prompt>

   Por que é melhor: O prompt bom fornece um exemplo concreto do estilo e tom desejados, dando ao Claude um ponto de referência claro para o novo e-mail.

### 3. Incentive o raciocínio
   - Para tarefas complexas, peça ao Claude para "pensar passo a passo" ou "explicar seu raciocínio".
   - Isso pode levar a respostas mais precisas e detalhadas.

   Prompt ruim:
   <prompt>
   "Como posso melhorar a produtividade da equipe?"
   </prompt>

   Prompt bom:
   <prompt>
   "Estou buscando melhorar a produtividade da minha equipe. Pense nisso passo a passo, considerando os seguintes fatores:
   1. Bloqueadores de produtividade atuais (ex: reuniões demais, prioridades pouco claras)
   2. Soluções potenciais (ex: técnicas de gestão de tempo, ferramentas de gestão de projetos)
   3. Desafios de implementação
   4. Métodos para medir a melhoria

   Para cada etapa, forneça uma breve explicação do seu raciocínio. Depois, resuma suas ideias no final."
   </prompt>

   Por que é melhor: O prompt bom pede que o Claude pense no problema de forma sistemática, fornecendo uma estrutura guiada para a resposta e pedindo explicações do processo de raciocínio. Também solicita que o Claude crie um resumo ao final para facilitar a leitura.

### 4. Refinamento iterativo
   - Se a primeira resposta do Claude não estiver exata, peça esclarecimentos ou modificações.
   - Você sempre pode dizer "Está quase, mas pode ajustar X para ficar mais parecido com Y?"

   Prompt ruim:
   <prompt>
   "Melhore isso."
   </prompt>

   Prompt bom:
   <prompt>
   "É um bom começo, mas refine mais. Faça os seguintes ajustes:
   1. Torne o tom mais casual e amigável
   2. Adicione um exemplo específico de como nosso produto ajudou um cliente
   3. Encurte o segundo parágrafo para focar mais nos benefícios em vez das funcionalidades"
   </prompt>

   Por que é melhor: O prompt bom fornece feedback específico e instruções claras para melhorias, permitindo que o Claude faça ajustes direcionados em vez de depender apenas da noção inata do que "melhor" significaria — que provavelmente é diferente da definição do usuário!

### 5. Aproveite o conhecimento do Claude
   - O Claude possui conhecimento amplo em diversas áreas. Não hesite em pedir explicações ou informações de contexto.
   - Inclua contexto e detalhes relevantes para que a resposta do Claude seja direcionada ao máximo para ser útil.

   Prompt ruim:
   <prompt>
   "O que é marketing? Como faço?"
   </prompt>

   Prompt bom:
   <prompt>
   "Estou desenvolvendo uma estratégia de marketing para uma nova linha de produtos de limpeza ecológicos. Pode fornecer uma visão geral das tendências atuais em marketing verde? Por favor, inclua:
   1. Estratégias de messaging que ressoam com consumidores ambientalmente conscientes
   2. Canais eficazes para alcançar esse público
   3. Exemplos de campanhas de marketing verde bem-sucedidas do último ano
   4. Armadilhas potenciais a evitar (ex: acusações de greenwashing)

   Essas informações me ajudarão a moldar nossa abordagem de marketing."
   </prompt>

   Por que é melhor: O prompt bom pede informações específicas e contextualmente relevantes que aproveitam a ampla base de conhecimento do Claude. Fornece contexto sobre como a informação será usada, o que ajuda o Claude a enquadrar sua resposta da forma mais relevante possível.

### 6. Use role-playing
   - Peça ao Claude para adotar um papel ou perspectiva específica ao responder.

   Prompt ruim:
   <prompt>
   "Me ajude a preparar para uma negociação."
   </prompt>

   Prompt bom:
   <prompt>
   "Você é um fornecedor de tecidos para minha empresa de fabricação de mochilas. Estou me preparando para uma negociação com esse fornecedor para reduzir preços em 10%. Como fornecedor, por favor forneça:
   1. Três objeções potenciais ao nosso pedido de redução de preço
   2. Para cada objeção, sugira um contra-argumento da minha perspectiva
   3. Duas propostas alternativas que o fornecedor pode oferecer em vez de um corte direto no preço

   Depois, troque de papel e forneça conselhos sobre como eu, como comprador, posso abordar melhor essa negociação para alcançar nosso objetivo."
   </prompt>

   Por que é melhor: Esse prompt usa role-playing para explorar múltiplas perspectivas da negociação, proporcionando uma preparação mais abrangente. O role-playing também incentiva o Claude a adotar mais prontamente as nuances de perspectivas específicas, aumentando a inteligência e a performance da resposta.


## Dicas e exemplos por tipo de tarefa

### Criação de conteúdo

1. **Especifique seu público**
   - Diga ao Claude para quem o conteúdo é destinado.

   Prompt ruim:
   <prompt>
   "Escreva algo sobre cibersegurança."
   </prompt>

   Prompt bom:
   <prompt>
   "Preciso escrever um post de blog sobre boas práticas de cibersegurança para donos de pequenas empresas. O público não é muito técnico, então o conteúdo deve ser:
   1. Fácil de entender, evitando jargão técnico quando possível
   2. Prático, com dicas acionáveis que possam implementar rapidamente
   3. Envolvente e levemente bem-humorado para manter o interesse

   Por favor, forneça um outline para um post de 1.000 palavras cobrindo as 5 principais práticas de cibersegurança que esses empresários devem adotar."
   </prompt>

   Por que é melhor: O prompt bom especifica o público, o tom desejado e as características-chave do conteúdo, dando ao Claude diretrizes claras para criar um output apropriado e eficaz.

2. **Defina o tom e estilo**
   - Descreva o tom desejado.
   - Se você tem um guia de estilo, mencione os pontos principais.

   Prompt ruim:
   <prompt>
   "Escreva uma descrição de produto."
   </prompt>

   Prompt bom:
   <prompt>
   "Por favor, me ajude a escrever uma descrição de produto para nossa nova cadeira de escritório ergonômica. Use um tom profissional, mas envolvente. A voz da nossa marca é amigável, inovadora e preocupada com a saúde. A descrição deve:
   1. Destacar as principais funcionalidades ergonômicas da cadeira
   2. Explicar como essas funcionalidades beneficiam a saúde e produtividade do usuário
   3. Incluir uma breve menção aos materiais sustentáveis utilizados
   4. Terminar com um call-to-action incentivando os leitores a experimentar a cadeira

   Mire em cerca de 200 palavras."
   </prompt>

   Por que é melhor: Esse prompt fornece orientação clara sobre tom, estilo e elementos específicos a incluir na descrição do produto.

3. **Defina a estrutura do output**
   - Forneça um outline básico ou lista de pontos que deseja cobrir.

   Prompt ruim:
   <prompt>
   "Crie uma apresentação sobre os resultados da empresa."
   </prompt>

   Prompt bom:
   <prompt>
   "Preciso criar uma apresentação sobre nossos resultados do Q2. Estruture com as seguintes seções:
   1. Visão Geral
   2. Desempenho de Vendas
   3. Aquisição de Clientes
   4. Desafios
   5. Perspectivas para o Q3

   Para cada seção, sugira 3-4 pontos-chave a cobrir, com base em apresentações de negócios típicas. Também recomende um tipo de visualização de dados (ex: gráfico, chart) que seria eficaz para cada seção."
   </prompt>

   Por que é melhor: Esse prompt fornece uma estrutura clara e pede elementos específicos (pontos-chave e visualizações de dados) para cada seção.

### Resumo de documentos e Q&A

1. **Seja específico sobre o que deseja**
   - Peça um resumo de aspectos ou seções específicas do documento.
   - Formule suas perguntas de forma clara e direta.
   - Especifique que tipo de resumo (estrutura do output, tipo de conteúdo) você deseja.

2. **Use os nomes dos documentos**
   - Refira-se a documentos anexados pelo nome.

3. **Peça citações**
   - Solicite que o Claude cite partes específicas do documento em suas respostas.

Aqui está um exemplo que combina as três técnicas acima:

   Prompt ruim:
   <prompt>
   "Resuma esse relatório para mim."
   </prompt>

   Prompt bom:
   <prompt>
   "Anexei um relatório de pesquisa de mercado de 50 páginas chamado 'Tendências da Indústria Tech 2023'. Pode fornecer um resumo de 2 parágrafos focando em tendências de IA e machine learning? Depois, por favor, responda a estas perguntas:
   1. Quais são as 3 principais aplicações de IA em negócios este ano?
   2. Como o machine learning está impactando os papéis profissionais na indústria tech?
   3. Quais riscos ou desafios potenciais o relatório menciona sobre a adoção de IA?

   Por favor, cite seções específicas ou números de página ao responder essas perguntas."
   </prompt>

   Por que é melhor: Esse prompt especifica o foco exato do resumo, fornece perguntas específicas e pede citações, garantindo uma resposta mais direcionada e útil. Também indica a estrutura ideal do resumo, como limitar a resposta a 2 parágrafos.

### Análise de dados e visualização

1. **Especifique o formato desejado**
   - Descreva claramente o formato em que deseja os dados.

   Prompt ruim:
   <prompt>
   "Analise nossos dados de vendas."
   </prompt>

   Prompt bom:
   <prompt>
   "Anexei uma planilha chamada 'Dados de Vendas 2023'. Pode analisar esses dados e apresentar as principais descobertas no seguinte formato:

   1. Resumo Executivo (2-3 frases)

   2. Métricas-chave:
      - Total de vendas por trimestre
      - Categoria de produto com melhor desempenho
      - Região com maior crescimento

   3. Tendências:
      - Liste 3 tendências notáveis, cada uma com uma breve explicação

   4. Recomendações:
      - Forneça 3 recomendações baseadas em dados, cada uma com uma breve justificativa

   Após a análise, sugira três tipos de visualizações de dados que comunicariam eficazmente essas descobertas."
   </prompt>

   Por que é melhor: Esse prompt fornece uma estrutura clara para a análise, especifica métricas-chave para focar e pede recomendações e sugestões de visualização para formatação adicional.

### Brainstorming
 1. Use o Claude para gerar ideias pedindo uma lista de possibilidades ou alternativas.
     - Seja específico sobre quais tópicos deseja que o Claude aborde no brainstorming.

   Prompt ruim:
   <prompt>
   "Me dê algumas ideias de team building."
   </prompt>

   Prompt bom:
   <prompt>
   "Precisamos criar atividades de team building para nossa equipe remota de 20 pessoas. Pode me ajudar a fazer um brainstorm:
   1. Sugerindo 10 atividades virtuais de team building que promovam colaboração
   2. Para cada atividade, explique brevemente como ela promove trabalho em equipe
   3. Indique quais atividades são melhores para:
      a) Ice-breakers
      b) Melhorar a comunicação
      c) Habilidades de resolução de problemas
   4. Sugira uma opção de baixo custo e uma opção premium."
   </prompt>

   Por que é melhor: Esse prompt fornece parâmetros específicos para a sessão de brainstorming, incluindo número de ideias, tipo de atividades e categorização adicional, resultando em um output mais estruturado e útil.

2. Solicite respostas em formatos específicos como bullet points, listas numeradas ou tabelas para facilitar a leitura.

   Prompt ruim:
   <prompt>
   "Compare opções de software de gestão de projetos."
   </prompt>

   Prompt bom:
   <prompt>
   "Estamos considerando três opções diferentes de software de gestão de projetos: Asana, Trello e Microsoft Project. Pode compará-los em formato de tabela usando os seguintes critérios:
   1. Funcionalidades principais
   2. Facilidade de uso
   3. Escalabilidade
   4. Preços (inclua planos específicos se possível)
   5. Capacidades de integração
   6. Mais indicado para (ex: equipes pequenas, enterprise, setores específicos)"
   </prompt>

   Por que é melhor: Esse prompt solicita uma estrutura específica (tabela) para a comparação e fornece critérios claros, tornando a informação fácil de entender e aplicar.

## Troubleshooting, minimização de alucinações e maximização de performance

1. **Permita que o Claude reconheça incerteza**
   - Diga ao Claude que ele pode dizer que não sabe, caso realmente não saiba. Ex: "Se você não tiver certeza sobre algo, tudo bem admitir. Apenas diga que não sabe."

2. **Divida tarefas complexas**
   - Se uma tarefa parece grande demais e o Claude está pulando etapas ou não executando bem certas etapas, divida em etapas menores e trabalhe nelas com o Claude uma mensagem por vez.

3. **Inclua toda a informação contextual em novos pedidos**
   - O Claude não retém informações de conversas anteriores, então inclua todo o contexto necessário em cada nova conversa.

## Exemplos comparativos de prompts bons vs. ruins

Estes são mais exemplos que combinam múltiplas técnicas de prompting para mostrar a diferença gritante entre prompts ineficazes e altamente eficazes.

### Exemplo 1: Desenvolvimento de estratégia de marketing

Prompt ruim:
<prompt>
"Me ajude a criar uma estratégia de marketing."
</prompt>

Prompt bom:
<prompt>
"Como um consultor sênior de marketing, preciso da sua ajuda para desenvolver uma estratégia de marketing abrangente para nossa nova linha de acessórios ecológicos para smartphones. Nosso público-alvo são consumidores millennials e Gen Z ambientalmente conscientes. Por favor, forneça uma estratégia detalhada que inclua:

1. Análise de Mercado:
   - Tendências atuais em acessórios tech ecológicos
   - 2-3 concorrentes-chave e suas estratégias
   - Tamanho potencial do mercado e projeções de crescimento

2. Persona do Público-Alvo:
   - Descrição detalhada do nosso cliente ideal
   - Seus pain points e como nossos produtos os resolvem

3. Marketing Mix:
   - Produto: Funcionalidades-chave a destacar
   - Preço: Estratégia de pricing sugerida com justificativa
   - Praça: Canais de distribuição recomendados
   - Promoção:
     a) 5 canais de marketing para focar, com prós e contras de cada
     b) 3 ideias criativas de campanha para o lançamento

4. Estratégia de Conteúdo:
   - 5 temas de conteúdo que ressoariam com nosso público
   - Tipos de conteúdo sugeridos (ex: blog posts, vídeos, infográficos)

5. KPIs e Mensuração:
   - 5 métricas-chave para acompanhar
   - Ferramentas sugeridas para medir essas métricas

Por favor, apresente essa informação em formato estruturado com cabeçalhos e bullet points. Onde relevante, explique seu raciocínio ou forneça exemplos breves.

Após delinear a estratégia, identifique quaisquer desafios ou riscos potenciais dos quais devemos estar cientes e sugira estratégias de mitigação para cada um."
</prompt>

Por que é melhor: Esse prompt combina múltiplas técnicas, incluindo atribuição de papel, divisão específica de tarefas, solicitação de output estruturado, brainstorming (para ideias de campanha e temas de conteúdo) e pedidos de explicação. Fornece diretrizes claras enquanto permite espaço para a análise e criatividade do Claude.

### Exemplo 2: Análise de relatório financeiro

Prompt ruim:
<prompt>
"Analise esse relatório financeiro."
</prompt>

Prompt bom:
<prompt>
"Anexei o relatório financeiro do Q2 da nossa empresa, intitulado 'Q2_2023_Financial_Report.pdf'. Atue como um CFO experiente e analise este relatório, preparando um briefing para nosso conselho de administração. Por favor, estruture sua análise da seguinte forma:

1. Resumo Executivo (3-4 frases destacando pontos-chave)

2. Visão Geral de Desempenho Financeiro:
   a) Receita: Compare com o trimestre anterior e o mesmo trimestre do ano passado
   b) Margens de lucro: Bruta e Líquida, com explicações para quaisquer mudanças significativas
   c) Fluxo de caixa: Destaque preocupações ou desenvolvimentos positivos

3. Indicadores-Chave de Desempenho:
   - Liste nossos 5 principais KPIs e seu status atual (use formato de tabela)
   - Para cada KPI, forneça uma breve explicação de sua importância e quaisquer tendências notáveis

4. Análise por Segmento:
   - Desmembre o desempenho por nossos três principais segmentos de negócio
   - Identifique os segmentos com melhor e pior desempenho, com possíveis razões para sua performance

5. Revisão do Balanço Patrimonial:
   - Destaque quaisquer mudanças significativas em ativos, passivos ou patrimônio líquido
   - Calcule e interprete índices-chave (ex: índice de liquidez corrente, endividamento)

6. Declarações Prospectivas:
   - Com base nesses dados, forneça 3 previsões-chave para o Q3
   - Sugira 2-3 movimentos estratégicos que devemos considerar para melhorar nossa posição financeira

7. Avaliação de Riscos:
   - Identifique 3 riscos financeiros potenciais com base neste relatório
   - Proponha estratégias de mitigação para cada risco

8. Comparação com Pares:
   - Compare nosso desempenho com 2-3 concorrentes-chave (use dados publicamente disponíveis)
   - Destaque áreas onde estamos superando e áreas para melhoria

Por favor, use charts ou tabelas quando apropriado para visualizar dados. Para quaisquer suposições ou interpretações que fizer, declare-as claramente e forneça seu raciocínio.

Após completar a análise, gere 5 perguntas potenciais que membros do conselho podem fazer sobre este relatório, junto com respostas sugeridas.

Por fim, resuma toda essa análise em um único parágrafo que eu possa usar como declaração de abertura na reunião do conselho."
</prompt>

Por que é melhor: Esse prompt combina role-playing (como CFO), output estruturado, solicitações específicas de análise de dados, análise preditiva, avaliação de riscos, análise comparativa e até antecipa perguntas de follow-up. Fornece um framework claro enquanto incentiva análise profunda e pensamento estratégico.

---

## Fontes

Fonte canônica atual — substitui as subpáginas antigas (be-clear-and-direct, multishot-prompting, chain-of-thought, use-xml-tags, system-prompts, prefill-claudes-response, chain-prompts, long-context-tips):

- [Prompting best practices — Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)

Complementos oficiais:

- [Prompt engineering overview — Anthropic](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/overview)
- [Prompt engineering interactive tutorial — anthropics/prompt-eng-interactive-tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
- [Prompt engineering interactive tutorial (Google Sheets) — Anthropic](https://docs.google.com/spreadsheets/d/19jzLgRruG9kjUQNKtCg1ZjdD6l6weA6qRXG5zLIAhC8)

---

## Gap em relação ao guia oficial atual

Tópicos cobertos hoje na fonte canônica e **ausentes** nesta tradução — candidatos naturais para ampliação:

| Área | Tópicos |
| --- | --- |
| Fundamentos estruturais | XML tags (`<instructions>`, `<context>`, `<example>`, `<documents>`), long context prompting (documentos no topo, extração por quotes) |
| Controle de saída | Dizer o que fazer vs. o que não fazer, controle de verbosidade, LaTeX, migração de prefilled responses |
| Tool use | Instrução explícita para agir vs. sugerir, otimização de parallel tool calling |
| Thinking | Adaptive thinking, parâmetro `effort` (low/medium/high/xhigh/max), controle de overthinking |
| Sistemas agênticos | State tracking multi-context-window, subagent orchestration, research patterns, balanceamento autonomia/segurança, redução de hallucinations |
| Específico por modelo | Guidance para Claude Opus 4.7 (response length, tool triggering, literal instruction following, design defaults, code review harnesses) |
| Design e vision | Prompting para frontend design (evitar AI slop), crop tool para vision |
