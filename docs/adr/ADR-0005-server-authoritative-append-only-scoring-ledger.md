---
id: ADR-0005
title: "Server-authoritative, append-only scoring ledger"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-CMP-001..008"
---
# ADR-0005: Server-authoritative, append-only scoring ledger

**Status:** Accepted

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
