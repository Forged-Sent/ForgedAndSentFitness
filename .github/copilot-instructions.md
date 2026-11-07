# GitHub Copilot repository instructions

Follow `AGENTS.md` and `docs/development/START_HERE.md`.
Production application is Flutter/Dart under `mobile/`. Existing `index.html` is the prototype reference and must not be rewritten during Flutter work.

Use a branch and PR for every change. All paths require the deterministic GitHub `ci-gate`, but the solo maintainer does not need another person to approve any PR. Functional Flutter/backend changes follow docs/development/FLUTTER-AI-REVIEW-GATE.md; report authorship accurately and verify its rollout status. Copilot comments do not substitute for the selected Codex/Claude gate. Never push to main or self-merge using an agent. Read the prototype instructions for `index.html`, `versions/`, `dev/` and `seed/`.
Use small branches, preserve offline durability, and never invent Firebase integration or change competition/privacy rules without approval. All group authorization and official score updates belong in server code.

Before requesting a merge, list changed files, results of `flutter analyze` and `flutter test`, and security/architecture implications.
