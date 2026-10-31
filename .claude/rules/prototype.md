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
- Prototype-only PRs use lightweight CI with optional human approval, but changes to protected seed rules, scoring, security or product decisions need human review.
