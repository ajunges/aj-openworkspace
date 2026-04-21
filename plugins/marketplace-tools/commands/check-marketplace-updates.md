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

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/check.sh
```

O script emite um TSV em stdout com o header `PLUGIN OLD_SHA NEW_SHA COMMITS FILES BREAKING TOP_COMMITS`. Apresento o TSV formatado pra você (um bloco por plugin) e pergunto quais aplicar. Se não houver updates, a tabela fica com só o header.

### Etapa 2 — apply seletivo

Após sua seleção, invoco:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/check.sh --apply plugin1 plugin2 ...
```

O script aplica em sequência — um commit por plugin no formato `bump <nome> para <short-sha>`. Erros em plugins individuais não abortam o batch (sumário final mostra quantos falharam e quantos foram no-op).

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
- **JSON inválido após edit**: aborta o plugin específico, não chega a commit.
- **`--apply` com nome inexistente**: skip + warning em stderr, sumário final reporta.
- **`--apply` em plugin já no HEAD**: reporta como `SKIP` e conta em `skipped` (não é erro).

## Não-objetivos

- Não checa plugins Level 1 (sem SHA) — esses recebem updates via Claude Code
- Não atualiza plugins Level 3 (./plugins/) — use `/publish-plugin`
- Não detecta vulnerabilidades de segurança no diff
- Não faz rollback automático
- Não suporta repos privados que exijam auth além do default do `gh`

## Testar o script isoladamente

Fora do Claude Code, da raiz de um repo com marketplace:

```bash
bash plugins/marketplace-tools/scripts/check.sh                           # dry-run
bash plugins/marketplace-tools/scripts/check.sh --apply humanizador       # apply seletivo
```
