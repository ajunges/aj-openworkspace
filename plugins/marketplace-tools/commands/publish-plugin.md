---
description: Publica mudanças em plugin Level 3 — bump version, commit, push, sync clone local e re-cacheia aplicando o workaround dos bugs de cache do Claude Code Desktop
---

# /publish-plugin

Fecha o ciclo completo de "publicar" uma mudança num plugin Level 3 (`source: "./plugins/..."`) do marketplace. Encapsula os passos manuais que os bugs [#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081) do Claude Code forçam.

## Pré-requisito crítico — NÃO bumpe a version manualmente antes

> ⚠️ **Regra do fluxo**: o script é o **único** lugar que bumpa a `version` do plugin no `marketplace.json`. Se você bumpar manualmente antes de invocar o script (ex: incluindo o bump no mesmo pacote dos ajustes), o script vai bumpar de novo — resultado: **bump duplo + commit "bump version" vazio + ruído no histórico do marketplace público**.
>
> **Fluxo correto**: aplicar mudanças no plugin → commit dos ajustes (sem tocar em `marketplace.json`) → invocar `/marketplace-tools:publish-plugin <nome> <bump>` → o script bumpa, comita o bump, pusha, sincroniza clone, re-cacheia.
>
> **Se você já bumpou manualmente** (caiu na armadilha): pule o script e execute manualmente os passos 4-6 (push direto + pull no clone + re-cache via `cp -R`). Não tente "consertar" com bump duplo.

## Quando usar

Use sempre que mexer em arquivos dentro de `plugins/<nome>/` (skills, commands, agents, plugin.json, etc.) e quiser que o plugin instalado localmente reflita a mudança.

**Não use** quando: já bumpou a version manualmente (ver regra acima); plugin é Level 1/2 (use `/marketplace-tools:check-marketplace-updates`); só quer validar sem publicar (use `/marketplace-tools:validate`).

## Execução

A lógica vive em `scripts/publish.sh`. Invocar com o nome do plugin e o tipo de bump:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/publish.sh "$1" "$2"
```

Onde `$1` é o nome do plugin (ex: `humanizador`) e `$2` é o bump type (`patch`, `minor` ou `major` — default `patch` se omitido).

Exemplo de invocação via slash command:

```
/marketplace-tools:publish-plugin humanizador patch
/marketplace-tools:publish-plugin sdd-workflow minor
/marketplace-tools:publish-plugin portfolio-docs major
```

O script é interativo — apresenta plano e pergunta `[y/N]` antes de fazer mudanças.

## O que o script faz

Os 6 passos, em ordem:

1. **Valida args + Level 3 check** — garante que o plugin existe e tem `source` string local
2. **Detecta mudanças** — conta commits afetando `plugins/<nome>/` desde o último bump (informacional, não aborta)
3. **Bumpa version em `marketplace.json`** — via `jq`, nunca regex. **Sempre bumpa, sempre.** Não tem flag pra pular nem detecção de "já bumpado" (ver pré-requisito crítico no topo).
4. **Commit + push**:
   - Se branch atual é `main`: push direto
   - Caso contrário: merge FF em main via worktree temporário, push
5. **Pull no clone local** — `~/.claude/plugins/marketplaces/<mkt>/`
6. **Re-cacheia**:
   - Backup timestamped de `installed_plugins.json`
   - Remove entry `<plugin>@<mkt>` (força o app a re-instalar)
   - Limpa `cache/<mkt>/<plugin>/*` e copia clone → `cache/<mkt>/<plugin>/<new-version>/`

## Quando usar cada tipo de bump

| Tipo | Usar quando |
|---|---|
| `patch` | Bugfix, ajuste pequeno, mudança de prose, cleanup interno |
| `minor` | Feature nova retrocompatível (comando novo, skill nova, hook novo opcional) |
| `major` | Breaking change — comando/skill removido ou com comportamento diferente |

## Próximo passo após publish

Reiniciar o Claude Code Desktop para o app detectar a nova entry no `installed_plugins.json` (que o script removeu) e criar a nova apontando para o cache populado.

Após restart, validar com:

```bash
jq '.plugins["<nome>@<mkt>"][0] | {version, gitCommitSha}' ~/.claude/plugins/installed_plugins.json
```

Ou rodar `/marketplace-tools:marketplace-qa` pra sanity completo.

## Tratamento de erros no script

- **Plugin não é Level 3**: erro, sai. Para Level 1/2 use `/marketplace-tools:check-marketplace-updates`.
- **JSON inválido após edit**: restaura backup, aborta.
- **Push falha**: reporta, deixa commit local pro user resolver.
- **Pull no clone falha (conflito)**: reporta, pula re-cache (user resolve manualmente).
- **Cópia clone→cache falha**: sinaliza, sugere rodar `/marketplace-qa` pra verificar.

## Não-objetivos (v0.3)

- Não detecta tipo de bump automaticamente via análise de commits. Usuário escolhe.
- Não detecta se a version já foi bumpada manualmente antes da invocação. Sempre bumpa.
- Não roda `claude plugin validate` antes do commit.
- Não reinicia o Claude Code Desktop.
- Não atualiza changelog.
- Não lida com plugins Level 1/2.
- Não suporta publicar múltiplos plugins numa chamada.

## Fallback manual (quando o script não pode rodar)

Se cair em situação onde o script não serve (bump já feito manualmente, conflito no clone que precisa resolução manual, etc.), executar os passos equivalentes:

```bash
# 1. Push do que está local em main
git push origin main

# 2. Sync do clone do marketplace
git -C ~/.claude/plugins/marketplaces/<mkt>/ pull --ff-only

# 3. Backup + remover entry do plugin no installed_plugins.json
cp ~/.claude/plugins/installed_plugins.json ~/.claude/plugins/installed_plugins.json.bak.$(date +%Y%m%d-%H%M%S)
jq 'del(.plugins["<plugin>@<mkt>"])' ~/.claude/plugins/installed_plugins.json > /tmp/inst.tmp && mv /tmp/inst.tmp ~/.claude/plugins/installed_plugins.json

# 4. Limpar cache antigo + copiar versão atual
rm -rf ~/.claude/plugins/cache/<mkt>/<plugin>/*
mkdir -p ~/.claude/plugins/cache/<mkt>/<plugin>/<new-version>
cp -R ~/.claude/plugins/marketplaces/<mkt>/plugins/<plugin>/. ~/.claude/plugins/cache/<mkt>/<plugin>/<new-version>/

# 5. Restart do Claude Code Desktop
```

## Testar o script isoladamente

Fora do Claude Code, passe os args:

```bash
cd /caminho/do/repo-com-marketplace
bash plugins/marketplace-tools/scripts/publish.sh humanizador patch
```

Útil para testar mudanças na lógica sem passar pelo slash command.
