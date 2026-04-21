# Marketplace-tools Onda 1 — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Expandir o plugin `marketplace-tools` de v0.4.0 (3 comandos, 1 inline) para v0.5.0 (5 comandos, todos padrão opção Z) com `/validate` e `/restart-desktop` novos, `/check` migrado, lib compartilhada de checks em `scripts/checks/`, e testes `bats`.

**Architecture:** Sub-scripts standalone em `scripts/checks/` com contrato padronizado (args posicionais → stdout estruturado + exit 0/1/2). `qa.sh` e `validate.sh` invocam os sub-scripts via `bash`. Cada sub-script é testável isoladamente via `bats`. Refactor do `qa.sh` é behavior-preserving (verificado via `diff` de outputs antes/depois).

**Tech Stack:** Bash 5+, jq, gh CLI, git, bats-core (testing). Todos os scripts seguem padrão estabelecido por `qa.sh`/`publish.sh` atuais: `set -Eeuo pipefail`, `trap ERR`, PATH hardening, sanity checks.

**Spec:** [docs/superpowers/specs/2026-04-20-marketplace-tools-onda-1-design.md](../specs/2026-04-20-marketplace-tools-onda-1-design.md)

---

## Pré-requisito — instalar bats-core

Antes de começar, garantir que `bats-core` está instalado (testes da Onda 1 dependem dele):

```bash
command -v bats >/dev/null || brew install bats-core
bats --version
```

Esperado: `Bats 1.x.x` ou superior.

---

## Task 1: Estrutura de diretórios + fixtures

Cria a árvore de diretórios nova e fixtures de teste compartilhadas pelos sub-scripts.

**Files:**
- Create: `plugins/marketplace-tools/scripts/checks/` (diretório)
- Create: `plugins/marketplace-tools/tests/fixtures/marketplace-ok.json`
- Create: `plugins/marketplace-tools/tests/fixtures/marketplace-bad-tags.json`
- Create: `plugins/marketplace-tools/tests/fixtures/marketplace-l3-versioned.json`
- Create: `plugins/marketplace-tools/tests/fixtures/plugin-with-version.json`
- Create: `plugins/marketplace-tools/tests/fixtures/plugin-without-version.json`

- [ ] **Step 1.1: Criar diretórios**

```bash
mkdir -p plugins/marketplace-tools/scripts/checks
mkdir -p plugins/marketplace-tools/tests/fixtures
mkdir -p plugins/marketplace-tools/tests/checks
```

- [ ] **Step 1.2: Criar `tests/fixtures/marketplace-ok.json`**

```json
{
  "name": "test-mkt",
  "owner": {"name": "Test"},
  "metadata": {"description": "fixture"},
  "plugins": [
    {
      "name": "plugin-a",
      "source": "./plugins/plugin-a",
      "version": "1.0.0",
      "tags": ["recomendado"]
    },
    {
      "name": "plugin-b",
      "source": {"source": "url", "url": "https://github.com/x/y.git", "sha": "abc"},
      "tags": ["em-testes"]
    }
  ]
}
```

- [ ] **Step 1.3: Criar `tests/fixtures/marketplace-bad-tags.json`**

```json
{
  "name": "test-mkt",
  "owner": {"name": "Test"},
  "metadata": {"description": "fixture"},
  "plugins": [
    {
      "name": "plugin-bad",
      "source": "./plugins/plugin-bad",
      "version": "1.0.0",
      "tags": ["tag-invalida"]
    }
  ]
}
```

- [ ] **Step 1.4: Criar `tests/fixtures/marketplace-l3-versioned.json`**

```json
{
  "name": "test-mkt",
  "owner": {"name": "Test"},
  "metadata": {"description": "fixture"},
  "plugins": [
    {
      "name": "duplicated",
      "source": "./plugins/duplicated",
      "version": "2.0.0",
      "tags": ["em-testes"]
    }
  ]
}
```

- [ ] **Step 1.5: Criar `tests/fixtures/plugin-with-version.json`**

```json
{
  "name": "duplicated",
  "description": "fixture",
  "version": "1.9.9"
}
```

- [ ] **Step 1.6: Criar `tests/fixtures/plugin-without-version.json`**

```json
{
  "name": "clean-plugin",
  "description": "fixture"
}
```

- [ ] **Step 1.7: Commit**

```bash
git add plugins/marketplace-tools/tests/fixtures/
git commit -m "marketplace-tools: fixtures de teste pros sub-scripts de checks"
```

---

## Task 2: Sub-script `version-duplicated.sh` + testes

Detecta plugins Level 3 com `version` em ambos `plugin.json` e `marketplace.json`. Lógica idêntica ao check 3.7 atual do `qa.sh`.

**Files:**
- Create: `plugins/marketplace-tools/scripts/checks/version-duplicated.sh`
- Create: `plugins/marketplace-tools/tests/checks/version-duplicated.bats`

- [ ] **Step 2.1: Escrever teste happy path que falha**

Criar `plugins/marketplace-tools/tests/checks/version-duplicated.bats`:

```bash
#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/checks/version-duplicated.sh"
FIXTURES="$BATS_TEST_DIRNAME/../fixtures"

setup() {
  TMPDIR_TEST=$(mktemp -d)
  # Simula um plugin Level 3 SEM version em plugin.json
  mkdir -p "$TMPDIR_TEST/clean-plugin/.claude-plugin"
  cp "$FIXTURES/plugin-without-version.json" "$TMPDIR_TEST/clean-plugin/.claude-plugin/plugin.json"
}

teardown() {
  rm -rf "$TMPDIR_TEST"
}

@test "happy path: plugin sem version em plugin.json passa" {
  # marketplace.json tem version pra 'plugin-a', plugin.json não tem version
  mkdir -p "$TMPDIR_TEST/plugin-a/.claude-plugin"
  cp "$FIXTURES/plugin-without-version.json" "$TMPDIR_TEST/plugin-a/.claude-plugin/plugin.json"
  run bash "$SCRIPT" "plugin-a" "$TMPDIR_TEST/plugin-a" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
```

- [ ] **Step 2.2: Rodar teste, verificar que falha (script não existe ainda)**

```bash
cd plugins/marketplace-tools
bats tests/checks/version-duplicated.bats
```

Expected: FAIL (script ainda não existe).

- [ ] **Step 2.3: Criar script mínimo que passa o happy path**

Criar `plugins/marketplace-tools/scripts/checks/version-duplicated.sh`:

```bash
#!/usr/bin/env bash
# Detecta se 'version' está em ambos plugin.json e marketplace.json (bug silencioso documentado).
# Uso: version-duplicated.sh <plugin_name> <plugin_dir> <mkt_json_path>
# Exit: 0 ok, 1 duplicado, 2 uso inválido

set -Eeuo pipefail
trap 'echo "ERRO em version-duplicated.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

PLUGIN_NAME="${1:-}"
PLUGIN_DIR="${2:-}"
MKT_JSON="${3:-}"

if [ -z "$PLUGIN_NAME" ] || [ -z "$PLUGIN_DIR" ] || [ -z "$MKT_JSON" ]; then
  echo "Uso: version-duplicated.sh <plugin_name> <plugin_dir> <mkt_json_path>" >&2
  exit 2
fi

command -v jq >/dev/null || { echo "ERRO: jq não instalado" >&2; exit 2; }
test -f "$MKT_JSON" || { echo "ERRO: $MKT_JSON não existe" >&2; exit 2; }

MKT_VER=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .version // ""' "$MKT_JSON")
[ -z "$MKT_VER" ] && exit 0

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"
[ -f "$PLUGIN_JSON" ] || exit 0

PJS_VER=$(jq -r '.version // ""' "$PLUGIN_JSON")
if [ -n "$PJS_VER" ]; then
  echo "MEDIUM|3.7|$PLUGIN_NAME|version-duplicated: plugin.json=$PJS_VER marketplace.json=$MKT_VER (plugin.json vence silenciosamente)|yes"
  exit 1
fi

exit 0
```

Dar permissão de execução:
```bash
chmod +x plugins/marketplace-tools/scripts/checks/version-duplicated.sh
```

- [ ] **Step 2.4: Rodar teste, confirmar que passa**

```bash
cd plugins/marketplace-tools
bats tests/checks/version-duplicated.bats
```

Expected: `1 test, 0 failures`

- [ ] **Step 2.5: Adicionar teste sad path (version duplicada)**

Apender ao `version-duplicated.bats`:

```bash
@test "sad path: version em ambos → finding MEDIUM + exit 1" {
  mkdir -p "$TMPDIR_TEST/duplicated/.claude-plugin"
  cp "$FIXTURES/plugin-with-version.json" "$TMPDIR_TEST/duplicated/.claude-plugin/plugin.json"
  run bash "$SCRIPT" "duplicated" "$TMPDIR_TEST/duplicated" "$FIXTURES/marketplace-l3-versioned.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"MEDIUM|3.7|duplicated|version-duplicated:"* ]]
  [[ "$output" == *"plugin.json=1.9.9"* ]]
  [[ "$output" == *"marketplace.json=2.0.0"* ]]
}
```

- [ ] **Step 2.6: Rodar teste, confirmar passa**

```bash
cd plugins/marketplace-tools
bats tests/checks/version-duplicated.bats
```

Expected: `2 tests, 0 failures`

- [ ] **Step 2.7: Adicionar testes de edge cases**

Apender:

```bash
@test "edge: plugin.json ausente → exit 0 silencioso" {
  mkdir -p "$TMPDIR_TEST/missing"   # sem .claude-plugin/
  run bash "$SCRIPT" "duplicated" "$TMPDIR_TEST/missing" "$FIXTURES/marketplace-l3-versioned.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "edge: plugin não existe no marketplace.json → exit 0 silencioso" {
  run bash "$SCRIPT" "nao-existe" "$TMPDIR_TEST/clean-plugin" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "edge: args faltando → exit 2" {
  run bash "$SCRIPT" "plugin-a"
  [ "$status" -eq 2 ]
  [[ "$stderr" == *"Uso:"* ]] || [[ "$output" == *"Uso:"* ]]
}

@test "edge: marketplace.json inexistente → exit 2" {
  run bash "$SCRIPT" "plugin-a" "$TMPDIR_TEST/clean-plugin" "/nao/existe.json"
  [ "$status" -eq 2 ]
}
```

- [ ] **Step 2.8: Rodar suite completa, confirmar**

```bash
cd plugins/marketplace-tools
bats tests/checks/version-duplicated.bats
```

Expected: `6 tests, 0 failures`

- [ ] **Step 2.9: Commit**

```bash
git add plugins/marketplace-tools/scripts/checks/version-duplicated.sh
git add plugins/marketplace-tools/tests/checks/version-duplicated.bats
git commit -m "marketplace-tools: sub-script version-duplicated.sh + testes bats"
```

---

## Task 3: Sub-script `tags-valid.sh` + testes

Detecta plugins com `tags[0]` fora do conjunto `{recomendado, em-testes, nao-recomendado}` (convenção do CLAUDE.md deste repo).

**Files:**
- Create: `plugins/marketplace-tools/scripts/checks/tags-valid.sh`
- Create: `plugins/marketplace-tools/tests/checks/tags-valid.bats`

- [ ] **Step 3.1: Criar testes bats (3 casos)**

Criar `plugins/marketplace-tools/tests/checks/tags-valid.bats`:

```bash
#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/checks/tags-valid.sh"
FIXTURES="$BATS_TEST_DIRNAME/../fixtures"

@test "happy path: tags[0]=recomendado → exit 0" {
  run bash "$SCRIPT" "plugin-a" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "happy path: tags[0]=em-testes → exit 0" {
  run bash "$SCRIPT" "plugin-b" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 0 ]
}

@test "sad path: tags[0] inválida → finding + exit 1" {
  run bash "$SCRIPT" "plugin-bad" "$FIXTURES/marketplace-bad-tags.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"MEDIUM|tag-convention|plugin-bad|tags-valid:"* ]]
  [[ "$output" == *"tag-invalida"* ]]
}

@test "edge: args faltando → exit 2" {
  run bash "$SCRIPT"
  [ "$status" -eq 2 ]
}

@test "edge: plugin não existe no marketplace → exit 1 (tags[0] ausente)" {
  run bash "$SCRIPT" "nao-existe" "$FIXTURES/marketplace-ok.json"
  [ "$status" -eq 1 ]
  [[ "$output" == *"tags[0] ausente"* ]]
}
```

- [ ] **Step 3.2: Rodar testes, confirmar que falham (script inexiste)**

```bash
cd plugins/marketplace-tools
bats tests/checks/tags-valid.bats
```

Expected: FAIL

- [ ] **Step 3.3: Criar `scripts/checks/tags-valid.sh`**

```bash
#!/usr/bin/env bash
# Detecta se tags[0] está fora do conjunto {recomendado, em-testes, nao-recomendado}.
# Uso: tags-valid.sh <plugin_name> <mkt_json_path>
# Exit: 0 ok, 1 inválido, 2 uso inválido

set -Eeuo pipefail
trap 'echo "ERRO em tags-valid.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

PLUGIN_NAME="${1:-}"
MKT_JSON="${2:-}"

if [ -z "$PLUGIN_NAME" ] || [ -z "$MKT_JSON" ]; then
  echo "Uso: tags-valid.sh <plugin_name> <mkt_json_path>" >&2
  exit 2
fi

command -v jq >/dev/null || { echo "ERRO: jq não instalado" >&2; exit 2; }
test -f "$MKT_JSON" || { echo "ERRO: $MKT_JSON não existe" >&2; exit 2; }

TAG0=$(jq -r --arg n "$PLUGIN_NAME" '.plugins[] | select(.name == $n) | .tags[0] // ""' "$MKT_JSON")

if [ -z "$TAG0" ]; then
  echo "MEDIUM|tag-convention|$PLUGIN_NAME|tags-valid: tags[0] ausente (esperado: recomendado/em-testes/nao-recomendado)|no"
  exit 1
fi

case "$TAG0" in
  recomendado|em-testes|nao-recomendado) exit 0 ;;
  *)
    echo "MEDIUM|tag-convention|$PLUGIN_NAME|tags-valid: tags[0]='$TAG0' fora do conjunto permitido (recomendado/em-testes/nao-recomendado)|no"
    exit 1
    ;;
esac
```

```bash
chmod +x plugins/marketplace-tools/scripts/checks/tags-valid.sh
```

- [ ] **Step 3.4: Rodar suite, confirmar 5 passam**

```bash
cd plugins/marketplace-tools
bats tests/checks/tags-valid.bats
```

Expected: `5 tests, 0 failures`

- [ ] **Step 3.5: Commit**

```bash
git add plugins/marketplace-tools/scripts/checks/tags-valid.sh
git add plugins/marketplace-tools/tests/checks/tags-valid.bats
git commit -m "marketplace-tools: sub-script tags-valid.sh + testes bats"
```

---

## Task 4: Sub-script `semver-valid.sh` + testes

Valida formato SemVer (regex). Simples — quase trivial, mas mantém padrão TDD.

**Files:**
- Create: `plugins/marketplace-tools/scripts/checks/semver-valid.sh`
- Create: `plugins/marketplace-tools/tests/checks/semver-valid.bats`

- [ ] **Step 4.1: Criar testes bats**

Criar `plugins/marketplace-tools/tests/checks/semver-valid.bats`:

```bash
#!/usr/bin/env bats

SCRIPT="$BATS_TEST_DIRNAME/../../scripts/checks/semver-valid.sh"

@test "happy: 1.0.0 válido" {
  run bash "$SCRIPT" "1.0.0" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "happy: 0.4.0 válido" {
  run bash "$SCRIPT" "0.4.0" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "happy: 1.2.3-alpha.1 válido (pre-release)" {
  run bash "$SCRIPT" "1.2.3-alpha.1" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "happy: 1.2.3+build.1 válido (build metadata)" {
  run bash "$SCRIPT" "1.2.3+build.1" "plugin-x"
  [ "$status" -eq 0 ]
}

@test "sad: 1.0 inválido (só dois segmentos) → finding + exit 1" {
  run bash "$SCRIPT" "1.0" "plugin-x"
  [ "$status" -eq 1 ]
  [[ "$output" == *"LOW|semver-invalid|plugin-x|semver-invalid:"* ]]
  [[ "$output" == *"'1.0'"* ]]
}

@test "sad: v1.0.0 inválido (prefixo v) → exit 1" {
  run bash "$SCRIPT" "v1.0.0" "plugin-x"
  [ "$status" -eq 1 ]
}

@test "sad: string vazia → exit 2" {
  run bash "$SCRIPT" "" "plugin-x"
  [ "$status" -eq 2 ]
}

@test "sad: plugin_name faltando → exit 2" {
  run bash "$SCRIPT" "1.0.0"
  [ "$status" -eq 2 ]
}
```

- [ ] **Step 4.2: Rodar, confirmar falha**

```bash
cd plugins/marketplace-tools
bats tests/checks/semver-valid.bats
```

Expected: FAIL

- [ ] **Step 4.3: Criar `scripts/checks/semver-valid.sh`**

```bash
#!/usr/bin/env bash
# Valida se version casa com SemVer (https://semver.org).
# Uso: semver-valid.sh <version_string> <plugin_name>
# Exit: 0 ok, 1 inválido, 2 uso inválido

set -Eeuo pipefail
trap 'echo "ERRO em semver-valid.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

VERSION="${1:-}"
PLUGIN_NAME="${2:-}"

if [ -z "$VERSION" ] || [ -z "$PLUGIN_NAME" ]; then
  echo "Uso: semver-valid.sh <version_string> <plugin_name>" >&2
  exit 2
fi

SEMVER_RE='^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$'

if [[ "$VERSION" =~ $SEMVER_RE ]]; then
  exit 0
fi

echo "LOW|semver-invalid|$PLUGIN_NAME|semver-invalid: '$VERSION' não casa com SemVer (formato esperado: MAJOR.MINOR.PATCH[-pre][+build])|no"
exit 1
```

```bash
chmod +x plugins/marketplace-tools/scripts/checks/semver-valid.sh
```

- [ ] **Step 4.4: Rodar suite, confirmar 8 passam**

```bash
cd plugins/marketplace-tools
bats tests/checks/semver-valid.bats
```

Expected: `8 tests, 0 failures`

- [ ] **Step 4.5: Rodar suite completa da lib, confirmar tudo passa**

```bash
cd plugins/marketplace-tools
bats tests/checks/
```

Expected: `19 tests, 0 failures` (6 + 5 + 8)

- [ ] **Step 4.6: Commit**

```bash
git add plugins/marketplace-tools/scripts/checks/semver-valid.sh
git add plugins/marketplace-tools/tests/checks/semver-valid.bats
git commit -m "marketplace-tools: sub-script semver-valid.sh + testes bats"
```

---

## Task 5: Refactor `qa.sh` para usar `version-duplicated.sh` (behavior-preserving)

Extrai o check 3.7 inline de `qa.sh` pra chamada do sub-script. Garantir que output é **idêntico** antes/depois.

**Files:**
- Modify: `plugins/marketplace-tools/scripts/qa.sh:118-131` (bloco do check 3.7)

- [ ] **Step 5.1: Capturar output atual de `qa.sh` (baseline)**

Rodar a partir da raiz do repo:

```bash
cd /Users/andrejunges/repos/aj-openworkspace/.claude/worktrees/lucid-greider-6c1747
bash plugins/marketplace-tools/scripts/qa.sh > /tmp/qa-before.txt 2>&1 || true
head -5 /tmp/qa-before.txt
wc -l /tmp/qa-before.txt
```

Guardar o output pra comparar após o refactor.

- [ ] **Step 5.2: Editar `plugins/marketplace-tools/scripts/qa.sh` — substituir bloco 3.7**

Localizar o bloco atual no arquivo (linhas ~118-131 — verificar antes com `grep -n "3.7 Version duplicated"`):

```bash
# ---------------- 3.7 Version duplicated (plugin.json vs marketplace.json) ----------------
# Doc oficial: "avoid setting the version in both places. The plugin manifest always wins silently".
# Se plugin.json tem version E marketplace.json tem version pra mesma entry, o plugin.json vence
# e o bump em marketplace.json fica invisível (bug silencioso já sentido na pele).
jq -r --arg m "$MKT_NAME" '.plugins[] | select(.source | type == "string") | "\(.name)\t\(.source)\t\(.version // "")"' "$MKT_JSON" > "$TMPDIR_QA/l3.tsv"
while IFS=$'\t' read -r name plugin_dir mkt_ver; do
  [ -z "$mkt_ver" ] && continue       # sem version em marketplace.json → não há duplicação possível
  plugin_json_path="$plugin_dir/.claude-plugin/plugin.json"
  [ -f "$plugin_json_path" ] || continue
  pjs_ver=$(jq -r '.version // ""' "$plugin_json_path" 2>/dev/null || echo "")
  if [ -n "$pjs_ver" ]; then
    echo "MEDIUM|3.7|$name|version-duplicated: plugin.json=$pjs_ver marketplace.json=$mkt_ver (plugin.json vence silenciosamente)|yes" >> "$FINDINGS"
  fi
done < "$TMPDIR_QA/l3.tsv"
```

Substituir por:

```bash
# ---------------- 3.7 Version duplicated (plugin.json vs marketplace.json) ----------------
# Doc oficial: "avoid setting the version in both places. The plugin manifest always wins silently".
# Lógica extraída pra sub-script reutilizado por /validate (ver scripts/checks/version-duplicated.sh).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
jq -r '.plugins[] | select(.source | type == "string") | "\(.name)\t\(.source)"' "$MKT_JSON" > "$TMPDIR_QA/l3.tsv"
while IFS=$'\t' read -r name plugin_dir; do
  bash "$SCRIPT_DIR/checks/version-duplicated.sh" "$name" "$plugin_dir" "$MKT_JSON" >> "$FINDINGS" || true
done < "$TMPDIR_QA/l3.tsv"
```

Nota: o `|| true` evita que exit 1 do sub-script aborte o qa.sh (que roda com `set -e`). Findings vão pro `$FINDINGS` de qualquer jeito.

- [ ] **Step 5.3: Rodar `qa.sh` novamente, capturar output novo**

```bash
bash plugins/marketplace-tools/scripts/qa.sh > /tmp/qa-after.txt 2>&1 || true
diff /tmp/qa-before.txt /tmp/qa-after.txt
```

Expected: **zero output** (diff vazio = behavior-preserving).

Se houver diff, diagnosticar: diferença de mensagem, ordem de plugins L3 no loop, espaços em branco. Ajustar até diff ser vazio.

- [ ] **Step 5.4: Commit**

```bash
git add plugins/marketplace-tools/scripts/qa.sh
git commit -m "marketplace-tools: refactor qa.sh check 3.7 pra usar sub-script (behavior-preserving)"
```

---

## Task 6: Comando `/validate` — script + markdown

Orquestrador que roda `claude plugin validate` + todos os sub-scripts da lib.

**Files:**
- Create: `plugins/marketplace-tools/scripts/validate.sh`
- Create: `plugins/marketplace-tools/commands/validate.md`

- [ ] **Step 6.1: Criar `scripts/validate.sh`**

```bash
#!/usr/bin/env bash
# marketplace-tools validate.sh — validação pré-commit do marketplace
# Uso: bash scripts/validate.sh
# Invocado pelo slash command /marketplace-tools:validate
#
# Roda:
#   1. claude plugin validate .
#   2. scripts/checks/tags-valid.sh pra cada plugin
#   3. scripts/checks/semver-valid.sh pra plugins com version
#   4. scripts/checks/version-duplicated.sh pra plugins Level 3

set -Eeuo pipefail
trap 'echo "ERRO em validate.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz do repo do marketplace."; exit 1; }
command -v jq >/dev/null || { echo "ERRO: jq não instalado."; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MKT_JSON=".claude-plugin/marketplace.json"
FINDINGS=$(mktemp) || { echo "ERRO: mktemp falhou"; exit 1; }
trap 'rm -f "$FINDINGS"' EXIT
FAIL=0

echo "=== /validate ==="

# 1. claude plugin validate
if command -v claude >/dev/null 2>&1; then
  echo ""
  echo "[1/2] claude plugin validate ."
  if ! claude plugin validate .; then
    FAIL=1
  fi
else
  echo "[1/2] AVISO: 'claude' CLI não disponível — pulando schema validation."
fi

echo ""
echo "[2/2] Checks custom de convenção..."

# Helper: roda sub-script e trata exit code
run_check() {
  local check_name="$1"
  shift
  set +e
  bash "$SCRIPT_DIR/checks/$check_name" "$@" >> "$FINDINGS"
  local rc=$?
  set -e
  case $rc in
    0) ;;
    1) FAIL=1 ;;
    *) echo "ERRO: $check_name retornou exit $rc (uso inválido)" >&2; exit 3 ;;
  esac
}

# 2. Por plugin: tags-valid + semver-valid + version-duplicated (L3 only)
jq -r '.plugins[] | [.name, (.source | if type == "string" then . else "" end), (.version // "")] | @tsv' "$MKT_JSON" > "$FINDINGS.plugins"

while IFS=$'\t' read -r name plugin_dir version; do
  run_check "tags-valid.sh" "$name" "$MKT_JSON"
  if [ -n "$version" ]; then
    run_check "semver-valid.sh" "$version" "$name"
  fi
  if [ -n "$plugin_dir" ]; then
    run_check "version-duplicated.sh" "$name" "$plugin_dir" "$MKT_JSON"
  fi
done < "$FINDINGS.plugins"
rm -f "$FINDINGS.plugins"

# 3. Relatório
count_sev() { awk -F'|' -v s="$1" '$1==s{n++}END{print n+0}' "$FINDINGS"; }
N_HIGH=$(count_sev HIGH)
N_MED=$(count_sev MEDIUM)
N_LOW=$(count_sev LOW)
N_TOTAL=$((N_HIGH + N_MED + N_LOW))

echo ""
if [ "$N_TOTAL" -eq 0 ] && [ "$FAIL" -eq 0 ]; then
  echo "Validação OK — sem findings."
  exit 0
fi

if [ "$N_HIGH" -gt 0 ]; then
  echo "HIGH ($N_HIGH):"
  awk -F'|' '$1=="HIGH"{printf "  [%s] %s: %s\n", $2, $3, $4}' "$FINDINGS"
  echo ""
fi
if [ "$N_MED" -gt 0 ]; then
  echo "MEDIUM ($N_MED):"
  awk -F'|' '$1=="MEDIUM"{printf "  [%s] %s: %s\n", $2, $3, $4}' "$FINDINGS"
  echo ""
fi
if [ "$N_LOW" -gt 0 ]; then
  echo "LOW ($N_LOW):"
  awk -F'|' '$1=="LOW"{printf "  [%s] %s: %s\n", $2, $3, $4}' "$FINDINGS"
  echo ""
fi
echo "Total: $N_TOTAL findings ($N_HIGH high, $N_MED medium, $N_LOW low)"
exit 1
```

```bash
chmod +x plugins/marketplace-tools/scripts/validate.sh
```

- [ ] **Step 6.2: Smoke test — rodar no repo atual**

```bash
bash plugins/marketplace-tools/scripts/validate.sh
```

Expected: sai com 0 ou 1 (dependendo do estado atual), sem erros de execução do script em si. Se houver findings reais, anotar — pode precisar ser corrigido em task separada ou já confirmam que validate detecta coisas.

- [ ] **Step 6.3: Criar `commands/validate.md`**

```markdown
---
description: Valida o marketplace pré-commit — schema oficial + convenções (tags, SemVer, version duplicada em L3)
---

# /validate

Roda validação completa do marketplace do repo atual. Combina o validator oficial da Anthropic com checks de convenção específicos deste marketplace.

## Quando usar

Antes de commitar mudanças em `marketplace.json` ou em plugins Level 3. Também útil pós-merge de branches externas pra sanity check rápido.

## Execução

A lógica vive em `scripts/validate.sh`:

\`\`\`bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh
\`\`\`

Sem argumentos. Saída estruturada com findings agrupados por severidade.

## O que o script faz

1. **Roda `claude plugin validate .`** — schema oficial do marketplace.json e plugin.json. Se o CLI `claude` não estiver no PATH, pula com aviso.
2. **Pra cada plugin** no catálogo:
   - `tags-valid.sh` — `tags[0]` ∈ `{recomendado, em-testes, nao-recomendado}` (convenção deste marketplace)
   - `semver-valid.sh` — se tem `version`, precisa ser SemVer válido
   - `version-duplicated.sh` — plugins Level 3 não podem ter `version` em ambos plugin.json e marketplace.json (bug silencioso documentado pela Anthropic)
3. **Relatório** — agrupa findings por severidade (HIGH/MEDIUM/LOW), emite total.

Exit 0 = sem findings. Exit 1 = algum finding. Exit 3 = erro interno (sub-script com uso inválido).

## Tratamento de erros

- **`claude` CLI ausente**: pula schema validation, continua checks custom. Não é erro fatal.
- **Sub-script com uso inválido** (exit 2 ou outro): aborta validate com exit 3 — indica bug no próprio validate, não no repo.
- **jq ausente**: aborta com exit 1.

## Não-objetivos

- Não corrige findings automaticamente (só reporta).
- Não cobre plugins de outros marketplaces (só o do repo atual).
- Não verifica availability de URLs de Level 1/2 (isso é responsabilidade do `/check-marketplace-updates`).
- Não valida prose/estilo de `description` dos plugins.

## Testar o script isoladamente

Fora do Claude Code, da raiz do repo:

\`\`\`bash
bash plugins/marketplace-tools/scripts/validate.sh
\`\`\`
```

Nota: remover os backticks de escape (`\`\`\``) ao criar o arquivo real — era só pra não quebrar o markdown deste plan.

- [ ] **Step 6.4: Commit**

```bash
git add plugins/marketplace-tools/scripts/validate.sh
git add plugins/marketplace-tools/commands/validate.md
git commit -m "marketplace-tools: comando /validate + scripts/validate.sh"
```

---

## Task 7: Comando `/restart-desktop` — script + markdown

**Files:**
- Create: `plugins/marketplace-tools/scripts/restart.sh`
- Create: `plugins/marketplace-tools/commands/restart-desktop.md`

- [ ] **Step 7.1: Criar `scripts/restart.sh`**

```bash
#!/usr/bin/env bash
# marketplace-tools restart.sh — reinicia o Claude Code Desktop
# Uso: bash scripts/restart.sh
# Invocado pelo slash command /marketplace-tools:restart-desktop

set -Eeuo pipefail
trap 'echo "ERRO em restart.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

echo "Reiniciar Claude Code Desktop? [y/N]"
read -r answer
case "$answer" in
  y|Y) ;;
  *) echo "Abortado."; exit 0 ;;
esac

if ! osascript -e 'tell application "Claude" to quit' 2>/dev/null; then
  echo ""
  echo "AVISO: osascript falhou. Possíveis causas:"
  echo "  - App não está aberto"
  echo "  - App travado (Force Quit via Cmd+Option+Esc)"
  echo "  - macOS security: dar permissão em System Settings → Privacy → Automation"
  echo ""
  echo "Tentando abrir mesmo assim..."
fi

# Pequeno delay pra garantir quit completou antes de open
sleep 2

open -a "Claude"
echo "Claude Code Desktop (re)iniciado."
```

```bash
chmod +x plugins/marketplace-tools/scripts/restart.sh
```

- [ ] **Step 7.2: Criar `commands/restart-desktop.md`**

```markdown
---
description: Reinicia o Claude Code Desktop — útil após publicar plugin Level 3 pra app detectar nova version
---

# /restart-desktop

Encerra o Claude Code Desktop e abre de novo. Utilidade principal: após rodar `/publish-plugin`, o app precisa ser reiniciado pra detectar a nova entry em `installed_plugins.json`.

## Quando usar

- Logo após `/publish-plugin <nome>` completar
- Quando suspeitar que o app está com cache stale (ex: plugin atualizado não reflete no menu)
- Debug de estados inconsistentes pós-`/marketplace-qa` com HIGH findings

## Execução

A lógica vive em `scripts/restart.sh`:

\`\`\`bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/restart.sh
\`\`\`

O script pede confirmação `[y/N]` antes de fechar o app. Sem argumentos.

## O que o script faz

1. Prompt `[y/N]` — abortar se diferente de `y`/`Y`
2. `osascript -e 'tell application "Claude" to quit'` — quit gentil (salva estado, fecha janelas)
3. `sleep 2` — aguarda quit completar
4. `open -a "Claude"` — reabre

## Tratamento de erros

- **osascript falha**: geralmente significa que o app não está aberto, travou, ou falta permissão de Automation. Script mostra diagnóstico e tenta `open` mesmo assim.
- **App travado hard**: se `osascript` não funciona, o usuário precisa forçar quit manualmente (`Cmd+Option+Esc`) ou via terminal (`killall Claude`) — o script **não** faz kill automático (destrutivo).

## Não-objetivos

- Não funciona fora do macOS (usa AppleScript via `osascript` e `open -a`).
- Não garante que plugins recém-publicados serão detectados — isso depende do app ler `installed_plugins.json` no startup (o que ele faz, mas sem garantia).
- Não suporta nome do app diferente de "Claude" (se você tem uma build custom, ajustar o script).

## Testar o script isoladamente

Fora do Claude Code:

\`\`\`bash
bash plugins/marketplace-tools/scripts/restart.sh
\`\`\`

(Só testar quando for oportuno fechar o app.)
```

- [ ] **Step 7.3: Commit**

```bash
git add plugins/marketplace-tools/scripts/restart.sh
git add plugins/marketplace-tools/commands/restart-desktop.md
git commit -m "marketplace-tools: comando /restart-desktop + scripts/restart.sh"
```

---

## Task 8: Migração `/check` — `scripts/check.sh` dry-run

Migra a lógica de dry-run do comando `/check-marketplace-updates` pro script. A lógica de `--apply` vem na Task 9.

**Files:**
- Create: `plugins/marketplace-tools/scripts/check.sh`

- [ ] **Step 8.1: Criar `scripts/check.sh` com modo dry-run**

```bash
#!/usr/bin/env bash
# marketplace-tools check.sh — verifica updates em plugins Level 2 do marketplace
# Uso:
#   bash scripts/check.sh              → dry-run, emite TSV de updates disponíveis em stdout
#   bash scripts/check.sh --apply N1 N2 → aplica updates nos plugins listados (commit individual)
#
# Invocado pelo slash command /marketplace-tools:check-marketplace-updates

set -Eeuo pipefail
trap 'echo "ERRO em check.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

# --- Parse args ---
MODE="dry-run"
APPLY_LIST=()
if [ "${1:-}" = "--apply" ]; then
  MODE="apply"
  shift
  if [ "$#" -eq 0 ]; then
    echo "Uso: check.sh --apply <plugin1> [plugin2] ..." >&2
    exit 2
  fi
  APPLY_LIST=("$@")
fi

# --- Sanity ---
test -f .claude-plugin/marketplace.json || { echo "ERRO: rode da raiz de um repo com marketplace."; exit 1; }
for cmd in gh jq git awk sed; do
  command -v "$cmd" >/dev/null || { echo "ERRO: $cmd não instalado."; exit 1; }
done
gh auth status >/dev/null 2>&1 || { echo "ERRO: gh não autenticado. Rode 'gh auth login'."; exit 1; }

MKT_JSON=".claude-plugin/marketplace.json"
TMPDIR_CHECK=$(mktemp -d) || { echo "ERRO: mktemp -d falhou"; exit 1; }
trap 'rm -rf "$TMPDIR_CHECK"' EXIT

# --- Helper: resolve HEAD atual do upstream ---
resolve_head() {
  local source_type="$1" url="$2" ref="$3"
  case "$source_type" in
    url)
      git ls-remote "$url" "$ref" 2>/dev/null | awk '{print $1}' | head -1
      ;;
    git-subdir)
      local owner_repo
      owner_repo=$(echo "$url" | sed -E 's|https://github.com/([^/]+/[^/]+)(\.git)?$|\1|')
      gh api "repos/$owner_repo/commits/$ref" --jq '.sha' 2>/dev/null || echo ""
      ;;
    *)
      echo ""
      ;;
  esac
}

# --- Helper: emite TSV line pra plugin com update ---
check_plugin() {
  local name="$1" source_type="$2" url="$3" path_prefix="$4" ref="$5" old_sha="$6"
  local new_sha
  new_sha=$(resolve_head "$source_type" "$url" "$ref")
  if [ -z "$new_sha" ]; then
    echo "ERRO: não consegui resolver HEAD de $name ($source_type $url $ref)" >&2
    return
  fi
  [ "$new_sha" = "$old_sha" ] && return  # sem update

  local owner_repo
  owner_repo=$(echo "$url" | sed -E 's|https://github.com/([^/]+/[^/]+)(\.git)?$|\1|')
  local compare
  compare=$(gh api "repos/$owner_repo/compare/$old_sha...$new_sha" 2>/dev/null) || {
    echo "ERRO: gh compare falhou para $name" >&2
    return
  }

  local file_count
  if [ "$source_type" = "git-subdir" ] && [ -n "$path_prefix" ]; then
    file_count=$(echo "$compare" | jq -r --arg p "$path_prefix/" '.files[]? | select(.filename | startswith($p)) | .filename' | wc -l | tr -d ' ')
  else
    file_count=$(echo "$compare" | jq '.files | length')
  fi

  [ "$file_count" -eq 0 ] && return  # SHA mudou mas nenhum arquivo relevante

  local commit_count breaking top_commits
  commit_count=$(echo "$compare" | jq '.commits | length')
  if echo "$compare" | jq -r '.commits[] | .commit.message' | grep -qiE 'BREAKING|breaking:|!:'; then
    breaking="yes"
  else
    breaking="no"
  fi
  top_commits=$(echo "$compare" | jq -r '.commits[:5][] | .commit.message | split("\n")[0]' | paste -sd '|' -)

  printf "%s\t%s\t%s\t%d\t%d\t%s\t%s\n" "$name" "${old_sha:0:12}" "${new_sha:0:12}" "$commit_count" "$file_count" "$breaking" "$top_commits"
}

# --- Extrair plugins Level 2 (com SHA) ---
jq -r '.plugins[] | select((.source | type) == "object" and .source.sha) | [.name, .source.source, .source.url, .source.path // "", .source.ref // "main", .source.sha] | @tsv' "$MKT_JSON" > "$TMPDIR_CHECK/l2.tsv"

if [ ! -s "$TMPDIR_CHECK/l2.tsv" ]; then
  echo "Nenhum plugin Level 2 (SHA pinnado) em $MKT_JSON." >&2
  exit 0
fi

# --- Modo dry-run ---
if [ "$MODE" = "dry-run" ]; then
  printf "PLUGIN\tOLD_SHA\tNEW_SHA\tCOMMITS\tFILES\tBREAKING\tTOP_COMMITS\n"
  while IFS=$'\t' read -r name source_type url path_prefix ref old_sha; do
    check_plugin "$name" "$source_type" "$url" "$path_prefix" "$ref" "$old_sha"
  done < "$TMPDIR_CHECK/l2.tsv"
  exit 0
fi

# --- Modo --apply é na Task 9 ---
echo "ERRO: modo --apply ainda não implementado (Task 9)." >&2
exit 1
```

```bash
chmod +x plugins/marketplace-tools/scripts/check.sh
```

- [ ] **Step 8.2: Smoke test — rodar dry-run**

```bash
cd /Users/andrejunges/repos/aj-openworkspace/.claude/worktrees/lucid-greider-6c1747
bash plugins/marketplace-tools/scripts/check.sh
```

Expected: linha de header TSV, seguida por zero ou mais linhas de plugins com update. Sem erros de execução. Dependendo do estado do upstream, pode haver 0 updates — o importante é rodar até o fim sem erro.

- [ ] **Step 8.3: Validar formato do TSV**

```bash
bash plugins/marketplace-tools/scripts/check.sh | awk -F'\t' '{print NF}' | sort -u
```

Expected: `7` (todas as linhas têm exatamente 7 campos).

- [ ] **Step 8.4: Commit**

```bash
git add plugins/marketplace-tools/scripts/check.sh
git commit -m "marketplace-tools: scripts/check.sh modo dry-run (migração do inline)"
```

---

## Task 9: `scripts/check.sh` modo `--apply`

Adiciona lógica de aplicação seletiva. Commit individual por plugin.

**Files:**
- Modify: `plugins/marketplace-tools/scripts/check.sh` (seção final)

- [ ] **Step 9.1: Editar `scripts/check.sh` — substituir placeholder `--apply`**

Localizar o bloco final:

```bash
# --- Modo --apply é na Task 9 ---
echo "ERRO: modo --apply ainda não implementado (Task 9)." >&2
exit 1
```

Substituir por:

```bash
# --- Helper: aplica update pra um plugin (edit jq + commit) ---
apply_plugin() {
  local name="$1" source_type="$2" url="$3" ref="$4" old_sha="$5"
  local new_sha
  new_sha=$(resolve_head "$source_type" "$url" "$ref")
  if [ -z "$new_sha" ]; then
    echo "ERRO: não consegui resolver $name" >&2
    return 1
  fi
  if [ "$new_sha" = "$old_sha" ]; then
    echo "SKIP: $name já está no HEAD ($old_sha)."
    return 0
  fi

  local tmp
  tmp=$(mktemp) || { echo "ERRO: mktemp falhou"; return 1; }
  jq --arg n "$name" --arg s "$new_sha" '(.plugins[] | select(.name == $n) | .source.sha) = $s' "$MKT_JSON" > "$tmp"
  if ! jq . "$tmp" > /dev/null; then
    echo "ERRO: JSON inválido após edit para $name"
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$MKT_JSON"

  git add "$MKT_JSON"
  git commit -m "bump $name para ${new_sha:0:12}"
  echo "OK: $name → ${new_sha:0:12}"
  return 0
}

# --- Modo --apply ---
errors=0
applied=0
skipped=0
for target in "${APPLY_LIST[@]}"; do
  line=$(awk -F'\t' -v n="$target" '$1==n{print; exit}' "$TMPDIR_CHECK/l2.tsv")
  if [ -z "$line" ]; then
    echo "SKIP: $target não é Level 2 ou não está em $MKT_JSON" >&2
    skipped=$((skipped + 1))
    continue
  fi
  IFS=$'\t' read -r name source_type url _path_prefix ref old_sha <<< "$line"
  if apply_plugin "$name" "$source_type" "$url" "$ref" "$old_sha"; then
    applied=$((applied + 1))
  else
    errors=$((errors + 1))
  fi
done

echo ""
echo "Resumo: aplicados=$applied, skipped=$skipped, erros=$errors"
[ "$errors" -gt 0 ] && exit 1 || exit 0
```

- [ ] **Step 9.2: Smoke test — rodar `--apply` com plugin inválido (não deve fazer nada destrutivo)**

```bash
bash plugins/marketplace-tools/scripts/check.sh --apply plugin-nao-existe
```

Expected: `SKIP: plugin-nao-existe não é Level 2 ...`, resumo com skipped=1, exit 0.

Confirma que o script não aborta e não faz commit espúrio.

- [ ] **Step 9.3: Verificar git status limpo**

```bash
git status
```

Expected: nenhuma mudança em `.claude-plugin/marketplace.json`. Se houver, é bug — investigar.

- [ ] **Step 9.4: Commit**

```bash
git add plugins/marketplace-tools/scripts/check.sh
git commit -m "marketplace-tools: scripts/check.sh modo --apply com commit individual"
```

---

## Task 10: Reduzir `commands/check-marketplace-updates.md` pro padrão opção Z

Hoje o `.md` tem ~186 linhas com bash inline em code blocks. Reduzir pro padrão dos outros comandos (70-100 linhas, sem bash operacional).

**Files:**
- Modify: `plugins/marketplace-tools/commands/check-marketplace-updates.md` (reescrita completa)

- [ ] **Step 10.1: Substituir `commands/check-marketplace-updates.md` por versão reduzida**

Apagar todo o conteúdo atual e substituir por:

```markdown
---
description: Verifica updates nos plugins com SHA pinnado no marketplace e aplica seletivamente sob confirmação
---

# /check-marketplace-updates

Verifica cada plugin Level 2 (com `source.sha`) em `.claude-plugin/marketplace.json` contra o HEAD atual do upstream e apresenta updates disponíveis. Aplica os selecionados pelo usuário via commits individuais.

## Quando usar

- Periodicamente (ex: quinzenal) pra manter SHAs pinnados atualizados
- Antes de qualquer release ou push grande do marketplace
- Pós-incidente (plugin upstream teve bug corrigido que precisamos absorver)

## Execução em duas etapas

O script é non-interativo por design — a interação mora no chat entre você e eu. Fluxo:

### Etapa 1 — dry-run

\`\`\`bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/check.sh
\`\`\`

O script emite um TSV em stdout com o header `PLUGIN OLD_SHA NEW_SHA COMMITS FILES BREAKING TOP_COMMITS`. Apresento o TSV formatado pra você (um bloco por plugin) e pergunto quais aplicar. Se não houver updates, a tabela fica com só o header.

### Etapa 2 — apply seletivo

Após sua seleção, invoco:

\`\`\`bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/check.sh --apply plugin1 plugin2 ...
\`\`\`

O script aplica em sequência — um commit por plugin no formato `bump <nome> para <short-sha>`. Erros em plugins individuais não abortam o batch (sumário final mostra quantos falharam).

## O que o script detecta

Pra cada plugin Level 2 (`source.sha` pinnado):

- **Resolve HEAD atual do upstream**:
  - `source.source == "url"` → `git ls-remote`
  - `source.source == "git-subdir"` → `gh api /repos/{owner}/{repo}/commits/{ref}`
- **Compara com SHA pinnado**
- **Se mudou**: fetch compare via `gh api`, extrai:
  - Número de commits entre SHAs
  - Número de arquivos (filtrado por `source.path` se git-subdir)
  - Detecção de breaking via keyword em commit messages (`BREAKING`, `breaking:`, `!:`)
  - Top 5 mensagens de commit
- **Se SHA mudou mas nenhum arquivo relevante foi alterado**: silencia (não emite linha).

## Tratamento de erros

- **Upstream inacessível**: loga erro em stderr e segue pro próximo plugin. Dry-run completa com os plugins que deu pra resolver.
- **Rate limit do `gh`**: mensagem explicativa em stderr; plugins subsequentes podem falhar até reset.
- **JSON inválido após edit**: aborta o plugin específico, restaura via git (o edit não chega a ser committed).
- **`--apply` com nome inexistente**: skip + warning em stderr, sumário final reporta.

## Não-objetivos

- Não checa plugins Level 1 (sem SHA) — esses recebem updates via Claude Code
- Não atualiza plugins Level 3 (./plugins/) — use `/publish-plugin`
- Não detecta vulnerabilidades de segurança no diff
- Não faz rollback automático
- Não suporta repos privados que exijam auth além do default do `gh`

## Testar o script isoladamente

Fora do Claude Code, da raiz de um repo com marketplace:

\`\`\`bash
bash plugins/marketplace-tools/scripts/check.sh                           # dry-run
bash plugins/marketplace-tools/scripts/check.sh --apply humanizador       # apply seletivo
\`\`\`
```

Nota: remover os backticks de escape (`\`\`\``) ao criar o arquivo real.

- [ ] **Step 10.2: Verificar que o novo `.md` está menor**

```bash
wc -l plugins/marketplace-tools/commands/check-marketplace-updates.md
```

Expected: bem menor que as 186 linhas originais (alvo: ~80-100 linhas).

- [ ] **Step 10.3: Commit**

```bash
git add plugins/marketplace-tools/commands/check-marketplace-updates.md
git commit -m "marketplace-tools: reduz commands/check-marketplace-updates.md pro padrão opção Z"
```

---

## Task 11: Atualizar `plugin.json.description`

**Files:**
- Modify: `plugins/marketplace-tools/.claude-plugin/plugin.json`

- [ ] **Step 11.1: Atualizar description**

Substituir o conteúdo de `plugins/marketplace-tools/.claude-plugin/plugin.json` por:

```json
{
  "name": "marketplace-tools",
  "description": "Toolkit de manutenção do marketplace aj-openworkspace — updates de plugins pinnados (Level 2), validação pré-commit, QA de saúde, publicação de plugins Level 3 e utilidades do Claude Code Desktop.",
  "author": {
    "name": "André Junges"
  },
  "homepage": "https://github.com/ajunges/aj-openworkspace/tree/main/plugins/marketplace-tools"
}
```

- [ ] **Step 11.2: Validar JSON**

```bash
jq . plugins/marketplace-tools/.claude-plugin/plugin.json > /dev/null && echo OK
```

Expected: `OK`.

- [ ] **Step 11.3: Commit**

```bash
git add plugins/marketplace-tools/.claude-plugin/plugin.json
git commit -m "marketplace-tools: atualiza plugin.json.description pro escopo ampliado"
```

---

## Task 12: Reescrever `README.md`

**Files:**
- Modify: `plugins/marketplace-tools/README.md`

- [ ] **Step 12.1: Substituir `README.md` pela versão nova**

Conteúdo completo pra substituir:

```markdown
# marketplace-tools

Plugin próprio do marketplace `aj-openworkspace` — toolkit de manutenção do próprio marketplace. Encapsula fluxos manuais forçados pelos bugs conhecidos de cache do Claude Code Desktop ([#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081)).

## Comandos disponíveis

| Comando | Resumo |
|---|---|
| `/check-marketplace-updates` | Verifica updates em plugins Level 2 (SHA pinnado) e aplica seletivamente |
| `/marketplace-qa` | Diagnóstico de saúde do marketplace local (clone stale, dangling paths, version drift) |
| `/publish-plugin <nome> [patch\|minor\|major]` | Publica mudança em plugin Level 3 — bump + commit + push + re-cache |
| `/validate` | Validação pré-commit: schema oficial + convenções do marketplace (tags, SemVer, version duplicada em L3) |
| `/restart-desktop` | Reinicia o Claude Code Desktop (útil após `/publish-plugin`) |

Todos seguem o padrão **opção Z**: lógica operacional em `scripts/*.sh`, `.md` só explica quando usar e o que o script faz conceitualmente.

## Roadmap (ondas futuras)

### Onda 2 — Edição do catálogo
- `/add-plugin` — adicionar Level 1/2 ao `marketplace.json` a partir de uma URL
- `/remove-plugin` — remover entry + cleanup de cache
- `/reclassify` — mudar `tags[0]` entre `recomendado`/`em-testes`/`nao-recomendado`

### Onda 3 — Automação residual
- `/nuke-cache` — invalidação total pra casos de emergência
- `/changelog` — gera changelog entre versions de um plugin L3

### Onda 4 — Scaffolding
- `/new-plugin` — cria dir + plugin.json + entry em marketplace.json pra plugin Level 3 novo

## Como testar

Testes automatizados cobrem os sub-scripts de `scripts/checks/` (funções puras, determinísticas):

\`\`\`bash
brew install bats-core                  # se ainda não tem
cd plugins/marketplace-tools
bats tests/checks/
\`\`\`

Scripts de orquestração (`check.sh`, `validate.sh`, `qa.sh`, `publish.sh`, `restart.sh`) não têm testes automatizados na Onda 1 — testabilidade manual rodando cada um fora do Claude Code.

## Instalação

Como parte do marketplace `aj-openworkspace`:

\`\`\`bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install marketplace-tools@aj-openworkspace
\`\`\`

## Autor

André Junges (@ajunges). Plugin escrito em colaboração com Claude Code.
```

Nota: remover os backticks de escape ao criar o arquivo real.

- [ ] **Step 12.2: Commit**

```bash
git add plugins/marketplace-tools/README.md
git commit -m "marketplace-tools: reescreve README pro escopo ampliado + roadmap"
```

---

## Task 13: Bump version 0.4.0 → 0.5.0

**Files:**
- Modify: `.claude-plugin/marketplace.json` (entry de `marketplace-tools`)

- [ ] **Step 13.1: Verificar version atual**

```bash
jq -r '.plugins[] | select(.name == "marketplace-tools") | .version' .claude-plugin/marketplace.json
```

Expected: `0.4.0`.

- [ ] **Step 13.2: Bump via jq**

```bash
tmp=$(mktemp)
jq '(.plugins[] | select(.name == "marketplace-tools") | .version) = "0.5.0"' .claude-plugin/marketplace.json > "$tmp"
jq . "$tmp" > /dev/null && mv "$tmp" .claude-plugin/marketplace.json
```

- [ ] **Step 13.3: Validar**

```bash
jq -r '.plugins[] | select(.name == "marketplace-tools") | .version' .claude-plugin/marketplace.json
```

Expected: `0.5.0`.

- [ ] **Step 13.4: Commit**

```bash
git add .claude-plugin/marketplace.json
git commit -m "Bump marketplace-tools para 0.5.0"
```

---

## Task 14: Verificação final end-to-end

**Files:**
- Nenhum a modificar — só rodar os comandos novos e confirmar.

- [ ] **Step 14.1: Rodar suite de testes bats**

```bash
cd plugins/marketplace-tools
bats tests/checks/
```

Expected: `19 tests, 0 failures`.

- [ ] **Step 14.2: Rodar `/validate` (via script direto)**

```bash
cd /Users/andrejunges/repos/aj-openworkspace/.claude/worktrees/lucid-greider-6c1747
bash plugins/marketplace-tools/scripts/validate.sh
```

Expected: report. Anotar findings reais — se houver problemas no marketplace, decidir com o usuário se corrige nesta PR ou em separado.

- [ ] **Step 14.3: Rodar `/marketplace-qa`**

```bash
bash plugins/marketplace-tools/scripts/qa.sh
```

Expected: report de saúde. Comparar rapidamente com comportamento pré-refactor — findings do check 3.7 precisam aparecer da mesma forma.

- [ ] **Step 14.4: Rodar `/check-marketplace-updates` dry-run**

```bash
bash plugins/marketplace-tools/scripts/check.sh
```

Expected: header TSV + eventuais linhas de plugins com update. Sem erros de execução.

- [ ] **Step 14.5: Review do git log**

```bash
git log --oneline origin/main..HEAD
```

Expected: ~13-14 commits coerentes na branch (um por task ou sub-task). Conferir mensagens em pt-BR, sem Co-Authored-By Claude (conforme CLAUDE.md global).

- [ ] **Step 14.6: Registrar métricas do gate pós-Onda 1**

Abrir o spec em `docs/superpowers/specs/2026-04-20-marketplace-tools-onda-1-design.md`, seção 7.1. Anotar:

- Quantos sub-scripts temos em `scripts/checks/`? (baseline: 3)
- Quanto tempo total foi gasto em debug de edge cases bash durante esta implementação?
- Algum bug de bash custou > 1h de debug?
- Manipulação JSON em algum momento ficou desconfortável?

Se qualquer gatilho da seção 7.2 disparou, anotar no spec como "atualização pós-Onda 1" com recomendação de migrar Python antes da Onda 2.

- [ ] **Step 14.7: Commit final se alguma anotação foi feita**

Se o spec foi atualizado com métricas do gate:

```bash
git add docs/superpowers/specs/2026-04-20-marketplace-tools-onda-1-design.md
git commit -m "marketplace-tools: métricas do gate pós-Onda 1 (spec atualizado)"
```

Caso contrário, pular este step.

---

## Pós-plano: publish

Após o plano completar e o usuário aprovar, usar `/marketplace-tools:publish-plugin marketplace-tools minor` pra fechar o ciclo (push em main, sync do clone, repopulação de cache, restart do Desktop). Esse passo é **fora do escopo deste plan** — é operação de publicação, não implementação.

---

## Resumo dos commits esperados

13-14 commits em sequência (um por task, Task 14 pode não ter commit se nenhuma anotação for feita):

1. `marketplace-tools: fixtures de teste pros sub-scripts de checks`
2. `marketplace-tools: sub-script version-duplicated.sh + testes bats`
3. `marketplace-tools: sub-script tags-valid.sh + testes bats`
4. `marketplace-tools: sub-script semver-valid.sh + testes bats`
5. `marketplace-tools: refactor qa.sh check 3.7 pra usar sub-script (behavior-preserving)`
6. `marketplace-tools: comando /validate + scripts/validate.sh`
7. `marketplace-tools: comando /restart-desktop + scripts/restart.sh`
8. `marketplace-tools: scripts/check.sh modo dry-run (migração do inline)`
9. `marketplace-tools: scripts/check.sh modo --apply com commit individual`
10. `marketplace-tools: reduz commands/check-marketplace-updates.md pro padrão opção Z`
11. `marketplace-tools: atualiza plugin.json.description pro escopo ampliado`
12. `marketplace-tools: reescreve README pro escopo ampliado + roadmap`
13. `Bump marketplace-tools para 0.5.0`
14. (opcional) `marketplace-tools: métricas do gate pós-Onda 1 (spec atualizado)`
