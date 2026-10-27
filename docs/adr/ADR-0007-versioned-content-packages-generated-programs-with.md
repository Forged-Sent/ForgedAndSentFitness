---
id: ADR-0007
title: "Versioned content packages; generated programs with equivalence tests; content approval"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-CNT-001..005, FS-TRN-001..006"
---
# ADR-0007: Versioned content packages; generated programs with equivalence tests; content approval

**Status:** Accepted

## Context
1,460 materialized workout days; devotionals with unknown rights; ESV in UI strings.

## Decision
Content lives as source files (`content/`), built by `tools/fs_content` into versioned packages with license metadata and named approvals, published to Storage with a Firestore manifest. Programs are generated from templates; an equivalence test must reproduce all 1,460 seed rows (with RPE/RIR restored) before templates are edited. Default translation BSB; ESV only with Crossway notice or license. Workflow: draft → in_review → approved → published → retired. AI may flag, never approve.

## Alternatives considered
Keep materialized rows; ship content embedded in the app only.

## Consequences
+ One edit updates the program; traceable approvals. − Requires a small CLI and reviewers.

## Requirements and verification
Requirements: FS-CNT-001..005, FS-TRN-001..006. Verification: Round-trip test; publish gate refuses unapproved packages.
