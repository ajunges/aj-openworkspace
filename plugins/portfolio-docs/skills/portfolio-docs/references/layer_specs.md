# Layer Specifications — portfolio-docs

Especificação detalhada de cada camada: propósito, público, obrigatoriedade, campos, regras de qualidade, anti-patterns.

---

## Camada 0 — Identidade

**Propósito:** resposta em 5 linhas para "o que é isso?". Serve como cabeçalho identificador do dossiê.

**Público:** todos.

**Obrigatória:** Sim.

**Campos:**
- Nome oficial
- One-liner (1 frase, sem jargão técnico)
- Categoria (de mercado reconhecida, ou inventada com justificativa em 2.1)
- Owner (PM)
- Executive sponsor
- Estágio no portfólio (idea / discovery / beta / GA / scale / mature / EOL)
- Data de início do produto

**Regras de qualidade:**
- One-liner deve ser compreensível por pessoa fora de TI/produto
- Categoria inventada sem justificativa em 2.1 = validation fail
- Estágio deve refletir realidade, não aspiração ("GA" só quando tem ≥3 clientes pagantes)

**Anti-patterns:**
- One-liner cheio de siglas: "Platform for AIOps with MLOps and DevSecOps in cloud-native K8s environments"
- "Owner: {nome da empresa}" — owner é pessoa, não empresa
- Estágio pulado ("beta → scale" sem passar por GA)

---

## Camada 1 — Sumário Universal

**Propósito:** explicar o produto em 1 página para qualquer pessoa da organização.

**Público:** novos colaboradores, RH, finanças, times de outros produtos, qualquer um que precisa entender o produto em 2 minutos.

**Obrigatória:** Sim.

**Campos:**
- O que é (2-3 frases)
- Para quem é (pintura, não ICP formal)
- Dor que resolve (o problema, não a solução)
- Como se diferencia (uma frase contestável e defensável)
- Como ganha dinheiro (modelo simplificado)
- Status atual (1-2 frases)
- Próximos marcos (3 marcos com prazo)

**Regras de qualidade:**
- Prosa dominante, não lista
- Zero sigla não explicada
- Deve caber em 1 página impressa A4 com margem normal
- "Diferencia-se" não pode ser bullshit genérico ("somos mais completos e seguros")

**Anti-patterns:**
- Feature list disfarçada de sumário
- Linguagem de marketing ("revolucionário", "disruptivo", "líder")
- Ausência de marcos ("em evolução constante" = não tem plano)

---

## Camada 2 — Posicionamento e Mercado

**Propósito:** onde competimos, para quem, e por que ganhamos.

**Público:** Comercial, Marketing, Liderança.

**Obrigatória:** Sim.

**Subseções obrigatórias:**
- 2.1 Positioning Statement (Moore) — 8 linhas completas
- 2.2 ICP (pelo menos um tier completo)
- 2.3 Personas (pelo menos 1 persona detalhada)
- 2.5 Competitive Landscape (pelo menos Tier A)
- 2.6 Battlecards (pelo menos 1 para Tier A direto)

**Subseções opcionais:**
- 2.4 TAM/SAM/SOM (quando modelado)
- Battlecards Tier B (quando relevante)

**Regras de qualidade:**
- Moore parcial é worse than useless — todas 8 linhas preenchidas ou marcar seção como incompleta
- Anti-ICP é obrigatório — listar quem NÃO vender
- Battlecard deve incluir "como vencemos", não só "o que eles fazem"

**Anti-patterns:**
- "Para empresas em geral" — nunca é verdade
- ICP sem gatilhos ("por que compram agora")
- Landscape sem tiering (alfabético = inútil)
- Battlecard sem perguntas-armadilha

---

## Camada 3 — Produto

**Propósito:** o que o produto faz e como é construído.

**Público:** Produto, Engenharia, Comercial, Pré-vendas.

**Obrigatória:** Sim.

**Subseções obrigatórias:**
- 3.1 Capability Map (agrupado por domínio)
- 3.2 Diferenciais Técnicos (com justificativa)
- 3.4 Roadmap Macro (horizontes)

**Subseções opcionais:**
- 3.3 Tiers (só quando há packaging formalizado)
- 3.5 Dependências Técnicas (recomendada)

**Regras de qualidade:**
- Capability map agrupado por domínio funcional, não lista solta
- Status honesto: GA / Beta / Roadmap. "Em desenvolvimento" é Roadmap.
- Diferenciais técnicos devem ter justificativa, não ser slogan

**Anti-patterns:**
- Feature list gigante sem hierarquia
- Tudo marcado como "GA" incluindo coisas que só funcionam em beta
- Roadmap com datas específicas (commitments públicos viram cobrança)
- Diferenciais genéricos ("é seguro", "é completo", "é rápido")

---

## Camada 4 — Go-to-Market

**Propósito:** como vendemos, por quais canais, a que preço.

**Público:** Comercial, Marketing, Operações, Finance.

**Obrigatória:** Sim.

**Subseções obrigatórias:**
- 4.1 Motion de Vendas
- 4.2 Canais
- 4.3 Pricing Oficial (mesmo que seja "sob consulta", documentar política)
- 4.6 Lifecycle Stage

**Subseções opcionais:**
- 4.4 Partner Strategy (só quando há programa)
- 4.5 Campaigns Ativas (só quando há campanhas ativas)

**Regras de qualidade:**
- Pricing deve ter discount policy mesmo que o preço seja sob consulta
- Se preço varia por deal, DOCUMENTAR A POLÍTICA — é o único jeito de evitar variação aleatória (ver exemplo em `validation_rules.md`, Validation 3.1)
- Motion deve ter justificativa, não só label

**Anti-patterns:**
- Pricing "sob consulta" sem política interna
- Canal "Partners" listado sem partner real
- Lifecycle "scale" quando o produto tem 3 clientes

---

## Camada 5 — Sales Enablement

**Propósito:** armas para o time comercial usar em campo.

**Público:** AEs, SDRs, Pré-vendas, CS.

**Obrigatória:** Sim.

**Subseções obrigatórias:**
- 5.1 Storytelling (Situação/Impacto/Resolução)
- 5.2 Buying Cycle (3 estágios)
- 5.3 SPIN (todas as 4 categorias)
- 5.4 MEDDPICC (todas as 8 letras)
- 5.5 Pitch em 3 versões (30s, 2min, 5min — textos literais)
- 5.6 Objection Handling (mínimo 5 objeções com resposta + proof + fecho)
- 5.7 Proof Points (mesmo que seja "nenhum case autorizado ainda")

**Regras de qualidade:**
- Pitch tem texto literal, não descrição. Se AE precisa improvisar, não está pronto.
- Objeções devem referir-se ao produto descrito na Camada 0 (validação crítica)
- Proof points com número exigem campo de autorização explícito

**Anti-patterns:**
- Storytelling genérico ("um cliente tinha o problema X")
- Pitch descrito em vez de escrito ("abrir com dor, mostrar solução, fechar com CTA")
- SPIN com perguntas de Situação que são quase todas de Problema
- Objeções copiadas de outro produto (classic copy-paste failure — ver Validation 1)

---

## Camada 6 — Marketing (progressiva)

**Propósito:** narrativa, assets, canais de demand gen.

**Público:** Marketing, Growth, Content.

**Obrigatória:** Não.

**Quando preencher:** produto em estágio GA ou posterior, com atividade de marketing real.

**Quando deixar vazia:** produto em discovery/beta — marcar "Marketing não ativo ainda — previsto para {data}".

**Regras de qualidade:**
- Messaging framework deve ter entrada por persona, não mensagem única
- Keywords devem ter intenção categorizada (informacional / comercial / compra)

---

## Camada 7 — Operação e Economics (progressiva)

**Propósito:** unit economics, metas, KPIs, responsabilidades.

**Público:** Liderança, Finance, CRO, PM.

**Obrigatória:** Não.

**Quando preencher:** produto com dados estáveis (tipicamente >6 meses em GA com ≥10 deals fechados).

**Quando deixar parcialmente vazia:** marcar "baseline em construção — revisar em {data}".

**Regras de qualidade:**
- Dados inventados são pior que dados ausentes — credibilidade do dossiê depende disso
- RACI deve ter decisor único na coluna Accountable

**Anti-patterns:**
- CAC calculado sem incluir custo de pré-vendas
- Payback calculado pós-fechamento, ignorando ciclo de venda
- "ARR projetado" como meta sem baseline

---

## Camada 8 — Riscos e Dívidas (recomendada)

**Propósito:** o que está aberto, o que dá medo, o que pode quebrar.

**Público:** Liderança, PM, CRO.

**Obrigatória:** Não, mas ausência sinaliza ingenuidade.

**Regras de qualidade:**
- Dívida sem dono = não é dívida, é wishful thinking
- Prazo obrigatório (mesmo que seja "TBD — decidir em {reunião}")
- Severidade deve ter critério (Crítica = trava escala; Alta = trava logos específicos; Média = reduz margem)

---

## Camada 9 — Referências e História (opcional)

**Propósito:** onde encontrar tudo. Decisões arquivadas evitam re-discussão.

**Público:** todos.

**Quando preencher:** quando há material disperso que precisa ser linkado.

---

## Camada 10 — Instruções para AI (recomendada)

**Propósito:** ensinar IAs a operar consistentemente sobre o produto.

**Público:** Claude Code, Claude.ai, agentes internos.

**Quando preencher:** sempre que a organização trabalha com IA intensivamente.

**Regras de qualidade:**
- Instruções devem ser específicas, não genéricas ("use português" não ajuda; "não usar '{termo descartado}' como headline — foi rejeitado pelo comitê de produto em {data}" ajuda)
- Terminologia correta e termos a evitar devem ter justificativa curta
- Referências cruzadas com outros dossiês usando nomes de arquivo exatos

---

## Campos Transversais (aparecem em todas as camadas quando aplicável)

### `[PENDENTE — {contexto}]`
Uso: campo obrigatório mas informação ainda não disponível.
Formato: `[PENDENTE — validar pricing oficial com {responsável} até {data}]`

### `[DIVERGÊNCIA: fonte A diz X; fonte B diz Y — validar com {owner}]`
Uso: em Mode B (Consolidação) quando fontes conflitam.
Nunca resolver silenciosamente.

### `Não aplicável — {motivo}`
Uso: camada progressiva que legitimamente não se aplica.
Formato: `Camada 6 — Não aplicável: produto em discovery, marketing não ativo. Previsão de ativação: Q3 2026.`

### Frescor
Toda métrica em Camada 7 deve ter data de referência.
Formato: `CAC: R$ 45K (base Jan-Mar/2026, n=12 deals)`
