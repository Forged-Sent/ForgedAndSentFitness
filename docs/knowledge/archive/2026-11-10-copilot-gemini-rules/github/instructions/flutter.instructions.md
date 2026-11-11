---
status: archived
updated: 2026-11-11
owner: Chadillac12
source_ref: main
source_sha: 1c26ccd05d11df3c00a6a7824b2027346406bc2f
superseded_by: AGENTS.md
original_path: .github/instructions/flutter.instructions.md
original_sha256: 2998f601a0cb4be242eff3d5aa8f96c418b2cabeffcc74d52aa8215e855130f1
applyTo: "mobile/**"
---

# Flutter development conventions for Copilot
- Read `AGENTS.md`, `mobile/AGENTS.md` and applicable ADRs.
- Add testable domain/application code with explicit authorization and offline-state boundaries.
- Keep the existing HTML prototype intact unless the issue explicitly requires both surfaces.
- Run Flutter analyze/tests and record untested builds or integrations in the PR.
- Required Flutter CI/tests must pass. For database/security changes, offer a non-author AI review; no second-person review is mandatory. Agents never self-merge.
