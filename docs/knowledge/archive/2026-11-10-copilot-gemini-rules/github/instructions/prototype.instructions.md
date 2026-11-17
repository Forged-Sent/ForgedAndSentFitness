---
status: archived
updated: 2026-11-11
owner: Chadillac12
source_ref: main
source_sha: 1c26ccd05d11df3c00a6a7824b2027346406bc2f
superseded_by: AGENTS.md
original_path: .github/instructions/prototype.instructions.md
original_sha256: 65c44321fe92a4dc2984909beaed55f87e22bdd75a3af1601c2ebab475337fb1
applyTo: "index.html,versions/**,dev/**,seed/**"
---

# HTML prototype conventions for Copilot
- This is a fast iteration space, not the Flutter production implementation.
- Follow the root `AGENTS.md` prototype workflow. Work on a short-lived branch and open a PR, never push directly to `main`.
- Keep `index.html` current and archived `versions/app-vN.html` files immutable.
- Run `python3 dev/make_preview.py`; review in a browser and state what was not tested.
- Use the mock only for visual/interaction checks, not real data-access or persistence claims.
- Required CI applies to prototype and executable scripts. Additional human approval is not mandatory for the solo maintainer; privacy/security/scoring changes need explicit maintainer decisions and appropriate tests. Non-author AI review is an optional second opinion.
