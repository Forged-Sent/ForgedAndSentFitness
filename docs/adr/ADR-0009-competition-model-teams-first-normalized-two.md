---
id: ADR-0009
title: "Competition model: teams first, normalized; two difficulty tiers; approved alternates; personal improvement"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-CMP-001..014"
---
# ADR-0009: Competition model: teams first, normalized; two difficulty tiers; approved alternates; personal improvement

**Status:** Accepted

## Context
Approved: team competition primary with independent participation; normalized team scores; two difficulty levels; approved alternates; published point differences; no unsafe or dishonest incentives; no cash prizes.

## Decision
Seasons pin a ruleset. Point sources: scheduled workout participation (capped per week), weekly physical challenge (tier `standard`/`foundation` with published multipliers; alternates map to a tier), 1–2 weekly missions, personal improvement vs frozen baseline, bounded nutrition participation (ADR-0011), bounded faith participation (ADR-0012). Team score = normalized per enrolled member (formula OD-02). Individuals may enroll without a team. Late submissions use server time + grace (OD-13). No prize, wager or paid-entry fields exist in the schema.

## Alternatives considered
Age brackets with leader-relative 0–100 (prototype); separate divisions (review).

## Consequences
+ Fair across sizes and abilities. − Requires published rules and approval of multipliers and caps.

## Requirements and verification
Requirements: FS-CMP-001..014. Verification: Team-size fairness property tests; alternates scoring tests; caps tests.
