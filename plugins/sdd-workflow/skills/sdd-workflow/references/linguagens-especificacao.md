# Linguagens e notações — EARS + BDD + TDD

Reference do plugin `sdd-workflow` (v1.0.0). Duas linguagens controladas (EARS pra requirements, BDD pra cenários de teste com dados específicos) e a notação canônica do ciclo TDD operam em camadas diferentes do fluxo, cada uma no que faz melhor.

> **Nota v1.0.0**: TDD canônico universal é a heurística H9 da Camada 1 — sempre ativa, todos os tipos, todos os tiers (incluindo arquivos não-código com refactor adaptado). Detalhe operacional consolidado aqui na seção 3. Ver `references/heuristicas.md` pra contexto da governança em 3 camadas.

## 1. EARS — Easy Approach to Requirements Syntax

**Origem**: Alistair Mavin, Rolls-Royce, 2009. 15+ anos de uso em sistemas críticos (aerospace, defesa). Em consideração pra integração no SDD canônico ([Spec Kit Issue #1356](https://github.com/github/spec-kit/issues/1356)).

**Quando usar**: Spec.Requirements (definir o que o sistema deve fazer/não fazer).

### 1.1 Os 5 padrões EARS

| Padrão | Keyword | Estrutura |
|---|---|---|
| Ubiquitous | (nenhuma) | `O <sujeito> deve <comportamento>` |
| State-driven | `Enquanto` | `Enquanto <estado>, o <sujeito> deve <comportamento>` |
| Event-driven | `Quando` | `Quando <evento>, o <sujeito> deve <comportamento>` |
| Optional Feature | `Onde` | `Onde <feature presente>, o <sujeito> deve <comportamento>` |
| Unwanted Behavior | `Se / então não` | `Se <condição>, então o <sujeito> não deve <comportamento>` |
| Complex | combinação | `Enquanto X, quando Y, o <sujeito> deve Z` |

### 1.2 Exemplos

```ears
Ubiquitous:
  O sistema deve operar em pt-BR para textos de UI.

State-driven:
  Enquanto não houver sessão autenticada, o sistema deve redirecionar para /login.

Event-driven:
  Quando um pedido for fechado com valor maior que R$ 1000, o sistema deve aplicar
  desconto progressivo de 5% sobre o valor excedente.

Optional Feature:
  Onde o módulo de exportação estiver habilitado, o sistema deve oferecer botão
  "Exportar XLSX" na tela de relatórios.

Unwanted Behavior:
  Se o token JWT estiver expirado, então o sistema não deve processar a requisição
  e deve retornar HTTP 401.

Complex:
  Enquanto o usuário tiver perfil "admin", quando ele clicar em "Promover Tier",
  o sistema deve abrir o sub-fluxo de promoção registrando a ação no histórico.
```

### 1.3 Vantagens vs prosa

- Reduz ambiguidade drasticamente (linguagem controlada com gramática rígida)
- LLMs parseiam confiavelmente (sintaxe regular)
- Curva de aprendizado mínima (5-6 keywords)
- Validação humana fica trivial (cada requirement é uma frase verificável)

### 1.4 Anti-patterns EARS

- Misturar 2 padrões na mesma frase sem usar "Complex" (vira frase ambígua)
- Usar "deve" + "deveria" + "precisa" como sinônimos (escolher um e padronizar — recomendo `deve`)
- Sujeito implícito ("aplica desconto" sem dizer "o sistema deve aplicar") — sempre ser explícito

---

## 2. BDD — Behavior-Driven Development (Given-When-Then / Gherkin)

**Origem**: Dan North, ~2006. Mainstream em testing há quase 20 anos.

**Quando usar**: Build.Tasks [H1] (cenários de teste com dados específicos), e Ship.Audit dimensão 8 (Lógica de negócio).

### 2.1 Estrutura

- **Given** — estado do mundo antes do comportamento
- **When** — comportamento sendo especificado
- **Then** — mudanças esperadas
- **And** — condições adicionais em qualquer dos blocos acima

### 2.2 Exemplo (Build.Tasks [H1] — validação contra dados reais)

```gherkin
Cenário: Cálculo bate com planilha de referência (fevereiro 2026)
  Dado os dados reais da planilha "pedidos-fev-2026.xlsx"
  Quando recalculo total com a nova regra de desconto progressivo
  Então cada linha bate com a coluna "Total Final" da planilha
  E a soma total bate com a célula F999 da planilha
```

### 2.3 Por que BDD aqui em vez de EARS

EARS é otimizado pra requirements (o que o sistema deve fazer). Given-When-Then é otimizado pra cenários de teste executáveis com dados específicos. **Complementares**, não competem.

### 2.4 Anti-patterns BDD

- Cenários longos (>5 steps) — quebrar em cenários menores
- Abstração demais ("Dado um usuário válido" — qual usuário?) — usar dados reais específicos
- "Then" sem dados verificáveis ("Então funciona corretamente") — sempre asserção concreta

---

## 3. TDD — ciclo canônico Red/Green/Refactor

**Quando usar**: Build.Implementation (heurística H9 — TDD canônico universal). Notação compacta do ciclo:

```
write test → run (FAIL) → implement → run (PASS) → REFACTOR (improve design, run tests, mantém PASS) → commit
```

### 3.1 Etapas

| Etapa | O que acontece |
|---|---|
| **write test** | Escrever teste cobrindo o comportamento desejado |
| **run (FAIL)** | Executar — deve falhar (Red). Confirma que o teste cobre algo que ainda não existe |
| **implement** | Implementar o mínimo de código pra fazer o teste passar |
| **run (PASS)** | Executar — deve passar (Green) |
| **REFACTOR** | Melhorar design (nomes, duplicação, estrutura) mantendo todos os testes passando. **Pode ser noop conscientemente declarado** — nunca pulado silenciosamente |
| **commit** | Commit atômico (1 commit = 1 ciclo completo) |

### 3.2 Refactor pra arquivos não-código

Markdown, JSON, YAML — Refactor adapta semântica:

- **Markdown**: melhorar headings, linkagem, eliminar repetição, consolidar seções relacionadas
- **JSON/YAML**: ordenar chaves por convenção do schema, remover redundância, agrupar relacionados

Mesma regra: refactor só roda **depois** do PASS, e não pode quebrar a forma vigente.

### 3.3 Anti-patterns TDD

- Pular Red (escrever teste já passando) — perde a confirmação de que o teste detecta a ausência do comportamento
- Pular Refactor (commit no Green) — acumula débito que vira refactor caro depois
- Refactor que muda comportamento — refactor é só design; mudança de comportamento exige novo ciclo

---

## 4. GEARS — possível evolução pra v4.0 (não adotado em v3.0)

**GEARS (Generalized EARS)** foi publicado em janeiro/2026 como extensão do EARS otimizada pra IA. Promete unificar specs e tests numa sintaxe só (substituindo a separação EARS+BDD adotada aqui).

**Decisão atual (v3.0)**: não adotar. GEARS é muito novo (3 meses), pouca tração comprovada, pode mudar de forma. EARS e BDD são maduros e LLMs modernos parseiam ambos sem dificuldade.

GEARS fica no radar pra revisão na v4.0 (6-12 meses), quando tiver sinais de adoção mainstream e o Spec Kit eventualmente posicionar-se sobre o tema.

---

## 5. Fontes

- [Alistair Mavin — EARS](https://alistairmavin.com/ears/)
- [Jama Software — Adopting EARS](https://www.jamasoftware.com/requirements-management-guide/writing-requirements/adopting-the-ears-notation-to-improve-requirements-engineering/)
- [Cucumber — History of BDD](https://cucumber.io/docs/bdd/history/)
- [Martin Fowler — Given When Then](https://martinfowler.com/bliki/GivenWhenThen.html)
- [Kent Beck — Test-Driven Development: By Example](https://www.oreilly.com/library/view/test-driven-development/0321146530/)
- [Martin Fowler — Refactoring](https://martinfowler.com/books/refactoring.html)
- [GEARS — DEV Community](https://dev.to/sublang/gears-the-spec-syntax-that-makes-ai-coding-actually-work-4f3f)
