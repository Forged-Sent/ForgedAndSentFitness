# 01 · System architecture

Status: **Accepted (Phase 0)**, subject to the open decisions in `../requirements/open-decisions.md`. Diagrams: `../diagrams/`.

## 1. System context

Actors:

- Members (adult men; spouses, families and youth come later).
- Group leaders.
- Reviewers: proof reviewers, plus content reviewers for theology and fitness.
- Platform admins (the project owners).

External systems:

- Firebase (Auth, Firestore, Functions, Storage, FCM, App Check, Crashlytics, Remote Config, App Distribution).
- Apple HealthKit and Android Health Connect, on the device.
- A nutrition provider behind a Functions proxy (OD-07).
- App Store and Google Play.
- Scripture text sources: BSB is public domain; ESV only with notice or license.

See `diagrams/01-system-context.mmd`.

## 2. Logical subsystems (modular monolith)

| Subsystem | Responsibility | Client module | Server module |
|---|---|---|---|
| Identity & access | Sign-in, profile, adult attestation, invites, membership, roles | `features/onboarding`, `core/auth` | `functions/src/membership`, rules |
| Experience engine | Devotional workout orchestration: modes, stages, timing, safety | `packages/fs_domain/experience`, `features/workout_experience` | — (pure client logic; state syncs) |
| Devotion & journal | Reading content, private reflections, prayer list | `features/devotion`, `features/journal` | — |
| Training | Programs, schedule, sessions, sets, PRs, substitutions | `packages/fs_domain/training`, `features/train` | — |
| Nutrition & health | Meals, macros, hydration, fasting, health sources | `features/nutrition`, `features/health` | `functions/src/nutrition` (provider proxy) |
| Community | Feed, comments, reactions, prayer requests, partners | `features/feed`, `features/prayer` | `functions/src/notify`, `functions/src/moderation` |
| Competition | Seasons, teams, challenges, missions, attempts, standings | `features/challenges`, `features/board` | `functions/src/scoring` |
| Proof media | Capture, local retention, upload, review, retention | `features/proof` | `functions/src/proof` |
| Content | Versioned packages, approvals, publishing | bundled packages + `core/content` | `tools/fs_content`, `functions/src/content` |
| Account & data rights | Export, deletion | `features/settings` | `functions/src/account` |
| Platform | Sync, DB, logging, flags, routing, design tokens | `core/*` | `functions/src/common` |

**Dependency rule:**

- Features depend on `core/*`, on `packages/fs_domain`, and on other features' `api.dart` only.
- `fs_domain` has no Flutter or Firebase imports.
- The server shares **contracts** (`contracts/*.schema.json`, golden fixtures) with the client, not code.

## 3. Flutter module boundaries

```text
app/
  lib/
    main_dev.dart · main_staging.dart · main_prod.dart      # flavors → Firebase projects (ADR-0014)
    bootstrap.dart                                          # ProviderScope, error zones, Crashlytics, App Check
    core/
      auth/        # FirebaseAuth wrapper → AuthRepository
      firebase/    # generated firebase_options_*.dart, App Check, emulator toggles (debug only)
      db/          # Drift schema, DAOs, migrations (device source of truth for personal records)
      sync/        # outbox, pull cursors, ack tracking, state machine
      content/     # bundled + downloaded content packages (read-only)
      logging/     # redacting logger → Crashlytics breadcrumbs
      flags/       # Remote Config-backed feature flags (households, youth default false)
      routing/     # go_router
      design/      # Forged Iron tokens
    features/<name>/{api.dart, ui/, data/, domain/?}
packages/
  fs_domain/       # pure Dart: experience engine, training (prescription, schedule, PR), scoring preview, time, privacy scopes
functions/         # TypeScript, Cloud Functions 2nd gen
  src/{membership,scoring,proof,notify,moderation,nutrition,account,content,common}
firebase/          # firestore.rules, storage.rules, firestore.indexes.json, tests/rules
contracts/         # JSON Schemas + golden fixtures shared by Dart and TS
tools/             # fs_content (Dart CLI), validators
```

**How to add a feature without coupling:**

1. Create `features/<name>/` with `api.dart`.
2. Put any rules in `fs_domain` and test them there.
3. Add a repository interface in `data/`, implemented over Drift and Firestore.
4. Never import another feature's `data/` or `ui/`.
5. A new Firestore collection, rule or index is a **protected-zone** change (ADR-0015).

## 4. Firebase deployment architecture

| Project | Purpose | Data | Deploy trigger |
|---|---|---|---|
| `dev` | Shared by both developers for day-to-day testing; disposable data | Synthetic only | Merge to `main` (rules, indexes, functions) |
| `staging` | Release candidates, practice seasons, restore drills | Synthetic plus volunteer testers | Release tag `vX.Y.Z-rc*` |
| `prod` | Pilot group | Real | Tag `vX.Y.Z` plus manual approval |

**Settings:**

- Location (OD-15) is irreversible, so choose it before creating the prod database.
- Use the Blaze plan with budget alerts.
- Daily scheduled Firestore exports go to a locked bucket.
- Functions run in the same region as Firestore.
- Testers get builds through App Distribution (Android and iOS ad hoc) and TestFlight.

## 5. Authentication and group access

- **Sign-in providers:** Sign in with Apple, Google and email link.
- **Adult gate:** `adultAttestedAt` is recorded at onboarding (FS-FAM-003).
- **Joining:** the callable `redeemInvite(code)` creates `groups/{gid}/members/{uid}`. Only Functions write membership (ADR-0004).
- **Rules:** a `memberRole(gid)` helper uses one `get()`, and a request is budgeted at ≤ 3 rule reads (ADR-0018).

## 6. Offline storage and synchronization

Summary (details in `05-offline-sync.md`):

- Drift holds personal in-progress data.
- An outbox writes Firestore documents with deterministic IDs.
- An entry is acknowledged only when the server confirms it.
- Firestore's cache serves shared reads.
- Server-only intents show a pending state.

## 7. Workout and devotional orchestration

The Experience Engine (`03-devotional-workout-engine.md`) owns the day's run and listens to workout state events from the training module (`resting`, `active_set`, `timed_interval`, `finished`). The training module knows nothing about devotions. The engine knows only workout **states**, not exercises.

## 8. Challenge submission and scoring

1. The client creates an `attempt` (create-only rule, within the window by `request.time`).
2. If proof is required, the proof lifecycle runs.
3. A reviewer decides (or auto-approval applies when the policy allows).
4. A Function evaluates the attempt against the pinned ruleset and writes the ledger.
5. The standings projection is recomputed.
6. A scheduled finalization job freezes the week or season.

See `04-competition-scoring.md`.

## 9. Nutrition and health

The provider proxy is the `nutritionSearch` callable, with caching. Food entries are private. Daily summaries are computed on the client and mirrored to a private document, and nutrition participation facts are emitted for scoring. Health samples are aggregated daily with provenance. See `07-nutrition-health.md`.

## 10. Media storage and proof review

Proof media lives in app-private storage, uploads resumably to a scoped Storage path, and is readable only by its owner and reviewers. Playback for reviewers uses short-lived signed URLs from a Function. There is no `getDownloadURL` for proof, and a retention job deletes media after the retention period. See `06-proof-media.md`.

## 11. Community moderation and notifications

- **Reports:** go to `groups/{gid}/reports`, readable by leaders. Actions are taken through a Function (remove, warn, mute, remove member) and every one is audit-logged.
- **Blocks:** enforced in feed queries and rules.
- **Notifications:** FCM sends payloads with no private text. Reminders use local notifications so they work offline.

## 12. Observability and operations

Crashlytics with redaction (ADR-0016); structured Functions logs with correlation IDs; budget alerts; an incident runbook; moderation SLAs (OD-17). See `09-operations.md`.
