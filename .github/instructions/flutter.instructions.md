---
applyTo: "mobile/**"
---

# Flutter development conventions for Copilot
- Read `AGENTS.md`, `mobile/AGENTS.md` and applicable ADRs.
- Add testable domain/application code with explicit authorization and offline-state boundaries.
- Keep the existing HTML prototype intact unless the issue explicitly requires both surfaces.
- Run Flutter analyze/tests and record untested builds or integrations in the PR.
- Required Flutter CI/tests must pass. For database/security changes, offer a non-author AI review; no second-person review is mandatory. Agents never self-merge.
