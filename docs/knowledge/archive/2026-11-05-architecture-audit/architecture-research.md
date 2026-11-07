---
status: archived
updated: 2026-11-05
owner: Codex research team
source_ref: main
source_sha: 60b9f5de11b1a1074b921ee26ae68fb3c3e7228d
superseded_by: docs/knowledge/CURRENT.md
original_sha256: ff3c840de02181c4bedd900c9b68f1862252c148145df956a93fac71ecf2208b
---

> Historical snapshot; recommendations remain proposals. Operational successor: [CURRENT](../../CURRENT.md). Original body follows unchanged.

# Mobile, Firebase and architecture research — 2026-11-05

Scope: read-only inspection of local branch pr4-workstation-test at c8e1267832e686206166a545a78dcbff5839c0ac. This is not an audit of current main; combine with the GitHub audit. No dependency installation, source changes, deployment, paid model invocation or runtime test was performed by this researcher. Proposed choices require maintainer approval; none are accepted ADRs yet.

## Observed implementation

- mobile/lib/main.dart contains preview/emulator dispatch. Unknown/cloud modes fail closed. Preview does not connect Firebase. Emulator startup performs anonymous sign-in then smoke reads with 15-second timeouts and shows an outage message on failure.
- mobile/lib/src/firebase/forged_firebase_runtime.dart owns Firebase SDK imports. Project ID must equal demo-forgedandsent at runtime. Connects Auth9099, Firestore8080, Storage9199 before operations. Default Android emulator host10.0.2.2, other platforms127.0.0.1, explicit FNS_EMULATOR_HOST override for devices. The smoke read is Firestore developer_smoke/{uid}; Storage missing-object metadata is considered healthy only for object-not-found.
- mobile/lib/src/app/forged_sent_app.dart is a Material3 dark foundation page. It has no product workflow. Its displayed verified-emulator message can be set by constructor, so widget assertions do not themselves prove emulator connectivity.
- mobile/pubspec.yaml pins firebase_core5.1.0, firebase_auth7.0.1, cloud_firestore7.1.0, firebase_storage14.0.1; Dart >=3.9.0<4.0.0. No Riverpod, go_router, Drift, Functions client or notification/health integration.
- Exactly three tracked mobile/lib Dart files and two mobile/test files were listed. git ls-files mobile/android mobile/ios mobile/web returned no files: no committed host projects in this local baseline.
- firebase/firestore.rules and storage.rules permit only authenticated owner developer_smoke paths; everything else denied. This is a smoke fixture, not user/group authorization.
- tooling/firebase/tests/security-rules.test.mjs has nine node:test cases: owned smoke write/read, guest/other-user denial, outside-smoke denial, Storage ownership/guest denial, exact runtime document/missing-object health checks. No real group/role/private-data model is tested.
- firebase.json configures local Auth, Firestore, Storage and UI. No Functions emulator or backend implementation. ADR0001 accepts Flutter/Firebase direction; ADR0002 defines emulator-first, explicit environment separation, no contributor production options, no default cloud Firebase MCP, CI workload identity/protected environment for eventual deployment.
- Existing SYSTEM.md and CODE-MAP.md distinguish planned repositories/outbox/scoring from implementation. Preserve these sources rather than establishing a second architecture hierarchy.

## Tool verification

| Tool | Observed | What this proves / limitation |
|---|---|---|
| Context7 | resolve+query successful for Flutter, Drift, Firebase and Riverpod | Documentation connectivity verified; not installed package compatibility |
| Flutter on PATH | C:/ws_c/flutter/bin/flutter.bat:3.44.8, revision058e0af2c2; Dart3.12.2 | CLI works, but differs from project pin |
| Pinned Flutter | C:/Users/Cornw/develop/flutter/bin/flutter.bat:3.47.8, revision737ba8f885; Dart3.13.7 | Matches tooling/versions.json; reports channel[user-branch]. Use established launcher; do not reinstall merely due to PATH mismatch |
| Java on PATH | Oracle17.0.18 | Insufficient evidence of launcher JDK |
| Project JDK discovery | Find-FSJava21 found C:/Program Files/Eclipse Adoptium/jdk-21.0.13.9-hotspot, major21 | Existing launcher can select Java21; no installation needed |
| Node/Firebase CLI | Node22.19.0; Firebase15.34.2 | Executables work; no cloud auth checked or requested |
| Codex CLI |0.162.1; codex login status reports Logged in using ChatGPT | Auth status verified, no generation/review model eligibility or marginal price verified |
| Claude Code |2.1.310; claude auth status.loggedIn false, authMethod none | Installed but unauthenticated; not a ready independent reviewer |
| Gemini CLI |0.58.0; help works | No read-only auth-status subcommand shown; authentication and generation NOT VERIFIED |
| Maestro | Not resolved by Get-Command | Not verified installed/usable; avoid adding another framework now |
| Emulator listeners | No current listeners on9099/8080/9199/4000 | No live emulator success claimed; do not run destructive clearFirestore tests against someone else's fixture |
| Dart MCP | Namespace disappeared in this session; configured launcher SDK executable exists | Connected functionality NOT VERIFIED by this researcher; use pinned CLI fallback |
| Playwright MCP | Repo configuration exists and launcher specifies isolated Chrome @playwright/mcp0.0.83 | Configured, not connected/tested here |

The initial combined diagnostic command exit1 came from the no-listener query, not proof the preceding version commands failed. CLI versions/auth status do not establish model cost, quality or cloud-agent provisioning. Never claim Claude/Gemini reviews occurred.

## Preferred architecture — proposal

Use a feature-first modular monolith. Flutter views consume immutable screen state from Riverpod Notifier/AsyncNotifier presentation view models. Riverpod is the single composition/DI mechanism; use constructor-injected pure-Dart repositories/use cases beneath it, no global service locator or simultaneous Bloc stack. Prefer manual provider declarations initially to reduce generator complexity. Retain plain immutable Dart sealed/value types and explicit wire DTO validation; use Drift generation where needed. Introduce generated JSON/Freezed only when repeated model work justifies a dependency decision.

go_router owns root navigation, authenticated redirects, nested tab state and deep links. Redirects improve UX only; backend authorization remains independent. Keep auth state in an AuthRepository and preserve intended safe destination after sign-in. Views never see Firebase User/DocumentSnapshot/Reference types.

Drift/SQLite is the durable local store for sessions, workout/devotional events, cached approved content, outbox, upload state and sync cursors. Repository streams provide the UI source of truth. Do not depend on Firestore cache or Riverpod experimental offline persistence for promised saves. Persist event and local projection/outbox in one awaited transaction before reporting Saved on device. The choice incurs migrations and generated schemas, justified by crash recovery and queryable pending state. Foreground sync on start/resume/manual retry is mandatory; OS background scheduling is an optimization.

Use Firebase Auth, Firestore, Cloud Storage and TypeScript Cloud Functions2nd gen with Admin SDK as the managed backend. Keep Functions in firebase/functions if consistent with reconciled main; do not invent a second backend service. Client reads authorized snapshots; trusted callable endpoints process sensitive commands, membership/invites/scoring, and event acceptance. Use strict input validation and authorization in every function because Admin SDK bypasses Firestore rules. Prefer per-user event transaction plus receipt, not direct client score mutations. Add Functions emulator to existing suite when first endpoint lands; no cloud provisioning prerequisite.

Firestore suggested boundaries: users/{uid} for private account settings; users/{uid}/workoutEvents and private reflections/nutrition/measurements separate from groups/{groupId}/members/{uid}, groupPosts, challenges and scoreboards. Public/group profile projections contain an explicit allowlist such as display name/avatar and approved shared totals; never copy a complete private profile. Membership docs govern group access. Roles owner/admin/leader/member are proposed names, not accepted product capabilities. Authorize role transition/invite redemption transactionally. Invite tokens are random, expiring, hashed server-side, bounded use; do not expose member email lists. Groups have independent memberships; teams are within groups and never imply cross-group permission. Youth disabled.

Private prayers default to owner-only. Sharing creates a separate explicit projection with chosen audience; withdrawal deletes that projection and invalidates cached group copies when devices reconnect. Offline revocation cannot erase data already downloaded to an offline device, so minimize cached group content and communicate this limit. Personal notes are not score inputs. No spirituality-quality scoring or food-restriction points.

Scoring: immutable accepted facts, eventId and payload hash, ruleVersion, server acceptedAt, membership and challenge-window decisions. Atomic receipt+projection update, rejecting eventId reuse with different payload. Duplicate same-payload delivery returns original receipt. Persist received client time separately; do not trust it for eligibility. Product must decide backdating/grace windows, timezone boundaries, edits and disqualification. Correction events compensate prior facts with audit trail; version aggregate rebuilds. Trigger retries/out-of-order delivery must not double count. Self-reported activity remains self-reported even when calculation is server-authoritative.

Offline contract: UUID generated once per logical operation; states pending/inFlight/accepted/rejected/requiresAction, attempts/nextAttemptAt/lease expiry; bounded jittered exponential retry for transient failures; no infinite retry of permission/validation failures. Logout stops workers and locks/switches user-scoped store; never upload A's queue with B's token. Retain unsynced work according to approved sign-out/deletion policy. Crash after server commit before local acknowledgment safely replays same ID. Expired credentials pause pending work until re-authentication. Restarts reclaim expired leases. Device clock errors cannot corrupt backoff or scoring. Upload media from managed durable files, content checksums and deterministic object IDs; finalize record only after verified upload, with orphan cleanup policy. File/db operations need explicit recoverable state machine because they cannot share a SQLite transaction.

Conflict policy: append-only facts commute where possible; edits use expected revision/explicit conflict UI, no universal last-write-wins for workouts/membership/scoring. Content caches use published version IDs. Current server membership is required for every group upload; revoked/expired membership yields retained private fact plus rejected group contribution if the approved product policy allows it.

Native: Android WorkManager and iOS BGTaskScheduler behind SyncScheduler adapter; no exact background SLA. Checkpoint before expiration and retry foreground. Android debug-only local cleartext policy; no release permissive exception. Native package IDs, minimum OS, signing ownership and notification entitlements require approval. FCM push carries non-sensitive identifiers, not prayers/health payloads; user preference and permission denial tested. HealthKit/Health Connect later behind opt-in service interfaces, least data access, revocation, duplicate-import provenance, no permissions just to use basic workouts. macOS/Xcode is required for iOS build/sign/device verification; Windows cannot substitute.

Diagnostics: typed errors and opaque correlation/event IDs; count pending age, retry reasons, acceptance latency and duplicate suppression without logging content, tokens, names or health records. Structured backend logs first; proposed Crashlytics only after consent/retention approval and cloud environment availability. No automatic Analytics or private-content ingestion. Redact exception details before upload. DEV/PROD distinct projects, IAM, secrets and signing; demo mode remains cloud-disabled. Production changes through protected CI environment, never agent credentials.

AI/RAG later: server broker authenticates caller, determines tenant/user scope before retrieval, retrieves approved licensed content with provenance, applies per-document ACLs before generation and citations. Private user context is explicit opt-in and minimized. No direct device API secrets, no default embedding of group/private prayers, no model authority over permissions/scoring. Prompt injection from documents is untrusted data. Add evaluation set for cross-user leakage, unsupported health advice, ungrounded scripture claims and retrieval revocation. Provider, retention and spend limits await approval.

## Required boundary tests

1. Unit: immutable event transitions, scoring versions, clock boundaries, validation and permissions matrix.
2. Repository contract: same tests against fake and Drift adapters; real temporary SQLite reopen, migration and data-retention tests.
3. Crash checkpoints: before local commit; after local commit; during send; after server commit before acknowledgment; concurrent workers; account switch; full disk/corrupt DB/media missing.
4. Emulator: guest/A/B/outsider/member/removed member/admin matrices, list queries as well as document reads, field escalation, immutable fields, cross-group paths, expired invite/reuse and Storage metadata/path/size/content restrictions.
5. Backend: duplicate same ID twice/concurrently -> exactly one logical accepted event and score effect; differing payload same ID rejected; reorder triggers; function retries; aggregate rebuild parity; Admin-path authorization tests separate from client rules.
6. Widget: loading/empty/offline/pending/rejected/retry, large text, keyboard/semantics, narrow landscape, deep links after sign-in/out.
7. Device: airplane mode save then kill/reopen, low power, Android force-stop/reboot, iOS force-quit/background expiration, token expiration, notifications denied and permissions revoked. Background runs may be deferred; foreground resume must converge.
8. Workflow: sign-in -> approved content -> durable workout -> emulator receipt -> authorized secondary-client view, excluding private fields. A rendering test alone never marks feature done.

## Current primary documentation evidence

Context7 resolved exact IDs before queries: /flutter/website, /websites/drift_simonbinder_eu, /websites/firebase_google, /websites/riverpod_dev. Sources below directly support platform/API facts; architectural selections above are recommendations, not claims that frameworks require this exact design.

- Flutter recommends separate UI/data layers, repositories, immutable state and DI; domain use cases are conditional. ChangeNotifier is conditional, not mandated: https://docs.flutter.dev/app-architecture/recommendations
- Flutter go_router package supports redirects, deep links, nested navigation; package page observed18.1.3, but this is not an approved dependency pin: https://pub.dev/packages/go_router
- Riverpod providers/overrides support injectable environment/test dependencies; experimental offline persistence is explicitly labelled experimental: https://riverpod.dev/docs/concepts2/providers and https://riverpod.dev/docs/concepts2/overrides
- Riverpod advises testing the notifier through providers and substituting repository abstractions rather than mocking notifiers: https://riverpod.dev/docs/how_to/testing
- Drift transactions are atomic, queries inside must be awaited; schema and data migration tests are supported: https://drift.simonbinder.eu/dart_api/transactions/ and https://drift.simonbinder.eu/migrations/tests/
- Firebase Firestore triggers are unordered and at least once; Admin SDK operations bypass security rules: https://firebase.google.com/docs/firestore/extend-with-functions
- Android WorkManager persists scheduled tasks and supports constraints/backoff; it is not universal immediate execution: https://developer.android.com/develop/background-work/background-tasks/persistent
- Apple chooses background scheduling time; execution is limited: https://developer.apple.com/documentation/backgroundtasks/choosing-background-strategies-for-your-app
- iOS silent remote notifications do not automatically relaunch a force-quit app: https://developer.apple.com/documentation/uikit/uiapplicationdelegate/application%28_%3Adidreceiveremotenotification%3Afetchcompletionhandler%3A%29

## Consequential decisions to request, grouped

Approve the dependency set (Riverpod/go_router/Drift/TypeScript Functions) and proposed ADRs; pilot identity/provider and invite/role policy; sensitive data sharing/retention/deletion and local-store protection; scoring/time/backdating semantics; native IDs/platform floor and signing owner; DEV cloud billing/region/operational owner; notification/health/AI consent and licensing. Defer choices not needed for the first slice rather than blocking basic architecture on future AI/health. No recommendation authorizes deployment or spending.
