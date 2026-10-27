---
id: ADR-0012
title: "Faith participation and privacy"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-PRV-001..006, FS-CMP-012"
---
# ADR-0012: Faith participation and privacy

**Status:** Accepted

## Context
Approved: never score content or perceived quality of prayers or reflections; personal prayers, confessions and reflections private unless explicitly shared; faith participation weights open.

## Decision
Journals (`users/{uid}/journal`) are owner-only; no leader, admin-client or Function reads for scoring. Faith participation may emit boolean facts (stage completed) only; weights and caps per ruleset (OD-01). Sharing is an explicit per-item action creating a separate shared document; revocable. Push payloads carry no private text.

## Alternatives considered
No faith points at all (Blueprint D09).

## Consequences
+ Honors integration without surveillance. − Weights need pastoral input.

## Requirements and verification
Requirements: FS-PRV-001..006, FS-CMP-012. Verification: Leader-cannot-read-journal test; ruleset schema bans journal-field inputs.
