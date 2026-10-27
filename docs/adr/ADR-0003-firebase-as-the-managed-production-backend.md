---
id: ADR-0003
title: "Firebase as the managed production backend"
status: Accepted
date: 2026-10-27
relations: "Rejects review ADR-003 (Supabase); see docs/reviews/2026-10-26-independent-architecture-review"
requirements: "FS-ACC-*, FS-CMP-*, FS-OPS-*"
---
# ADR-0003: Firebase as the managed production backend

**Status:** Accepted · Rejects review ADR-003 (Supabase); see docs/reviews/2026-10-26-independent-architecture-review

## Context
Approved direction selects Firebase. The independent review preferred PostgreSQL for relational integrity (groups, scoring ledger, audit). This ADR records how each concern is met on Firebase rather than silently reversing.

## Decision
Use Firebase Authentication, Cloud Firestore (Native mode), Cloud Functions (2nd gen, TypeScript), Cloud Storage for Firebase, Firebase Cloud Messaging, App Check, Crashlytics, Remote Config (flags) and App Distribution. Integrity controls: (1) ledger, standings, review outcomes and moderation actions are written **only** by Functions via the Admin SDK, enforced by rules denying client writes; (2) every client fact uses a deterministic or client-generated document ID with create-only rules; (3) every event-triggered Function is idempotent (Functions are at-least-once); (4) rules unit tests are a required CI check; (5) scheduled Firestore exports to a locked Cloud Storage bucket support recovery and exit.

## Alternatives considered
Supabase/PostgreSQL (review recommendation): stronger relational constraints and SQL; rejected by product decision. Custom API + Postgres: more ops.

## Consequences
+ Built-in offline cache, auth providers, FCM, App Distribution, low ops. − Rules `get()/exists()` calls are billed reads and capped at 10 per single-document request / 20 per batch; no server-side joins (projections maintained by Functions); relational analytics require BigQuery export later; per-read billing punishes broad listeners (banned by validator).

## Requirements and verification
Requirements: FS-ACC-*, FS-CMP-*, FS-OPS-*. Verification: Rules test suite (`firebase/tests/rules`), Functions idempotency tests, cost dashboards and budget alerts.
