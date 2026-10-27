---
name: fs-scoring-rule-change
description: Change how Forged & Sent awards points, PRs, streak/faithfulness rules, challenge scoring, brackets or finalization. Use for any edit to the ruleset JSON, scoring SQL functions or golden fixtures. Requires owner-approved policy (CP-n) and an ADR.
---
# Scoring rule change

1. Locate the approved policy (docs/rules/*.md, CP-n). If none exists, stop and draft a policy proposal instead.
2. Never edit an existing ruleset version. Copy to `ruleset/<slug>@<n+1>`; validate against `contracts/ruleset.schema.json`.
3. Golden fixtures: add cases under `contracts/golden/scoring/` (facts in → expected score events out) covering the change,
   ties, retries (same fact twice), late submission, bracket edges, Scaled/Adaptive divisions.
4. Update SQL `evaluate_*` functions and the Dart preview in `packages/fs_domain` together; both must pass the same fixtures.
5. Spiritual practices must remain unscored for individuals (FS-DSC-001); the schema test enforces this.
6. New versions apply to future seasons only. A retroactive re-score is a separate, audited admin command with its own ADR.
7. PR body: policy id, ruleset version, effective-from, fixtures added, expected standings impact on the previous season (run the replay script).
