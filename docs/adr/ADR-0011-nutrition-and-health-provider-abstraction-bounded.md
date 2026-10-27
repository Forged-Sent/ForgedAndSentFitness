---
id: ADR-0011
title: "Nutrition and health: provider abstraction; bounded participation points; provenance"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-NUT-001..008, FS-HLT-001..006"
---
# ADR-0011: Nutrition and health: provider abstraction; bounded participation points; provenance

**Status:** Accepted

## Context
Approved: nutrition is part of the product and may earn bounded points; provider abstraction; optional HealthKit/Health Connect; private data; consent; dedupe; no points for under-eating.

## Decision
`NutritionProvider` interface behind a Functions proxy (keys server-side, caching); first provider chosen in OD-07. Food logs are private. Points only for logging consistency and hydration, capped weekly (OD-04); no deficit or weight-loss scoring; safety floor prompts a check-in, not points. Health data: consented per type, stored as daily aggregates with source provenance and dedupe keys; device diary import is **not** claimed unless verified per source app.

## Alternatives considered
AI estimates as numbers (prototype); calorie-accuracy points.

## Consequences
+ Useful and safe. − Provider licensing/attribution obligations.

## Requirements and verification
Requirements: FS-NUT-001..008, FS-HLT-001..006. Verification: Under-eating-not-rewarded test; dedupe tests.
