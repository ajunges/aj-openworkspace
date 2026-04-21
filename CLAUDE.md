# CLAUDE.md

Instruções específicas deste repo. Carrega junto com `~/.claude/CLAUDE.md` (preferências pessoais globais) — mantém aqui apenas o que é específico do workspace.

## O que é este repo

Workspace pessoal de notas do André Junges (`ajunges`). **Não é um projeto de código** — sem `build system`, sem testes, sem `package manager`, sem código-fonte. Apenas markdown. Não procure por `package.json`, não sugira `linters`, CI ou `test runners`.

## Estilo de documentação

House style para novas notas e edições — **overrides** o `Tom e formato` do global quando o conteúdo for nota/guia deste repo:

- Seções H2 numeradas (`## 1.`, `## 2.`, ...) separadas por horizontal rules (`---`)
- Tabelas markdown para comparações — "antes/depois", "quando usar", "incluir/não incluir"
- Fenced code blocks para comandos, JSON configs e exemplos de `prompt`
- Tom **dentro das notas**: imperativo e opinativo, hedging mínimo — é playbook pessoal, não documentação neutra (distinto do tom de conversa do global, que é profissional-amigável)
- Guias de referência terminam com uma seção **Fontes** linkando fontes primárias (Anthropic docs primeiro)

## Convenções do repo

- Branch padrão: `main`. Sem CI, sem workflow de PR obrigatório — commits vão direto para `main` a menos que o usuário peça branch/PR.
- **Repositório público** em `ajunges/aj-openworkspace` — tudo committado é world-readable.
- `.claude/` está no `.gitignore`. Não tentar committar settings locais.
- Usar o `gh` CLI para qualquer interação com GitHub — disponível e autenticado.

## Marketplace

Este repo hospeda um marketplace Claude Code (`ajunges/aj-openworkspace`) com 29 plugins curados (7 Level 2 com SHA pin, 18 Level 1 em HEAD, 4 Level 3 próprios: `marketplace-tools`, `sdd-workflow`, `humanizador`, `portfolio-docs`).

- `.claude-plugin/marketplace.json` é o catálogo. Schema: `metadata.description` (não `description` no root). Validar com `claude plugin validate .` antes de commitar mudanças.
- `plugins/` contém plugins Level 3 (próprios). Level 1/2 são referências externas.
- Classificação: `tags[0]` sempre é `recomendado`, `em-testes` ou `nao-recomendado`. Plugins novos começam `em-testes`.
- Level 2 (SHA pin) pra plugins que injetam workflow. Level 1 (HEAD) pra tools passivas.
- Descriptions em pt-BR, opinativas, do ponto de vista do usuário.
- Repo público — sanitizar dados profissionais antes de publicar (grep gate: Supero, caminhos absolutos, brand colors).
- Docs do marketplace em `marketplace/README.md` (uso) e `marketplace/ADMIN.md` (administração).

### Versioning de plugins Level 3

- Para plugins com `source: "./plugins/..."`, **`version` vive no `marketplace.json`**, não no `plugin.json`. Se duplicar, o `plugin.json` vence silenciosamente (warning oficial da Anthropic) e facilita drift entre os dois arquivos.
- **Toda mudança de comportamento em plugin Level 3 exige bump de `version`** no `marketplace.json`. Sem bump, o cache do Claude Code não é invalidado e o app continua servindo a versão antiga — comportamento documentado em [docs oficiais](https://code.claude.com/docs/en/plugins-reference#version-management) ("If you change your plugin's code but don't bump the version… existing users won't see your changes due to caching").
- SemVer: patch para bugfix sem mudar API, minor para feature nova (comando/skill), major para breaking change.

### Bugs conhecidos no ciclo de update

O Desktop app sofre de três bugs documentados que fazem plugins ficarem stale mesmo com push feito em main:

- [#13799](https://github.com/anthropics/claude-code/issues/13799) — cache não invalida quando marketplace atualiza
- [#14061](https://github.com/anthropics/claude-code/issues/14061) — `/plugin update` não invalida cache
- [#46081](https://github.com/anthropics/claude-code/issues/46081) — `claude plugin update` usa clone stale (não faz `git fetch` antes)

**Fluxo manual para publicar Level 3** (encapsulado em `/marketplace-tools:publish-plugin`):

1. Bumpar `version` do plugin em `.claude-plugin/marketplace.json`
2. Commit + push em `main`
3. `git -C ~/.claude/plugins/marketplaces/aj-openworkspace pull --ff-only`
4. `jq 'del(.plugins["<nome>@aj-openworkspace"])' ~/.claude/plugins/installed_plugins.json > tmp && mv tmp …`
5. Copiar `marketplaces/aj-openworkspace/plugins/<nome>` → `cache/aj-openworkspace/<nome>/<version>` (workaround do #14061)
6. Reiniciar Claude Code Desktop

**Diagnóstico** via `/marketplace-tools:marketplace-qa` — detecta clone stale, dangling installPaths, version drift entre installed e clone, e plugins habilitados sem entry em installed_plugins.

### Bugs conhecidos no picker de slash commands (Desktop)

Regressão em Claude Code Desktop 2.1.109+: autocomplete do `/` trunca a lista prematuramente e pode ocultar tanto built-ins (`/plugin`, `/clear`, etc.) quanto skills custom, dependendo do estado do cache e da quantidade de skills instaladas. Sintoma típico: digitar um built-in mostra apenas skills custom cujo nome contém aquele termo, escondendo o built-in e forçando escolha de um sufixo. Confirmar olhando a lista antes de aceitar o sugerido.

- [#49087](https://github.com/anthropics/claude-code/issues/49087) (closed, duplicate) — autocomplete mostra só ~5 built-ins, esconde 78 skills custom (regressão do fix de #22020)
- [#49454](https://github.com/anthropics/claude-code/issues/49454) (closed, duplicate) — plugin slash commands não aparecem no picker do Desktop; CLI funciona
- [#45593](https://github.com/anthropics/claude-code/issues/45593) (closed) — custom `/commands` de `~/.claude/commands/` somem do autocomplete após update
- [#49148](https://github.com/anthropics/claude-code/issues/49148) (open) — skills de `~/.claude/skills/` não aparecem no dropdown (Desktop Windows)

**Workarounds:**

1. Digitar `/<comando>` → pressionar **Esc** pra dispensar o picker → **Enter** pra submit literal. Funciona pro built-in `/plugin` quando está shadowed.
2. Usar a CLI fora de sessão: `claude plugin <install|list|enable|disable|update|uninstall>`. A CLI não passa pelo picker quebrado.
3. Gerenciar plugins via Settings UI (botão **+** → **Plugins** na sessão) quando o slash command falhar.
