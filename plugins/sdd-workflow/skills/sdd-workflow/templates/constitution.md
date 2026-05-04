---
tipo_projeto: <web-saas | claude-plugin | hubspot | outro>
tier: <prototipo_descartavel | uso_interno | mvp | beta_publico | producao_real>
tier_decidido_em: YYYY-MM-DD
tier_confianca: <alta | media | baixa>
gates: <explicitos | reduzidos | minimos>
audiencia: <BR | global | hibrida>
gera_receita: <sim | nao | talvez>
trade_offs:
  custo_vs_tempo: <ex: "aceito +20% tempo por -50% custo">
  custo_vs_qualidade: <ex: "preserva qualidade — não comprometer pra reduzir custo">
  custo_vs_velocidade_iteracao: <ex: "lento e barato em fase exploratória, rápido em produção">
---

# Constitution — [Nome do Projeto]

## 1. Identidade

- **O que o projeto faz** (1 frase): [...]
- **Para quem é**: [...]
- **Que problema resolve**: [...]

## 2. Tier — justificativa

[Por que esse tier? Captura a intenção, não só a tag. Importante pra promoções futuras saberem se a justificativa original ainda vale.]

**Tier projetado** (visão final do desenvolvimento, premissa fundadora do plugin): <tier>
**Confiança**: <alta | media | baixa> — confiança baixa = IA propõe revisão antes de Build.Tasks
**Sinais de subdeclaração checados na Discovery**:
- [ ] Vai gerar receita?
- [ ] Armazena dados pessoais?
- [ ] Fica online 24/7?
- [ ] Usuário externo (não-staff) tem acesso?

[Marcar respostas. Se inconsistente com tier declarado, registrar em "Emendas" abaixo.]

## 3. Princípios aplicáveis (governança em 3 camadas)

### Camada 1 — Heurísticas universais (sempre ativas)

Detalhe completo: `skills/sdd-workflow/references/heuristicas.md` da skill SDD.

- H1 Dados reais sempre
- H2 Reuso antes de construção
- H3 Simplicidade preferida
- H4 Anti-abstração prematura (3+ casos antes de abstrair)
- H5 Decisões registradas (mecanismo de exceção embutido)
- H6 Defensividade sobre dependências externas
- H7.1 Custo consciente — auto-execução quando barata = melhor
- H7.2 Custo consciente — trade-offs pré-declarados (ver YAML acima)
- H8 Linguagem ubíqua
- H9 TDD canônico universal

### Camada 2 — Princípios arquiteturais por `tipo_projeto`

Aplica em `mvp+`. Em tier 1-2 vira informativo (IA cita como contexto, não força). Detalhe inline em `references/tipos-projeto.md` da skill SDD por tipo.

[Listar princípios da Camada 2 do `tipo_projeto` deste projeto. Exemplo pra `web-saas`: P-ws1, P-ws2, P-ws3, P-ws4.]

### Camada 3 — Disciplinas operacionais por tier

Cumulativas — cada tier herda do anterior. Detalhe completo em `references/disciplinas-tier.md` da skill SDD.

[Listar disciplinas do tier projetado deste projeto, herdando dos tiers anteriores. Exemplo pra `mvp`: D-ui1, D-ui2, D-mvp1, D-mvp2, D-mvp3.]

## 4. Stack

Stack default sugerida (ver `references/stacks.md` da skill SDD):

| Camada | Tecnologia |
|--------|-----------|
| [Camada] | [Tecnologia + justificativa se override] |

**Override de default** (se aplicável): [justificativa]

**Auth, Billing, Email, Storage, Hosting**: ver `references/overrides-matrix.md` pra escolha por modelo de negócio.

## 5. Inventário de dependências

```yaml
inventario:
  cli_essencial:
    - <ferramenta>   # disponível | AUSENTE
  cli_opcional: []
  mcp_essencial:
    - <mcp>          # disponível | AUSENTE
  mcp_opcional: []
  skills_familia_a:
    - superpowers:brainstorming    # disponível
    - superpowers:writing-plans    # disponível
    # ... (ver references/inventario-dependencias.md pra lista completa)
  servicos_externos:
    - <serviço>      # disponível em env | AUSENTE
```

## 6. Alvo de deploy

[Decisão explícita perguntada na Pré-spec.Stack — ver `references/alvos-deploy.md`]

- **Alvo**: [...]
- **Justificativa**: [...]

## 7. Restrições e Limites (v1)

- O que o sistema **NÃO** faz: [...]
- Limites de escopo: [...]
- Dependências externas: [...]

## 8. Quality Standards

Conforme tier definido (Camada 3 acima cobre). Standards adicionais específicos do projeto:

- [Standards específicos]
- Mobile-first quando UI: 375px / 768px / 1440px (apenas se `tipo_projeto: web-saas`)
- Toast para feedback (nunca `alert()`) (apenas se UI)
- Empty states e loading states em todas as telas (apenas se UI)
- Isolamento de dados entre perfis (se aplicável; via RLS quando Supabase)

## 9. Decisões Registradas (ADRs via H5)

Toda decisão técnica significativa vira ADR aqui. Inclui exceções a heurísticas, princípios da Camada 2 ou disciplinas da Camada 3.

| Data | Decisão | Contexto/Motivação | Heurística/Princípio afetado |
|------|---------|---|---|
| YYYY-MM-DD | Tier inicial: <tier> | <motivação> | premissa fundadora |
| YYYY-MM-DD | tipo_projeto: <tipo> | <motivação> | — |
| YYYY-MM-DD | gates: <modo> | <motivação> | — |

(Promoções de Tier registradas automaticamente pela sub-skill `sdd-promote-tier` ao executar.)

## 10. Emendas (exceções formais a heurísticas e princípios)

H5 (Decisões registradas) embute mecanismo de exceção. Esta seção registra desvios formais a heurísticas (Camada 1), princípios (Camada 2) ou disciplinas (Camada 3).

| Data | Heurística/Princípio/Disciplina afetado | Exceção registrada | Motivação | Backwards compatibility |
|------|---|---|---|---|
| YYYY-MM-DD | (ex: H1) | (ex: usar dados sintéticos por LGPD em campos sensíveis) | (ex: compliance LGPD não permite dados pessoais reais) | (ex: estrutura preservada; pode voltar a real após anonimização) |

(Vazia ao iniciar. Toda exceção a uma heurística vira entrada aqui.)
