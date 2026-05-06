# Fluxo detalhado — Estágio III (Build)

> Reference detalhado do Estágio III. Carregado pela SKILL principal quando IA está em Build.Tasks ou no loop de Build.Implementation por feature.

## 1. Build.Tasks (plano-mestre)

Escreva `specs/tasks.md` copiando + preenchendo `templates/tasks.md`. **Plano-mestre** = índice de features. Cada feature terá seu próprio plano detalhado em `specs/plans/<feature>.md`.

Quebra típica de features (adaptar conforme `tipo_projeto`):

1. **Infra e Setup** (Docker, scripts, banco)
2. **Auth + Layout** (login, JWT, sidebar, mobile drawer) se UI
3. **CRUDs** (entidades administrativas)
4. **Lógica de negócio [H1]** (cálculos, validações — validação obrigatória contra dados reais)
5. **Dashboards e visualizações** (se aplicável)
6. **Funcionalidades específicas** (simulação, relatórios, etc.)
7. **Polish** (isolamento, validações, responsividade)

Cada feature do plano-mestre deve:
- Ser testável independentemente
- Ter critério claro de done
- Indicar dependências
- Marcar com [H1] se exige validação contra dados reais

**Quality Gate Tasks**: Cada feature tem plano detalhado planejado em `specs/plans/<feature>.md` | Dependências entre features claras | Features [H1] identificadas | Plano-mestre revisado | progress.md atualizado com features.

## 2. Build.Implementation — loop por feature

Pra cada feature do plano-mestre:

1. **Escrever plano detalhado** em `specs/plans/<feature>.md` usando `superpowers:writing-plans` com **5 ajustes de convenção SDD**:

   1. **Marcação [H1]** — header de task `### Task N: [Component] [H1]` ou step extra `- [ ] **Step X: validar contra dados reais [H1]**` antes do commit
   2. **Quebra por fase típica** absorvida no nível superior (`tasks.md` plano-mestre)
   3. **Quality Gate por feature** absorve gates antigos
   4. **Localização**: `specs/plans/<feature>.md` no projeto (autocontido)
   5. **Refactor explícito no ciclo TDD canônico** — `write test → run (FAIL) → implement → run (PASS) → REFACTOR → commit`. Refactor pode ser noop conscientemente declarado (não pulado silenciosamente); pra arquivos não-código (markdown, JSON) adapta semântica. Notação completa e anti-patterns: `references/linguagens-especificacao.md` seção 3.

2. **Cenário BDD pra tasks [H1]** (validação contra dados reais) — formato Given/When/Then com dados reais específicos (planilha, exportação, dataset). Estrutura completa e exemplo: `references/linguagens-especificacao.md` seção 2.

3. **Executar plano detalhado** com:
   - `superpowers:executing-plans` — execução inline com checkpoints, OU
   - `superpowers:subagent-driven-development` — fresh subagent per task com review entre tasks (recomendado pra features grandes)

4. **Skills durante Implementation**:
   - `superpowers:test-driven-development` — TDD canônico Red/Green/Refactor
   - `superpowers:systematic-debugging` — em erros (reproduzir → isolar → diagnosticar → corrigir)
   - `superpowers:verification-before-completion` — antes de declarar task pronta
   - `superpowers:using-git-worktrees` — quando feature precisa isolamento
   - `superpowers:dispatching-parallel-agents` — quando subtasks independem
   - `commit-commands:commit` — substituir commits manuais
   - `simplify` — depois de bloco grande de implementação

5. **Quality Gate por feature** (gate além do gate por task): Todos os steps do plano detalhado executados | Testes da feature passando (output mostrado) | Se [H1]: comparativo contra dados reais mostrado e aprovado | Refactor declarado (executado ou noop justificado) | progress.md marcado [atendido].

6. **Atualizar `specs/progress.md`** ao concluir feature.

## 3. Final de sessão (não é fase, é evento)

Quando a sessão de trabalho encerrar (mesmo no meio da Implementation):

1. **Atualizar `specs/progress.md`** com estado atual
2. **Revisar `CLAUDE.md` do projeto** com aprendizados (`claude-md-management:revise-claude-md`)
3. **Salvar na memória**: `remember:remember`
4. **Relatório de sessão** (opcional): `session-report:session-report`
