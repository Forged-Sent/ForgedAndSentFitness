---
id: ADR-0018
title: "Authorization source: membership documents (claims optional cache)"
status: Proposed
date: 2026-10-27
relations: ""
requirements: "FS-ACC-001..006"
---
# ADR-0018: Authorization source: membership documents (claims optional cache)

**Status:** Proposed

## Context
Rules need group role checks; claims refresh lags and are size-limited.

## Decision
Membership docs are the source of truth; rules use `get()` on `groups/{gid}/members/{request.auth.uid}`. Custom claims may cache `platformAdmin` only. Keep rule paths to ≤ 3 document reads per request.

## Alternatives considered
Claims-only roles.

## Consequences
+ Immediate revocation. − Billed rule reads.

## Requirements and verification
Requirements: FS-ACC-001..006. Verification: Rules tests; read-count budget review.
