# GitHub Copilot repository instructions

Follow `AGENTS.md` and `docs/development/START_HERE.md`.
Production application is Flutter/Dart under `mobile/`. Existing `index.html` is the prototype reference and must not be rewritten during Flutter work.

Use a branch and PR for every change. Only the low-risk paths exempted in `tooling/policy/review_scope.py` skip mandatory approval; Flutter, executable preview scripts, infrastructure, CI, security and all unknown/new paths require a human review through GitHub's path-specific ruleset. Never push to main or self-merge using an agent. Read the prototype instructions for `index.html`, `versions/`, `dev/` and `seed/`.
Use small branches, preserve offline durability, and never invent Firebase integration or change competition/privacy rules without approval. All group authorization and official score updates belong in server code.

Before requesting a merge, list changed files, results of `flutter analyze` and `flutter test`, and security/architecture implications.
