---
description: Diagnóstico de saúde do marketplace local — detecta clone stale, dangling installPaths, version drift e outros estados inconsistentes
---

# /marketplace-qa

Faz um exame completo do estado dos plugins instalados vs. o que o marketplace declara. Produz um relatório com severidades e oferece auto-fix para findings com remédio mecânico.

Cobre os estados inconsistentes causados pelos bugs conhecidos [#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081) do Claude Code.

## Pré-requisitos

- Rodar da raiz de um repo com `.claude-plugin/marketplace.json`
- `jq` instalado
- Acesso de leitura a `~/.claude/plugins/`

## Fluxo

Siga os passos em ordem. Pare no primeiro erro crítico.

### 1. Sanity check

Garantir PATH consistente — o shell snapshot do Claude Code às vezes perde ferramentas mid-execution. Fazer isso **antes** de qualquer `command -v`.

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
command -v jq >/dev/null || { echo "ERRO: jq não instalado."; exit 1; }
command -v git >/dev/null || { echo "ERRO: git não instalado."; exit 1; }
test -f ~/.claude/plugins/installed_plugins.json || { echo "ERRO: installed_plugins.json não encontrado."; exit 1; }
test -f ~/.claude/plugins/known_marketplaces.json || { echo "ERRO: known_marketplaces.json não encontrado."; exit 1; }
```

### 2. Identificar marketplace atual

```bash
MKT_NAME=$(jq -r '.name' .claude-plugin/marketplace.json)
CLONE_PATH="$HOME/.claude/plugins/marketplaces/$MKT_NAME"
test -d "$CLONE_PATH" || { echo "AVISO: clone local do marketplace não encontrado em $CLONE_PATH — plugin não está instalado via esse marketplace ou está com nome diferente."; }
```

### 3. Rodar os checks

Rodar os checks abaixo e agregar findings num array. Cada finding tem: `severity` (high/medium/low), `check_id`, `plugin` (ou `*` para geral), `message`, `auto_fixable` (bool).

#### 3.1 Clone behind remote (MEDIUM)

Mede **sinal direto**: há commits no remote que ainda não foram puxados para o clone local? Substitui o check antigo baseado em `known_marketplaces.json.lastUpdated` (que era um proxy enganoso — só atualizava quando a UI rodava `/plugin marketplace update`, não pelo `git pull` externo).

```bash
if [ -d "$CLONE_PATH" ]; then
  if git -C "$CLONE_PATH" fetch origin --quiet 2>/dev/null; then
    LOCAL_HEAD=$(git -C "$CLONE_PATH" rev-parse HEAD)
    # Detectar o branch trackeado (geralmente origin/main, mas pode ser outro)
    TRACKING=$(git -C "$CLONE_PATH" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "origin/main")
    REMOTE_HEAD=$(git -C "$CLONE_PATH" rev-parse "$TRACKING" 2>/dev/null)
    if [ -n "$REMOTE_HEAD" ] && [ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]; then
      BEHIND=$(git -C "$CLONE_PATH" rev-list --count "$LOCAL_HEAD..$REMOTE_HEAD" 2>/dev/null || echo "?")
      # Finding MEDIUM: clone behind remote ($BEHIND commits)
      # Auto-fix: git -C "$CLONE_PATH" pull --ff-only
      echo "MEDIUM clone-behind-remote: $BEHIND commits atrás de $TRACKING"
    fi
  else
    # Fetch falhou — offline ou credenciais. Finding LOW para não espamar HIGH/MEDIUM.
    # Auto-fix: não (requer intervenção manual — conectar internet ou ajustar credenciais)
    echo "LOW fetch-failed: não consegui fetch em $CLONE_PATH (offline ou auth?)"
  fi
fi
```

Nota: o campo `known_marketplaces.json.lastUpdated` permanece informativo (dá pra exibir no relatório como "última vez que o app sincronizou"), mas não determina staleness.

#### 3.2 Dangling installPath (HIGH)

Plugin em `installed_plugins.json` cujo `installPath` aponta para diretório inexistente.

```bash
jq -r '.plugins | to_entries[] | "\(.key)\t\(.value[0].installPath)"' ~/.claude/plugins/installed_plugins.json | \
  while IFS=$'\t' read -r name path; do
    if [ ! -d "$path" ]; then
      # Finding HIGH: $name installPath inválido ($path)
      # Auto-fix: copiar do clone pro cache
      echo "HIGH dangling-path: $name → $path"
    fi
  done
```

Auto-fix para dangling-path — copiar do clone para o caminho esperado:

```bash
SUBPATH=$(echo "$path" | sed "s|$HOME/.claude/plugins/cache/||")
MKT=$(echo "$SUBPATH" | cut -d/ -f1)
PLUG=$(echo "$SUBPATH" | cut -d/ -f2)
VER=$(echo "$SUBPATH" | cut -d/ -f3)
SRC="$HOME/.claude/plugins/marketplaces/$MKT/plugins/$PLUG"
[ -d "$SRC" ] && cp -R "$SRC" "$path"
```

#### 3.3 Version drift instalado vs. clone (MEDIUM)

`gitCommitSha` em `installed_plugins.json` diferente do HEAD atual do clone do marketplace.

```bash
if [ -d "$CLONE_PATH" ]; then
  CLONE_HEAD=$(git -C "$CLONE_PATH" rev-parse HEAD)
  jq -r --arg m "$MKT_NAME" '.plugins | to_entries[] | select(.key | endswith("@\($m)")) | "\(.key)\t\(.value[0].gitCommitSha)"' ~/.claude/plugins/installed_plugins.json | \
    while IFS=$'\t' read -r name sha; do
      if [ "$sha" != "$CLONE_HEAD" ]; then
        # Finding MEDIUM: $name instalado em ${sha:0:12}, clone em ${CLONE_HEAD:0:12}
        echo "MEDIUM sha-drift: $name ${sha:0:12} vs ${CLONE_HEAD:0:12}"
      fi
    done
fi
```

Nota: esse finding é esperado quando o plugin não mudou desde a instalação — mas se houver commits que afetaram `plugins/<plugin-name>/`, é drift real. Para filtrar, usar `git log ${sha}..${CLONE_HEAD} -- plugins/<plugin-name>/` e só reportar se houver commits.

#### 3.4 Version drift cache vs. marketplace.json (MEDIUM)

Para plugins Level 3, `marketplace.json[].version` diferente de `cache/.../plugin.json.version` (ou do path da pasta de cache).

```bash
jq -r --arg m "$MKT_NAME" '.plugins[] | select(.source | type == "string") | "\(.name)\t\(.version // "none")"' .claude-plugin/marketplace.json | \
  while IFS=$'\t' read -r name mkt_ver; do
    installed_ver=$(jq -r --arg k "$name@$MKT_NAME" '.plugins[$k][0].version // "none"' ~/.claude/plugins/installed_plugins.json)
    if [ "$mkt_ver" != "$installed_ver" ] && [ "$installed_ver" != "none" ]; then
      # Finding MEDIUM: $name marketplace=$mkt_ver instalado=$installed_ver
      echo "MEDIUM version-drift: $name mkt=$mkt_ver installed=$installed_ver"
    fi
  done
```

Auto-fix: rodar `/marketplace-tools:publish-plugin <nome>` com bump adequado ou reinstalar.

#### 3.5 Plugin habilitado mas não instalado (HIGH)

Entry em `settings.json.enabledPlugins` sem correspondência em `installed_plugins.json`.

```bash
jq -r '.enabledPlugins // {} | keys[]' ~/.claude/settings.json | \
  while read -r key; do
    if ! jq -e --arg k "$key" '.plugins[$k]' ~/.claude/plugins/installed_plugins.json >/dev/null 2>&1; then
      # Finding HIGH: $key habilitado mas não instalado
      echo "HIGH enabled-not-installed: $key"
    fi
  done
```

Auto-fix: instalar via UI ou remover do `enabledPlugins` (sem auto-fix mecânico por segurança).

#### 3.6 Cache orphan antigo (LOW)

Diretórios em `cache/<mkt>/<plugin>/<versão>/` não referenciados por `installed_plugins.json` e mais antigos que 7 dias (período de graça oficial expirado).

```bash
find ~/.claude/plugins/cache -maxdepth 3 -mindepth 3 -type d | \
  while read -r dir; do
    mkt=$(basename "$(dirname "$(dirname "$dir")")")
    plug=$(basename "$(dirname "$dir")")
    ver=$(basename "$dir")
    key="$plug@$mkt"
    installed_path=$(jq -r --arg k "$key" '.plugins[$k][0].installPath // empty' ~/.claude/plugins/installed_plugins.json)
    if [ "$installed_path" != "$dir" ]; then
      age_days=$(( ( $(date +%s) - $(stat -f %m "$dir") ) / 86400 ))
      if [ "$age_days" -gt 7 ]; then
        echo "LOW orphan-cache: $key $ver (idade ${age_days}d)"
      fi
    fi
  done
```

Auto-fix: `rm -rf "$dir"`.

### 4. Apresentar relatório

```
=== Marketplace QA: <nome> ===

HIGH (<N>):
  [H1] <plugin>: <mensagem> [auto-fixable: yes/no]
  ...

MEDIUM (<N>):
  [M1] <plugin>: <mensagem> [auto-fixable: yes/no]
  ...

LOW (<N>):
  [L1] <plugin>: <mensagem> [auto-fixable: yes/no]
  ...

Total: <N> findings (<H> high, <M> medium, <L> low)
```

### 5. Auto-fix interativo

Para cada finding com `auto_fixable: yes`, perguntar:

```
[H1] <mensagem>
Fix proposto: <comando/ação>
Aplicar? [A]plicar / [S]kip / [P]arar tudo
```

Processar:
- `A` / `apply` → executar fix, validar, logar resultado
- `S` / `skip` → ir pro próximo
- `P` / `stop` → encerrar

### 6. Relatório final

```
Total findings:     <N>
Auto-fix aplicados: <N>
Pulados:            <N>
Requerem ação manual: <N>
Erros no fix:       <N>
```

Se houver findings `auto_fixable: no`, listar as ações manuais recomendadas ao final.

## Checks não implementados (v0.1)

- Validação de schema do `marketplace.json` (usa `claude plugin validate`)
- Detecção de loops de dependência em `dependencies`
- Comparação cross-marketplace (plugin com mesmo nome em marketplaces diferentes)
- Verificação de `permission` overrides em hooks do plugin

## Tratamento de erros

- **jq fail**: erro específico na stderr + abortar o check específico, continuar com os outros.
- **Clone path inacessível**: reportar como HIGH (`marketplace-clone-missing`) e pular os checks que dependem do clone.
- **`settings.json` ausente**: pular check 3.5.

## Não-objetivos (v0.1)

- Não checa plugins de outros marketplaces (limita-se ao marketplace do repo atual).
- Não atualiza nada automaticamente sem confirmação (step 5 é interativo).
- Não reinicia o Claude Code Desktop (usuário precisa fazer manualmente após fixes).
- Não detecta bugs do plugin em si — só inconsistências de state.
