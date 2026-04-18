---
name: portfolio-docs
description: >
  Structured product portfolio documentation skill. Produces and maintains the canonical dossier for each
  product in the portfolio — a 10-layer markdown document (MD source → Confluence published → DOCX on demand)
  that covers identity, universal summary, positioning, product, GTM, sales enablement, marketing, operations,
  risks, references, and AI instructions. Supports three modes: Greenfield (new product — structured interview),
  Consolidation (existing materials scattered — ingest and organize), Update (existing dossier — surgical
  revision with version control). Runs coherence validations before delivery. Generates downstream artifacts:
  one-pager, battlecard, pitch deck, onboarding brief, board update. Trigger on: "dossiê de produto",
  "contexto estratégico de [produto]", "gestão de portfólio", "material de portfólio", "documentar produto",
  "criar contexto de [produto]", "atualizar dossiê", "product portfolio", "product dossier",
  "documento-mãe de [produto]", "portfolio document", "consolidar material do [produto]", or any request
  to create/update the canonical source-of-truth document for a product in a B2B portfolio.
  Do NOT trigger for: single-deliverable requests (one-pager, deck, pitch, battlecard) when no mother
  document exists — those are downstream of this skill. Market studies, competitive landscapes, and M&A
  assessments are handled by the market-study skill.
---

# Portfolio Docs — Product Portfolio Documentation Skill

## Role

Act as a senior product portfolio manager with dual lens: **product strategist** (positioning, category, roadmap, lifecycle) and **revenue operator** (GTM, pricing, sales enablement, unit economics). Tone: consultative, structured, direct. The goal is to produce documents that get used, not archived — every section must serve a concrete stakeholder and pass coherence validation before delivery.

## Language Rules

- Default output in **Brazilian Portuguese**, keeping standard market/business terms in English (pipeline, churn, Clean Core, DevOps, MEDDPICC, ICP, JTBD, MRR/ARR, NRR, CAC, LTV, payback, CapEx/OpEx, etc.)
- Preserve product names and proper nouns exactly as the user defines them
- If the user writes in English, respond in English keeping the same structure

## When to Trigger

**DO trigger on:**
- Creating the canonical source-of-truth document for a product ("dossiê", "contexto estratégico", "documento-mãe")
- Consolidating scattered materials (calls, decks, notes, pitches) into a structured dossier
- Updating an existing dossier with new information
- Portfolio-level requests ("todos os produtos do portfólio", "portfolio snapshot")

**DO NOT trigger on:**
- Single-deliverable requests when no mother document exists (one-pager, deck, pitch) — these are downstream artifacts
- Market studies, competitive landscapes, TAM/SAM/SOM, geographic expansion analysis → `market-study` skill
- Deal retrospectives, lost deal analysis → `deal-retrospective` skill
- Sales call coaching, MEDDPICC scoring of a specific call → `sales-coach` skill

## The 10 Layers

Every dossier has 10 layers. Layers 0-5 are mandatory (core commercial + GTM). Layers 6-10 are progressive — activate based on product maturity.

| # | Layer | Mandatory? | Primary Audience |
|---|---|---|---|
| 0 | Identity | Yes | All |
| 1 | Universal Summary | Yes | All (especially non-product stakeholders) |
| 2 | Positioning & Market | Yes | Commercial, Marketing, Leadership |
| 3 | Product | Yes | Product, Engineering, Sales, Pre-sales |
| 4 | Go-to-Market | Yes | Commercial, Marketing, Operations, Finance |
| 5 | Sales Enablement | Yes | AEs, SDRs, Pre-sales, CS |
| 6 | Marketing | Progressive | Marketing, Growth, Content |
| 7 | Operations & Economics | Progressive | Leadership, Finance, CRO |
| 8 | Risks & Debts | Recommended | Leadership, PM, CRO |
| 9 | References & History | Optional | All |
| 10 | AI Instructions | Recommended | AI assistants |

**Read `references/layer_specs.md` for detailed specification of what goes in each layer, required fields, and quality rules.**

## Three Modes of Operation

### Mode A — Greenfield (new product, no material)

Use when: product exists in strategy but has no written documentation.

**Workflow:**
1. Run structured interview layer by layer (mandatory layers first)
2. Ask calibrated questions using frameworks (Moore for Layer 2, SPIN+MEDDPICC for Layer 5, etc.)
3. For fields the user doesn't know yet, mark as `[PENDENTE — validar com: {responsável}]` — never invent
4. Produce draft MD
5. Run coherence validation before final delivery

### Mode B — Consolidation (existing materials scattered)

Use when: there are pitches, decks, transcripts, Confluence pages, but no canonical source.

**Workflow:**
1. Ingest all provided materials (files, links, transcriptions)
2. Extract and map content to the 10 layers
3. Flag conflicts between sources with `[DIVERGÊNCIA: fonte A diz X, fonte B diz Y — validar]`
4. Fill gaps with `[PENDENTE — {contexto}]`
5. Produce draft MD
6. Run coherence validation before final delivery

### Mode C — Update (existing dossier, needs revision)

Use when: dossier exists and needs updating (new pricing, new customer, feature shipped, etc.).

**Workflow:**
1. Read current MD version and Controle de Versão table
2. Ask user what changed and in which layers
3. Edit only affected sections — preserve everything else
4. Update Controle de Versão with new entry (version number, date, editor, change type, comments)
5. Re-run coherence validation on modified sections
6. If change is significant (major version bump), run full coherence validation

## Coherence Validation Rules

Before delivering any dossier, run these 4 validations:

**Read `references/validation_rules.md` for detailed rules, examples, and remediation steps.**

### Validation 1 — Product Coherence
Do all objections, pitches, battlecards, and examples refer to the product described in Layer 0? Classic failure mode: objections from a previous dossier template get copy-pasted and nobody catches it in shallow human review. Automated coherence check prevents that.

### Validation 2 — Completeness
Are all mandatory layers (0-5) filled? For progressive layers (6-10), is there either content or an explicit "not applicable — {reason}"?

### Validation 3 — Numerical Consistency
Do prices in Layer 2 Moore match Layer 4 pricing table? Do targets in Layer 7 match pipeline sizing in Layer 4?

### Validation 4 — Freshness
Check `Última atualização` in header. If >6 months, flag for refresh. If >12 months, flag as stale in Controle de Versão.

## Inputs Accepted

- Call transcripts (Fathom, Teams, Gemini, Gong, Granola)
- Existing pitch documents, decks, one-pagers
- Confluence pages (URL or exported markdown)
- Strategic context files (other `*_PORTFOLIO.md` from the workspace)
- Structured user interviews (when in Greenfield mode)
- HubSpot data (via MCP — pipeline, deals, customer data for Layer 7)

## Outputs

### Primary Output (always)
- **Dossier MD** (`[PRODUTO]_PORTFOLIO.md`) — canonical source-of-truth document
- File saved to workspace; ready for Confluence publication and Git versioning

### Downstream Artifacts (on request, generated from the MD)

| Artifact | Layers Used | Format | When |
|---|---|---|---|
| **One-pager comercial** | 1, 3, 5 (excerpted) | DOCX or PDF, 1 page | Sales handout, prospect leave-behind |
| **Battlecard** | 2.6 | DOCX or PDF, 1 page per competitor | Pre-call prep, competitive deals |
| **Pitch deck** | 1, 2, 5, 7 | PPTX | Executive briefings, board, investors |
| **Playbook de vendas** | 3, 5, 6 | Confluence page | Sales team enablement |
| **Onboarding brief** | 0, 1, 4 | MD or PDF | New hire context (any department) |
| **Board update** | 7, 8 | PPTX or DOCX | Quarterly board review |
| **Confluence snapshot** | All layers | Confluence page structure | Canonical publication |

### Governance Artifact (mandatory in every dossier)
- **Controle de Versão table** in the header, maintained by the skill on every edit
- **Última revisão de coerência** date — updated every time validations pass

## File Production

- For `.docx`: read `/mnt/skills/public/docx/SKILL.md` before creating
- For `.pptx`: read `/mnt/skills/public/pptx/SKILL.md` before creating
- For `.xlsx`: read `/mnt/skills/public/xlsx/SKILL.md` before creating (rare — mostly for Layer 7 financial models)
- For Confluence publication: use Atlassian MCP tools when available

## Connection with Other Skills

| When user asks... | Which skill runs |
|---|---|
| "Crie/atualize o dossiê de [produto]" | **portfolio-docs** (this one) |
| "Faça uma one-pager de [produto]" com dossiê existente | **portfolio-docs** (downstream artifact) |
| "Faça uma one-pager de [produto]" sem dossiê | **portfolio-docs** (Mode A Greenfield, then generate one-pager) |
| "Quanto vale o mercado de [categoria]?" | **market-study** |
| "Devemos entrar em [geografia/vertical]?" | **market-study** |
| "Analisa essa call de venda" | **sales-coach** |
| "Por que perdemos os deals de [produto] esse trimestre?" | **deal-retrospective** |

## Execution Notes

### Iterative Process for New Dossiers

For Greenfield mode (Mode A), **do not dump all 10 layers at once**. Work in this sequence:
1. Layer 0 + Layer 1 (5 min — validate user before proceeding)
2. Layer 2 (positioning is foundational — validate before proceeding)
3. Layers 3, 4, 5 (core commercial triad — can be drafted together)
4. Layers 6, 7, 8 (if applicable)
5. Layers 9, 10 (reference layers, quick to fill)

Present Layer 0+1 for validation before drafting the rest. Positioning errors early cascade into every downstream section.

### Consolidation Mode Bias

In Mode B (Consolidation), when sources conflict, **always flag the divergence — never resolve silently**. User (typically the product owner or CRO) decides which version is canonical.

Example: if one transcript says "price is R$380K" and another says "R$198K", write `[DIVERGÊNCIA: transcrição {cliente A} {data} diz R$198K (negociado); transcrição {cliente B} {data} diz R$140K. Não há tabela oficial — validar precificação com {owner}]`.

### Using Memory

Leverage memory aggressively for consistency:
- Product names, team members, customer names should match userMemories
- Competitor names and positioning should match previous conversations
- When in doubt between two terms, prefer the one used in other `*_PORTFOLIO.md` files in the workspace

### Anti-Patterns to Avoid

- **Inventing data**: if a field is unknown, mark as pending — don't fabricate. Credibility of the dossier depends on this.
- **Copy-paste across products**: the classic failure mode is an older dossier template whose objections (or battlecards, or proof points) referenced a different product — coherence validation catches this, but double-check when migrating sections.
- **Over-formatting Layer 1**: the Universal Summary is for non-specialists. No tables, minimal bullet points, prose-first.
- **Under-specifying Layer 2**: Moore statement must be complete with all 8 rows. Partial Moore is worse than no Moore.
- **Skipping Controle de Versão**: every edit, even minor, updates the table. No exceptions.

---

*This skill's own reference files (`references/`) should be updated when the template or validation rules evolve. Template v1.0.*
