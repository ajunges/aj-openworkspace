# [Nome da Feature] Implementation Plan

> **Para agentic workers**: REQUIRED SUB-SKILL — Use `superpowers:subagent-driven-development` (recomendado) ou `superpowers:executing-plans` pra executar este plano task-by-task. Steps usam checkbox (`- [ ]`).
>
> **Convenção SDD v1.0.0**: este plano segue o template do `superpowers:writing-plans` com **5 ajustes** de convenção SDD:
> 1. Marcação `[H1]` em tasks de validação contra dados reais (heurística **H1** — Dados reais sempre)
> 2. Quebra por feature acontece no nível superior (`tasks.md` plano-mestre)
> 3. Quality Gate por feature absorve gates SDD
> 4. Localização: `specs/plans/<feature>.md` no projeto
> 5. **Refactor explícito** no ciclo TDD canônico Red/Green/**Refactor** (heurística **H9** — TDD canônico universal; ver `references/heuristicas.md` e `references/linguagens-especificacao.md` seção 3)

**Goal:** [Uma frase descrevendo o que essa feature constrói]

**Architecture:** [2-3 frases sobre a abordagem]

**Tech Stack:** [Tecnologias-chave usadas nesta feature]

---

## Task N: [Nome do componente]

**Files:**
- Create: `exact/path/to/file.ext`
- Modify: `exact/path/to/existing.ext:linhas`
- Test: `tests/exact/path/test.ext`

- [ ] **Step 1: Write the failing test (Red)**

```python
def test_specific_behavior():
    result = function(input_real_data)
    assert result == expected_real_value
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL com "function not defined" ou similar

- [ ] **Step 3: Write minimal implementation (Green)**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Refactor**

Improve design without changing behavior. Run tests novamente após cada mudança.

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS (mesmo comportamento)

**Decisão de noop**: se o código já saiu limpo no Step 3, declarar "Refactor: noop — Green saiu limpo, sem duplicação ou complexidade pra resolver". Decisão consciente, não pulada.

- [ ] **Step 6: Commit**

```bash
git add tests/path/test.py src/path/file.ext
git commit -m "feat: <descrição da task>"
```

---

## Task N+1: [Componente seguinte] [H1] (se exige validação contra dados reais)

**Files:**
- [...]

**Cenário BDD de validação [H1]** (formato Given-When-Then — ver `references/linguagens-especificacao.md`):

```gherkin
Cenário: [Nome do cenário]
  Dado os dados reais da [planilha/PDF/sistema] "<arquivo>.xlsx"
  Quando [ação executada pelo sistema]
  Então [resultado bate com dados de referência]
  E [asserção adicional]
```

- [ ] **Step 1-5**: ciclo TDD canônico (mesmo padrão da Task N acima)

- [ ] **Step 6: Validação contra dados reais [H1]**

Run: script que executa o cenário BDD acima contra dados reais
Expected: cada asserção bate com `<arquivo>.xlsx`. Mostrar comparativo ao usuário.

- [ ] **Step 7: Commit**

(Após aprovação humana do comparativo)

```bash
git add tests/path/test.py src/path/file.ext
git commit -m "feat: <descrição> [H1] validado contra <arquivo>"
```

---

## Self-Review (após escrever o plano completo)

1. **Spec coverage**: cada requirement EARS de `requirements.md` tem task que implementa? Listar gaps.
2. **Placeholder scan**: nenhum "TBD"/"TODO"/"fill in"/"add validation"/"similar to Task N"
3. **Type consistency**: tipos, signatures, property names batem entre tasks?

Fix inline. Sem re-review.

---

## Execution Handoff

Após salvar este plano:

> "Plan complete and saved to `specs/plans/<feature>.md`. Two execution options:
> 1. **Subagent-Driven** (recommended) — fresh subagent per task, review between tasks
> 2. **Inline Execution** — executar nesta sessão usando `superpowers:executing-plans`
>
> Which approach?"
