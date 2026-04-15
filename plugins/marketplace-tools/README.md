# marketplace-tools

Plugin próprio do marketplace `aj-openworkspace` com ferramentas para manter o próprio marketplace. Primeira versão (v0.1.0) expõe um slash command:

## `/check-marketplace-updates`

Verifica cada plugin Level 2 (com `source.sha` pinnado) no `.claude-plugin/marketplace.json` do repo atual, resolve o HEAD atual do upstream, mostra o diff e aplica updates sob confirmação.

### Como usar

1. Estar na raiz de um repo que contenha `.claude-plugin/marketplace.json`
2. Ter `gh` CLI autenticado (`gh auth status`)
3. Invocar `/check-marketplace-updates` no Claude Code

O comando apresenta um sumário por plugin com updates disponíveis e pergunta: aplicar, skip, detalhar ou parar. Aplicações bem-sucedidas geram commits individuais no formato `bump <plugin> to <short-sha>`.

### Limitações v0.1

- Só checa plugins Level 2 (com SHA). Plugins Level 1 recebem updates automaticamente via Claude Code.
- Não faz rollback automático.
- Não cobre plugins Level 3 (./plugins/).
- Não detecta vulnerabilidades de segurança no diff.

### Instalação

Como parte do marketplace `aj-openworkspace`:

```bash
/plugin marketplace add ajunges/aj-openworkspace
/plugin install marketplace-tools@aj-openworkspace
```

### Autor

André Junges (@ajunges). Plugin escrito 100% via Claude Code.
