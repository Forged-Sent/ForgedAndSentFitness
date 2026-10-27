---
id: ADR-0013
title: "Households and youth: modeled, inactive, grant nothing"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-FAM-001..004"
---
# ADR-0013: Households and youth: modeled, inactive, grant nothing

**Status:** Accepted

## Context
Approved: adult men's pilot; future women, spouses, families, possibly youth; model must not assume male, married or parent; households never grant access to private data; youth requires its own design.

## Decision
Profiles have no required gender/marital/child fields. `households/{hid}` and `guardianLinks/{id}` are reserved collections denied by rules (feature flag `households`, `youth` off). When activated, household membership grants only explicitly shared items. Youth accounts require a separate ADR covering consent, moderation and messaging.

## Alternatives considered
Model families now with access semantics (premature, risky).

## Consequences
+ No rewrite later. − None now.

## Requirements and verification
Requirements: FS-FAM-001..004. Verification: Rules test: reserved collections denied; household member cannot read journal.
