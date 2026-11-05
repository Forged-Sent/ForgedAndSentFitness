# GitHub Copilot repository instructions

Follow `AGENTS.md` and `docs/development/START_HERE.md`.
Production application is Flutter/Dart under `mobile/`. Existing `index.html` is the prototype reference and must not be rewritten during Flutter work.

Use a branch and PR for every change. All paths require the deterministic GitHub `ci-gate`, but the solo maintainer does not need another person to approve any PR. For Flutter database and Firebase access-rule changes, offer a non-author AI security review as an optional second opinion. Never push to main or self-merge using an agent. Read the prototype instructions for `index.html`, `versions/`, `dev/` and `seed/`.
Use small branches, preserve offline durability, and never invent Firebase integration or change competition/privacy rules without approval. All group authorization and official score updates belong in server code.

Before requesting a merge, list changed files, results of `flutter analyze` and `flutter test`, and security/architecture implications.
