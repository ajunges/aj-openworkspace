# Spec — sdd-workflow v1.0.0

Versão: 1.0.0 (major bump a partir de 0.2.4)
Data: 2026-05-03
Status: aprovado, em execução

## Objetivo

Refundar a estrutura de governança do plugin `sdd-workflow` substituindo "8 princípios invioláveis" por uma taxonomia de 3 camadas (heurísticas universais, princípios arquiteturais por tipo, disciplinas operacionais por tier) e atualizar a stack default `web-saas` baseada em pesquisa profunda de convergência de mercado para desenvolvimento solo dirigido por Claude Code em 2026.

## Motivação

Duas tensões acumuladas resolvidas em conjunto:

1. **Princípios invioláveis sem mecanismo de exceção.** A formulação "violação = STOP" é forte mas inflexível. Tensões reais entre princípios (dados reais sempre vs LGPD em dados pessoais) não têm protocolo. Reorganização em 3 camadas com H5 (Decisões registradas via ADR) embute o mecanismo de exceção.
2. **Stack default `web-saas` (Vite + Express + Prisma) está fora do consenso 2026 para desenvolvimento solo dirigido por Claude Code.** Convergência empírica forte aponta Next.js App Router + Supabase + Tailwind v4 + shadcn/ui CLI v4 + MCP. Mudança no momento certo evita migração tardia mais cara.

Empacotar as duas mudanças num único major bump v1.0.0 evita confusão de dois breaking changes em sequência para projetos em uso.

## Estrutura final consolidada

### Preâmbulo — premissa fundadora

> Este plugin parte da premissa de que **rigor escala pelo destino, não pelo estado atual**. Tier projetado captura essa premissa e ativa Camada 3 (Disciplinas Operacionais) proporcionalmente. Não é princípio inviolável — é a tese fundadora do plugin.

### Camada 1 — 9 Heurísticas universais (sempre ativas, todos os tipos, todos os tiers)

| # | Heurística | Origem |
|---|---|---|
| H1 | Dados reais sempre (com declaração explícita de estimativa quando não houver) | Princípio 1 atual |
| H2 | Reuso antes de construção | Spec Kit Article IX |
| H3 | Simplicidade preferida | Spec Kit Article VII |
| H4 | Anti-abstração prematura (3+ casos antes de abstrair) | Spec Kit Article VIII |
| H5 | Decisões registradas (toda decisão técnica vira ADR; mecanismo de exceção embutido) | Princípio 6 + ADR |
| H6 | Defensividade sobre dependências externas | Princípio 3 |
| H7.1 | Custo consciente — auto-execução quando barata = melhor opção | Adição usuário |
| H7.2 | Custo consciente — trade-offs pré-declarados na constitution | Adição usuário |
| H8 | Linguagem ubíqua | Princípio 8 + DDD |
| H9 | TDD canônico universal (incluindo markdown/JSON com refactor adaptado) | Princípio 5 atual |

### Não-heurísticas (campos da constitution ou mecânicas do plugin)

| Conceito | Onde fica |
|---|---|
| Tier projetado | Premissa fundadora (preâmbulo) + campo `tier:` na constitution |
| Gates | Campo configurável `gates: explicitos\|reduzidos\|minimos` (default `explicitos`) |
| Promoção de tier | Mecânica do `sdd-promote-tier` (preservada) |

### Camada 2 — Princípios arquiteturais por tipo (ativam em mvp+; informativos em tier 1-2)

**`claude-plugin`:** P-cp1 Library-First; P-cp2 CLI/Slash Mandate; P-cp3 SKILL.md como contrato; P-cp4 Versionamento explícito (tendo ou não marketplace-tools)

**`web-saas`:** P-ws1 Stack convencional preferida; P-ws2 Auth e billing terceirizados; P-ws3 Multi-tenancy desde dia 1 (RLS quando Supabase); P-ws4 Integration testing em fronteiras críticas

**`hubspot`:** P-hs1 UI Extensions seguem padrão; P-hs2 Serverless functions com timeout consciente; P-hs3 Dados sensíveis nunca em frontend; P-hs4 Workflow vs UI Extension vs Custom Object — escolha consciente

**`outro`:** P-ou1 Discovery obrigatório de tipo real; P-ou2 Princípios arquiteturais propostos pela IA validados pelo usuário; P-ou3 Promoção a tipo nomeado quando 2+ projetos similares

### Camada 3 — Disciplinas operacionais por tier (cumulativas)

| Tier | Disciplinas |
|---|---|
| 1 prototipo_descartavel | Nenhuma (Camada 1 + Camada 2 informativa) |
| 2 uso_interno | D-ui1 Logs básicos; D-ui2 README operacional |
| 3 mvp | D-mvp1 Observability básica (Sentry default); D-mvp2 Backup com restore testado; D-mvp3 Doc de recovery |
| 4 beta_publico | (mvp +) D-bp1 Integration testing; D-bp2 SemVer explícito; D-bp3 Audit logs imutáveis; D-bp4 Performance baseline declarado obrigatório / medição "perguntar"; D-bp5 Rate limiting |
| 5 producao_real | (beta_publico +) D-pr1 SLO; D-pr2 DR testado; D-pr3 Compliance; D-pr4 Audit dimensional completo; D-pr5 Defesa prompt injection (se LLM); D-pr6 Plano de incidente |

### Stack default `web-saas` (congelada por 18 meses; revisão Q3-Q4 2026 com TanStack Start 1.0)

```
Linguagem:        TypeScript 5.x estrito
Frontend+Backend: Next.js 16+ (App Router, Server Components, Server Actions)
UI:               Tailwind v4 + shadcn/ui CLI v4 (Skill + MCP shadcn.io)
DB:               PostgreSQL 17 via Supabase
ORM:              Prisma (Drizzle override em producao_real edge)
Auth:             Supabase Auth (RLS em TODAS as tabelas)
Storage default:  Supabase Storage
Email default:    Resend (com React Email)
Hosting default:  Vercel Pro a partir de mvp; Hobby OK em prototipo_descartavel/uso_interno não-comercial
Observabilidade:  Sentry + Supabase logs
Mobile-first:     375 / 768 / 1440 (mantido)
```

### Audit dimensional — 13 → 14 dimensões

Adicionada **dim 14: Defesa contra prompt injection** (OWASP LLM01). Aplicabilidade condicional a "produto tem LLM no caminho?". Em `beta_publico` e `producao_real` com LLM = obrigatório; com LLM apenas interno = perguntar; sem LLM = não rodada.

### Mudanças de RLS na Audit existente

- Dim 2 (Isolamento de dados) e dim 3 (Integridade de dados) ganham tratamento específico quando stack usa Supabase: RLS é o mecanismo padrão; auditoria valida políticas RLS em vez de middleware customizado.

## Decisões consolidadas

| Item | Decisão | Origem |
|---|---|---|
| Tier projetado vira premissa fundadora (não princípio) | OK | Pushback 1 |
| Gates configuráveis (3 níveis) na constitution | OK | Pushback 2 |
| TDD canônico universal preservado como H9 (sem D-mvp1 separado) | OK | Pushback 3 |
| H7 sub-dividido em H7.1 (auto-execução) + H7.2 (trade-offs declarados) | OK | Adição usuário |
| Camada 2 ativa em mvp+, informativa em tier 1-2 | OK | Pushback prévio |
| Stack default revertida pra Prisma (não Drizzle) | OK | Pushback 1 da pesquisa |
| Vercel Pro a partir de mvp; Hobby OK em tier 1-2 não-comercial | OK | Pushback 2 da pesquisa |
| Mercado Pago documentado como caminho, sem snippet mantido | OK | Pushback 3 da pesquisa |
| Rails 8 + Hotwire como override forte com OnboardingHub como evidência | OK | Pushback 4 da pesquisa |
| Plano consolidado num único major v1.0.0 | OK | Pushback 5 da pesquisa |

## Decisões parqueadas (NÃO entram em v1.0.0)

Items 4.1.1-4.1.7 do BACKLOG ([NEEDS CLARIFICATION] marker, Constitutional Amendment Process operacional, sdd-bootstrap, sdd-bugfix, drift detection, TinySpec, templates ativos), 4.2.4 catálogo aberto de tipos. Permanecem no BACKLOG pra v1.1+ ou trigger.

Item 4.3 mantido como "decisão registrada de NÃO adotar".

## Migração v0.x → v1.0.0

Sub-skill nova `sdd-migrate-v1`:

- Detecta projeto v0.x por sinais (constitution sem campos `gates:`, `audiencia:`, `gera_receita:`, `trade_offs:`; referência a "Princípios invioláveis" sem "Camadas")
- Propõe (opt-in) atualização da constitution preservando conteúdo
- Se `web-saas`, oferece revisar stack — usuário pode manter v0.x como ADR via H5
- Tudo com `[INFERIDO — confirmar]` markers
- Não toca em código do projeto, só em `specs/constitution.md`

## Quality Gates de v1.0.0 (testes manuais antes do bump)

1. `claude plugin validate .` passa
2. `grep -r "princípio inviolável\|princípios invioláveis"` no plugin retorna apenas referências históricas (changelog/migração), não em fluxo ativo
3. `grep -r "plugin:context7:context7"` zero ocorrências
4. Cross-link integridade: SKILL.md aponta pros references novos; references linkam de volta quando aplicável
5. Templates renderizam markdown válido
6. Sub-skill `sdd-migrate-v1` detecta projeto v0.x simulado
7. `sdd-promote-tier` preservada e funcional
8. Stack default referencia ferramentas existentes em maio/2026
9. `disable-model-invocation: true` mantido em SKILL.md principal
10. Frontmatter atualizada (version 1.0.0, descrição coerente)
