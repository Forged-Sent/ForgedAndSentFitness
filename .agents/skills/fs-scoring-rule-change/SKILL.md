---
name: fs-scoring-rule-change
description: Change Forged & Sent scoring (ruleset components, caps, tiers, team normalization, finalization, appeals). Use for contracts/ruleset.schema.json, functions/src/scoring or ruleset documents. Needs an approved OD/ADR.
---
# Scoring rule change

1. Find the approving decision (ADR-0005/0009/0012 and the OD in `docs/requirements/open-decisions.md`). If the OD is still Open, stop and draft a proposal instead.
2. Never edit an existing ruleset version. Create `version + 1` with `approvedBy`, `approvedAt` and `effectiveWeek`. Validate it against `contracts/ruleset.schema.json`.
3. Inputs are fact kinds only. No journal, prayer or reflection fields; no prize, wager or entry fields. No points for volume, deficits or weight loss.
4. Functions:
   - Ledger id = `{sourceType}_{sourceId}_{rulesetVersion}_{kind}`, created only if absent, inside a transaction.
   - Standings are recomputed from the ledger, never incremented.
   - Finalized snapshots are immutable; corrections are `adjustment` entries plus a new snapshot version.
5. Golden fixtures in `contracts/golden/scoring/` cover: caps, ties, retries (same fact twice, duplicate trigger), late or grace, tiers and alternates, team sizes 3 versus 9 (TC-007), nutrition floor (TC-011), and finalized-season unchanged (TC-006).
6. The Dart preview in `fs_domain` and the TypeScript evaluator must both pass the same fixtures.
