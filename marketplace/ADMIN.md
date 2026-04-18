# Marketplace aj-openworkspace — guia de administração

> Referência pra manutenção do marketplace: adicionar plugins, atualizar SHAs, criar plugins próprios, classificar, validar e publicar.

Este guia é pra quem mantém o marketplace (eu). Pra quem quer usar/instalar plugins, veja [README.md](README.md).

---

## 1. Estrutura do repo

```
aj-openworkspace/
├── .claude-plugin/
│   └── marketplace.json           # catálogo (15 plugins hoje)
├── plugins/                       # plugins Level 3 (próprios)
│   ├── marketplace-tools/
│   └── sdd-workflow/
├── marketplace/
│   ├── README.md                  # guia de uso (pra quem instala)
│   └── ADMIN.md                   # este arquivo
├── guias/                         # guias opinativos
├── docs/                          # artefatos de processo (specs, plans)
├── README.md                      # ponto de entrada do repo
└── CLAUDE.md                      # instruções pro Claude
```

**Regra de ouro**: `.claude-plugin/marketplace.json` e `plugins/` ficam na raiz — obrigatório pelo schema do Claude Code. Documentação fica em `marketplace/`.

---

## 2. Adicionar plugin externo ao marketplace

### 2.1 Decidir o nível

| Pergunta | Se sim | Se não |
|---|---|---|
| O plugin injeta skills, hooks ou agents no workflow? | **Level 2** (SHA pin) | Continuar ↓ |
| É tool passiva (MCP server, LSP, docs)? | **Level 1** (HEAD) | Continuar ↓ |
| É código seu que vive neste repo? | **Level 3** (local) | Não é plugin pra este marketplace |

### 2.2 Coletar informações do upstream

```bash
# Pra plugins em repo próprio (url source)
gh api repos/<owner>/<repo>/commits/main --jq '{sha: .sha, date: .commit.author.date}'

# Pra plugins dentro de monorepo (git-subdir source)
# Use o SHA do repo inteiro + path do plugin
gh api repos/<owner>/<repo>/commits/main --jq '{sha: .sha, date: .commit.author.date}'
```

### 2.3 Adicionar entry no marketplace.json

Editar `.claude-plugin/marketplace.json`, adicionar ao array `plugins`:

**Level 2 (url com SHA pin)**:

```json
{
  "name": "<nome-kebab-case>",
  "description": "<descrição opinativa em pt-BR>",
  "source": {
    "source": "url",
    "url": "https://github.com/<owner>/<repo>.git",
    "sha": "<40-char-sha>"
  },
  "category": "<development|productivity|security>",
  "tags": ["em-testes", "<origem>", "<função>", "<domínio>"],
  "homepage": "https://github.com/<owner>/<repo>"
}
```

**Level 2 (git-subdir com SHA pin)**:

```json
{
  "name": "<nome-kebab-case>",
  "description": "<descrição opinativa em pt-BR>",
  "source": {
    "source": "git-subdir",
    "url": "https://github.com/<owner>/<repo>.git",
    "path": "<path/dentro/do/repo>",
    "sha": "<40-char-sha>"
  },
  "category": "<development|productivity|security>",
  "tags": ["em-testes", "<origem>", "<função>", "<domínio>"],
  "homepage": "https://github.com/<owner>/<repo>/tree/main/<path>"
}
```

**Level 1 (url sem SHA)**:

```json
{
  "name": "<nome-kebab-case>",
  "description": "<descrição opinativa em pt-BR>",
  "source": {
    "source": "url",
    "url": "https://github.com/<owner>/<repo>.git"
  },
  "category": "<development|productivity|security>",
  "tags": ["em-testes", "<origem>", "<função>", "<domínio>"],
  "homepage": "https://github.com/<owner>/<repo>"
}
```

### 2.4 Decidir status e tags

**Status (obrigatório, sempre `tags[0]`)**:

- Plugins novos **sempre começam como `em-testes`**
- Promover pra `recomendado` após uso real confirmado
- Rebaixar pra `nao-recomendado` quando testou e não compensa (manter no marketplace como registro, com motivo na description)

**Tags livres (2-4 após o status)**:

| Grupo | Opções base |
|---|---|
| Origem | `oficial-anthropic`, `terceiro-oficial`, `comunidade`, `proprio` |
| Função | `workflow`, `meta-skills`, `review`, `seguranca`, `mcp`, `lsp`, `integracao` |
| Domínio | `git`, `python`, `jira`, `azure`, `docs`, `core`, `solo-dev`, `meta-marketplace` |

Vocabulário é aberto — inventar tags novas conforme fizer sentido.

### 2.5 Validar e commitar

```bash
# Validar JSON
jq . .claude-plugin/marketplace.json > /dev/null && echo "JSON OK"

# Contar plugins (deve incrementar)
jq '.plugins | length' .claude-plugin/marketplace.json

# Validar tags[0] em todos os plugins
jq '.plugins[] | select(.tags[0] | IN("recomendado", "em-testes", "nao-recomendado") | not) | .name' .claude-plugin/marketplace.json
# (output vazio = ok)

# Validador oficial
claude plugin validate .

# Commit
git add .claude-plugin/marketplace.json
git commit -m "Adicionar <nome> ao marketplace (<status>, Level <N>)

<justificativa curta: por que este plugin, o que faz, por que este nível>"
git push
```

### 2.6 Instalar pra testar

Após push:

```bash
claude plugin marketplace update aj-openworkspace
claude plugin install <nome>@aj-openworkspace --scope local
```

Começar com `--scope local` pra não poluir o user scope antes de validar.

---

## 3. Atualizar SHAs dos plugins Level 2

### 3.1 Via slash command (recomendado)

```
/check-marketplace-updates
```

Verifica cada plugin Level 2 contra o HEAD do upstream. Pra cada update encontrado:
- Mostra: SHA antigo → novo, N commits, N arquivos, breaking flags
- Pergunta: [A]plicar / [S]kip / [D]etalhar / [P]arar
- Se aplicar: edita o JSON via `jq` e commita `bump <plugin> para <short-sha>`

Requer: `gh` CLI autenticado + `jq`.

### 3.2 Manualmente (pra um plugin específico)

```bash
# Pegar SHA novo
NEW_SHA=$(gh api repos/<owner>/<repo>/commits/main --jq '.sha')
echo $NEW_SHA

# Ver o que mudou
gh api repos/<owner>/<repo>/compare/<old-sha>...$NEW_SHA --jq '.commits | length, .files | length'

# Editar o marketplace.json (substituir o SHA antigo pelo novo)
# Usar Edit tool ou jq:
jq --arg name "<nome>" --arg sha "$NEW_SHA" \
  '(.plugins[] | select(.name == $name) | .source.sha) = $sha' \
  .claude-plugin/marketplace.json > /tmp/mktmp.json \
  && mv /tmp/mktmp.json .claude-plugin/marketplace.json

# Validar e commitar
jq . .claude-plugin/marketplace.json > /dev/null && echo "OK"
git add .claude-plugin/marketplace.json
git commit -m "bump <nome> para ${NEW_SHA:0:12}"
git push
```

### 3.3 Após atualizar no marketplace, atualizar na máquina local

```bash
claude plugin marketplace update aj-openworkspace
```

O refresh do marketplace aplica automaticamente as novas versões dos plugins instalados. Não existe `claude plugin update <plugin>` — a atualização acontece via refresh do catálogo, não por comando per-plugin.

Restart da sessão pra aplicar.

---

## 4. Criar plugin próprio (Level 3)

### 4.1 Estrutura mínima

```bash
mkdir -p plugins/<nome>/.claude-plugin
mkdir -p plugins/<nome>/skills/<nome>     # se for skill
mkdir -p plugins/<nome>/commands          # se for slash command
```

### 4.2 Criar plugin.json

```json
{
  "name": "<nome>",
  "description": "<descrição curta em pt-BR>",
  "version": "0.1.0",
  "author": {
    "name": "André Junges"
  },
  "homepage": "https://github.com/ajunges/aj-openworkspace/tree/main/plugins/<nome>"
}
```

### 4.3 Criar a skill ou command

**Skill** (`plugins/<nome>/skills/<nome>/SKILL.md`):

```markdown
---
name: <nome>
description: >
  <descrição detalhada do que a skill faz e quando deve ser invocada>
disable-model-invocation: true
---

# <Título>

<conteúdo da skill — instruções pro Claude seguir>
```

**Slash command** (`plugins/<nome>/commands/<cmd>.md`):

```markdown
---
description: <descrição curta do que o comando faz>
---

# /<cmd>

<instruções detalhadas do fluxo>
```

### 4.4 Se precisar de ajuda, usar skill-creator

```
/skill-creator
```

O plugin `skill-creator` guia a criação de skills com frontmatter correto, triggers, e até benchmarking.

### 4.5 Adicionar ao marketplace.json

```json
{
  "name": "<nome>",
  "description": "<descrição opinativa>",
  "source": "./plugins/<nome>",
  "category": "<development|productivity|security>",
  "tags": ["em-testes", "proprio", "<função>", "<domínio>"],
  "author": {
    "name": "André Junges"
  }
}
```

### 4.6 Validar, commitar, instalar

```bash
# Validar
jq . .claude-plugin/marketplace.json > /dev/null
jq . plugins/<nome>/.claude-plugin/plugin.json > /dev/null
claude plugin validate .

# Commitar
git add plugins/<nome>/ .claude-plugin/marketplace.json
git commit -m "Criar plugin <nome> (Level 3, em-testes)

<descrição do que o plugin faz>"
git push

# Instalar localmente
claude plugin marketplace update aj-openworkspace
claude plugin install <nome>@aj-openworkspace
```

---

## 5. Sanitizar skills privadas pra publicação

Quando uma skill do `dev-monorepo/.claude/skills/` ou outro repo privado for promovida a plugin Level 3 público:

### 5.1 Checklist de sanitização

Antes de publicar, remover/substituir:

- [ ] Nomes de empresas (Grupo Supero, clientes)
- [ ] Caminhos absolutos (`~/repos/dev-monorepo`, `~/Downloads/`)
- [ ] Brand colors específicas (`#E8611A`, `#333333`)
- [ ] Regras de negócio de clientes (cálculos de comissão, metas, preços)
- [ ] Nomes de pessoas, projetos internos, dados de clientes
- [ ] Referências a arquivos que não existem no repo público (`.claude/rules/security.md`)
- [ ] Credenciais, tokens, URLs internas

### 5.2 Grep de validação (gate obrigatório)

Após sanitizar, rodar:

```bash
grep -iE "Supero|dev-monorepo|~/repos/|E8611A|#333333|<outros-termos-sensíveis>" plugins/<nome>/skills/<nome>/SKILL.md
```

**Zero matches = passa. Qualquer match = não commitar até corrigir.**

### 5.3 Generalização vs remoção

| Antes (privado) | Depois (público) | Técnica |
|---|---|---|
| `~/repos/dev-monorepo/NOME` | `"$PROJECTS_DIR/$PROJECT_NAME"` | Variável de ambiente |
| `Brand colors: #E8611A` | `Brand colors: definir no constitution` | Abstração |
| `Stack Obrigatória` | `Stack Default (preferência do autor)` | Generalização |
| `calcularComissao({ receita: 150000 })` | `calcularDesconto({ valor: 1500 })` | Exemplo genérico |
| `Respeitar .claude/rules/security.md` | `Respeitar regras de segurança do projeto` | Referência genérica |

---

## 6. Mudar status de um plugin

### Promover: em-testes → recomendado

Após uso real confirmado e opinião formada:

```bash
# Editar tags[0] no marketplace.json
jq --arg name "<nome>" \
  '(.plugins[] | select(.name == $name) | .tags[0]) = "recomendado"' \
  .claude-plugin/marketplace.json > /tmp/mktmp.json \
  && mv /tmp/mktmp.json .claude-plugin/marketplace.json

git add .claude-plugin/marketplace.json
git commit -m "Promover <nome> para recomendado

<motivo: por que agora é recomendado>"
git push
```

### Rebaixar: recomendado/em-testes → nao-recomendado

Testou e não compensou. Manter no marketplace como registro com motivo na description:

```bash
# Editar tags[0] E description
jq --arg name "<nome>" --arg desc "<descrição com motivo da rejeição>" \
  '(.plugins[] | select(.name == $name)) |= (.tags[0] = "nao-recomendado" | .description = $desc)' \
  .claude-plugin/marketplace.json > /tmp/mktmp.json \
  && mv /tmp/mktmp.json .claude-plugin/marketplace.json

git add .claude-plugin/marketplace.json
git commit -m "Rebaixar <nome> para nao-recomendado

<motivo: por que não compensa>"
git push
```

---

## 7. Remover plugin do marketplace

Raramente necessário — preferir `nao-recomendado` pra manter registro. Mas se quiser limpar:

```bash
# Remover entry do JSON
jq --arg name "<nome>" \
  '.plugins |= map(select(.name != $name))' \
  .claude-plugin/marketplace.json > /tmp/mktmp.json \
  && mv /tmp/mktmp.json .claude-plugin/marketplace.json

# Se Level 3, remover também a pasta
rm -rf plugins/<nome>/

# Validar e commitar
jq . .claude-plugin/marketplace.json > /dev/null
jq '.plugins | length' .claude-plugin/marketplace.json
git add .claude-plugin/marketplace.json plugins/
git commit -m "Remover <nome> do marketplace

<motivo>"
git push
```

---

## 8. Validação completa do marketplace

Checklist pra rodar antes de qualquer push importante:

```bash
# 1. JSON válido
jq . .claude-plugin/marketplace.json > /dev/null && echo "JSON: OK"

# 2. Contagem de plugins
echo "Plugins: $(jq '.plugins | length' .claude-plugin/marketplace.json)"

# 3. Todos têm tags[0] válido
INVALID=$(jq -r '.plugins[] | select(.tags[0] | IN("recomendado", "em-testes", "nao-recomendado") | not) | .name' .claude-plugin/marketplace.json)
[ -z "$INVALID" ] && echo "Tags: OK" || echo "Tags INVÁLIDAS: $INVALID"

# 4. Nomes únicos (sem duplicatas)
DUPES=$(jq -r '.plugins[].name' .claude-plugin/marketplace.json | sort | uniq -d)
[ -z "$DUPES" ] && echo "Nomes: OK" || echo "DUPLICATAS: $DUPES"

# 5. Sources Level 3 apontam pra dirs existentes
jq -r '.plugins[] | select(.source | type == "string") | .source' .claude-plugin/marketplace.json | while read p; do
  [ -d "$p" ] && echo "Path OK: $p" || echo "Path MISSING: $p"
done

# 6. Validador oficial
claude plugin validate .

# 7. plugin.json dos Level 3
for pj in plugins/*/. claude-plugin/plugin.json; do
  jq . "$pj" > /dev/null 2>&1 && echo "OK: $pj" || echo "ERRO: $pj"
done
```

---

## 9. Regras do marketplace

Decisões tomadas no brainstorm (2026-04-15) que governam este marketplace:

1. **Só plugins** — conectores MCP gerenciados pela UI do Desktop (PDF Tools, Gmail, HubSpot) não entram. São outra camada.
2. **Só o que não é padrão** — skills inline do Desktop app (anthropic-skills, brand-voice, design, data, engineering, productivity) não entram. Já vêm com o app.
3. **Status começa em `em-testes`** — promoção pra `recomendado` exige uso real confirmado.
4. **Level 2 por default** pra plugins que injetam workflow. Level 1 só pra tools passivas.
5. **Description em pt-BR**, opinativa, do ponto de vista do usuário.
6. **Sem `Co-Authored-By: Claude`** nos commits — preferência do autor.
7. **Repo público** — tudo que vai pro marketplace.json é world-readable. Sanitizar antes de publicar.

---

## 10. Fontes

- [Schema oficial do marketplace](https://anthropic.com/claude-code/marketplace.schema.json)
- [Doc: Create and distribute a plugin marketplace](https://code.claude.com/docs/en/plugin-marketplaces)
- [Doc: Discover and install plugins](https://code.claude.com/docs/en/discover-plugins)
- [Doc: Plugins reference](https://code.claude.com/docs/en/plugins-reference)
- [Spec do brainstorm](../docs/superpowers/specs/2026-04-15-marketplace-design.md)
- [Plano de implementação](../docs/superpowers/plans/2026-04-15-marketplace.md)
