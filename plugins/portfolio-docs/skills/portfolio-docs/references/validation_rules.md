# Validation Rules — portfolio-docs

Regras de validação de coerência que a skill executa antes de entregar o dossiê. Uma falha = bloqueio de delivery até remediação.

---

## Validation 1 — Product Coherence

**O que verifica:** todas as seções se referem ao mesmo produto descrito na Camada 0.

**Motivação:** a classic failure mode é um dossiê novo que herda objeções, battlecards ou proof points de um template anterior — as seções passam por revisão humana superficial sem detecção. Exemplo típico: objeções de um produto de FinOps aparecerem em um dossiê de produto de IA generativa. Erros desse tipo destroem credibilidade em call.

**Checks:**

### 1.1 Objeções referenciam produto correto
- Cada objeção em 5.6 deve citar ou referenciar elementos do produto descrito em 0
- Se objeção menciona concorrente, concorrente deve estar em 2.5 ou ser justificado como adjacente

### 1.2 Battlecards são consistentes com landscape
- Todo concorrente com battlecard em 2.6 deve estar listado em 2.5
- Concorrente Tier A em 2.5 deveria ter battlecard em 2.6 (warning se ausente)

### 1.3 Keywords alinham com posicionamento
- Keywords em 6.3 devem incluir a categoria declarada em 0 ou 2.1
- Keywords totalmente desconectadas do posicionamento = warning

### 1.4 Pitch referencia produto correto
- Pitch em 5.5 (as 3 versões) deve mencionar o nome oficial do produto (Camada 0)
- Pitch que usa nome diferente ou genérico = fail

### 1.5 Proof points são coerentes
- Cases em 5.7 devem estar conectados ao setor/ICP declarado em 2.2
- Case fora do ICP = warning (pode ser outlier legítimo, mas merece flag)

**Remediação:** bloquear delivery, apontar seções inconsistentes ao usuário, solicitar correção ou confirmação de que é intencional.

---

## Validation 2 — Completeness

**O que verifica:** todas as camadas obrigatórias estão preenchidas; camadas progressivas estão ou preenchidas ou explicitamente marcadas como não aplicáveis.

**Checks:**

### 2.1 Camadas obrigatórias (0, 1, 2, 3, 4, 5)
- Todas as subseções marcadas como obrigatórias em `layer_specs.md` devem ter conteúdo (não só título)
- Campos `[PENDENTE — ...]` são aceitos, mas limitados a 20% dos campos obrigatórios — acima disso, dossiê é considerado draft, não publicável

### 2.2 Camadas progressivas (6, 7, 8, 9, 10)
- Se vazia, deve ter marcação explícita: `Não aplicável — {motivo}` ou `Pendente — previsto para {data}`
- Camada vazia sem justificativa = fail

### 2.3 Moore completo
- Todas as 8 linhas da tabela 2.1 preenchidas (sem "-" ou vazias)
- Moore parcial = fail (regra especial)

### 2.4 Pitch literal
- 5.5 deve ter texto literal entre aspas, não descrição
- Descrição de pitch ("abrir com dor, mostrar solução...") = fail

### 2.5 Objection handling mínimo
- 5.6 deve ter mínimo 5 objeções com Resposta + Proof + Fecho
- Menos de 5 = warning; menos de 3 = fail

**Remediação:** listar gaps ao usuário, sugerir preenchimento ou marcação explícita de não aplicabilidade.

---

## Validation 3 — Numerical Consistency

**O que verifica:** números iguais em lugares diferentes são de fato iguais. Previne erros de cópia/atualização parcial.

**Checks:**

### 3.1 Preços consistentes
- Preços em 2.1 (Moore, linha "É um") devem bater com tabela em 4.3
- Se Moore diz "a partir de R$X", tabela em 4.3 deve ter R$X como entry point
- Divergência = fail

### 3.2 Metas consistentes
- Meta de revenue em 7.2 deve bater com pipeline sizing implícito em 4 (se houver)
- ACV médio em 7.1 deve bater com range de preço em 4.3
- Divergência = warning (pode haver contexto)

### 3.3 Volumes de clientes
- Se 5.7 cita "10 clientes pagantes" e 0 diz "estágio beta" (tipicamente <5 clientes), há tensão
- Se 7.1 diz "n=12 deals" e 5.7 lista 3 cases, deveria haver 9 cases não autorizados em proof points qualitativos
- Inconsistências = warning

### 3.4 Timeline coerente
- Data de início do produto (0) não pode ser posterior a data do primeiro case (5.7)
- Marcos futuros (1) não podem conflitar com roadmap (3.4)
- Divergência = fail

**Remediação:** apontar divergência, solicitar qual número é o correto, atualizar todos os locais.

---

## Validation 4 — Freshness

**O que verifica:** o dossiê não está estagnado.

**Checks:**

### 4.1 Última atualização
- Campo `Última atualização` no header
- Se >6 meses = warning (flag no relatório de entrega)
- Se >12 meses = fail (dossiê considerado stale, bloquear publicação sem refresh)

### 4.2 Última revisão de coerência
- Campo `Última revisão de coerência` no header
- Se >3 meses desde última revisão = warning
- Atualizar sempre que validações passam

### 4.3 Datas em campos críticos
- Métricas em 7.1 devem ter data de referência (ex: "CAC: R$ 45K (Jan-Mar/2026)")
- Métricas sem data = warning
- Metas em 7.2 devem ter horizonte explícito

### 4.4 Próximos marcos
- Se próximos marcos em 1 (Sumário Universal) estão todos no passado, dossiê está desatualizado
- Marcos passados sem status ("concluído" / "atrasado" / "cancelado") = warning

**Remediação:** notificar usuário sobre staleness, sugerir agenda de review.

---

## Validation 5 — Structural Integrity (invisível ao usuário)

**O que verifica:** o arquivo tem a estrutura esperada. Usado para validar tecnicamente antes das validações semânticas acima.

**Checks:**
- Header presente com todos os campos
- 11 headers de Camada (0 a 10)
- Controle de Versão table presente e atualizada na rodada
- Tabelas obrigatórias (Moore, RACI, ICP) presentes em formato parseável
- Markdown válido (cabeçalhos, listas, tabelas bem formadas)

**Remediação:** erro técnico — refazer estrutura antes de validações semânticas.

---

## Execução das Validações

### Sequência
1. Validation 5 (structural) — se fail, bloquear imediatamente
2. Validation 2 (completeness) — identifica gaps antes de analisar coerência
3. Validation 1 (product coherence) — validação mais importante semanticamente
4. Validation 3 (numerical) — pega erros de atualização parcial
5. Validation 4 (freshness) — último, não bloqueia, só alerta

### Relatório de Validação

Ao final, a skill apresenta um bloco:

```
=== VALIDATION REPORT ===
Structural: PASS
Completeness: PASS (2 warnings)
  - Layer 6 marked "Não aplicável" without reason statement
  - Layer 7.3 KPIs Operacionais empty
Product Coherence: PASS
Numerical Consistency: FAIL
  - Price in Moore (2.1) = "R$ 140K entry"
  - Price in Pricing Table (4.3) = "R$ 198K Standard Tier"
  - Resolve before publishing
Freshness: PASS
========================
```

### Quando liberar vs bloquear

- **Fails críticas** (Product Coherence, Completeness of mandatory layers, Numerical FAIL): bloquear delivery até correção
- **Warnings**: incluir no relatório, permitir delivery, sinalizar ao owner
- **Passes com notas**: delivery OK, notas ficam no arquivo como comentário HTML invisível
