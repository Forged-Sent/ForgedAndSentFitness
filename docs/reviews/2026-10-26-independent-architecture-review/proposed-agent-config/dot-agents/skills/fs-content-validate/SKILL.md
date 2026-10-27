---
name: fs-content-validate
description: Validate, generate and package Forged & Sent content (programs, movements, substitutions, devotionals, challenges, standards) with tools/fs_content. Use when editing anything under content/ or preparing a content package release. Agents may prepare packages but never set approvals.
---
# Content validation

1. `dart run tools/fs_content validate` — schema, references (every program slot → movement variant for all 4 equipment setups),
   substitution graph, challenge unit/scoredBy compatibility, duplicate warm-up movements, prescription grammar.
2. Programs: `fs_content generate --program <slug>` must reproduce the expected schedule fixtures exactly (round-trip test).
   Intensity (RPE/RIR/deload) must be present for every work set.
3. Devotionals: `fs_content validate --scripture bsb` compares verse text to the BSB source; report mismatches, never "fix" theology.
4. License metadata is required per package (`license`, `source`, `attribution`). Missing → fail.
5. `approved.yaml` files are human-only. Prepare a review packet (`fs_content review-packet --package <id>`) for the reviewers instead.
