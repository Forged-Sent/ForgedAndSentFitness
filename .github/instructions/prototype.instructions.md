---
applyTo: "index.html,versions/**,dev/**,seed/**"
---

# HTML prototype conventions for Copilot
- This is a fast iteration space, not the Flutter production implementation.
- Follow the root `AGENTS.md` prototype workflow. Work on a short-lived branch and open a PR, never push directly to `main`.
- Keep `index.html` current and archived `versions/app-vN.html` files immutable.
- Run `python3 dev/make_preview.py`; review in a browser and state what was not tested.
- Use the mock only for visual/interaction checks, not real data-access or persistence claims.
- Human approval is optional ONLY for the explicit low-risk prototype exceptions in `tooling/policy/review_scope.py`. `dev/make_preview.py`, `dev/patches/**`, `dev/firebase/**`, protected seed rules and all unfamiliar paths require approval; privacy/security/scoring decisions always need human sign-off.
