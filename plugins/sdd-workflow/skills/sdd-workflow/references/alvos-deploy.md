# Alvos de deploy — catálogo por tipo + tier

Reference do plugin `sdd-workflow` (v1.0). Alvo de deploy é **decisão explícita do projeto**, perguntada na Pré-spec.Stack e registrada na constitution. Tipo+tier nunca determinam alvo automaticamente — eles **sugerem** opções.

## 1. Princípio: alvo é decisão, não derivação

Mesmo dois projetos `web-saas` no tier `mvp` podem ter alvos completamente diferentes:
- Um deploya em Vercel + Supabase (full managed)
- Outro deploya em VPS DigitalOcean com Docker (mais controle)

A IA pergunta na Pré-spec.Stack:

> "Onde esse projeto vai viver? [opções típicas pra <tipo>+<tier>]"

E registra a escolha na constitution.

---

## 2. `web-saas`

| Tier | Alvos típicos |
|---|---|
| `prototipo_descartavel` | Roda local, sem deploy |
| `uso_interno` | Docker compose local, ou VPS pequeno |
| `mvp` | Hosting gerenciado: Vercel/Netlify (frontend), Railway/Render (backend), Supabase/Neon (DB) |
| `beta_publico` | Mesmo do `mvp` + rollback plan + error tracking + CDN |
| `producao_real` | Hosting com replicas, backup, alertas, on-call ou processo de incidente |

---

## 3. `claude-plugin`

Pré-spec.Stack pergunta explicitamente:

| Opção | Significado |
|---|---|
| **Local apenas** | Instalado via `claude plugin install /path/to/plugin`, sem repo nem marketplace |
| **Repo próprio sem marketplace** | Clonar e instalar via path do clone |
| **Marketplace privado** | Publicar em marketplace próprio ou da equipe (com bump de version) |
| **Marketplace público/comunitário** | Publicar pra distribuição ampla (com bump de version) |

Se a opção é "marketplace privado" ou "público" e o usuário tiver `marketplace-tools:publish-plugin` instalado, esse plugin é citado como atalho (automatiza o fluxo dos 6 passos com workaround dos bugs de cache documentados). Se não tiver, a SKILL.md descreve o fluxo manual: bump version → commit → push → invalidar cache.

---

## 4. `hubspot`

| Tier | Alvos típicos |
|---|---|
| `uso_interno` | Portal próprio (sandbox + prod do user) |
| `mvp+` | App publicado privadamente em portal de cliente |
| `producao_real` | App no marketplace HubSpot (se distribuível) |

Sandbox SEMPRE antes de prod. Pré-spec.Stack registra **portal IDs** (sandbox + prod) e **scopes** mínimos.

---

## 5. `outro`

Alvo decidido caso a caso na Pré-spec.Stack, junto com a Stack Decision livre.

---

## 6. Skills usadas no Ship.Deploy

- `superpowers:finishing-a-development-branch` — fechamento da branch
- `commit-commands:commit-push-pr` — abrir PR final se aplicável
- Skills domain-específicas pro alvo (ex: `marketplace-tools:publish-plugin` pra `claude-plugin` em marketplace)
