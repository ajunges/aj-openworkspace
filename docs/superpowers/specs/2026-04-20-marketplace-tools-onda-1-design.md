# Marketplace-tools — Onda 1 (design)

Design da expansão do plugin `marketplace-tools` de "ferramentas pontuais" para **toolkit de manutenção do marketplace**. Cobre a primeira de 4 ondas planejadas.

---

## 1. Contexto

O plugin `marketplace-tools` está em `v0.4.0`. Expõe 3 comandos:

- `/check-marketplace-updates` — verifica updates em plugins Level 2 (SHA pinnado). Lógica **inline no `.md`** (~7 kB de bash em code blocks), não migrado para o padrão "opção Z".
- `/marketplace-qa` — diagnóstico de saúde do marketplace local. Lógica em `scripts/qa.sh`. Segue padrão opção Z.
- `/publish-plugin` — publica mudanças em plugin Level 3 (bump + commit + push + re-cache). Lógica em `scripts/publish.sh`. Segue padrão opção Z.

O padrão "opção Z" foi batizado no commit `5da64da` (v0.3.0): desloca lógica do `.md` para `.sh`, executado em processo bash dedicado com `set -Eeuo pipefail`, `trap ERR` e PATH hardening próprio. Isso evita que o LLM execute múltiplos blocos de bash no shell snapshot bugado do Claude Code.

O plugin cresceu de "só `/check`" para 3 comandos sem atualização de `plugin.json.description` nem `README.md` — ambos ainda descrevem apenas o estado v0.1.0.

---

## 2. Escopo

### 2.1 Inclui (Onda 1)

1. **Migração** de `/check-marketplace-updates` para o padrão opção Z (`scripts/check.sh`)
2. **Comando novo `/validate`** — wrapper de `claude plugin validate` + checks de convenção
3. **Comando novo `/restart-desktop`** — automação do restart manual do Claude Code Desktop
4. **Refactor de `qa.sh`** — extrai checks compartilhados para `scripts/checks/` (behavior-preserving)
5. **Cleanup de docs stale** — `plugin.json.description` + `README.md`
6. **Testes automatizados** em `bats` para os sub-scripts de `scripts/checks/`
7. **Gate de avaliação pós-Onda 1** — decisão explícita bash vs Python antes da Onda 2

### 2.2 Exclui — ondas futuras (só documentar roadmap)

- **Onda 2** — `/add-plugin`, `/remove-plugin`, `/reclassify`
- **Onda 3** — `/nuke-cache`, `/changelog`
- **Onda 4** — `/new-plugin`

### 2.3 Descartado (com razão registrada)

- **Grep gate de termos sensíveis** (era B.2 no brainstorm) — hardcode de nomes proibidos em repo público é autossabotagem; mesmo movido pra arquivo local gitignored, o mecanismo público revela a estrutura. Mitigação adotada: usuário pede ao LLM revisar 3x antes de qualquer push que contenha conteúdo potencialmente sensível.
- **Lint de descriptions pt-BR opinativas** (era B.4) — sem LLM no loop, só resta heurística fraca (detectar palavras inglesas, comprimento, padrões robóticos). Com LLM, foge do padrão opção Z (que é lógica determinística em bash).
- **Migração para Python na Onda 1** — considerado seriamente. Benefícios reais (pytest > bats, JSON nativo, tratamento estruturado de erro, portabilidade macOS/Linux). Custo proibitivo agora: reescrever `qa.sh` (153 linhas) e `publish.sh` (171 linhas) pra manter consistência. Adiado pro **gate pós-Onda 1** (seção 7).

---

## 3. Arquitetura

### 3.1 Estrutura final do plugin

```
plugins/marketplace-tools/
├── .claude-plugin/plugin.json        # description atualizada
├── README.md                         # reescrito (comandos + roadmap)
├── commands/
│   ├── check-marketplace-updates.md  # reduzido (padrão opção Z)
│   ├── marketplace-qa.md             # inalterado
│   ├── publish-plugin.md             # inalterado
│   ├── validate.md                   # novo
│   └── restart-desktop.md            # novo
├── scripts/
│   ├── check.sh                      # novo (migração)
│   ├── qa.sh                         # refactor behavior-preserving
│   ├── publish.sh                    # inalterado
│   ├── validate.sh                   # novo
│   ├── restart.sh                    # novo
│   └── checks/                       # novo: sub-scripts standalone
│       ├── version-duplicated.sh
│       ├── tags-valid.sh
│       └── semver-valid.sh
└── tests/
    ├── fixtures/                     # JSONs fake pros testes
    │   ├── marketplace-ok.json
    │   ├── marketplace-bad-tags.json
    │   └── plugin-with-version.json
    └── checks/
        ├── version-duplicated.bats
        ├── tags-valid.bats
        └── semver-valid.bats
```

### 3.2 Decisão de compartilhamento de lógica — sub-scripts standalone

Três approaches foram considerados:

| Approach | Descrição | Decisão |
|---|---|---|
| **1. Function library** | `scripts/lib/checks.sh` com `check_X()` source-ado | Rejeitado — namespace global, testabilidade menor |
| **2. Sub-scripts standalone** | `scripts/checks/<nome>.sh`, invocado via `bash` | **Adotado** |
| **3. qa.sh multi-mode** | `qa.sh --mode=validate` compartilhado | Rejeitado — vira god-script |

Razões pra adoção do approach 2:

- **Testabilidade pura**: `bats tests/checks/version-duplicated.bats` roda o script real, sem mock/source.
- **Descobribilidade**: `ls scripts/checks/` documenta todos os checks existentes de graça.
- **Scope creep resistance**: filosofia Unix "1 arquivo, 1 responsabilidade" força disciplina.
- **Evolução independente**: Ondas 2/3 adicionam checks sem risco de quebrar existentes (bash não tem namespacing de funções).
- **Fork overhead irrelevante**: ~5ms por invocação × ~3 chamadas = imperceptível.

### 3.3 Contrato dos sub-scripts de `scripts/checks/`

Cada script:

- Recebe contexto via args posicionais (`$1`, `$2`, ...)
- Se problema detectado: emite finding estruturado em stdout (formato abaixo) + `exit 1`
- Se ok: silencia stdout + `exit 0`
- Não aborta em condições esperadas (ex: `plugin.json` ausente → `exit 0` silencioso)
- Aborta em condições inválidas (arg missing, JSON quebrado) com mensagem em stderr + `exit 2`
- Inclui boilerplate comum: shebang `#!/usr/bin/env bash`, `set -Eeuo pipefail`, `trap ERR`, PATH hardening

**Formato do finding estruturado** (idêntico ao usado em `qa.sh` hoje):

```
SEV|CHECK_ID|TARGET|MSG|AUTOFIXABLE
```

Exemplo: `MEDIUM|3.7|humanizador|version-duplicated: plugin.json=3.0.0 marketplace.json=3.0.1 (plugin.json vence silenciosamente)|yes`

---

## 4. Componentes

### 4.1 `scripts/check.sh` — migração do `/check-marketplace-updates`

**Modalidades via args:**

- `bash scripts/check.sh` (sem args) → dry-run. Emite TSV de plugins com update em stdout. Exit 0.
- `bash scripts/check.sh --apply nome1 nome2 ...` → aplica updates seletivos. Um commit por plugin. Erros em plugins individuais não abortam o batch; sumário final reporta.

**Formato do TSV (dry-run):**

```
PLUGIN	OLD_SHA	NEW_SHA	COMMITS	FILES	BREAKING	TOP_COMMITS
humanizador	abc123	def456	5	12	no	feat: X|fix: Y|chore: Z
```

Colunas:
- `PLUGIN` — nome do plugin
- `OLD_SHA` — SHA atual em marketplace.json (short, 12 chars)
- `NEW_SHA` — HEAD atual do upstream (short, 12 chars)
- `COMMITS` — número de commits entre old e new
- `FILES` — número de arquivos alterados (filtrado por `source.path` se git-subdir)
- `BREAKING` — `yes`/`no` (detectado via keyword nas mensagens: `BREAKING`, `breaking:`, `!:`)
- `TOP_COMMITS` — top 5 mensagens de commit, separadas por `|`

Se `FILES == 0` (SHA mudou mas nenhum arquivo do plugin foi afetado), pula — não emite linha.

**Lógica preservada do inline atual:**

- Sanity check de ambiente (jq, gh, git, gh auth)
- `git ls-remote` para `source.source == "url"`
- `gh api /repos/{owner}/{repo}/commits/{ref}` para `source.source == "git-subdir"`
- `gh api /repos/{owner}/{repo}/compare/{old}...{new}` para obter diff
- Filtro de arquivos por `source.path` em git-subdir
- Detecção de breaking via keyword em commit messages
- Edit via `jq` (nunca regex) + validação de JSON pós-edit
- Commit individual por plugin aplicado: `bump <plugin> para <short-sha>`

**Responsabilidade do LLM (separada do script):**

1. Invoca dry-run
2. Parse do TSV
3. Formata no chat pro usuário (um bloco por plugin com updates)
4. Pergunta quais aplicar
5. Invoca `--apply` com os nomes selecionados

### 4.2 `scripts/validate.sh` — comando `/validate`

**Lógica sequencial:**

1. Roda `claude plugin validate .` — captura exit code e stdout
2. Para cada plugin Level 3 em `marketplace.json`:
   - Chama `bash scripts/checks/version-duplicated.sh <name> <dir> <mkt_json>`
   - Chama `bash scripts/checks/tags-valid.sh <name> <mkt_json>`
   - Chama `bash scripts/checks/semver-valid.sh <version> <name>`
3. Coleta findings de todos os sub-scripts
4. Exit code final: 1 se qualquer sub-script ou `claude plugin validate` falhou; 0 caso contrário
5. Output: findings agrupados por severidade (igual ao formato do `qa.sh`)

**Sem flags na Onda 1.** Decisão futura se precisar de modo `--fast` / `--strict`.

### 4.3 `scripts/checks/*.sh` — sub-scripts da lib

**`version-duplicated.sh`** — args: `<plugin_name> <plugin_dir> <mkt_json_path>`

Detecta se `version` existe em ambos `<plugin_dir>/.claude-plugin/plugin.json` e `<mkt_json_path>[.plugins[] | select(.name == $name)]`. Doc oficial: *"The plugin manifest always wins silently"*. Finding MEDIUM check id `3.7`.

**`tags-valid.sh`** — args: `<plugin_name> <mkt_json_path>`

Detecta se `tags[0]` está no conjunto `{recomendado, em-testes, nao-recomendado}`. Convenção do repo (CLAUDE.md). Finding MEDIUM check id `tag-convention`.

**`semver-valid.sh`** — args: `<version_string> <plugin_name>`

Detecta se a string casa com `^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?(\+[a-zA-Z0-9.-]+)?$`. Finding LOW check id `semver-invalid`.

### 4.4 `scripts/qa.sh` — refactor behavior-preserving

**Hoje** o check 3.7 (version-duplicated) é bloco inline de ~10 linhas em `qa.sh:122-131`.

**Depois do refactor**, 3.7 vira chamada externa:

```bash
# substitui o bloco inline
while IFS=$'\t' read -r name plugin_dir _; do
  bash "$SCRIPT_DIR/checks/version-duplicated.sh" "$name" "$plugin_dir" "$MKT_JSON" >> "$FINDINGS" || true
done < "$TMPDIR_QA/l3.tsv"
```

**Propriedade garantida**: rodar `qa.sh` antes e depois do refactor produz **exatamente o mesmo output** em um repo idêntico. Teste de verificação:

```bash
bash plugins/marketplace-tools/scripts/qa.sh > /tmp/qa-before.txt
# aplica refactor
bash plugins/marketplace-tools/scripts/qa.sh > /tmp/qa-after.txt
diff /tmp/qa-before.txt /tmp/qa-after.txt  # precisa sair vazio
```

Se o diff não for vazio, o refactor falhou em preservar comportamento — corrigir a interface do sub-script antes de commitar.

**Decisão sobre check 3.4 (version-drift)**: **Não é extraído** na Onda 1. O check compara `marketplace.json[].version` com `installed_plugins.json[...].version` — depende do `$INSTALLED` (path de `~/.claude/plugins/installed_plugins.json`), que é contexto exclusivo de diagnóstico pós-fato. O `validate.sh` (pre-commit) **não tem** acesso a esse estado (installed_plugins representa o que o app tem cached, não o que está no repo). Extrair pra `scripts/checks/` criaria um sub-script nunca reutilizado. Fica inline em `qa.sh`. Se em Ondas futuras algum comando novo precisar dele, extrai com justificativa.

Apenas **check 3.7** é extraído na Onda 1 — esse sim é compartilhado (detecta violação de convenção que tanto pre-commit quanto diagnóstico devem capturar).

### 4.5 `scripts/restart.sh` — comando `/restart-desktop`

```bash
#!/usr/bin/env bash
set -Eeuo pipefail
trap 'echo "ERRO em restart.sh linha $LINENO: $BASH_COMMAND" >&2' ERR
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"

echo "Reiniciar Claude Code Desktop? [y/N]"
read -r answer
[ "$answer" = "y" ] || [ "$answer" = "Y" ] || { echo "Abortado."; exit 0; }

if ! osascript -e 'tell application "Claude" to quit' 2>/dev/null; then
  echo "AVISO: osascript falhou. Se o app estiver travado, use 'killall Claude' e abra manualmente."
  exit 1
fi

sleep 2
open -a "Claude"
echo "Claude Code Desktop reiniciado."
```

Fallback se `osascript` falhar: mensagem sugere `killall Claude` manual — não faz automático (destrutivo sem confirmação).

### 4.6 `commands/*.md` — slash commands

Todos seguem o template de `publish-plugin.md`:

1. Frontmatter com `description` curta
2. Título H1
3. Seção "Quando usar"
4. Seção "Execução" com a única linha `bash ${CLAUDE_PLUGIN_ROOT}/scripts/<nome>.sh [args]`
5. Seção "O que o script faz" — descrição conceitual, sem código
6. Seção "Tratamento de erros"
7. Seção "Não-objetivos"
8. Seção "Testar o script isoladamente"

### 4.7 `tests/checks/*.bats` — testes automatizados

Um arquivo `.bats` por sub-script. Cada um cobre:

- **Happy path**: entrada ok → exit 0, stdout vazio
- **Sad path**: entrada com problema → exit 1, stdout contém finding estruturado no formato `SEV|CHECK_ID|TARGET|MSG|AUTOFIXABLE`
- **Edge cases**: arquivos ausentes, JSON inválido, args faltando

Fixtures em `tests/fixtures/`:
- `marketplace-ok.json` — marketplace.json válido, passa todos os checks
- `marketplace-bad-tags.json` — `tags[0]` fora do conjunto permitido
- `plugin-with-version.json` — plugin.json com `version` (pra provocar version-duplicated)

Pré-requisito local: `brew install bats-core`. Documentar no README.

---

## 5. Cleanup de docs stale

### 5.1 `plugin.json.description`

**Antes:**

> Ferramentas para manter o marketplace aj-openworkspace — principalmente verificação de updates em plugins com SHA pinnado (Level 2).

**Depois:**

> Toolkit de manutenção do marketplace aj-openworkspace — updates de plugins pinnados (Level 2), validação pré-commit, QA de saúde, publicação de plugins Level 3 e utilidades do Claude Code Desktop.

### 5.2 `README.md`

Reescrito em seções:

1. **Visão geral** — o que o plugin faz, público-alvo (quem mantém marketplaces de plugin do Claude Code)
2. **Comandos disponíveis** — lista com uma linha por comando:
   - `/check-marketplace-updates` — verifica e aplica updates em plugins Level 2
   - `/marketplace-qa` — diagnóstico de saúde (clone stale, dangling paths, version drift)
   - `/publish-plugin <nome> [patch|minor|major]` — publica plugin Level 3 com workaround dos bugs de cache
   - `/validate` — valida marketplace.json + convenções pré-commit
   - `/restart-desktop` — reinicia o Claude Code Desktop
3. **Roadmap** — Ondas 2, 3, 4 com itens listados (sem cronograma)
4. **Como testar** — `cd tests/ && bats checks/*.bats`
5. **Instalação** — trecho do marketplace
6. **Autor**

---

## 6. Versioning

Bump **minor** (3 comandos novos retrocompatíveis, sem breaking change em `qa`/`publish`):

`.claude-plugin/marketplace.json[plugins[name=marketplace-tools]].version`: **0.4.0 → 0.5.0**

Versão mora apenas em `marketplace.json` (convenção do repo; verificado pelo próprio check 3.7).

---

## 7. Gate de avaliação pós-Onda 1

Antes de iniciar implementação da Onda 2, **avaliação explícita** se migrar pra Python vale o custo.

### 7.1 Métricas de custo do bash (coletar durante Onda 1)

1. Tempo gasto debugando edge cases de bash (quoting, PATH, macOS `mktemp`/`stat`, IFS)
2. Número de sub-scripts em `scripts/checks/` ao fim da Onda 1 (baseline: 3)
3. Quantas vezes `jq` encadeado ficou desconfortável ou frágil

### 7.2 Gatilhos de migração (qualquer um dispara)

- Algum bug de bash consumiu > 1h de debug
- Lib de checks atingiria > 8-10 sub-scripts em Onda 2 (expectativa hoje: 3 novos)
- Manipulação JSON sofisticada ficou esperada (merge de objetos, schema diff estrutural, validação cruzada)

### 7.3 Plano de migração se disparar

- Reescrever `qa.sh` + `publish.sh` + os 3 scripts novos da Onda 1 em Python stdlib-only
- Manter interface de invocação (`bash ${CLAUDE_PLUGIN_ROOT}/scripts/X.sh` vira `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/X.py`)
- Commit separado da migração, com diff de comportamento = vazio em casos conhecidos
- Documentar decisão em commit message + atualizar este spec com entrada "atualização pós-Onda 1"

### 7.4 Plano se não disparar

Continuar em bash nas Ondas 2+. Revisitar gate ao fim de cada onda.

---

## 8. Error handling

Todos os scripts seguem o padrão já estabelecido por `qa.sh` e `publish.sh`:

- `set -Eeuo pipefail` no topo
- `trap 'echo "ERRO em <script> linha $LINENO: $BASH_COMMAND" >&2' ERR`
- PATH hardening: `export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin${PATH:+:$PATH}"`
- Sanity check de dependências (`command -v jq`, `command -v gh`, etc.) no início

**Comportamento específico:**

- `check.sh --apply`: erro aplicando um plugin individual não aborta o batch; sumário final reporta erros por plugin.
- `validate.sh`: qualquer sub-script retornando `exit 1` → validate retorna `exit 1`. `exit 2` de sub-script (erro inválido, não finding) aborta validate.
- Sub-scripts em `checks/`: condições esperadas (arquivo ausente, plugin sem version) → `exit 0` silencioso. Condições inválidas (arg missing, JSON quebrado) → `exit 2` + mensagem em stderr.
- `restart.sh`: falha em `osascript` → mensagem explicativa + `exit 1`. Não tenta `killall` automático.

---

## 9. Testing strategy

### 9.1 Automatizado (bats)

**Cobertura**: `scripts/checks/*.sh` — funções puras, determinísticas, fácil de testar.

**Exclusão explícita**: `check.sh`, `validate.sh` (orquestrador), `qa.sh`, `publish.sh`, `restart.sh` — scripts de integração que exigiriam mocks pesados de `gh`, `git`, `osascript`, sistema de arquivos. Baixo ROI na Onda 1.

### 9.2 Verificação manual (one-shot no fim da Onda 1)

- `diff` do output de `qa.sh` antes/depois do refactor → precisa ser vazio (behavior-preserving)
- Rodar `validate.sh` no repo atual → confirmar pass limpo (ou findings esperados)
- Rodar `check.sh` sem args num plugin de teste → verificar formato TSV
- Rodar `check.sh --apply` num plugin com update pendente → verificar commit correto
- Rodar `restart.sh` (em momento oportuno, com confirmação)

### 9.3 CI

**Não introduzir na Onda 1.** Workspace pessoal, sem GitHub Actions neste repo hoje. Reavaliar se a suíte de testes crescer significativamente.

---

## 10. Não-objetivos

- Não implementar comandos das Ondas 2, 3, 4
- Não validar schema custom do `marketplace.json` além do que `claude plugin validate` já faz
- Não testar scripts de integração (`check`, `validate` como orquestrador, `qa`, `publish`, `restart`)
- Não introduzir CI no repo
- Não cobrir plugins de outros marketplaces em `/validate` (só o do repo atual)
- Não automatizar detecção de termos sensíveis (B.2 descartado)
- Não migrar para Python na Onda 1 (avaliado no gate da seção 7)
- Não mexer no `publish.sh` (funcionando, fora do escopo)

---

## 11. Referências

- Commit `5da64da` (marketplace-tools 0.3.0) — origem do padrão opção Z
- Commit `dcd26f0` (marketplace-tools 0.3.1) — exemplo de edge case bash em macOS (`mktemp`)
- Commit `3f1577a` (marketplace-tools 0.4.0) — estado base
- `CLAUDE.md` deste repo — seções "Versioning de plugins Level 3" e "Bugs conhecidos no ciclo de update"
- Docs Anthropic Plugins — [Version Management](https://code.claude.com/docs/en/plugins-reference#version-management)
- Bugs do Claude Code cobertos — [#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081)
