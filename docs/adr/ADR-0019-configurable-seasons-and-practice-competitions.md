---
id: ADR-0019
title: "Configurable seasons and practice competitions"
status: Accepted
date: 2026-10-27
relations: "Supersedes Blueprint D27 recommendation"
requirements: "FS-CMP-010"
---
# ADR-0019: Configurable seasons and practice competitions

**Status:** Accepted · Supersedes Blueprint D27 recommendation

## Context
The Nov 2, 2026 prototype start is not binding.

## Decision
Seasons are data with IANA time zone, start/end, ruleset and `practice` flag. Practice seasons produce no permanent standings. Real seasons require: rules suite green in staging, scoring golden tests green, owner approval.

## Alternatives considered
Hard-coded week1Start (prototype).

## Consequences
+ Safe launch. − None.

## Requirements and verification
Requirements: FS-CMP-010. Verification: Season config validation tests.
