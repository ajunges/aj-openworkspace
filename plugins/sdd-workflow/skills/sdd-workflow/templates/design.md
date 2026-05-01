# Design Técnico — [Nome do Projeto]

> Stack base definida na `constitution.md` seção 4. Este doc detalha **como** implementar os requirements (`requirements.md`).

## 1. Stack confirmada

[Reproduzir tabela da constitution + qualquer ajuste decidido nesta fase]

## 2. Schema do banco (se aplicável)

### 2.1 Tabelas

```sql
-- Exemplo
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  -- ...
);
```

### 2.2 Relações e constraints

[Diagramas/listas de FKs, índices, constraints únicos]

### 2.3 Índices

[Quais índices criar e por quê]

## 3. API Routes

### 3.1 Endpoints

| Método | Path | Auth | Descrição |
|---|---|---|---|
| GET | /api/... | JWT/admin | [...] |
| POST | /api/... | JWT | [...] |

### 3.2 Payloads (request/response)

```typescript
// POST /api/...
interface RequestBody {
  field: string;
}

interface ResponseBody {
  id: string;
  field: string;
}
```

### 3.3 Autenticação e autorização

[JWT? OAuth? Como rotas admin diferem de rotas públicas]

## 4. Arquitetura de componentes (frontend, se aplicável)

[Hierarquia de componentes principais. Mobile-first se `tipo_projeto: web-saas`.]

## 5. Organização de pastas

```
src/
├── ...
```

## 6. Estratégia de seed

[Como popular o banco com dados reais (princípio 1). Scripts? SQL? Migrations?]

## 7. Bounded contexts (opcional — DDD parcial)

(Apenas se `tier: producao_real` com domínio complexo, ou `hubspot` extension grande)

[Identificar áreas com modelos distintos. Context map.]

Se não aplicável: noop, declarar "modelo único, sem bounded contexts".

## 8. Spike técnico requerido?

(Decisão da Spec.Design — entra na Fase Spec.Spike opcional)

- [ ] Sim — risco identificado: [descrição]. Cria `specs/spike.md`.
- [ ] Não — todas as tecnologias/integrações são conhecidas e validadas.

## 9. Decisões importantes

[Decisões arquiteturais relevantes — registrar também na constitution seção 9]

- [Decisão] — Por quê: [justificativa] — Alternativas consideradas: [...]
