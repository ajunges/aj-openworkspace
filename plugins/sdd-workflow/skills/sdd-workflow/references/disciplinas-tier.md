# Disciplinas operacionais por tier — Camada 3

Reference do plugin `sdd-workflow` (v1.0.0). Disciplinas que escalam com o nível de risco declarado. **Cumulativas** — cada tier herda todas as disciplinas dos tiers anteriores.

Diferente da Camada 1 (heurísticas universais sempre ativas) e da Camada 2 (princípios arquiteturais por tipo), a Camada 3 ativa proporcionalmente ao tier projetado.

---

## Tier 1 — `prototipo_descartavel`

**Nenhuma disciplina obrigatória.**

Camada 1 (heurísticas) ativa. Camada 2 do `tipo_projeto` é informativa (IA cita como contexto, não força). Liberdade pra explorar.

---

## Tier 2 — `uso_interno`

### D-ui1 Logs básicos

Logging estruturado em fronteiras críticas: autenticação, ações destrutivas, integrações externas.

**Mínimo:** linha por evento com timestamp, identificador de usuário/sessão, ação, resultado. Formato JSON line preferido pra parsing futuro.

**Anti-pattern:** `console.log("erro")` sem contexto; logging só na pasta local sem rotação.

### D-ui2 README operacional mínimo

README cobre:
- Como rodar localmente
- Como configurar variáveis de ambiente
- Como debugar problema comum (lista de 2-3)
- Quem chamar quando dá errado (mesmo que seja "eu mesmo")

**Anti-pattern:** README só com `npm install && npm start`.

---

## Tier 3 — `mvp` (herda tudo de uso_interno +)

### D-mvp1 Observability básica

**Ferramenta default:** Sentry (instalação trivial em Vercel marketplace pra stack default; equivalente em outros hosts).

**Mínimo obrigatório:**
- Logs estruturados (D-ui1) + agregação (Sentry, BetterStack, ou similar)
- Tracking de erros com stack trace e contexto de usuário (não-PII)
- Métricas básicas: latência (p50, p95), error rate, throughput

**Anti-pattern:** apenas logs locais sem agregação; sem alerta quando error rate sobe.

### D-mvp2 Backup automático com restore testado

Se há banco persistente, há backup automatizado **e** restore testado pelo menos uma vez antes de declarar `mvp` pronto.

**Mínimo:**
- Backup diário (ou frequência ajustada à criticidade)
- Retenção mínima de 7 dias
- Restore exercitado em ambiente de teste — registrado na constitution com data e resultado

**Anti-pattern:** "tem backup" sem nunca ter testado restore; backup no mesmo servidor que o banco.

### D-mvp3 Documentação de recovery

README operacional (D-ui2) expandido com:
- Como recuperar se cair (passos concretos, não "checar logs")
- Como reverter deploy quebrado (rollback procedure)
- Contatos de incidente (mesmo que seja só você + provedor de hosting)
- Tempo esperado de recuperação (RTO informal)

**Anti-pattern:** "se quebrar, eu resolvo" sem documentação.

---

## Tier 4 — `beta_publico` (herda tudo de mvp +)

### D-bp1 Integration testing em fronteiras críticas

Auth, payment, integrações externas, qualquer coisa que se quebrar tira o produto do ar.

**Mínimo:**
- Test suite cobrindo cenários de fronteira (login, pagamento, webhook)
- Rodando em CI antes de cada deploy
- Bloqueia deploy se integration test falha

**Anti-pattern:** unit tests apenas; "testar manualmente antes de subir".

### D-bp2 Versionamento semântico explícito

Releases versionadas (SemVer), changelog mantido, breaking changes anunciados.

**Mínimo:**
- `package.json` ou equivalente com `version:` SemVer
- `CHANGELOG.md` na raiz do projeto, atualizado por release
- Tag git por release (`v1.2.3`)

**Anti-pattern:** "main em produção" sem tag; mudar API sem bumpar major.

### D-bp3 Audit logs imutáveis em ações sensíveis

Quem fez o quê, quando, por quê. Especialmente em multi-tenant.

**Mínimo:**
- Log dedicado pra ações sensíveis (login, mudança de permissão, ação destrutiva, transação financeira)
- Imutável (append-only, sem delete; idealmente em armazenamento separado)
- Retenção definida em política

**Anti-pattern:** logs gerais misturados; audit log que pode ser editado.

### D-bp4 Performance baseline declarado obrigatório, medição "perguntar"

**Declarar baseline é obrigatório.** Constitution registra targets concretos: "Página principal carrega em <2s P95", "API endpoints retornam <500ms P99", etc.

**Medir é "perguntar" no Audit.** Audit dimensão Performance pergunta: "Vocês têm instrumentação ativa pra medir os baselines declarados?". Se sim, mede e compara. Se não, registra ausência na constitution e sinaliza débito técnico (não bloqueia, mas obriga reflexão).

**Trigger pra subir pra "obrigatório" full:** se durante uso real aparece reclamação de performance ou incidente, baseline + medição viram obrigatório no próximo Audit.

**Anti-pattern:** "performance é importante" sem número; medir só quando reclamam.

### D-bp5 Rate limiting

API pública sem rate limit é convite a abuso.

**Mínimo:**
- Rate limit por IP em endpoints públicos
- Rate limit por usuário autenticado em endpoints autenticados
- Resposta HTTP 429 quando limite excedido
- Limite documentado pro consumidor da API

**Anti-pattern:** API aberta sem proteção; limite só no cliente.

---

## Tier 5 — `producao_real` (herda tudo de beta_publico +)

### D-pr1 SLO declarado e monitorado

Service Level Objective explícito: uptime alvo, RTO (Recovery Time Objective), RPO (Recovery Point Objective).

**Mínimo:**
- SLO documentado: ex "99.5% uptime mensal", "RTO 4h", "RPO 1h"
- Painel ativo medindo SLO em tempo real
- Alertas quando SLO está em risco (não só quando violado)

**Anti-pattern:** "queremos uptime alto" sem número; medir só após violação.

### D-pr2 Disaster recovery testado

Não só backup (D-mvp2). Restore exercitado periodicamente em ambiente equivalente a produção.

**Mínimo:**
- Exercício de DR pelo menos trimestral
- Teste de restore em ambiente isolado
- Documento "lessons learned" após cada exercício
- Tempo medido vs RTO declarado

**Anti-pattern:** "tem DR plan" sem nunca ter exercitado; testar só em ambiente onde pouco quebra.

### D-pr3 Compliance aplicável

LGPD (Brasil), PCI-DSS (cartão), SOC 2 (B2B SaaS sério), HIPAA (saúde nos EUA), etc. Aplicar conforme domínio.

**Mínimo:**
- Compliance aplicáveis identificados na constitution
- Para cada um: checklist de requisitos atendidos, gaps registrados, plano de remediação
- Audit trail conformante (D-bp3)
- DPO/Privacy Officer designado se LGPD se aplica

**Anti-pattern:** "compliance é com o jurídico" sem ação técnica; tratar como TODO eterno.

### D-pr4 Audit dimensional completo

Todas as dimensões obrigatórias pelo tier (matriz em `references/tiers.md`) executadas no Audit. Achados críticos zerados antes de Ship.Delivery.

**Mínimo:**
- Audit completo executado pré-deploy
- Achados críticos zerados
- Achados importantes corrigidos ou aceitos via H5 (ADR)
- Audit registrado em `specs/audit-<data>.md`

### D-pr5 Defesa contra prompt injection (se LLM no caminho)

Aplica se o produto tem componente LLM no caminho de produção (chatbot, processamento via LLM, agente exposto a usuário).

**Quando aplica:**
- LLM usuário-facing em `beta_publico` ou `producao_real` → **obrigatório**
- LLM apenas interno em `producao_real` → **perguntar** (Audit pergunta no início)
- Sem LLM → dimensão pulada (— na matriz)

**Checks específicos (OWASP LLM Top 10):**
1. Inputs de usuário sanitizados antes de chegar ao LLM (sem instruction injection óbvia)
2. System prompt isolado de user prompt com delimitadores robustos
3. Outputs do LLM passam por validação antes de ação destrutiva (não executa código direto, não envia email direto sem confirmação)
4. Logs de prompts pra auditoria (sem PII)
5. Rate limiting específico em endpoints LLM-driven (D-bp5 reforçado)

**Sub-agente no Audit:** `security-review` (built-in) com prompt customizado pra OWASP LLM Top 10 (LLM01-LLM10).

**Anti-pattern:** confiar que "o usuário não vai tentar"; logar prompts com PII sem sanitização; LLM com permissão de executar código sem sandbox.

### D-pr6 Plano de incidente documentado

Quem chama quem, escalation, post-mortem padrão.

**Mínimo:**
- Runbook de incidente comum (banco caiu, deploy falhou, integração externa fora)
- Escalation matrix: severidade × responsável × tempo de resposta
- Template de post-mortem (causa raiz, ação imediata, ação preventiva, lessons learned)
- Histórico de incidentes em `specs/incidentes/<YYYY-MM-DD>.md`

**Anti-pattern:** "se der ruim, a gente decide na hora"; post-mortem sem ação preventiva registrada.

---

## Como disciplinas se relacionam com Audit

A Audit (Ship.Audit) usa as 14 dimensões em `references/audit-dimensoes.md`. Cada disciplina da Camada 3 mapeia pra dimensões específicas:

| Disciplina | Dimensões da Audit |
|---|---|
| D-ui1 Logs básicos | dim 7 Código + dim 12 Documentação operacional |
| D-mvp1 Observability básica | dim 10 Observabilidade |
| D-mvp2 Backup com restore testado | dim 12 Documentação operacional + dim 13 Manutenibilidade |
| D-bp1 Integration testing | dim 8 Lógica de negócio |
| D-bp4 Performance baseline | dim 4 Performance |
| D-pr3 Compliance | dim 11 Conformidade legal |
| D-pr5 Defesa prompt injection | dim 14 Defesa contra prompt injection (nova em v1.0.0) |

Disciplina ausente sem ADR registrado vira achado crítico na Audit do tier que a exige.

---

## Como exceções a disciplinas funcionam

Disciplinas da Camada 3 não são "invioláveis". Quando um projeto precisa pular ou adiar uma disciplina, registra exceção via H5 (ADR) na seção "Emendas" da constitution.

**Exemplo:** projeto `mvp` que aceita rodar sem D-mvp2 (backup) durante 2 sprints porque está em pivot de modelo de dados — exceção registrada com prazo de fim e plano de recuperação. Não é abandono; é débito técnico consciente.
