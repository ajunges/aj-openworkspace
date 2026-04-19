---
description: Publica mudanças em plugin Level 3 — bump version, commit, push, sync clone local e re-cacheia aplicando o workaround dos bugs de cache do Claude Code Desktop
---

# /publish-plugin

Fecha o ciclo completo de "publicar" uma mudança num plugin Level 3 (`source: "./plugins/..."`) do marketplace. Encapsula os passos manuais que os bugs [#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081) do Claude Code forçam.

## Quando usar

Use sempre que mexer em arquivos dentro de `plugins/<nome>/` (skills, commands, agents, plugin.json, etc.) e quiser que o plugin instalado localmente reflita a mudança.

Se a mudança for só em marketplace-tools/sdd-workflow/humanizador/portfolio-docs e você já commitou em `main`, roda:

```
/publish-plugin <nome> [patch|minor|major]
```

## Pré-requisitos

- Rodar da raiz do repo do marketplace (contém `.claude-plugin/marketplace.json`)
- Estar no branch de trabalho ou em `main`
- `git`, `jq`, `gh` instalados
- Clone do marketplace existe em `~/.claude/plugins/marketplaces/<marketplace-name>/`

## Fluxo

Siga os passos em ordem. Pare no primeiro erro crítico.

### 1. Parsing de argumentos e sanity check

Garantir PATH consistente — o shell snapshot do Claude Code às vezes perde ferramentas mid-execution. Fazer **antes** de `command -v`.

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

PLUGIN_NAME="$1"
BUMP_TYPE="${2:-patch}"   # patch, minor, ou major

test -n "$PLUGIN_NAME" || { echo "Uso: /publish-plugin <nome> [patch|minor|major]"; exit 1; }
test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
command -v jq >/dev/null && command -v gh >/dev/null && command -v git >/dev/null || { echo "ERRO: jq, gh e git são obrigatórios."; exit 1; }

# Verificar que o plugin é Level 3 (source string local)
SOURCE_TYPE=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .source | type' .claude-plugin/marketplace.json)
test "$SOURCE_TYPE" = "string" || { echo "ERRO: $PLUGIN_NAME não é Level 3 (source precisa ser string local, tipo './plugins/...'). Para Level 1/2, use /check-marketplace-updates."; exit 1; }

# Verificar que o plugin dir existe
PLUGIN_DIR=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
test -d "$PLUGIN_DIR" || { echo "ERRO: diretório $PLUGIN_DIR não encontrado."; exit 1; }
```

### 2. Confirmar que há mudanças para publicar

Checar que existe ao menos um commit em `HEAD` afetando `$PLUGIN_DIR/` depois do último bump de version.

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
# Achar o último commit que mudou version do plugin em marketplace.json
LAST_BUMP=$(git log --format=%H -- .claude-plugin/marketplace.json | head -1)
# Commits depois desse afetando o plugin
CHANGED=$(git log --format=%H "$LAST_BUMP..HEAD" -- "$PLUGIN_DIR/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$CHANGED" = "0" ]; then
  echo "AVISO: nenhum commit em $PLUGIN_DIR/ desde o último bump. Bump é desnecessário?"
  echo "Continuar mesmo assim? [y/N]"
  read -r answer
  [ "$answer" = "y" ] || exit 0
fi
```

### 3. Calcular nova version

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
CURR=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .version' .claude-plugin/marketplace.json)
IFS=. read -r MAJ MIN PAT <<< "$CURR"
case "$BUMP_TYPE" in
  patch) NEW="$MAJ.$MIN.$((PAT + 1))" ;;
  minor) NEW="$MAJ.$((MIN + 1)).0" ;;
  major) NEW="$((MAJ + 1)).0.0" ;;
  *) echo "ERRO: bump deve ser patch, minor ou major."; exit 1 ;;
esac
echo "Bump: $CURR → $NEW ($BUMP_TYPE)"
```

### 4. Apresentar plano ao usuário

```
Plugin:          <nome>
Diretório:       <path>
Version atual:   <curr>
Version nova:    <new>
Tipo de bump:    <patch|minor|major>
Commits afetando o plugin desde último bump: <N>

Plano:
  1. Editar marketplace.json: bumpar version para <new>
  2. git commit com mensagem "Bump <nome> para <new>"
  3. git push origin main (se estiver em main) OU pedir merge manual
  4. git -C ~/.claude/plugins/marketplaces/<mkt>/ pull --ff-only
  5. Backup e edit de installed_plugins.json: remover entry <nome>@<mkt>
  6. Copiar clone → cache para o path esperado
  7. Avisar para reiniciar o Claude Code Desktop

Continuar? [y/N]
```

Se o usuário escolher `n`, abortar sem mudanças.

### 5. Bumpar version em marketplace.json

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
jq --arg n "$PLUGIN_NAME" --arg v "$NEW" \
  '(.plugins[] | select(.name == $n) | .version) = $v' \
  .claude-plugin/marketplace.json > /tmp/mkt.new.json
jq . /tmp/mkt.new.json > /dev/null || { echo "ERRO: JSON inválido após edit."; exit 1; }
mv /tmp/mkt.new.json .claude-plugin/marketplace.json
```

### 6. Commit

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
git add .claude-plugin/marketplace.json
git commit -m "Bump $PLUGIN_NAME para $NEW"
```

### 7. Push em main

Se o branch atual é `main`, push direto:

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
if [ "$(git branch --show-current)" = "main" ]; then
  git push origin main
else
  echo "AVISO: você está em branch $(git branch --show-current), não em main."
  echo "O commit foi feito localmente. Faça merge em main quando apropriado."
  echo "Para o Desktop pegar a mudança, main remoto precisa ter este commit."
  echo ""
  echo "Quer fazer o merge agora via worktree temporário? [y/N]"
  read -r answer
  if [ "$answer" = "y" ]; then
    COMMIT_SHA=$(git rev-parse HEAD)
    # Se main não está checked out como worktree, checkout via worktree temporário
    MAIN_WT=$(git worktree list | grep "\[main\]" | awk '{print $1}' | head -1)
    if [ -z "$MAIN_WT" ]; then
      MAIN_WT=/tmp/publish-plugin-main-$$
      git worktree add "$MAIN_WT" main
      CREATED_WT=1
    fi
    (cd "$MAIN_WT" && git merge --ff-only "$COMMIT_SHA" && git push origin main)
    [ -n "$CREATED_WT" ] && git worktree remove "$MAIN_WT"
  else
    echo "Abortando antes de sync do clone. Faça o merge manual e re-rode /publish-plugin."
    exit 0
  fi
fi
```

### 8. Sync no clone local do marketplace

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
MKT_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
CLONE_PATH="$HOME/.claude/plugins/marketplaces/$MKT_NAME"
test -d "$CLONE_PATH" || { echo "AVISO: clone não encontrado em $CLONE_PATH. Pulando sync."; }
git -C "$CLONE_PATH" pull --ff-only
```

### 9. Remover entry do installed_plugins.json

Backup timestamped e edit via jq (nunca regex).

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
BACKUP=~/.claude/plugins/installed_plugins.json.bak-$(date +%Y%m%d-%H%M%S)
cp ~/.claude/plugins/installed_plugins.json "$BACKUP"
echo "Backup: $BACKUP"

KEY="$PLUGIN_NAME@$MKT_NAME"
jq --arg k "$KEY" 'del(.plugins[$k])' ~/.claude/plugins/installed_plugins.json > /tmp/ip.new.json
jq . /tmp/ip.new.json > /dev/null || { echo "ERRO: JSON inválido."; cp "$BACKUP" ~/.claude/plugins/installed_plugins.json; exit 1; }
mv /tmp/ip.new.json ~/.claude/plugins/installed_plugins.json
```

### 10. Copiar clone → cache (workaround do #14061)

Deletar cache antigo da versão anterior, copiar plugin atualizado do clone para o path que a nova install vai usar.

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"
CACHE_DIR="$HOME/.claude/plugins/cache/$MKT_NAME/$PLUGIN_NAME"
mkdir -p "$CACHE_DIR"

# Cleanup de versões antigas do cache desse plugin
find "$CACHE_DIR" -mindepth 1 -maxdepth 1 -type d | while read -r old; do
  echo "Removendo cache antigo: $old"
  rm -rf "$old"
done

# Copiar do clone
SRC="$CLONE_PATH/plugins/$PLUGIN_NAME"
DEST="$CACHE_DIR/$NEW"
cp -R "$SRC" "$DEST"
test -f "$DEST/.claude-plugin/plugin.json" && echo "Cache populado: $DEST"
```

### 11. Confirmar e instruir restart

```
Publicação concluída:
  Plugin:        <nome>
  Nova version:  <new>
  Commit:        <sha>
  Remote:        origin/main atualizado ✓
  Clone local:   pull ok ✓
  Cache:         re-populado em <path> ✓

Reinicie o Claude Code Desktop para o app detectar.

Após restart, valide com:
  jq '.plugins["<nome>@<mkt>"][0] | {version, gitCommitSha}' ~/.claude/plugins/installed_plugins.json

Ou rode /marketplace-qa para sanity check completo.
```

## Tratamento de erros

- **JSON inválido após edit**: restaurar via `git checkout .claude-plugin/marketplace.json`, abortar.
- **Push falha**: reportar erro, não limpar commits locais (deixar pro user decidir).
- **Pull no clone falha (conflito)**: reportar e pedir resolução manual; não aplicar os passos 9-10.
- **Cópia clone→cache falha**: sinalizar e sugerir rodar `/marketplace-qa` depois do restart pra verificar.

## Não-objetivos (v0.1)

- Não detecta o tipo de bump automaticamente via análise de commits. O usuário escolhe (patch/minor/major).
- Não roda `claude plugin validate` antes do commit. Rodar manual se quiser.
- Não reinicia o Claude Code Desktop. Avisa.
- Não atualiza o changelog. Fazer em commit separado se o plugin tem um.
- Não lida com plugins Level 1/2 (usa `/check-marketplace-updates` para esses).
- Não suporta publicar múltiplos plugins numa chamada (um por execução).
