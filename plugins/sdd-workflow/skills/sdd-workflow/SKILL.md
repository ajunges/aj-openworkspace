---
name: sdd-workflow
description: >
  Workflow completo de Spec-Driven Development para criar novos projetos solo gerados por IA.
  Use quando o usuário disser "novo projeto", "criar um sistema", "quero desenvolver",
  "use o workflow SDD", ou qualquer variação de pedido para construir software do zero.
  O desenvolvedor é não-programador — todo código é gerado por IA.
disable-model-invocation: true
version: 2.1.0
triggers:
  - sdd
  - novo projeto
  - criar um sistema
  - quero desenvolver
  - workflow sdd
  - nova feature
  - status do projeto
  - /sdd
  - /sdd.status
  - /sdd.gate
tags:
  - development-methodology
  - project-management
  - spec-driven
  - workflow
---

# Spec-Driven Development Workflow

Workflow completo para desenvolvimento de novos projetos solo, opcionalmente em monorepo. O desenvolvedor é não-programador — todo código é gerado por IA. Cada fase produz um artefato que deve ser aprovado antes de avançar.

> **Contexto do autor**: este workflow foi desenvolvido por um não-programador
> (executivo de negócio, sem background técnico) para dirigir o Claude Code na
> construção de sistemas completos — todo o código é gerado por IA. Os gates,
> quality checks e a auditoria em 8 dimensões existem exatamente para
> compensar a falta de conhecimento técnico direto: o humano valida resultado
> e regras de negócio, a IA escreve código. Se você é desenvolvedor
> experiente, provavelmente muitos dos guard rails vão parecer excessivos —
> use o que fizer sentido pro seu contexto.

**REGRA INVIOLÁVEL**: Sempre usar dados REAIS dos documentos fornecidos. NUNCA inventar dados fictícios para seed, testes ou demonstrações.

---

## Fase 0 — Discovery (antes de codificar qualquer coisa)

Faça perguntas ao usuário para entender:

1. **Problema**: Que dor operacional este projeto resolve?
2. **Usuários**: Quem vai usar? Quantas pessoas? Em que dispositivo?
3. **Dados**: Que dados entram, como são processados, o que sai?
4. **Referência**: Existe planilha, documento ou processo manual que será substituído?
5. **Escopo V1**: O que é essencial vs. nice-to-have?

Se o usuário fornecer documentos de referência (Excel, PDF, etc.), analise-os detalhadamente antes de avançar. Extraia todas as regras de negócio, cálculos, estruturas de dados e edge cases.

**Artefato**: Entendimento documentado no chat. Aprovação verbal do usuário.

---

## Fase 0.5 — Setup do Projeto

Após aprovação da discovery, execute automaticamente:

1. **Criar estrutura de pastas**:
```bash
# PROJECTS_DIR e PROJECT_NAME são configuráveis no CLAUDE.md raiz
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/specs"
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/src"
```

2. **Criar CLAUDE.md** do projeto com descrição baseada na discovery, estrutura `specs/` e `src/`, e referência aos padrões universais do CLAUDE.md raiz.

3. **Criar README.md** inicial com nome, descrição e status "Em desenvolvimento".

4. **Commit e push**:
```bash
cd "$PROJECTS_DIR"
git add "$PROJECT_NAME/"
git commit -m "Init $PROJECT_NAME — setup do projeto"
git push
```

5. Confirmar ao usuário: "Projeto criado e sincronizado com GitHub. Avançando para constitution."

**Artefato**: Pasta criada, CLAUDE.md, README.md, commit no GitHub. Avançar automaticamente para Fase 1.

---

## Fase 1 — Constitution (specs/constitution.md)

Antes de qualquer requisito, definir os princípios do projeto. Criar `specs/constitution.md` com:

```markdown
# Constitution — [Nome do Projeto]

## Identidade
- O que o projeto faz (1 frase)
- Para quem é
- Que problema resolve

## Princípios de Desenvolvimento
- [Herdados do /CLAUDE.md raiz + específicos deste projeto]
- Ex: "Código em inglês, UI em português"
- Ex: "Credenciais nunca no código"
- Ex: "Dados reais, nunca fictícios"
- Ex: "Cada tarefa entrega algo funcional"

## Stack Default (preferência do autor; substituir no constitution se o projeto exigir outra)
| Camada | Tecnologia |
|--------|-----------|
| Frontend | React + Vite + Tailwind CSS + shadcn/ui |
| Backend | Node.js + Express + Prisma |
| Banco | PostgreSQL via Docker |
| Auth | JWT |
| Gráficos | Recharts |
| Brand colors | definir no constitution de cada projeto (primary + neutral) |

## Restrições e Limites (v1)
- O que o sistema NÃO faz
- Limites de escopo
- Dependências externas

## Quality Standards
- Mobile-first (sidebar vira drawer, tabelas com scroll horizontal, cards empilham)
- Breakpoints: 375px (mobile), 768px (tablet), 1440px (desktop)
- Toast para feedback (nunca alert())
- Empty states e loading states em todas as telas
- Isolamento de dados entre perfis

## Decisões Registradas
| Data | Decisão | Contexto |
|------|---------|----------|
| YYYY-MM-DD | Decisão tomada | Por que essa escolha |
```

**Quality Gate 1** ✅:
```
□ Constitution revisada e aprovada pelo usuário
□ Stack definida e justificada
□ Princípios não conflitam com /CLAUDE.md raiz
□ Progress.md criado (ver seção Progress Tracking)
```

---

## Fase 2 — Requirements (specs/requirements.md)

Crie o documento de requisitos com:
- Visão geral do sistema
- Usuários e perfis de acesso
- Módulos do sistema com funcionalidades detalhadas
- Regras de negócio críticas (com exemplos dos dados reais)
- Dados iniciais — seed baseado em documentos reais, **NUNCA fictícios**
- Requisitos técnicos e não-funcionais
- Fora do escopo V1

**Quality Gate 2** ✅:
```
□ Todos os módulos têm requisitos claros
□ Regras de negócio documentadas com exemplos de dados reais
□ Dados de referência disponíveis e analisados
□ Isolamento de dados entre perfis definido
□ Requisitos revisados e aprovados pelo usuário
□ Progress.md atualizado
```

**Artefato**: `specs/requirements.md`. Usuário deve aprovar antes de avançar.

**Resumo pós-fase**:
```
## ✅ Fase 2 Concluída — Requirements

### Decisões-chave
1. [Decisão] — Por quê: [Justificativa]
2. [Decisão] — Por quê: [Justificativa]

### O que foi gerado
- requirements.md: [N] módulos, [N] requisitos funcionais

### Pontos de atenção
1. [Risco ou ambiguidade identificada]
2. [Dependência externa a resolver]

### Próximo passo
→ Fase 3: Design Técnico

📊 Progresso: [●●○○○○○] 20% | Features: 0/[N] implementadas
```

---

## Fase 3 — Design (specs/design.md)

Crie o documento de design técnico com:
- Stack tecnológica definida no constitution do projeto (pode divergir da default)
- Estrutura do banco (tabelas, relações, constraints)
- API routes (rotas, payloads, autenticação, autorização)
- Arquitetura de componentes frontend
- Organização de pastas
- Estratégia de seed com dados reais
- Decisões importantes registradas na constitution

**Quality Gate 3** ✅:
```
□ Schema cobre todos os módulos dos requirements
□ APIs têm autenticação e autorização definidas
□ Stack bate com constitution.md
□ Brand colors do projeto configurados no Tailwind conforme constitution
□ Mobile-first documentado (sidebar, tabelas, cards)
□ Design revisado e aprovado pelo usuário
□ Progress.md atualizado
```

**Artefato**: `specs/design.md`. Usuário deve aprovar antes de avançar.

---

## Fase 4 — Tasks (specs/tasks.md)

Quebre a implementação em tarefas incrementais por fase:

1. **Infra e Setup** (Docker, Prisma, Vite, scripts)
2. **Auth + Layout** (login, JWT, sidebar, mobile drawer)
3. **CRUDs** (entidades administrativas)
4. **Lógica de negócio** — marcar com 🔒 tarefas que precisam validação contra dados reais
5. **Dashboards e visualizações**
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** (isolamento, validações, responsividade)

Cada tarefa deve:
- Ser testável independentemente
- Ter critério claro de done (entregável)
- Indicar dependências

**Quality Gate 4** ✅:
```
□ Cada tarefa tem entregável testável
□ Dependências entre tarefas estão claras
□ Tasks 🔒 identificadas (pontos de validação contra dados reais)
□ Plano revisado e aprovado pelo usuário
□ Progress.md atualizado
```

**Artefato**: `specs/tasks.md`. Usuário deve aprovar antes de avançar.

---

## Fase 5 — Implementação

Executar tarefas sequencialmente conforme `specs/tasks.md`.

### Ciclo por task

Para CADA task do plano, seguir este ciclo:

```
Task → Testes (TDD) → Codar → Verificar → Checkpoint → Commit → Próxima
```

#### 1. Testes primeiro (TDD)

Antes de implementar, escrever os testes que definem "o que significa funcionar":

- Testes descrevem **regras de negócio**, não detalhes de implementação
- Rodar os testes e confirmar que **falham** (código ainda não existe)
- Usar `superpowers:test-driven-development` como referência de processo

Exemplo de teste para regra de negócio:
```javascript
test('desconto progressivo 5% quando pedido > threshold', () => {
  const result = calcularDesconto({ valor: 1500, threshold: 1000 })
  expect(result.percentual).toBe(0.05)
})
```

#### 2. Codar

- Implementar o mínimo necessário para os testes passarem
- **Seed SEMPRE com dados reais** dos documentos fornecidos
- Se encontrar erro, usar `superpowers:systematic-debugging`:
  reproduzir → isolar → diagnosticar → corrigir (nunca tentativa e erro)

#### 3. Verificar

Antes de declarar "pronto", **provar** que funciona:

- Rodar TODOS os testes da task e confirmar que passam
- Em tasks 🔒: testar contra dados reais, mostrar comparativo ao usuário
- Usar `superpowers:verification-before-completion` como referência
- **Nunca** dizer "pronto" sem mostrar output dos testes

#### 4. Checkpoint

Apresentar ao usuário um resumo curto:

```
✅ Task N: [Nome da task]
   Testes: X passando, 0 falhando
   O que foi feito: [1-2 frases]
   Decisões tomadas: [se houve alguma]
```

O usuário valida a direção (não o código). Se algo não faz sentido, corrigir antes de avançar.

#### 5. Commit

```bash
git add [arquivos relevantes]
git commit -m "feat: [descrição da task]"
```

### Regras da implementação
- Em tarefas 🔒: parar, testar contra dados reais, mostrar comparativo, só avançar com validação do usuário
- Se encontrar erro, corrigir antes de avançar — nunca deixar para depois
- Atualizar `specs/progress.md` ao concluir cada feature

### Quality Gate por task 🔒
```
□ Testes escritos ANTES da implementação
□ Todos os testes passando (output mostrado)
□ Entregável funcional demonstrado
□ Validado contra dados reais (comparativo mostrado)
□ Usuário aprovou antes de prosseguir
```

### Final de sessão

Quando a sessão de trabalho encerrar (mesmo no meio da Fase 5):

1. **Atualizar progress.md** com estado atual
2. **Revisar CLAUDE.md** do projeto com aprendizados da sessão (`claude-md-management:revise-claude-md`)
3. **Salvar na memória** decisões relevantes para o monorepo

---

## Fase 6 — Auditoria

Antes de entregar, auditar **8 dimensões**. Para cada achado, classificar como 🔴 Crítico (corrigir antes de usar), 🟡 Importante (corrigir em breve), 🟢 Melhoria (nice-to-have).

### 6.1 Segurança
Senhas hardcoded, tokens expostos, CORS mal configurado, rotas desprotegidas, variáveis sensíveis no código, rate limiting, headers HTTP (helmet).

### 6.2 Isolamento de dados
Confirmar que um perfil NÃO consegue acessar dados de outro via API. Testar com curl.

### 6.3 Integridade de dados
Validações de input no backend: valores negativos, campos obrigatórios, tipos errados, year/month fora de range.

### 6.4 Performance
Queries N+1, `await` em loop (usar `Promise.all`), imports desnecessários, bundle size do frontend, índices faltando no banco.

### 6.5 Responsividade
Testar em 375px (mobile), 768px (tablet), 1440px (desktop). Touch targets mínimo 20px. Tabelas com scroll horizontal. Drawer fecha ao navegar.

### 6.6 UX/Layout
Brand colors do projeto, loading states (Skeleton), empty states, toast para feedback (nunca `alert()`), consistência visual, espaçamentos.

### 6.7 Código
Imports errados ou não usados, `console.log` esquecidos, TODOs pendentes, try/catch em route handlers, error boundaries no React.

### 6.8 Lógica de negócio
Conferir cálculos e regras de negócio contra dados reais dos documentos de referência. Validar que resultados batem.

### Quality Gate 6 ✅
```
□ Zero itens 🔴 (críticos)
□ Itens 🟡 corrigidos ou aceitos com justificativa
□ Testado como todos os perfis de usuário
□ Testado em mobile (375px) e desktop (1440px)
□ Lógica de negócio validada contra dados reais
□ Progress.md atualizado
```

**Artefato**: Relatório de auditoria apresentado ao usuário. Corrigir 🔴 e 🟡 antes de avançar.

---

## Fase 7 — Entrega

1. Corrigir todos os achados da auditoria (🔴 e 🟡)
2. Commit final com todas as correções
3. Subir o sistema: Docker + seed + servidor dev
4. Informar URL e credenciais ao usuário
5. Apresentar resumo do que foi construído

### Quality Gate Final ✅
```
□ Zero itens 🔴 na auditoria
□ Seeds funcionando do zero (limpar banco + popular)
□ Sistema rodando e acessível
□ README.md atualizado com instruções de setup e uso
□ Usuário validou fluxos principais
```

---

## Progress Tracking

Manter `specs/progress.md` atualizado ao longo do projeto:

```markdown
# Progresso — [Nome do Projeto]

Atualizado em: YYYY-MM-DD

## Visão Geral
| Fase | Status | Gate |
|------|--------|------|
| 0. Discovery | ✅ | ✅ |
| 0.5. Setup | ✅ | ✅ |
| 1. Constitution | ✅ | ✅ |
| 2. Requirements | ✅ | ✅ |
| 3. Design | 🔄 Em andamento | — |
| 4. Tasks | ⏸️ Aguardando | — |
| 5. Implementação | ⏸️ Aguardando | — |
| 6. Auditoria | ⏸️ Aguardando | — |
| 7. Entrega | ⏸️ Aguardando | — |

## Features
| Feature | Tasks | Status | Progresso | Bloqueios |
|---------|-------|--------|-----------|-----------|
| Auth | T01-T05 | ✅ | 100% | — |
| CRUDs | T06-T09 | 🔄 | 60% | — |
| Motor | T10-T13 | ⏸️ | 0% | Depende: CRUDs |
```

### Status Line

Incluir no final de cada resposta durante implementação:

```
📊 [Feature Atual] ([Fase]) → Próxima: [Feature Seguinte]
   Progresso: [●●●○○] X% | Concluídas: N/Total | Bloqueios: [Status]
```

### Cálculo de Progresso

| Estágio | % |
|---------|---|
| Discovery + Setup + Constitution | 10% |
| Requirements prontos | 20% |
| Design pronto | 30% |
| Tasks definidas | 35% |
| Implementação (proporcional às tarefas) | 35-90% |
| Auditoria concluída | 95% |
| Entrega validada | 100% |

---

## Feature Management

### Comandos naturais suportados

| Usuário diz | Claude faz |
|-------------|------------|
| "Adiciona feature X" | Cria seção em requirements, propõe tasks, atualiza progress |
| "Move feature X antes de Y" | Reordena tasks.md respeitando dependências |
| "Status do projeto" | Mostra progress.md atualizado |
| "Qual o próximo passo?" | Identifica próxima task/fase e sugere ação |
| "Pula feature X por agora" | Marca como deferred em progress.md |
| "Terminamos feature X" | Atualiza status para ✅, sugere próxima |

---

## Regras Gerais

- Código em inglês, interface e docs em português brasileiro
- **NUNCA** commitar senhas ou API keys — usar `.env`
- Brand colors do projeto conforme constitution — nunca hardcoded no código
- Cada projeto tem `CLAUDE.md` e `README.md` próprios
- `docker-compose.yml` obrigatório quando usar banco
- Git commit a cada fase completa, não a cada arquivo
- Seed **SEMPRE** com dados reais — **NUNCA** dados fictícios
- Constitution do projeto **herda** padrões de `/CLAUDE.md` raiz e **adiciona** os específicos
- Respeitar regras de segurança do projeto e do CLAUDE.md raiz — regras invioláveis

---

## Exemplos de invocação

- "Quero criar um novo projeto chamado roi-calculator. Use o workflow SDD."
- "Preciso de um sistema para controlar X. Me guie no desenvolvimento."
- "Novo projeto: dashboard de pipeline."
- "Status do projeto" → mostra progress.md
- "Qual o próximo passo?" → identifica e sugere ação

---

## Resumo do Workflow

```
Discovery → Setup → Constitution → GATE →
Requirements → GATE → Design → GATE → Tasks → GATE →
Implementação (loop por task, 🔒 = pausa) →
Auditoria 8 dimensões → GATE → Entrega → ✅ Pronto
```

Cada GATE é um ponto de **pausa obrigatória** — Claude apresenta o resumo e aguarda aprovação antes de avançar.
