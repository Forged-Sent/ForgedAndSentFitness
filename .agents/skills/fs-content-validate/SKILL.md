---
name: fs-content-validate
description: Validate, generate and package Forged & Sent content (programs, movements, substitutions, devotionals, missions, experience templates) with tools/fs_content and prepare human review packets. Agents never set approvals.
---
# Content validation

1. Run `dart run tools/fs_content validate`. It checks schemas, that every program slot resolves to a movement variant for all 4 equipment setups, the substitution graph, challenge unit and tier compatibility, mission inclusive variants, experience-template safety and completion rules, and license metadata.
2. Programs: `fs_content generate --program <slug>` must reproduce the expected rows exactly (equivalence test), with RPE/RIR intact.
3. Scripture: `fs_content validate --scripture bsb` checks verse text. Report mismatches; never rewrite theology.
4. Prepare `fs_content review-packet --package <id>` for human reviewers. `content/**/approved.yaml` is human-only (protected zone).
