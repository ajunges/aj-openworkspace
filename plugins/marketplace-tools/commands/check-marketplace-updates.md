---
description: Verifica updates nos plugins com SHA pinnado no marketplace e aplica sob confirmação
---

# /check-marketplace-updates

Verifica cada plugin Level 2 (com `source.sha`) em `.claude-plugin/marketplace.json` contra o HEAD atual do upstream e apresenta updates disponíveis. Aplica updates aceitos editando o JSON e criando commits individuais.

## Pré-requisitos

- Rodar a partir da raiz de um repo que contenha `.claude-plugin/marketplace.json`
- `gh` CLI autenticado (checar com `gh auth status`)
- `jq` instalado

## Fluxo

Siga os passos abaixo em ordem. Pare no primeiro erro crítico.

### 1. Sanity check do ambiente

Verificar que estamos no lugar certo e com as ferramentas instaladas:

```bash
test -f .claude-plugin/marketplace.json || { echo "ERRO: .claude-plugin/marketplace.json não encontrado. Rode da raiz de um repo com marketplace."; exit 1; }
command -v gh >/dev/null || { echo "ERRO: gh CLI não instalado."; exit 1; }
command -v jq >/dev/null || { echo "ERRO: jq não instalado."; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "ERRO: gh não autenticado. Rode 'gh auth login'."; exit 1; }
```

### 2. Coletar plugins Level 2 (com SHA)

Extrair lista de plugins pinnados com metadados necessários para o check:

```bash
jq -r '.plugins[] | select((.source | type) == "object" and .source.sha) | [.name, .source.source, .source.url, .source.path // "", .source.ref // "main", .source.sha] | @tsv' .claude-plugin/marketplace.json
```

O `select` precisa validar que `.source` é object antes de acessar `.sha` — plugins Level 3 (locais) usam `source` como string (ex: `"./plugins/<nome>"`), e indexar string com campo aborta o `jq` inteiro.

Para cada linha do output (formato TSV: `name | source-type | url | path | ref | sha`), executar o check do passo 3.

### 3. Para cada plugin pinnado, resolver HEAD atual do upstream

**Se `source.source == "url"` (repo próprio do plugin):**

```bash
CURRENT_SHA=$(git ls-remote "$URL" "$REF" | awk '{print $1}' | head -1)
```

**Se `source.source == "git-subdir"` (plugin dentro de monorepo):**

Extrair `owner/repo` da URL e usar GitHub API:

```bash
OWNER_REPO=$(echo "$URL" | sed -E 's|https://github.com/([^/]+/[^/]+)\.git|\1|')
CURRENT_SHA=$(gh api "repos/$OWNER_REPO/commits/$REF" --jq '.sha')
```

Se `CURRENT_SHA` é vazio ou falha, logar erro e seguir pro próximo plugin (não abortar).

### 4. Comparar e extrair diff (se mudou)

Se `CURRENT_SHA != OLD_SHA`, buscar o compare entre os SHAs:

```bash
COMPARE=$(gh api "repos/$OWNER_REPO/compare/$OLD_SHA...$CURRENT_SHA")
```

Extrair do compare:
- Número de commits: `echo "$COMPARE" | jq '.commits | length'`
- Arquivos alterados: `echo "$COMPARE" | jq '.files | length'`
- Commits relevantes (filtrar por path se for git-subdir):

```bash
if [ -n "$PATH_PREFIX" ]; then
  RELEVANT_FILES=$(echo "$COMPARE" | jq -r ".files[] | select(.filename | startswith(\"$PATH_PREFIX/\")) | .filename")
else
  RELEVANT_FILES=$(echo "$COMPARE" | jq -r '.files[].filename')
fi
```

Se `RELEVANT_FILES` vazio (mudou o SHA mas nenhum arquivo do plugin foi afetado), pular este plugin.

Extrair top 5 commit messages:

```bash
TOP_COMMITS=$(echo "$COMPARE" | jq -r '.commits[:5][] | "- " + (.commit.message | split("\n")[0])')
```

Detectar breaking change por keyword nas commit messages:

```bash
BREAKING=$(echo "$COMPARE" | jq -r '.commits[] | .commit.message | select(test("BREAKING|breaking:|!:"; "i"))')
```

### 5. Apresentar sumário ao usuário

Para cada plugin com updates, apresentar:

```
### <nome do plugin>
- SHA antigo: <short-sha-antigo>
- SHA novo:   <short-sha-novo>
- Commits:    <N>
- Arquivos:   <N> (filtrados por path, se aplicável)
- Breaking:   <sim/não>

Top 5 commits:
<lista>

O que fazer? [A]plicar / [S]kip / [D]etalhar / [P]arar tudo
```

Aguardar input. Processar conforme:
- `A` / `apply` → atualizar SHA (passo 6)
- `S` / `skip` → não mexer, passar pro próximo plugin
- `D` / `detail` → mostrar lista completa de arquivos alterados e commit messages, depois perguntar de novo
- `P` / `stop` → encerrar o comando

### 6. Aplicar update (se aceito)

Editar o SHA no `marketplace.json` via `jq` (não regex):

```bash
jq --arg name "$PLUGIN_NAME" --arg new_sha "$CURRENT_SHA" \
  '(.plugins[] | select(.name == $name) | .source.sha) = $new_sha' \
  .claude-plugin/marketplace.json > .claude-plugin/marketplace.json.tmp \
  && mv .claude-plugin/marketplace.json.tmp .claude-plugin/marketplace.json
```

Validar JSON após edit:

```bash
jq . .claude-plugin/marketplace.json > /dev/null || { echo "ERRO: JSON quebrou após edit. Restaurar via git checkout."; exit 1; }
```

Commit individual para cada plugin atualizado:

```bash
git add .claude-plugin/marketplace.json
git commit -m "bump $PLUGIN_NAME para ${CURRENT_SHA:0:12}"
```

### 7. Output final

Após processar todos os plugins:

```
Verificados:      <N>
Sem updates:      <N>
Com updates:      <N>
Aplicados agora:  <N>
Pulados:          <N>
Erros:            <N>
```

Se erros > 0, listar quais plugins falharam e por quê.

## Tratamento de erros

- **Upstream inacessível**: loga (`ERRO ao checar <plugin>: <razão>`) e segue pro próximo plugin.
- **Rate limit do gh**: mostra mensagem explicativa e aborta (usuário deve esperar reset).
- **marketplace.json inválido após edit**: aborta imediatamente, restaura via `git checkout .claude-plugin/marketplace.json`.
- **Conflito de merge**: nunca acontece porque cada bump é um commit isolado, sem paralelismo.

## Não-objetivos (v0.1)

- Não verifica plugins Level 1 (sem SHA) — esses recebem updates automáticos do Claude Code
- Não faz rollback automático
- Não atualiza Level 3 (./plugins/) — esses são local-owned
- Não detecta vulnerabilidades de segurança no diff
- Não suporta private repos que exijam auth customizada além do `gh` default
