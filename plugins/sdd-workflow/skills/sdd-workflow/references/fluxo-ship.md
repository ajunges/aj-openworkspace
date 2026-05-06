# Fluxo detalhado — Estágio IV (Ship)

> Reference detalhado do Estágio IV. Carregado pela SKILL principal quando IA está em Ship.Audit, Ship.Delivery ou Ship.Deploy. Para Promoção de Tier (sub-fluxo dedicado), ver sub-skill `sdd-promote-tier`.

## 1. Ship.Audit — 14 dimensões × 5 tiers

Auditoria dimensional. Detalhe completo das 14 dimensões: `references/audit-dimensoes.md`. Matriz de obrigatoriedade por tier: `references/tiers.md` seção 3. Dim 14 (Defesa contra prompt injection) é condicional a "produto tem LLM no caminho?".

Fluxo da Audit:

1. **Pergunta dimensões `perguntar`** ao usuário no início (registra resposta na constitution)
2. **Roda dimensões `obrigatório` e `opcional`** em paralelo via `superpowers:dispatching-parallel-agents`
3. **Sub-agentes especializados**:
   - `code-review:code-review` — dimensão Código
   - `security-review` (built-in) — dimensão Segurança
   - `plugin-dev:plugin-validator` — substitui dimensões 1-7 em `claude-plugin`
4. **Compila relatório** em `specs/audit-<YYYY-MM-DD>.md` copiando + preenchendo `templates/audit.md`. Achados classificados em críticos (bloqueiam Delivery), importantes e melhorias.
5. **`superpowers:requesting-code-review`** — review humana antes da Audit começar, se aplicável

**Quality Gate Audit**: Todas as dimensões `obrigatório` do tier executadas | Dimensões `perguntar` decididas e registradas na constitution | Achados críticos zerados ou tratados antes de avançar | Achados importantes corrigidos ou aceitos com justificativa registrada | Lógica de negócio validada contra dados reais (dimensão 8 sempre obrigatória) | progress.md atualizado.

## 2. Ship.Delivery

Sistema rodando em ambiente de avaliação. Pré-deploy.

1. **Aplicar fixes** dos achados críticos e importantes da Audit
2. **Commit final** das correções
3. **Subir o sistema**: Docker compose ou equivalente conforme `tipo_projeto`
4. **Validar fluxos principais** com o usuário
5. **`superpowers:finishing-a-development-branch`** se branch isolada
6. **`commit-commands:commit-push-pr`** se PR aberto
7. **`pr-review-toolkit:review-pr`** se aplicável

**Quality Gate Delivery**: Zero achados críticos da Audit | Seeds funcionando do zero (limpar banco + popular com dados reais) | Sistema rodando e acessível em ambiente de avaliação | README.md atualizado com instruções de setup e uso | Usuário validou fluxos principais | progress.md atualizado.

## 3. Ship.Deploy — parametrizado por tier

Decisão do alvo foi tomada na Pré-spec.Stack (registrada na constitution). Esta fase **executa o deploy** conforme tier.

Comportamento por tier (ver `references/alvos-deploy.md` pra detalhe):

- **`prototipo_descartavel`**: não tem deploy. Roda local apenas. Ship.Deploy é noop declarado.
- **`uso_interno`**: deploy simples (Docker compose num servidor, Vercel free, hosting básico). Sem rollback formal.
- **`mvp`**: hosting gerenciado, deploy manual, monitoramento básico.
- **`beta_publico`**: rollback plan obrigatório, observabilidade obrigatória, error tracking.
- **`producao_real`**: rollback automático, alertas, on-call ou processo de incidente, monitoramento avançado.

Pra `claude-plugin` no marketplace:

- Se `marketplace-tools:publish-plugin` está instalado, usar o plugin (automatiza fluxo dos 6 passos com workaround dos bugs de cache)
- Senão, fluxo manual: bump version no `marketplace.json` → commit → push → invalidar cache local

**Quality Gate Deploy**: Env de prod separado (secrets fora do código) | Rollback plan documentado (mvp+) ou declarado noop (prototipo/uso_interno) | Monitoramento básico configurado (mvp+) ou declarado noop | Domínio configurado (se aplicável) | Fluxos validados em prod (smoke test pelo menos) | progress.md em 100%.

## 4. Promoção de Tier (sub-fluxo dedicado)

Quando o usuário expressar intenção de mudar tier ("promover esse projeto pra MVP", "agora vai virar prod real"), invocar a sub-skill **`sdd-promote-tier`** ou usar o command `/sdd-workflow:promote-tier`. 11 passos incrementais — não recomeça do zero.
