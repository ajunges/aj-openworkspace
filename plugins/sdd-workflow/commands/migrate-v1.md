---
description: Invoca sub-skill sdd-migrate-v1 (migração v0.x → v1.0.0)
---

Invocar a sub-skill `sdd-migrate-v1` pra migrar este projeto SDD v0.x pra v1.0.0.

A migração refunda a governança em 3 camadas (heurísticas universais + princípios arquiteturais por tipo + disciplinas operacionais por tier), adiciona campos novos no YAML inicial da constitution (`gates`, `audiencia`, `gera_receita`, `tier_confianca`, `trade_offs`), adiciona seção "Emendas" (mecanismo de exceção formal a heurísticas), e oferece revisar a stack default `web-saas` se aplicável.

Migração é opt-in, preserva conteúdo existente, marca propostas com `[INFERIDO — confirmar]`. Não toca em código do projeto — só em `specs/constitution.md`.

Detalhe completo do fluxo de 7 passos: ver `skills/sdd-migrate-v1/SKILL.md`.
