---
paths:
  - "index.html"
  - "versions/**"
  - "dev/**"
  - "seed/**"
---

# HTML prototype scope
- Follow the repository's `AGENTS.md` HTML prototype workflow.
- Limit edits to the requested prototype behavior; do not refactor `mobile/` without an explicit issue.
- Preserve existing archived HTML versions and maintain an append-only version history.
- Run `python3 dev/make_preview.py` and review visuals. Mock data is not evidence of real authentication, access controls or persistence.
- Only explicit low-risk exceptions listed in `tooling/policy/review_scope.py` have optional formal review. Executable `dev/*.py`, `dev/patches/**`, `dev/firebase/**`, protected seed rules, unknown new paths and security/scoring decisions require human review.
