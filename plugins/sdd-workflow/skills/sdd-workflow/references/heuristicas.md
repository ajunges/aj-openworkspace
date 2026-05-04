# Heurísticas universais — Camada 1

Reference do plugin `sdd-workflow` (v1.0.0). Disciplinas de raciocínio que devem rodar antes de qualquer ação significativa. **Não dependem de tipo nem tier — sempre ativas.**

São 9 heurísticas. Não são "invioláveis" — cada uma admite exceção desde que registrada via H5 (Decisões registradas). O agente para e considera antes de agir; quando desvia, registra o porquê.

---

## H1. Dados reais sempre

Antes de simular, estimar ou inventar dados, busca dados reais (planilhas, exportações, datasets, documentos de referência fornecidos pelo usuário). Se não houver dados disponíveis, **declara explicitamente** "não há dados, isto é estimativa" — nunca apresenta inventado como real.

**Aplica em:** seed de banco, exemplos em requirements, casos de teste, demos, validações de regra de negócio.

**Anti-pattern:** gerar usuário "João Silva" quando o usuário tem planilha real com 200 nomes.

---

## H2. Reuso antes de construção

Antes de codar nova solução, busca biblioteca, skill, template ou padrão existente que resolva. Reinvenção precisa de justificativa registrada via H5.

**Origem:** Spec Kit Article IX (Library-Driven Development).

**Aplica em:** decisões de stack, escolha de componentes UI, lógica utilitária, integrações.

**Anti-pattern:** escrever wrapper customizado de auth quando Supabase Auth resolve; recriar tabelas + queries quando shadcn/ui tem componente pronto.

---

## H3. Simplicidade preferida

Começa com a solução mais simples que funciona. Adiciona complexidade só quando justificada por requisito real registrado.

**Origem:** Spec Kit Article VII (Simplicity Gate).

**Aplica em:** arquitetura, número de projetos, camadas de abstração, dependências.

**Anti-pattern:** monorepo de 5 pacotes pra projeto solo de uma página; microserviços pra MVP de 1k MAU; framework UI customizado quando Tailwind+shadcn resolve.

---

## H4. Anti-abstração prematura

Não extrai abstração antes de ver **3+ casos de uso concretos**. Duplicação é melhor que abstração errada.

**Origem:** Spec Kit Article VIII (Anti-Abstraction Gate).

**Aplica em:** funções utilitárias, componentes UI, classes base, interfaces.

**Anti-pattern:** criar `BaseEntity` na primeira tabela; extrair `useApiCall` hook pra primeira chamada de API; abstrair "tipo de pagamento" antes de ter o segundo gateway.

---

## H5. Decisões registradas

Toda decisão técnica significativa vira ADR (Architecture Decision Record) ou registro equivalente na constitution. **Inclui exceções a outras heurísticas** — quando desvia de H1-H9, H5 obriga registro com motivação.

**Mecanismo de exceção embutido**: H5 é o que torna as outras heurísticas flexíveis sem perder rigor.

**Formato mínimo:** data, contexto, decisão, alternativas consideradas, motivação.

**Aplica em:** stack, arquitetura, override de princípios da Camada 2, override de disciplinas da Camada 3.

---

## H6. Defensividade sobre dependências externas

API de terceiro pode mudar, falhar, deprecar. Codifica timeout, retry, fallback, degradação graciosa em toda integração externa.

**Aplica em:** chamadas a APIs (Stripe, Mercado Pago, Resend, OpenAI, etc.), MCP servers, CLIs externos, serviços de terceiros.

**Anti-pattern:** `await fetch(url)` sem timeout; assumir que webhook chegou; pressupor que CLI está instalado sem inventário formal.

---

## H7. Custo consciente

Antes de operação cara em tokens, latência ou custo financeiro, avalia se há caminho mais barato com qualidade aceitável. Aplica especialmente a fases longas, re-prompts, agentes paralelos, deep research.

Sub-divide em duas regras operacionais:

### H7.1 — Auto-execução quando barata = melhor

Se a opção mais barata também é a melhor opção em qualidade/tempo, **IA executa direto sem perguntar**. Não vira pergunta cerimonial.

**Pré-requisito:** avaliação explícita feita. Sem avaliar, não pode pular pra "mais barata".

**Exemplo:** entre invocar subagent vs ler arquivo direto, ler arquivo é mais barato e tem qualidade igual ou superior pra inspeção rápida — executa direto.

### H7.2 — Trade-offs pré-declarados

Usuário declara na constitution preferências de trade-off. IA respeita declaração sem perguntar caso a caso.

**Formato na constitution:**

```yaml
trade_offs:
  custo_vs_tempo: "aceito +20% tempo por -50% custo"
  custo_vs_qualidade: "preserva qualidade — não comprometer pra reduzir custo"
  custo_vs_velocidade_iteracao: "lento e barato em fase exploratória, rápido em produção"
```

Quando há conflito custo × outra dimensão, IA consulta o trade-off declarado.

---

## H8. Linguagem ubíqua

Termos do domínio são consistentes entre spec, código, docs, UI. Define glossário curto na Pré-spec.Discovery e mantém propagação até o código.

**Origem:** Princípio 8 atual + DDD (Domain-Driven Design).

**Aplica em:** nomes de entidades, ações de UI, mensagens de erro, identificadores em código.

**Anti-pattern:** "cliente" no spec, "user" no código, "conta" na UI.

---

## H9. TDD canônico universal

Red → Green → Refactor → commit. Aplica universalmente, **incluindo arquivos não-código** (markdown, JSON, YAML com refactor adaptado).

### Etapas

| Etapa | O que acontece |
|---|---|
| write test | Escrever teste cobrindo o comportamento desejado |
| run (FAIL) | Executar — deve falhar (Red). Confirma que o teste cobre algo que ainda não existe |
| implement | Implementar o mínimo de código pra fazer o teste passar |
| run (PASS) | Executar — deve passar (Green) |
| REFACTOR | Melhorar design (nomes, duplicação, estrutura) mantendo todos os testes passando. **Pode ser noop conscientemente declarado** — nunca pulado silenciosamente |
| commit | Commit atômico (1 commit = 1 ciclo completo) |

### Refactor pra arquivos não-código

- **Markdown:** melhorar headings, linkagem, eliminar repetição, consolidar seções relacionadas
- **JSON/YAML:** ordenar chaves por convenção do schema, remover redundância, agrupar relacionados

Mesma regra: refactor só roda **depois** do PASS, e não pode quebrar a forma vigente.

### Anti-patterns

- Pular Red (escrever teste já passando) — perde a confirmação de que o teste detecta a ausência do comportamento
- Pular Refactor (commit no Green) — acumula débito que vira refactor caro depois
- Refactor que muda comportamento — refactor é só design; mudança de comportamento exige novo ciclo

Detalhe operacional completo, exemplos e fontes em `references/linguagens-especificacao.md` seção 3.

---

## Quando heurísticas conflitam

H5 resolve. Toda exceção a outra heurística é registrada como ADR — vira decisão consciente, não violação silenciosa.

**Exemplo:** dim H1 (dados reais sempre) vs LGPD em projeto que processa dados pessoais sensíveis. Resolução: ADR registra "uso dados sintéticos preservando estrutura por compliance LGPD; exceção a H1 documentada".

---

## Como heurísticas se relacionam com Camadas 2 e 3

- **Camada 1 (heurísticas):** sempre ativas, todos os tipos, todos os tiers
- **Camada 2 (princípios arquiteturais):** ativos em mvp+, informativos em tier 1-2, condicionados ao `tipo_projeto`
- **Camada 3 (disciplinas operacionais):** ativas conforme tier, cumulativas

As três camadas operam em conjunto. Heurísticas guiam o **como pensar**, princípios definem o **como construir** pra cada tipo, disciplinas definem o **rigor mínimo** pra cada tier.
