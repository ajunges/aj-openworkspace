---
description: Diagnóstico de saúde do marketplace local — detecta clone stale, dangling installPaths, version drift e outros estados inconsistentes
---

# /marketplace-qa

Faz um exame completo do estado dos plugins instalados vs. o que o marketplace declara. Produz um relatório com severidades e oferece auto-fix para findings com remédio mecânico.

Cobre os estados inconsistentes causados pelos bugs conhecidos [#13799](https://github.com/anthropics/claude-code/issues/13799), [#14061](https://github.com/anthropics/claude-code/issues/14061), [#46081](https://github.com/anthropics/claude-code/issues/46081) do Claude Code.

## Execução

A lógica vive em `scripts/qa.sh`. Rodar esse script dá saída formatada do QA completo:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/qa.sh
```

O script deve ser invocado em um único comando — a lógica está toda nele. Não fragmentar em múltiplas chamadas. O script em si tem PATH hardening próprio (shebang + export no topo) que sobrevive ao bug do shell snapshot do Claude Code.

## O que cada check faz

### 3.1 Clone behind remote (MEDIUM)

**Sinal direto**: `git fetch origin` no clone local do marketplace + comparação HEAD local vs. upstream. Substitui o check antigo baseado em `known_marketplaces.json.lastUpdated` (que era proxy enganoso — só atualizava quando a UI rodava `/plugin marketplace update`).

Se o fetch falhar (offline, credenciais), reporta `LOW fetch-failed` em vez de `MEDIUM clone-behind-remote` — sinal mais honesto de "não consegui medir" vs. "tem drift".

**Auto-fix**: `git -C "$CLONE_PATH" pull --ff-only`.

### 3.2 Dangling installPath (HIGH)

Plugin em `installed_plugins.json` cujo `installPath` aponta para diretório inexistente. Acontece quando o cache é apagado por GC do app mas a entry de metadata sobrevive (bug #14061).

**Auto-fix**: copiar do clone do marketplace para o path esperado.

### 3.3 SHA drift — Level 3 com commits afetando (MEDIUM)

`gitCommitSha` em `installed_plugins.json` diferente do HEAD do clone, **e** existem commits entre os dois SHAs que tocaram o diretório do plugin. Sem o filtro de path, o check disparava para todos os plugins cujo install é antigo, mesmo quando o plugin em si não mudou — falso positivo constante.

Só aplica a Level 3 (plugins com `source: "./plugins/..."`). Para Level 2 (SHA pinnado), a existência de drift contra HEAD do clone é **esperada** (o pin não muda automaticamente).

**Auto-fix**: `/marketplace-tools:publish-plugin <nome> patch` (ou bump adequado).

### 3.4 Version drift — marketplace.json vs installed (MEDIUM)

Para plugins Level 3, `marketplace.json[].version` diferente de `installed_plugins.json[...].version`. Indica que bumpei no catálogo mas o ciclo de re-cache não passou.

**Auto-fix**: `/marketplace-tools:publish-plugin <nome>` com bump adequado.

### 3.5 Plugin habilitado mas não instalado (HIGH)

Entry em `settings.json.enabledPlugins` sem correspondência em `installed_plugins.json`. Órfão de settings — plugin foi removido do marketplace mas a flag de habilitação sobreviveu.

**Auto-fix manual**: remover do `enabledPlugins` ou reinstalar.

### 3.6 Cache orphan antigo (LOW)

Diretórios em `cache/<mkt>/<plugin>/<versão>/` não referenciados por `installed_plugins.json` e mais antigos que 7 dias (período de graça oficial expirado).

**Auto-fix**: `rm -rf` no diretório.

## Auto-fix interativo

Depois de revisar o relatório, passar por cada finding `auto-fixable: yes` e decidir manualmente se aplica. Estes são os fixes correspondentes (rodar após revisão humana):

### 3.1 clone-behind-remote
```bash
git -C "$HOME/.claude/plugins/marketplaces/<marketplace-name>" pull --ff-only
```

### 3.2 dangling-path
Para cada finding:
```bash
SUBPATH=${path#$HOME/.claude/plugins/cache/}
MKT=$(echo "$SUBPATH" | cut -d/ -f1)
PLUG=$(echo "$SUBPATH" | cut -d/ -f2)
SRC="$HOME/.claude/plugins/marketplaces/$MKT/plugins/$PLUG"
[ -d "$SRC" ] && cp -R "$SRC" "$path"
```

### 3.3 sha-drift / 3.4 version-drift
Invocar `/marketplace-tools:publish-plugin <nome> patch` (ou bump adequado).

### 3.6 orphan-cache
```bash
rm -rf "$dir"
```

## Checks não implementados (v0.3)

- Validação de schema do `marketplace.json` (usar `claude plugin validate`)
- Detecção de loops de dependência em `dependencies`
- Comparação cross-marketplace (plugin com mesmo nome em marketplaces diferentes)
- Verificação de `permission` overrides em hooks do plugin

## Tratamento de erros

- **`jq` fail**: erro específico na stderr, check continua pros próximos (findings parciais).
- **Clone path inacessível**: reportado como HIGH `marketplace-clone-missing`, checks dependentes do clone pulam.
- **`settings.json` ausente**: pula check 3.5.

## Não-objetivos (v0.3)

- Não checa plugins de outros marketplaces (limita-se ao marketplace do repo atual).
- Não aplica fixes automaticamente — requer revisão humana.
- Não reinicia o Claude Code Desktop (usuário faz manualmente após fixes).
- Não detecta bugs do plugin em si — só inconsistências de state.

## Testar o script isoladamente

Fora do Claude Code:

```bash
cd /caminho/do/repo-com-marketplace
bash plugins/marketplace-tools/scripts/qa.sh
```

Útil para debugar mudanças na lógica sem depender do ciclo de re-install do plugin.
