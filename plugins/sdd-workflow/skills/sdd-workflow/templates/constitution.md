---
tipo_projeto: <web-saas | claude-plugin | hubspot | outro>
tier: <prototipo_descartavel | uso_interno | mvp | beta_publico | producao_real>
tier_decidido_em: YYYY-MM-DD
---

# Constitution — [Nome do Projeto]

## 1. Identidade

- **O que o projeto faz** (1 frase): [...]
- **Para quem é**: [...]
- **Que problema resolve**: [...]

## 2. Tier — justificativa

[Por que esse tier? Captura a intenção, não só a tag. Importante pra promoções futuras saberem se a justificativa original ainda vale.]

## 3. Princípios de Desenvolvimento

Herdados do `/CLAUDE.md` raiz + específicos deste projeto:

- Dados reais, nunca fictícios (princípio inviolável 1 do SDD)
- [Princípio específico 1]
- [Princípio específico 2]
- [...]

## 4. Stack

Stack default sugerida (ver `references/stacks.md` da skill SDD):

| Camada | Tecnologia |
|--------|-----------|
| [Camada] | [Tecnologia + justificativa se override] |

**Override de default** (se aplicável): [justificativa]

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

Conforme tier definido:

- [Standards específicos pro tier — ver `references/tiers.md` pra obrigatoriedades]
- Mobile-first quando UI: 375px / 768px / 1440px (apenas se `tipo_projeto: web-saas`)
- Toast para feedback (nunca `alert()`) (apenas se UI)
- Empty states e loading states em todas as telas (apenas se UI)
- Isolamento de dados entre perfis (se aplicável)

## 9. Decisões Registradas

| Data | Decisão | Contexto |
|------|---------|----------|
| YYYY-MM-DD | Tier inicial: <tier> | <motivação> |
| YYYY-MM-DD | tipo_projeto: <tipo> | <motivação> |

(Promoções de Tier registradas automaticamente pela sub-skill `sdd-promote-tier` ao executar.)
