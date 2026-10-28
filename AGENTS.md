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

## Working agreement
1. Read `docs/development/START_HERE.md` and any applicable ADR before work.
2. One focused issue per branch. Never change `main` directly.
3. Human approval required for new dependencies, authentication or data-access changes, scoring formula changes, health permissions, and public communication features.
4. Prefer a minimal vertical slice with tests over a large unreviewable implementation.
5. Keep Flutter features under `mobile/lib/src/features/`; UI depends on application/domain services, not Firebase SDK types.
6. Do not commit credentials, Firebase service account JSON, signing keys, personal data, or large generated media.
7. Pull requests report changed files, test commands/results, potential data exposure, and unresolved decisions.
8. Never claim an integration is tested until it has actually been run.

## Checks
- `cd mobile && flutter pub get && flutter analyze && flutter test`
- `cd mobile && flutter build apk --debug` once Android platform files are generated.
- On a new clone of the interim scaffold, first run `cd mobile && flutter create --platforms=android,ios --org=com.forgedandsent --project-name=forged_and_sent .`

## Agent roles
- Flutter Builder: one vertical slice, widget tests, no backend policy changes.
- Architecture Reviewer: independent read-only design and requirements assessment.
- Firebase Security Reviewer: authentication, rules, functions, storage and adversarial access tests.
Run 1 builder plus 1 reviewer per PR by default; do not run every agent for every issue.
