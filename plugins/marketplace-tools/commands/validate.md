---
description: Valida o marketplace pré-commit — schema oficial + convenções (tags, SemVer, version duplicada em L3)
---

# /validate

Roda validação completa do marketplace do repo atual. Combina o validator oficial da Anthropic com checks de convenção específicos deste marketplace.

## Quando usar

Antes de commitar mudanças em `marketplace.json` ou em plugins Level 3. Também útil pós-merge de branches externas pra sanity check rápido.

## Execução

A lógica vive em `scripts/validate.sh`:

```bash
bash ${CLAUDE_PLUGIN_ROOT}/scripts/validate.sh
```

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

```bash
bash plugins/marketplace-tools/scripts/validate.sh
```
