# Fluxo detalhado — Estágio II (Spec)

> Reference detalhado do Estágio II do workflow SDD. Carregado pela SKILL principal quando IA está atuando em Spec.Requirements, Spec.Design ou Spec.Spike (opcional).

## 1. Spec.Requirements (formato EARS)

Escreva `specs/requirements.md` copiando + preenchendo `templates/requirements.md`. **Formato EARS** pra cada regra de negócio — 5 padrões (Ubiquitous, State-driven, Event-driven, Optional Feature, Unwanted Behavior) + Complex pra combinações. Sintaxe e exemplos: `references/linguagens-especificacao.md` seção 1.

Conteúdo obrigatório do `requirements.md`:

- Visão geral do sistema
- Usuários e perfis de acesso
- Dados de referência (linkar paths/URLs dos documentos reais)
- Módulos do sistema com requirements EARS
- Regras de negócio críticas com exemplos de **dados reais** (princípio 1)
- Requisitos não-funcionais conforme tier (ver `references/tiers.md`)
- Dados iniciais (seed) — extraídos dos documentos reais
- Fora do escopo V1

**Quality Gate Requirements**: Cada módulo tem requirements EARS bem-formados | Regras de negócio com exemplos de dados reais | Documentos de referência analisados e linkados | Isolamento de dados entre perfis definido (se aplicável).

## 2. Spec.Design

Escreva `specs/design.md` copiando + preenchendo `templates/design.md`. Conteúdo:

- Stack confirmada (da constitution + ajustes desta fase)
- Schema do banco (tabelas, relações, constraints, índices) se aplicável
- API Routes (rotas, payloads, autenticação, autorização)
- Arquitetura de componentes frontend (mobile-first se `web-saas`)
- Organização de pastas
- Estratégia de seed com dados reais
- **Bounded contexts** opcional (DDD parcial — apenas se `tier: producao_real` complexo ou `hubspot` extension grande). Senão noop declarado.
- **Decisão Spike**: este Design identificou risco técnico? Sim → cria `specs/spike.md`; Não → segue direto pra Build.Tasks.
- Decisões importantes (cross-link com constitution)

Skills sugeridas:
- `frontend-design` se UI distintiva (web-saas)
- `claude-api` se usa API Anthropic
- `plugin-dev:*` se `tipo_projeto: claude-plugin`

MCP sugerido:
- `context7` pra docs atualizadas de libs

**Quality Gate Design**: Schema cobre todos os módulos dos requirements | APIs têm autenticação e autorização definidas | Stack bate com constitution | Brand colors do projeto configurados (Tailwind, se UI) | Mobile-first documentado (sidebar, tabelas, cards) se UI | Decisão Spike registrada (sim/não).

## 3. Spec.Spike (opcional)

Entra **apenas** se Spec.Design identificou risco técnico (integração externa nova, lib desconhecida, dependência crítica). Box temporal sugerido: 1-3 dias.

Escreva `specs/spike.md` copiando + preenchendo `templates/spike.md`. Estrutura:

1. Risco identificado (origem: Spec.Design seção 8)
2. Hipóteses (principal + alternativas)
3. Critérios de sucesso
4. Investigação (setup mínimo, resultados, surpresas)
5. **Decisão tripartite**: confirmada / parcialmente confirmada / não confirmada
6. Próximo passo
7. Aprendizados pra registrar na Constitution

Skills usadas:
- `superpowers:test-driven-development` (validar hipóteses com testes)
- `superpowers:systematic-debugging` (quando spike der erro)

**Quality Gate Spike**: Hipóteses validadas (ou negadas com pivot decidido) | Riscos resolvidos ou aceitos com justificativa | Decisão registrada (constitution histórico) | Aprendizados extraídos pra constitution.
