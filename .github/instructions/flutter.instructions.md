---
applyTo: "mobile/**"
---

# Flutter development conventions for Copilot
- Read `AGENTS.md`, `mobile/AGENTS.md` and applicable ADRs.
- Add testable domain/application code with explicit authorization and offline-state boundaries.
- Keep the existing HTML prototype intact unless the issue explicitly requires both surfaces.
- Run Flutter analyze/tests and record untested builds or integrations in the PR.
- Human approval is required before merging Flutter changes. Agents never supply that approval.
