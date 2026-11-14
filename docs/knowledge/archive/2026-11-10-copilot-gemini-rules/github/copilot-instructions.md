---
status: archived
updated: 2026-11-11
owner: Chadillac12
source_ref: main
source_sha: 1c26ccd05d11df3c00a6a7824b2027346406bc2f
superseded_by: AGENTS.md
original_path: .github/copilot-instructions.md
original_sha256: 2d849c8e676012994d6f5ba459e4933253475e984e7c4989474addbe9d5f5d26
---
# GitHub Copilot repository instructions

Follow `AGENTS.md` and `docs/development/START_HERE.md`.
Production application is Flutter/Dart under `mobile/`. Existing `index.html` is the prototype reference and must not be rewritten during Flutter work.

Use a branch and PR for every change. All paths require the deterministic GitHub `ci-gate`, but the solo maintainer does not need another person to approve any PR. Functional Flutter/backend changes follow docs/development/FLUTTER-AI-REVIEW-GATE.md; report authorship accurately and verify its rollout status. Copilot comments do not substitute for the selected Codex/Claude gate. Never push to main or self-merge using an agent. Read the prototype instructions for `index.html`, `versions/`, `dev/` and `seed/`.
Use small branches, preserve offline durability, and never invent Firebase integration or change competition/privacy rules without approval. All group authorization and official score updates belong in server code.

Before requesting a merge, list changed files, results of `flutter analyze` and `flutter test`, and security/architecture implications.
