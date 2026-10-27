> **Historical document. Superseded in part (2026-10-27).** The production direction approved on 2026-10-27 selects **Firebase**.
> This review's Supabase/PostgreSQL recommendation (its ADR-003, D.4, E.3, F schema) is **Rejected**, superseded by
> `docs/adr/ADR-0003`. Its "no video in v1" and "no faith points" positions are superseded by ADR-0010 and ADR-0012.
> Its risk findings (B), prototype inventory (C) and fitness, faith and scoring analysis remain valid evidence.
> Current source of truth: `docs/architecture/` (see `docs/architecture/00-reconciliation-matrix.md`).

# Independent architecture review: Forged & Sent (2026-10-26)

Start with **`ARCHITECTURE-REVIEW.md`**. Sections A-N follow the requested order: A executive verdict, B top 15 risks, C inventory, D alternatives, E architecture (incl. offline, scoring engine, security, faith, fitness), F data model, G ten diagrams, H migration, I backlog, J process and AI agents, K scaling, L ADRs, M owner questions, N recommendation.

Reviewed commit: `a71efab` (origin/main, v154). Nothing in the repository was changed. This folder is uncommitted.

| Folder | Contents |
|---|---|
| `diagrams/` | 11 Mermaid sources (10 requested views + core ER), all rendered successfully with Mermaid CLI |
| `schema/` | Preliminary PostgreSQL DDL with RLS sketches; applied cleanly to PostgreSQL 16 with Supabase stubs; idempotency smoke test |
| `evidence/` | Reproducible scripts and outputs: seed audit, decision matrices (with sensitivity run), cost model |
| `proposed-agent-config/` | Draft AGENTS.md, CLAUDE.md, 3 Claude Code subagents, 6 shared skills, zone guard. **Not installed** (dot-folders renamed). |

Run the evidence scripts from this folder:

```
python3 -I evidence/seed_audit.py ../../..        # path to the repo root
python3 -I evidence/decision_matrix.py
python3 -I evidence/cost_model.py
```
