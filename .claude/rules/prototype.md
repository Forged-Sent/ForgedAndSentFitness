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
- Keep required CI and maintain private-data boundaries. A separate human or AI review is optional for all paths. For sensitive security/scoring decisions, the solo maintainer decides and may seek a non-author AI second opinion.
