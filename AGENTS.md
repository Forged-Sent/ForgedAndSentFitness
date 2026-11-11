# Forged & Sent: agent instructions

This file is the shared rule set for every AI agent. Codex loads it directly. Claude Code loads it through the `@AGENTS.md` import in `CLAUDE.md`.

## Product
Forged & Sent is a faith-centered devotional workout and group accountability platform. The current `index.html` is a behavioral prototype, NOT the production mobile client. Preserve the prototype and its seed files unless the assigned task explicitly requires changing them.

## Architectural decisions
- Production mobile: Flutter/Dart for Android and iOS.
- Client stack (ADR-0005, accepted): Riverpod for state, go_router for navigation, Drift on native SQLite for durable local data.
- Preferred managed backend: Firebase (Auth, Firestore, Functions, Storage). No server is configured or deployed yet.
- Offline workout state must be locally durable and sync with idempotent event identifiers. Firebase cache alone is insufficient for durable media and conflict-prone writes.
- Group and role authorization must be enforced server-side. Private prayers, reflections, nutrition, injuries and body measurements must not appear in group queries.
- Scripture can be completed before, after, during safe rest periods, or at separate times of day. Prompts are optional.
- Team challenges and scoreboards are server-authoritative; no spirituality-quality scoring or points for eating less.
- Initially adult men's groups; design domain boundaries for future households and youth without enabling youth functionality by default.
- Product decisions and their status live in `docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md`. An answer still marked TODO is undecided: stop and ask. Never infer product rules from the HTML prototype.

## Protected operations
- GitHub rulesets, not instructions or AI reviews, enforce protected branches and mandatory checks. The live ruleset requires `ci-gate` and ZERO human approvals. Do not claim a second human review is enforced. Never push to `main`, force-push, bypass protections, or merge before required checks pass.
- **Agent push rule.** An AI agent may push commits to a non-`main` branch only when ALL of the following are confirmed immediately before the push: (1) a human explicitly authorized that push in the current session; (2) every review thread on the PR is closed (resolved or outdated), checked on GitHub rather than assumed; (3) `ci-gate` on the PR's current head is green, or the push is the fix for a failing `ci-gate`. Agents never push to `main`, force-push, approve or merge, even with authorization.
- AI reviews are advisory and never count as approval. Agents must not self-approve, self-merge, change branch protections, or impersonate a human reviewer. A tool that wrote a change is not an independent reviewer of it.
- Hosted review today: a Claude review runs automatically on pull requests that change `mobile/`, `firebase/` or `functions/` (`.github/workflows/claude-code-review.yml`). The separate functional AI review gate (`docs/development/FLUTTER-AI-REVIEW-GATE.md`) is staged and its ruleset is disabled; never claim it is enforced.
- Contributor development is emulator-first, with `demo-*` project IDs and no cloud CLI login. No default cloud Firebase MCP, Firebase deployment, or PROD credentials on colleague devices. Never run `flutterfire configure` automatically or include production FirebaseOptions in contributor builds. Follow `docs/architecture/ADR-0002-emulator-first-firebase.md`.
- Project MCP stdio commands use the allowlisted Node launcher. Never add a Firebase cloud MCP or request credentials automatically.

## Working agreement
1. Read the task's prompt or feature contract and any applicable ADR before work. `docs/development/START_HERE.md` is workstation setup for people; read it only for setup problems.
2. One focused task per branch. Never change `main` directly. Contributors use the project `fs-start` / `fs-save` / `fs-sync` / `fs-share` / `fs-status` helpers.
3. The maintainer makes product decisions for dependencies, authentication and data access, scoring, health permissions and communications, and may do so without a separate reviewer. Prototype-only changes do not approve production behavior.
4. Prefer a minimal vertical slice with tests over a large unreviewable implementation.
5. Keep Flutter features under `mobile/lib/src/features/`; UI depends on application and domain code, not Firebase SDK types.
6. Do not commit credentials, Firebase service account JSON, signing keys, personal data, or large generated media.
7. Pull requests report changed files, test commands and results, potential data exposure, and unresolved decisions.
8. Never claim an integration is tested until it has actually been run. Label what you did not run NOT VERIFIED.

## The work board
- `docs/knowledge/WORK.md` is the one board. Read your row before starting.
- Any pull request that starts, finishes or changes a board item edits that row **in the same pull request, written as it will be true once the pull request merges**. Do not open follow-up "refresh" pull requests.
- Edit only your own row. Do not record CI or merge state in the repository; link the pull request or branch instead. GitHub is the source for that.
- CI fails a pull request that changes `mobile/lib/`, `firebase/` or `functions/` without changing `docs/knowledge/WORK.md`.
- The pull request description is the handoff. Create `docs/knowledge/handoffs/<task>.md` only for work that must pause across sessions before a pull request exists.
- `docs/knowledge/HISTORY.md`, `docs/knowledge/archive/**` and `versions/**` are reference only. Leave them out of default searches unless the task needs a specific historical record.

## Docs are part of done
The maintainer reads this project in Obsidian from the `main` checkout. A pull request is not finished until every page that describes what it changed says what is now true. Write each page as it will be true once the pull request merges.

| If your pull request changes | Update in the same pull request |
|---|---|
| Anything on the board | Your row in `docs/knowledge/WORK.md` (CI-checked for app and backend code) |
| A prototype screen's Flutter status | Its row in `docs/knowledge/PROTOTYPE-PARITY.md`: Not started, In progress or Implemented |
| A feature's behavior | Its contract under `docs/features/<slug>/`: status, implementation paths, verified tests |
| Colors, type, spacing or shared widgets | `docs/design/DESIGN-SYSTEM.md` (CI-checked) |
| A boundary, data store, service or permission | `docs/architecture/SYSTEM.md`, plus an ADR for a lasting decision |
| Dart files | `docs/architecture/CODE-MAP.md`, by running the generator (CI-checked) |
| A product decision | `docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md`, by the maintainer only |

- Every page separates what is planned from what is implemented. Never describe planned work as existing.
- Do not hand-write pull request or CI state. After you open or update a pull request, and at the end of every session, run `python3 tooling/knowledge/live_status.py --pull`. It fast-forwards the `main` checkout and regenerates `docs/knowledge/LIVE.md`, the "needs your attention" section of the dashboard. That file is git-ignored; never commit it.

## HTML prototype workflow
- `index.html` is the active prototype. Use a short-lived `prototype/<topic>` branch and a PR to `main`, with a screenshot or notes for visual changes.
- Preserve `versions/app-vN.html` as append-only history; record a milestone in a new version file and never rewrite an older one.
- Run `python3 dev/make_preview.py`, open `dev/preview.html`, and note any untested `window.claude` behavior. The local mock is not proof of data access, sharing, identity or persistence.
- Only `index.html`, `versions/**`, `dev/*.html`, `dev/mock-claude.js`, `seed/devotionals*.json`, `seed/lifts.json`, `seed/esv-verses.json` and root `README.md` qualify for the lighter prototype review. `seed/db-rules.json`, `seed/tasks.json`, `seed/weekly-challenges.json`, `seed/movement-standards.json`, `dev/make_preview.py`, `dev/patches/**`, `dev/firebase/**` and `docs/development/**` are review-protected.
- If a prototype change alters authorization, scoring or privacy semantics, escalate to the maintainer. Do not introduce prototype runtime dependencies into `mobile/` or treat its backend adapter as production authorization.

## Pull request classification
- **Prototype:** the explicit exceptions above. Lightweight preview CI, required PR.
- **Application:** `mobile/` and production app architecture. Flutter CI applies.
- **Infrastructure and security:** `tooling/`, workflows, agent instructions, MCP settings, Firebase config, ADRs and protected seed rules. Policy CI and a maintainer decision.
- A mixed PR receives the strictest applicable checks. Prefer splitting unrelated changes. The maintainer decides when to merge; agents never self-merge.

## Checks
- `cd mobile && flutter pub get && flutter analyze && flutter test`, using the Flutter version pinned in `.github/workflows/ci-gate.yml`.
- `cd mobile && flutter build apk --debug` once Android platform files exist.
- `python3 tooling/knowledge/check.py` after changing anything under `docs/knowledge/`, `docs/features/` or `docs/HOME.md`.
- `python3 tooling/architecture/generate.py --write` after changing `mobile/lib/**`; CI rejects a stale `docs/architecture/CODE-MAP.md`.
- `python3 tooling/skills/sync.py --check` after changing a skill. `.agents/skills` is canonical; `.claude/skills` must match.
- Do not claim Android or iOS device behavior until it has been run and recorded.

## Skills and roles
Use one builder per task. Name the skill you are using in the pull request description.

| Use this skill | When |
|---|---|
| `flutter-vertical-slice` | Building or changing one Flutter feature |
| `flutter-platform-parity` | Porting or comparing a prototype screen |
| `independent-code-review` | Reviewing a change you did not write |
| `flutter-architecture-review` | Reviewing boundaries, imports and ADR compliance |
| `firebase-security-review` | Reviewing rules, auth, scoring or private data |
| `knowledge-steward` | Updating the work board or retiring a stale note |
| `task-coordinator` | Only when the maintainer asks for multi-agent coordination |

After a review, address findings once on the same branch, rerun checks, and ask for a fresh review of the new head. If that review still has findings, stop and wait for the maintainer.

## Architecture records
- `docs/architecture/SYSTEM.md` separates what exists from what is planned. `docs/architecture/CODE-MAP.md` is generated from real Dart source. Update `SYSTEM.md` and add an ADR when a boundary or lasting decision changes.
- The Architecture Explorer is generated by `python3 tooling/architecture/build_explorer.py --write`; keep `docs/architecture/explorer/model.json` aligned with real code and never label a proposed component as implemented.
- For Flutter, Dart or library questions, check the pinned SDK and `mobile/pubspec.lock` and current official documentation. See `docs/knowledge/FLUTTER-AI-DOCS.md`. Android and iOS come first; web is a preview; desktop is proposed only (`docs/knowledge/FLUTTER-PLATFORMS.md`).

## Feature contracts
High-risk work (auth, Firebase rules, scoring, group privacy, offline sync, health-related data, architectural boundaries) needs the maintainer's approved requirements, design and tasks contract under `docs/features/`. Agents may draft a contract but may not mark it approved. See `docs/features/README.md`.
