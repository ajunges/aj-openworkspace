# ACME Flow — Portfolio Dossier (Exemplo Fictício)

> **Este é um exemplo fictício.** Produto, clientes, pessoas e valores são inventados. Serve apenas para ilustrar como o template é preenchido — não como material comercial real.
> **Template:** portfolio-docs v1.0
> **Owner:** [Fulana da Silva, PM de Analytics]
> **Reviewer:** [Sicrano de Souza, CRO]
> **Última atualização:** 2026-04-17
> **Última revisão de coerência:** 2026-04-17
> **Estágio no portfólio:** beta
> **Classificação:** Exemplo público — não confidencial

---

## Controle de Versão

| Versão | Data | Editor | Tipo | Comentários |
|---|---|---|---|---|
| 0.1 | 2026-04-17 | Fulana da Silva | Criação | Primeira versão do dossiê gerada com portfolio-docs |

---

# CAMADA 0 — IDENTIDADE

- **Nome oficial:** ACME Flow
- **One-liner (1 frase, sem jargão):** Dashboard financeiro para empresas de serviço que precisam fechar o mês sem montar planilha manual.
- **Categoria:** Financial Operations Platform (FinOps para empresas de serviço)
- **Owner (PM):** Fulana da Silva, PM de Analytics
- **Executive sponsor:** Sicrano de Souza, CRO
- **Estágio no portfólio:** beta
- **Data de início do produto:** 2025-09

---

# CAMADA 1 — SUMÁRIO UNIVERSAL

## O que é
ACME Flow é uma plataforma SaaS que conecta ERPs e sistemas financeiros dispersos para consolidar fechamento mensal em um dashboard único. Foi construída para empresas de serviço de médio porte, onde a função financeira gasta 20+ horas por mês montando planilhas para virar relatório gerencial.

## Para quem é
Controllers e CFOs de empresas de serviço (consultoria, engenharia, agência) entre R$ 20M e R$ 200M de faturamento. Pessoas que abrem a planilha do mês anterior no dia 5 e gastam três dias ajustando números que deveriam já estar prontos.

## Dor que resolve
O fechamento do mês depende de 4-6 sistemas que não conversam, e a equipe de finanças vira um pipeline humano de cópia e cola. Erros acontecem, o relatório sai tarde, e a diretoria toma decisão com dado velho — ou pior, com dado errado.

## Como se diferencia
Somos a única plataforma que conecta ERPs brasileiros de médio porte (Omie, Conta Azul, Bling, Sankhya) nativamente, sem precisar de projeto de integração. Concorrentes exigem implementação de 3-6 meses.

## Como ganha dinheiro
Subscription anual. Tier Starter R$ 24K/ano (até 3 ERPs, 5 usuários), Tier Pro R$ 60K/ano (ilimitado).

## Status atual
Beta com 8 clientes pagantes. Primeiros contratos renovados em Mar/2026 (100% renew rate dos 3 elegíveis até agora).

## Próximos marcos
- GA público — 2026-06
- 25 clientes pagantes — 2026-09
- Integração Sankhya nativa — 2026-12

---

# CAMADA 2 — POSICIONAMENTO E MERCADO

## 2.1 Positioning Statement

| Dimensão | Descrição |
|---|---|
| **Para** | Controllers e CFOs de empresas de serviço brasileiras entre R$ 20M e R$ 200M de faturamento |
| **Que precisa** | Fechar o mês em até 3 dias úteis com dado confiável |
| **E quer** | Dormir tranquilo sabendo que o relatório da diretoria está certo |
| **O ACME Flow** | ACME Flow |
| **É um** | Dashboard de fechamento financeiro com integrações nativas aos principais ERPs brasileiros de médio porte |
| **Que** | Reduz tempo de fechamento de 3 semanas para 3 dias; elimina 80% da manipulação manual de planilha |
| **Ao contrário de** | Power BI + SQL sob medida (projeto de 6+ meses, dependência de TI) ou planilhas manuais (status quo lento e propenso a erro) |
| **Nosso produto** | Integra nativamente com Omie/Conta Azul/Bling/Sankhya sem projeto; onboarding em 2 semanas; dashboards prontos para empresa de serviço (CMV, margem por projeto, utilização) |

**Se a categoria é inventada, justificar:** "FinOps para empresas de serviço" não é categoria analista-reconhecida (IDC/Gartner não cobrem ainda). Escolhemos porque "BI", "ERP" e "Financial Reporting" descrevem categorias onde somos um subset e perderíamos o ângulo. Risco: prospects não procuram por "FinOps para serviço" no Google. Mitigação: keywords da Camada 6 cobrem dores diretas ("fechamento financeiro demorado", "consolidação de ERPs").

## 2.2 ICP — Ideal Customer Profile

### ICP Tier A — Enterprise (AM)
Não aplicável — produto em beta, sem AM dedicado. Tier A será ativado em GA (Jun/2026).

### ICP Tier B — Mid-market (Inside Sales)
- **Porte:** R$ 50M–R$ 200M de faturamento
- **Vertical:** Consultoria (estratégia, tecnologia, engenharia), agências de marketing digital, escritórios de advocacia mid-market
- **Geografia:** Brasil (SP, RJ, MG, PR, RS)
- **Maturidade digital:** Média — já tem ERP contratado, mas controller ainda monta relatório em Excel
- **Gatilhos:** Troca de CFO nos últimos 6 meses; auditoria anual puxando exigência de relatórios tempestivos; crescimento recente (>20% YoY) quebrando o processo manual antigo
- **Decisor:** CFO
- **Influenciadores:** Controller, Diretor Financeiro, eventualmente CEO

### ICP Tier C — SMB Canal
Não aplicável ainda — sem programa de canal estruturado.

### Anti-ICP
- Empresas de varejo ou indústria — nossa UX é otimizada para receita de serviço (horas, projetos, margens por pessoa), não para giro de estoque
- Empresas <R$ 10M — ACV fica abaixo do break-even operacional
- Empresas com SAP ou Oracle EBS — integração custa 5x mais que ROI para esse porte

## 2.3 Personas

| Persona | Cargo | Prioridades | Medos | Gatilhos de compra |
|---|---|---|---|---|
| Controller Caio | Controller Sênior | Fechar o mês no prazo; zerar erros; dar tempo de análise, não só apuração | Auditoria encontrar erro; ser apontado como gargalo; ter que explicar para o CFO por que o número mudou | Crescimento da empresa quebrou o processo; auditoria externa apontou controles fracos |
| CFO Cláudia | CFO | Confiança no número; previsibilidade; deixar equipe focar em análise | Apresentar número errado ao conselho; não ter visibilidade do mês corrente; perder controller bom por frustração com trabalho braçal | Troca de controle societário; preparação para captação ou M&A |

## 2.4 TAM / SAM / SOM
Não modelado ainda — previsto para Jul/2026 quando tivermos 15+ clientes pagantes para extrapolar ACV médio.

## 2.5 Competitive Landscape

| Tier | Concorrente | Tipo | Quando aparece | Como se diferenciam | Como vencemos |
|---|---|---|---|---|---|
| A — direto | Excel + BI sob medida (status quo) | DIY | Em todo deal, mesmo que não verbalizado | Zero custo explícito; controle total | Mostrar custo real (horas do controller × 12 meses + risco de erro) |
| A — direto | Power BI customizado | Incumbente | Empresas com TI próprio | Ferramenta conhecida; licença já paga | Projeto de implementação de 4-6 meses que nunca termina; nosso onboarding é 2 semanas |
| B — adjacente | Conta Azul / Omie (native reports) | ERP próprio | Quando cliente já usa um ERP | Já está contratado; reporte básico incluso | Falta consolidação multi-ERP; relatórios são do ERP, não do negócio; não cobre empresa com múltiplas operações |
| C — alternativa | Tactyo, Mindsight, outros nichados | Concorrente brasileiro emergente | Poucas vezes, mercado ainda incipiente | Alguns têm features específicas boas | Cobertura de ERPs brasileiros mais ampla; posicionamento explícito em empresa de serviço |

## 2.6 Battlecards

### Battlecard — Power BI customizado (Tier A)
- **Perfil:** Microsoft Power BI com camada de transformação (SQL, Dataflows) construída por consultoria ou TI interno.
- **Quando encontramos:** Empresas com TI próprio ou consultoria contratada; CFO defende internamente que "já pagamos".
- **Forças (3):** Ferramenta Microsoft conhecida; licença já inclusa no E3/E5; flexibilidade ilimitada.
- **Fraquezas (3):** Tempo de implementação (4-6 meses típico); dependência de TI para mudanças; nenhum connector pronto para ERPs brasileiros médios.
- **Nossa narrativa de 60s:** "Power BI é excelente se você tem 6 meses e uma equipe dedicada. Se o CFO precisa do relatório certo no dia 5 do mês que vem, a gente entrega em 2 semanas, com connector nativo para o seu ERP, e você mantém o Power BI para os dashboards estratégicos que não são fechamento. A comparação justa não é 'um ou outro', é 'o que cada um resolve melhor'."
- **Perguntas-armadilha:** "Quando o último dashboard de Power BI saiu do roadmap de TI para produção?" "Se a equipe de finanças precisa ajustar um cálculo amanhã, quantos dias leva?"
- **Objeções que eles plantam:** "Vocês são ferramenta especializada, Power BI resolve tudo" → Resolve, mas com custo de tempo e dependência de TI; posicionar como complementares, não competidores.

---

# CAMADAS 3-10

*Neste exemplo as Camadas 3-10 ficam omitidas para brevidade. Em um dossiê real seriam preenchidas seguindo o `template.md` — capability map, roadmap, canais, pricing policy, pitch literal em 3 versões, objection handling com mínimo 5 objeções, proof points, etc.*

**Exemplos de como marcariam se o produto ainda não tivesse conteúdo para elas:**

- **Camada 6 — Marketing:** Não aplicável — produto em beta, sem demand gen ativo. Previsão de ativação: Jul/2026 (pós-GA).
- **Camada 7 — Operação e Economics:** Pendente — baseline de unit economics em construção. Revisar em Out/2026 (após 6 meses em GA com ≥10 deals fechados).
- **Camada 10 — Instruções para AI:** Recomendada. Exemplo de entrada: "ACME Flow é FinOps para empresas de serviço — nunca posicionar como BI genérico nem como ERP. Categoria 'Financial Operations Platform' foi escolhida deliberadamente em 2026-02."

---

*Fim do exemplo. Este arquivo demonstra como o template é preenchido — para o template vazio original, veja `references/template.md`.*
