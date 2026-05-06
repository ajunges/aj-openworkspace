# Fluxo detalhado — Estágio I (Pré-spec)

> Reference detalhado do Estágio I do workflow SDD. Carregado pela SKILL principal `sdd-workflow/SKILL.md` quando IA está atuando em alguma das 3 fases do Pré-spec. Contém o passo-a-passo, exemplos, comandos shell, listagem completa de skills auxiliares e Quality Gates por fase.

## 1. Pré-spec.Discovery

Faça perguntas ao usuário pra entender:

1. **Problema**: que dor operacional este projeto resolve?
2. **Usuários**: quem vai usar? quantas pessoas? em que dispositivo?
3. **Dados**: que dados entram, como são processados, o que sai?
4. **Referência**: existe planilha, documento ou processo manual que será substituído?
5. **Escopo V1**: o que é essencial vs. nice-to-have?
6. **`tipo_projeto`** (decisão estrutural — ver `references/tipos-projeto.md`):
   - `web-saas` — sistema web full-stack com UI rica
   - `claude-plugin` — plugin para Claude Code
   - `hubspot` — extensão HubSpot
   - `outro` — Stack Decision livre
7. **`tier` projetado** (visão final — ver `references/tiers.md`):
   - `prototipo_descartavel` | `uso_interno` | `mvp` | `beta_publico` | `producao_real`
   - **Tier é projetado**, não estado atual. Pedir explicitamente.

Se documentos de referência foram fornecidos (Excel, PDF, etc.), analisar antes de avançar:
- PDF → `anthropic-skills:pdf`
- Excel → `anthropic-skills:xlsx`
- Word → `anthropic-skills:docx`
- PowerPoint → `anthropic-skills:pptx`

Use `superpowers:brainstorming` pra explorar problema/requisitos quando útil.

**Quality Gate Discovery**: Problema/usuários/dados/referência/escopo entendidos | tipo_projeto e tier respondidos com justificativa | Documentos de referência analisados (se houver).

## 2. Pré-spec.Constitution (com Setup absorvido)

Após Discovery aprovada, executar:

1. **Criar estrutura de pastas e commit init**:
```bash
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/specs"
mkdir -p "$PROJECTS_DIR/$PROJECT_NAME/src"
cd "$PROJECTS_DIR/$PROJECT_NAME"
git init  # se aplicável
```

2. **Escrever `specs/constitution.md`** copiando + preenchendo `templates/constitution.md`. Bloco YAML inicial obrigatório:

```yaml
---
tipo_projeto: <da Discovery>
tier: <da Discovery>
tier_decidido_em: YYYY-MM-DD
---
```

Mais bloco textual obrigatório explicando **por que** esse tier.

3. **Escrever `CLAUDE.md` do projeto** com referência aos padrões universais (`/CLAUDE.md` raiz). Use `claude-md-management:revise-claude-md`.

4. **Escrever `README.md` inicial**.

5. **Commit inicial**:
```bash
git add .
git commit -m "init: $PROJECT_NAME — setup + constitution"
```

**Quality Gate Constitution**: Bloco YAML preenchido | Stack default (ou override) justificada | Princípios não conflitam com `/CLAUDE.md` raiz | Brand colors definidos (se UI) | progress.md criado (template) | Commit init feito.

## 3. Pré-spec.Stack — checkpoint explícito (3 sub-componentes)

**Não é confirmação automática**. Pausa real onde a IA pergunta criticamente:

> "Considerando as particularidades descritas em Discovery (X, Y, Z), a stack default ainda faz sentido ou precisa override?"

Os 3 sub-componentes a registrar na constitution:

1. **Inventário de dependências** — ver `references/inventario-dependencias.md`. Categorias: CLI do sistema, MCP servers, skills do marketplace, acesso a serviços externos. Família A (`superpowers:*` essenciais) bloqueia se faltar.

2. **Stack técnica** — ver `references/stacks.md`. Default sugerida por `tipo_projeto`. Override permitido sempre, com justificativa.

3. **Alvo de deploy** — ver `references/alvos-deploy.md`. **Decisão explícita do projeto**, não derivada de tipo+tier. IA pergunta "onde o produto vai viver?".

**Quality Gate Stack**: Inventário registrado (todas as categorias) | Stack confirmada ou override registrado com justificativa | Alvo de deploy registrado (decisão explícita) | Particularidades de Discovery consideradas (anti-pattern: aceitar default sem reflexão).
