# ADR-0007: Server-authoritative, append-only scoring ledger

- Status: **Accepted** on 2026-10-27 (Phase 0); carried forward by decision Q4. **Planned: nothing here is built.**
- Date: 2026-10-27. Brought to `main` and renumbered on 2026-11-19.
- Decision owner: project maintainer (answer Q4 on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page)

## Where this record comes from

This is **Phase 0 ADR-0005**, "Server-authoritative, append-only scoring ledger", from branch `arch/firebase-reconciliation` (commit `0d21d21`, file `docs/adr/ADR-0005-server-authoritative-append-only-scoring-ledger.md`). It has a new number because `main` already has an [ADR-0005](ADR-0005-flutter-client-stack.md), the client stack (Riverpod, go_router, Drift). **On `main`, ADR-0005 means the client stack and nothing else.**

The five sections from **Context** to **Requirements and verification** are the Phase 0 text, word for word. The sections after them are new and say how the record stands on `main`. The table of old and new numbers is in [ADR-0006](ADR-0006-group-level-isolation.md).

## Context

Prototype scores are client-computed and mutable (review R2, R4).

## Decision

Clients write facts (check-ins, finished sessions, attempts, mission completions). Cloud Functions evaluate facts against an immutable ruleset version and write ledger entries with deterministic IDs `{sourceType}_{sourceId}_{rulesetVersion}_{kind}` using create-if-absent in a transaction. Corrections are `adjustment` entries with actor and reason. Standings are projections recomputed from the ledger (not incremented). Weeks and seasons finalize into hashed snapshots; finalized snapshots are never rewritten.

## Alternatives considered

Client scoring; increment counters (double-count under at-least-once delivery).

## Consequences

+ Fair, reproducible, auditable. − Points appear after server ack (client shows provisional).

## Requirements and verification

Requirements: FS-CMP-001..008. Verification: Retry-storm test; rule-change-after-finalize test; adjustment audit test.

## How this stands on `main`

- **Nothing is built.** There is no Cloud Function, no ledger and no rule set. The three tests named above have not been written or run.
- **"Review R2, R4"** are risks in the independent architecture review of 2026-10-26: client-computed scoring, and standings that change when a task's points are edited later. That review is on the Phase 0 branch and not on `main`. They are not the event ordering rules R1 to R3 in the 2026-11-10 review.
- **The requirement ids are not on `main`.** `FS-CMP-001..008` are defined in `docs/requirements/` on the Phase 0 branch.
- **What a rule set contains, and what a week and a season are, is not decided here.** Phase 0 described them in its ADR-0009 (competition model) and ADR-0019 (seasons), which Q4 does not carry forward. No points, weights or periods are approved by this record.
- **Later answers that scoring must follow** (Decisions page): Q2, the team board is the default and faith points count toward the team total only; Q3, fasting earns no points; Q5, the app hides point values until server scoring exists.
- Agrees with the standing rule in `AGENTS.md`: team challenges and scoreboards are server-authoritative.
