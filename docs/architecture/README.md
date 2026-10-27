# Forged & Sent production architecture

**Source of truth** for building Forged & Sent: a faith-centered devotional workout and brotherhood platform built on Flutter and Firebase. It reconciles the Blueprint discussion (D01–D35), the independent review (`docs/reviews/`) and the product direction approved on 2026-10-27.

| # | Document | Covers |
|---|---|---|
| 00 | [Reconciliation matrix](00-reconciliation-matrix.md) | D01–D35 classified, dispositions, approvals needed |
| 01 | [System architecture](01-system-architecture.md) | Context, subsystems, Flutter modules, Firebase deployment, auth, orchestration |
| 02 | [Data architecture (Firestore)](02-data-architecture-firestore.md) | Collections, ownership, sizes, indexes, authorization, lifecycles |
| 03 | [Devotional Workout Experience Engine](03-devotional-workout-engine.md) | Modes, stages, safety gate, re-planning, persistence |
| 04 | [Competition and scoring](04-competition-scoring.md) | Ledger, tiers, alternates, normalization, review and appeal, abuse controls |
| 05 | [Offline and sync](05-offline-sync.md) | Drift + outbox in front of the Firestore cache, idempotency, crash safety |
| 06 | [Proof media](06-proof-media.md) | Capture, local retention, upload, reviewer access, retention |
| 07 | [Nutrition and health](07-nutrition-health.md) | Provider abstraction, bounded points, health provenance |
| 08 | [Security and privacy](08-security-privacy.md) | Roles, threat model, minimum release requirements |
| 09 | [Operations](09-operations.md) | Observability, incidents, moderation, cost model |
| 10 | [Prototype parity](10-prototype-parity.md) | What the prototype does, what is extracted, redesigned or retired |
| 11 | [Roadmap](11-roadmap.md) | Phases 0–7 with gates; first vertical slice and PR sequence |

**Related:**

- Decisions: [`../adr/`](../adr/README.md).
- Requirements: [`../requirements/requirements.yaml`](../requirements/requirements.yaml).
- Tests: [`../requirements/test-catalog.yaml`](../requirements/test-catalog.yaml).
- Open decisions: [`../requirements/open-decisions.md`](../requirements/open-decisions.md).
- Diagrams: [`../diagrams/`](../diagrams/). These are informal UML/C4 views, not formal SysML models.
- Rules drafts: [`../../firebase/`](../../firebase/).
- Agent guidance: [`../../AGENTS.md`](../../AGENTS.md).

**Status key:**

- **Accepted:** approved direction; build to it.
- **Proposed:** awaiting human approval.
- **Open (OD-xx):** a parameter a human must set. It lives in rulesets or config, never hard-coded.

**Validation:** `python3 tools/validate_architecture.py` runs in CI on every PR.

**Planning package (27 Oct 2026):** `docs/planning/`: the product brief, owner decision workshop, staged growth, milestones and Planning Hub spec. Owner decisions are recorded in `docs/planning/decision-log.yaml`, which takes precedence over this folder (AGENTS.md).
