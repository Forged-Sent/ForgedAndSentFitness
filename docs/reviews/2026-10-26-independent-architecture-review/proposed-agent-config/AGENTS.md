# Forged & Sent — instructions for coding agents

Read this file fully before any change. These rules are enforced in CI; violating them fails the build.

## What this repo is
Flutter app (`app/`), pure-Dart domain package (`packages/fs_domain/`), Supabase backend (`supabase/`),
content sources (`content/`) built by `tools/fs_content/`, shared contracts (`contracts/`), decisions (`docs/adr/`).
Architecture reference: `docs/architecture/ARCHITECTURE-REVIEW.md` sections E and F.

## Protected zones (single-writer; need label `contract-change` + an ADR id in the PR body)
- `contracts/` — ruleset schema, content schema, golden fixtures
- `supabase/migrations/` — append-only; never edit a merged migration file
- `docs/adr/`, `docs/rules/` — human-approved policy
- `content/**/approved.yaml` — theology/fitness approvals (humans only; agents may never set approvals)
If your task needs a change there, STOP and write a proposal in the PR description instead.

## Non-negotiable invariants
1. Clients never write score-bearing data. Points come only from SQL functions in `supabase/migrations`.
2. Every new table: `enable` + `force row level security`, policies, and pgTAP tests in `supabase/tests/rls/`.
3. Offline: user actions write to Drift first, then the outbox. Never call the network from a feature.
4. No silent failure: `catch (_) {}` and `.catchError((_) {})` are banned. Map errors to `AppFailure`.
5. Features import other features only via `features/<name>/api.dart`.
6. No health values, prayer text, reflections or food data in logs, analytics or crash reports.
7. Devotional, prayer and reflection activity never contributes to individual public scores (FS-DSC-001).
8. No test-date or clock overrides outside `kDebugMode`.

## Task boundaries
- One requirement id (`FS-XXX-nnn`) per PR. Name branches `feat/FS-XXX-nnn-short-slug`.
- Touch one feature directory plus its tests, unless the task says otherwise.
- Target ≤ 400 changed lines excluding generated files. Split larger work.

## Commands
- `dart run tools/fs_content validate` — content checks
- `melos run analyze` / `melos run test` — static analysis + tests
- `supabase db reset && supabase test db` — migrations from scratch + pgTAP
- `dart run build_runner build -d` — codegen (freezed, json, drift)
- `tools/check_zones.sh origin/main` — protected-zone guard (CI runs it too)

## Definition of Done (agent checklist)
Analyzer clean · tests added for every new branch of logic · FS ids referenced in test names ·
offline/empty/error states have widget tests · no new TODO without an issue link · PR template filled.

## Skills
Shared skills live in `.agents/skills/` (mirrored to `.claude/skills/`): `fs-feature-slice`, `fs-db-migration`,
`fs-scoring-rule-change`, `fs-content-validate`, `fs-architecture-review`, `fs-security-review`,
plus the pinned dart-lang skills listed in `skills-lock.json`.
