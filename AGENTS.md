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
- GitHub rulesets, not these instructions, enforce protected branches and path-specific human approval. Never push to main, force-push main, bypass protections, or merge a PR before required checks/reviews pass.
- Prototype-only pull requests may merge without an approval when all GitHub-required checks pass. Flutter, tooling, security policy and designated seed-rule paths require one other human reviewer through the path-specific ruleset.
- Never use an AI agent's review as an approval. Agents must not self-approve, self-merge, change branch protections, or impersonate a human reviewer.
- AI reviews are advisory and never satisfy required approval.
- No default cloud Firebase MCP, Firebase deployment, or PROD credentials on colleague devices.
- Contributor development is emulator-first, with demo-* project IDs and no cloud CLI login.
- Never automatically execute flutterfire configure or include production FirebaseOptions in Contributor builds.
- Follow docs/architecture/ADR-0002-emulator-first-firebase.md.

## Working agreement
1. Read `docs/development/START_HERE.md` and any applicable ADR before work.
2. One focused issue per branch. Never change `main` directly.
3. Human product approval is required for new dependencies, authentication/data-access changes, scoring formula changes, health permissions, and public communication features, even if first explored in the prototype. Do not claim a prototype-only PR approves these decisions.
4. Prefer a minimal vertical slice with tests over a large unreviewable implementation.
5. Keep Flutter features under `mobile/lib/src/features/`; UI depends on application/domain services, not Firebase SDK types.
6. Do not commit credentials, Firebase service account JSON, signing keys, personal data, or large generated media.
7. Pull requests report changed files, test commands/results, potential data exposure, and unresolved decisions.
8. Never claim an integration is tested until it has actually been run.

## HTML prototype workflow (lighter review, same hygiene)
- For `index.html`, `versions/`, `dev/` and ordinary `seed/` updates: create a short-lived `prototype/<topic>` branch and open a PR to `main`. Use a descriptive PR summary and a screenshot or notes for visual changes. A formal GitHub issue is optional for small iterations.
- Prototype-only PRs do not require a human approval by default, but may receive voluntary review. Do not merge when mandatory CI is failing, review has explicitly requested changes, or scope has broadened into protected files.
- `index.html` is the active prototype. Preserve existing `versions/app-vN.html` files as an append-only history; use a new version file when recording a milestone, never rewrite an older version.
- Run `python3 dev/make_preview.py`, open `dev/preview.html` in a browser, and note any untested `window.claude` behavior. The local mock is not proof of data access, sharing, identity or persistence.
- `seed/db-rules.json`, `seed/tasks.json`, `seed/weekly-challenges.json` and `seed/movement-standards.json` are review-protected because they describe data access or scoring. If a prototype change alters authorization, scoring or privacy semantics, escalate for human review even when the edit is only to `index.html`.
- Prototype work is reference material. Do not introduce prototype runtime dependencies into `mobile/` or treat its backend adapter as production authorization.

## Pull request classification
- **Prototype:** HTML, versions, preview tooling and ordinary seed data. Lightweight preview CI, optional review, required PR.
- **Application:** `mobile/` and production app architecture. Flutter CI plus required human review.
- **Infrastructure/security:** `tooling/`, workflows, agent instructions, MCP settings, Firebase config, architecture ADRs and protected seed rules. Mandatory policy CI plus required human review.
- A mixed PR receives the strictest applicable checks and review requirements. Prefer splitting unrelated changes.
- Ask the other developer for review on required PRs. A PR author cannot provide their own required approval. Do not enable broad one-approval rules that unnecessarily block prototype-only PRs.

## Platform-specific onboarding
- Windows bootstrap: FIRST-RUN-WINDOWS.cmd; Mac bootstrap: FIRST-RUN-MAC.command. Both must preserve emulator-first/no-cloud-Firebase MCP defaults.
- Mac bootstrap support in PR #3 covers Preview and tool-only Contributor foundation. Do not claim iOS/Android device integration or Firebase emulator readiness until PR #4.
- Project MCP stdio commands use the allowlisted Node launcher on both platforms. Never add Firebase cloud MCP or automatically request credentials.

## Checks
- `cd mobile && flutter pub get && flutter analyze && flutter test`
- `cd mobile && flutter build apk --debug` once Android platform files are generated.
- On a new clone of the interim scaffold, first run `cd mobile && flutter create --platforms=web --org=com.forgedandsent --project-name=forged_and_sent .`. CI generates temporary Android hosts; reviewed native hosts belong to PR #4

## Agent roles
- Flutter Builder: one vertical slice, widget tests, no backend policy changes.
- Architecture Reviewer: independent read-only design and requirements assessment.
- Firebase Security Reviewer: authentication, rules, functions, storage and adversarial access tests.
Run 1 builder plus 1 reviewer per PR by default; do not run every agent for every issue.
