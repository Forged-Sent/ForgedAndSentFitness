# Forged & Sent: agent instructions

## Product
Forged & Sent is a faith-centered devotional workout and group accountability platform. The current `index.html` is a behavioral prototype, NOT the production mobile client. Preserve the prototype and its seed files unless the assigned issue explicitly requires changing them.

## Architectural decisions
- Production mobile: Flutter/Dart for Android and iOS.
- Preferred managed backend: Firebase (Auth, Firestore, Functions, Storage). No server is configured or deployed yet.
- Both developers must be able to work independently using shared cloud-backed development environments; no home Linux server dependency.
- Offline workout state must be locally durable and sync with idempotent event identifiers. Firebase cache alone is insufficient for durable media and conflict-prone writes.
- Group and role authorization must be enforced server-side. Private prayers, reflections, nutrition, injuries and body measurements must not appear in group queries.
- Scripture can be completed before, after, during safe rest periods, or at separate times of day. Prompts are optional.
- Team challenges and scoreboards are server-authoritative; no spirituality-quality scoring or points for eating less.
- Initially adult men's groups; design domain boundaries for future households and youth without enabling youth functionality by default.

## Protected operations
- GitHub rulesets, not instructions or AI reviews, enforce protected branches and mandatory checks. The live ruleset currently requires ci-gate but ZERO human approvals. Do NOT claim a second human review is enforced. Never push to main, force-push main, bypass protections, or merge before required checks pass.
- **Agent push rule.** An AI agent may push commits to a non-`main` branch only when ALL of the following are confirmed immediately before the push: (1) a human explicitly authorized that push in the current session; (2) every review thread on the PR is closed (resolved or outdated), checked on GitHub rather than assumed; (3) `ci-gate` on the PR's current head is green, or the push is the fix for a failing `ci-gate`. Agents never push to `main`, force-push, approve or merge, even with authorization.
- Deterministic CI is mandatory; no additional human approval is required. Functional Flutter/backend changes follow docs/development/FLUTTER-AI-REVIEW-GATE.md: declare authorship and obtain the routed current-head AI review. The hosted rule is staged until its activation checks pass; never claim it is enforced merely because this instruction exists. Other AI reviews remain optional.
- Never use an AI agent's review as an approval. Agents must not self-approve, self-merge, change branch protections, or impersonate a human reviewer.
- AI reviews are advisory and never satisfy required approval.
- No default cloud Firebase MCP, Firebase deployment, or PROD credentials on colleague devices.
- Contributor development is emulator-first, with demo-* project IDs and no cloud CLI login.
- Never automatically execute flutterfire configure or include production FirebaseOptions in Contributor builds.
- Follow docs/architecture/ADR-0002-emulator-first-firebase.md.

## Working agreement
1. Read `docs/development/START_HERE.md` and any applicable ADR before work.
2. One focused issue per branch. Never change `main` directly.
3. The project maintainer makes explicit product decisions for dependencies, authentication/data access, scoring, health permissions and communications. A solo maintainer can make these decisions without a separate reviewer. Prototype-only changes do not implicitly approve production behavior.
4. Prefer a minimal vertical slice with tests over a large unreviewable implementation.
5. Keep Flutter features under `mobile/lib/src/features/`; UI depends on application/domain services, not Firebase SDK types.
6. Do not commit credentials, Firebase service account JSON, signing keys, personal data, or large generated media.
7. Pull requests report changed files, test commands/results, potential data exposure, and unresolved decisions.
8. Never claim an integration is tested until it has actually been run.

## HTML prototype workflow (lighter review, same hygiene)
- For prototype edits create a short-lived `prototype/<topic>` branch and a PR to `main`. Use a descriptive summary and a screenshot or notes for visual changes. A formal issue is optional for small iterations. Only `index.html`, archived `versions/**`, `dev/*.html`, `dev/mock-claude.js`, `seed/devotionals*.json`, `seed/lifts.json`, `seed/esv-verses.json` and root `README.md` qualify for optional formal review.
- PRs touching ONLY listed low-risk exceptions do not require a formal approval by default. A human should still choose when to merge. Do not merge with failing CI, requested changes or any protected file. All unknown/new paths require review.
- `index.html` is the active prototype. Preserve existing `versions/app-vN.html` files as an append-only history; use a new version file when recording a milestone, never rewrite an older version.
- Run `python3 dev/make_preview.py`, open `dev/preview.html` in a browser, and note any untested `window.claude` behavior. The local mock is not proof of data access, sharing, identity or persistence.
- `seed/db-rules.json`, `seed/tasks.json`, `seed/weekly-challenges.json`, `seed/movement-standards.json`, `dev/make_preview.py`, `dev/patches/**`, `dev/firebase/**` and `docs/development/**` are review-protected. If even an otherwise exempt `index.html` change alters authorization, scoring or privacy semantics, escalate for human review.
- Prototype work is reference material. Do not introduce prototype runtime dependencies into `mobile/` or treat its backend adapter as production authorization.

## Pull request classification
- **Prototype (explicit exceptions only):** HTML/versions, mock and listed seed content. Lightweight preview CI, optional formal review, required PR. Executable preview scripts are *not* review-exempt.
- **Application:** `mobile/` and production app architecture. Flutter CI and the functional AI review policy apply; see docs/development/FLUTTER-AI-REVIEW-GATE.md for scope and rollout status.
- **Infrastructure/security:** `tooling/`, workflows, agent instructions, MCP settings, Firebase config, architecture ADRs and protected seed rules. Mandatory policy CI and maintainer decision. The functional AI review gate includes these paths and other unclassified paths unless they are explicitly exempted in `tooling/review/flutter_scope.py`; consult that classifier and the gate guide before declaring review optional.
- A mixed PR receives the strictest applicable checks and review requirements. Prefer splitting unrelated changes.
- The live GitHub ruleset requires `ci-gate` but zero outside approvals. The functional AI review gate is a separate completion check, not a human approval. Other AI reviews are optional. Maintainers choose whether to merge; agents never self-merge.

## Platform-specific onboarding
- Windows bootstrap: START-WINDOWS.cmd; Mac bootstrap: START-MAC.command; numbered steps in `launchers/<os>/`. All must preserve emulator-first/no-cloud-Firebase MCP defaults.
- Both platforms set up Preview and Contributor (practice Firebase included). Windows also offers Mobile/Maintainer (Android Studio, Maestro); Mac offers optional iPhone simulator setup. Do not claim Android/iOS device integration until it has been run and recorded; no Maestro flows exist yet.
- Project MCP stdio commands use the allowlisted Node launcher on both platforms. Never add Firebase cloud MCP or automatically request credentials.

## Checks
- `cd mobile && flutter pub get && flutter analyze && flutter test`
- `cd mobile && flutter build apk --debug` once Android platform files are generated.
- On a new clone the setup launchers generate the git-ignored hosts (`flutter create --platforms=web`, plus `android` in Mobile setup and `ios` in the Mac iPhone step) with `--org=com.forgedandsent --project-name=forged_and_sent`. CI generates the same temporary hosts. Committed, reviewed native hosts are a later decision (see ADR-0003).

## Agent roles
- Flutter Builder: one vertical slice, widget tests, no backend policy changes.
- Architecture Reviewer: independent read-only design and requirements assessment.
- Firebase Security Reviewer: authentication, rules, functions, storage and adversarial access tests.
Use one builder by default. Route functional Flutter/backend changes to the opposite provider under the functional AI review policy; offer additional security reviews when useful. If invoked, never count the authoring model as independent. Mark missing coverage NOT VERIFIED.
- After a hosted review finishes, read the PR handoff comment and linked review evidence in the implementing Codex or Claude session. Address findings once on the same feature branch, rerun checks, and request a fresh review for the new head. If that next review still has findings, pause implementation and wait for the maintainer's human review before making another fix. GitHub comments notify the PR author but do not wake a local agent session on their own.

## Safe beginner Git collaboration

Use project-local fs-start / fs-save / fs-sync / fs-share / fs-status helpers
for contributor workflow. Never directly commit or push to main. Only open
draft PRs for teammates. Do not run firebase deploy, overwrite production
configurations, force-push, or merge PRs without explicit human approval.
GitHub server rules are the actual enforcement boundary; local prompts and
agent instructions are advisory. No cloud Firebase MCP is enabled by default.

## Living architecture and shared agent instructions

- Read docs/architecture/SYSTEM.md for current vs planned system boundaries and CODE-MAP.md for actual Dart symbols/imports.
- Update SYSTEM.md/ADRs when boundaries change; run `python3 tooling/architecture/generate.py --write` for Dart changes.
- Canonical skills are in .agents/skills; .claude/skills must match, enforced by `python3 tooling/skills/sync.py --check`.
- Before pushing, run `python3 tooling/review/review.py --dry-run`; functional Flutter/backend changes also follow docs/development/FLUTTER-AI-REVIEW-GATE.md; additional local reviews remain advisory.

## Architecture Explorer update contract

- The clickable static site is generated via `python3 tooling/architecture/build_explorer.py --write`. The source UI lives under `docs/architecture/explorer/`, and the generated site lives in the ignored `build/architecture-explorer/` directory.
- Keep the curated component/function glossary in `docs/architecture/explorer/model.json` aligned with `SYSTEM.md` and real code. Never label a proposed component as implemented.
- For new components or meaningful behavior, update model descriptions, source paths, dependencies, and the appropriate ADR. CI builds the latest file/symbol index and rejects dangling model file references.
- Never describe lexical file mentions or best-effort symbol detection as a complete runtime call graph. Explain uncertainty honestly.
## Git-backed development memory and Flutter platform strategy
- Start a new or resumed complex task at `docs/knowledge/INDEX.md` and `docs/knowledge/CURRENT.md`. Follow the scoped handoff, check exact PR/branch SHA and verify current tests before trusting a note.
- On meaningful handoff, write a dated, task-specific `docs/knowledge/handoffs/<task>.md` with owner, full source SHA, verified observations, unrun tests, blockers and a concrete next action. Never overwrite parallel agent work.
- Obsidian is an optional Markdown viewer/editor for `docs/`, NOT a second source of truth. Follow `docs/knowledge/LIFECYCLE.md` for superseding/archiving; never delete approved ADR history, generated docs or `versions/` snapshots.
- Flutter app code is the target, while `index.html` is behavioral reference only. Follow `docs/knowledge/PROTOTYPE-PARITY.md` and `docs/knowledge/FLUTTER-PLATFORMS.md`. Android/iOS are first, web is a preview target; Windows/Linux/macOS require separate reviewed host/CI/runtime qualification.
- For any Flutter/Dart/library/API question, check the installed/pinned SDK and current official docs or Dart MCP; use version-matched Context7 for third-party APIs when appropriate. Never treat stale snippets as project policy. Use `docs/knowledge/FLUTTER-AI-DOCS.md`; never paste large live docs into startup rules or silently install plugins.
- Use `flutter-platform-parity` and `knowledge-steward` skills for the matching tasks. Recheck the generated architecture map and handoff links after documentation changes.
