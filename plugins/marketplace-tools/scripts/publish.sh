#!/usr/bin/env bash
# marketplace-tools publish.sh — publica mudança em plugin Level 3
# Uso: bash scripts/publish.sh <plugin-name> [patch|minor|major]
# Invocado pelo slash command /marketplace-tools:publish-plugin
#
# Encapsula o fluxo manual que os bugs #13799, #14061, #46081 do Claude Code forçam:
#   bump → commit → push → pull no clone → remove entry → copy cache

set -u

# PATH hardening — script roda em processo bash dedicado
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# --- Parsing de args ---
PLUGIN_NAME="${1:-}"
BUMP_TYPE="${2:-patch}"

if [ -z "$PLUGIN_NAME" ]; then
  echo "Uso: bash scripts/publish.sh <plugin-name> [patch|minor|major]"
  exit 1
fi

# --- Sanity check ---
test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
for cmd in jq git; do
  command -v "$cmd" >/dev/null || { echo "ERRO: $cmd não instalado."; exit 1; }
done

# Verificar que o plugin é Level 3
SOURCE_TYPE=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .source | type' .claude-plugin/marketplace.json)
if [ "$SOURCE_TYPE" != "string" ]; then
  echo "ERRO: $PLUGIN_NAME não é Level 3 (source precisa ser string local, tipo './plugins/...')."
  echo "Para Level 1/2, use /marketplace-tools:check-marketplace-updates."
  exit 1
fi

PLUGIN_DIR=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .source' .claude-plugin/marketplace.json)
test -d "$PLUGIN_DIR" || { echo "ERRO: diretório $PLUGIN_DIR não encontrado."; exit 1; }

# --- Detectar mudanças desde último bump ---
LAST_BUMP=$(git log --format=%H -- .claude-plugin/marketplace.json 2>/dev/null | head -1)
if [ -n "$LAST_BUMP" ]; then
  CHANGED=$(git log --format=%H "$LAST_BUMP..HEAD" -- "$PLUGIN_DIR/" 2>/dev/null | wc -l | tr -d ' ')
else
  CHANGED="?"
fi

# --- Calcular nova version ---
CURR=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .version' .claude-plugin/marketplace.json)
IFS=. read -r MAJ MIN PAT <<< "$CURR"
case "$BUMP_TYPE" in
  patch) NEW="$MAJ.$MIN.$((PAT + 1))" ;;
  minor) NEW="$MAJ.$((MIN + 1)).0" ;;
  major) NEW="$((MAJ + 1)).0.0" ;;
  *)     echo "ERRO: bump deve ser patch, minor ou major."; exit 1 ;;
esac

MKT_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
CLONE_PATH="$HOME/.claude/plugins/marketplaces/$MKT_NAME"
BRANCH=$(git branch --show-current)

# --- Apresentar plano ---
echo "Plugin:          $PLUGIN_NAME"
echo "Diretório:       $PLUGIN_DIR"
echo "Version atual:   $CURR"
echo "Version nova:    $NEW ($BUMP_TYPE)"
echo "Branch atual:    $BRANCH"
echo "Commits em $PLUGIN_DIR desde último bump: $CHANGED"
echo ""
echo "Plano:"
echo "  1. Editar marketplace.json: version → $NEW"
echo "  2. git commit"
if [ "$BRANCH" = "main" ]; then
  echo "  3. git push origin main (direto — já em main)"
else
  echo "  3. Merge em main via worktree temporário + push (branch atual: $BRANCH)"
fi
echo "  4. git pull --ff-only em $CLONE_PATH"
echo "  5. Remover entry em installed_plugins.json (com backup)"
echo "  6. Cleanup cache + copy clone → cache/$PLUGIN_NAME/$NEW/"
echo ""
echo "Continuar? [y/N]"
read -r answer
[ "$answer" = "y" ] || [ "$answer" = "Y" ] || { echo "Abortado."; exit 0; }

# --- 1. Bump version em marketplace.json ---
TMPFILE=$(mktemp) || { echo "ERRO: mktemp falhou"; exit 1; }
jq --arg n "$PLUGIN_NAME" --arg v "$NEW" \
  '(.plugins[] | select(.name == $n) | .version) = $v' \
  .claude-plugin/marketplace.json > "$TMPFILE"
jq . "$TMPFILE" > /dev/null || { echo "ERRO: JSON inválido após edit."; rm -f "$TMPFILE"; exit 1; }
mv "$TMPFILE" .claude-plugin/marketplace.json

# --- 2. Commit ---
git add .claude-plugin/marketplace.json
git commit -m "Bump $PLUGIN_NAME para $NEW"
COMMIT_SHA=$(git rev-parse HEAD)

# --- 3. Push em main ---
if [ "$BRANCH" = "main" ]; then
  git push origin main
else
  # Merge via worktree temporário
  REPO_ROOT=$(git rev-parse --show-toplevel)
  # Achar worktree de main
  MAIN_WT=$(git worktree list --porcelain | awk '/^worktree / { wt=$2 } /^branch refs\/heads\/main$/ { print wt }')
  CREATED_WT=""
  if [ -z "$MAIN_WT" ]; then
    MAIN_WT="/tmp/publish-main-$$"
    git worktree add "$MAIN_WT" main
    CREATED_WT=1
  fi
  (cd "$MAIN_WT" && git merge --ff-only "$COMMIT_SHA" && git push origin main)
  [ -n "$CREATED_WT" ] && git worktree remove "$MAIN_WT"
fi

# --- 4. Sync clone local ---
if [ -d "$CLONE_PATH" ]; then
  git -C "$CLONE_PATH" pull --ff-only
else
  echo "AVISO: clone não encontrado em $CLONE_PATH. Pulando sync."
fi

# --- 5. Backup + remover entry em installed_plugins.json ---
INSTALLED="$HOME/.claude/plugins/installed_plugins.json"
BACKUP="$INSTALLED.bak-$(date +%Y%m%d-%H%M%S)-$PLUGIN_NAME"
cp "$INSTALLED" "$BACKUP"
echo "Backup: $BACKUP"

KEY="$PLUGIN_NAME@$MKT_NAME"
TMPIP=$(mktemp) || { echo "ERRO: mktemp falhou"; exit 1; }
jq --arg k "$KEY" 'del(.plugins[$k])' "$INSTALLED" > "$TMPIP"
jq . "$TMPIP" > /dev/null || { echo "ERRO: JSON inválido. Restaurando backup."; cp "$BACKUP" "$INSTALLED"; rm -f "$TMPIP"; exit 1; }
mv "$TMPIP" "$INSTALLED"

# --- 6. Cleanup + copy clone → cache ---
CACHE_DIR="$HOME/.claude/plugins/cache/$MKT_NAME/$PLUGIN_NAME"
mkdir -p "$CACHE_DIR"
rm -rf "${CACHE_DIR:?}"/*   # ${:?} trava se vazio
SRC="$CLONE_PATH/plugins/$PLUGIN_NAME"
if [ -d "$SRC" ]; then
  cp -R "$SRC" "$CACHE_DIR/$NEW"
  if [ -f "$CACHE_DIR/$NEW/.claude-plugin/plugin.json" ]; then
    echo "cache OK: $CACHE_DIR/$NEW"
  else
    echo "AVISO: cache populado mas sem .claude-plugin/plugin.json — verificar"
  fi
else
  echo "ERRO: clone não tem $SRC — cache não populado."
fi

echo ""
echo "Publicação concluída:"
echo "  Plugin:        $PLUGIN_NAME"
echo "  Nova version:  $NEW"
echo "  Commit:        $COMMIT_SHA"
echo "  Clone:         sincronizado"
echo "  Cache:         repopulado em $CACHE_DIR/$NEW"
echo ""
echo "Reinicie o Claude Code Desktop para o app detectar."
echo ""
echo "Após restart, valide com:"
echo "  jq '.plugins[\"$KEY\"][0] | {version, gitCommitSha}' $INSTALLED"
echo "Ou rode /marketplace-tools:marketplace-qa"
