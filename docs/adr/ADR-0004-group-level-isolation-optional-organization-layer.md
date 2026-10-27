---
id: ADR-0004
title: "Group-level isolation; optional organization layer"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-ACC-001..006"
---
# ADR-0004: Group-level isolation; optional organization layer

**Status:** Accepted

## Context
Pilot is one men's group; growth means many independent groups and possibly churches.

## Decision
`groups/{gid}` is the isolation boundary. Every shared document lives under a group path. Membership is `groups/{gid}/members/{uid}` (written only by Functions). Rules check membership and role. `organizations/{oid}` (future) links groups for administration only and **grants no member data access**. Cross-group feeds are off.

## Alternatives considered
Organization-first tenancy (premature). Custom-claims-only membership (token refresh lag, 1,000-byte claims limit).

## Consequences
+ Simple pilot, additive growth. − Rules reads per request; queries must always include the group path.

## Requirements and verification
Requirements: FS-ACC-001..006. Verification: Rules tests: non-member denied; member of group A denied group B.
