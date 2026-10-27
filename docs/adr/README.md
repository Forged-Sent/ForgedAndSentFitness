# Architecture Decision Records

Statuses: Proposed · Accepted · Rejected · Superseded. A decision is Accepted only by human approval recorded in the PR that changes its status. Validator `tools/validate_architecture.py` checks that no two Accepted ADRs claim the same decision and that every superseded ADR names its replacement.

| ADR | Title | Status | Notes |
|---|---|---|---|
| [ADR-0001](ADR-0001-rebuild-in-flutter-keep-the-prototype.md) | Rebuild in Flutter; keep the prototype as an executable behavioral reference | Accepted |  |
| [ADR-0002](ADR-0002-flutter-dart-for-ios-and-android.md) | Flutter/Dart for iOS and Android | Accepted |  |
| [ADR-0003](ADR-0003-firebase-as-the-managed-production-backend.md) | Firebase as the managed production backend | Accepted | Rejects review ADR-003 (Supabase); see docs/reviews/2026-10-26-independent-architecture-review |
| [ADR-0004](ADR-0004-group-level-isolation-optional-organization-layer.md) | Group-level isolation; optional organization layer | Accepted |  |
| [ADR-0005](ADR-0005-server-authoritative-append-only-scoring-ledger.md) | Server-authoritative, append-only scoring ledger | Accepted |  |
| [ADR-0006](ADR-0006-offline-first-drift-as-device-source-of.md) | Offline-first: Drift as device source of truth with an outbox in front of Firestore | Accepted |  |
| [ADR-0007](ADR-0007-versioned-content-packages-generated-programs-with.md) | Versioned content packages; generated programs with equivalence tests; content approval | Accepted |  |
| [ADR-0008](ADR-0008-devotional-workout-experience-engine.md) | Devotional Workout Experience Engine | Accepted |  |
| [ADR-0009](ADR-0009-competition-model-teams-first-normalized-two.md) | Competition model: teams first, normalized; two difficulty tiers; approved alternates; personal improvement | Accepted |  |
| [ADR-0010](ADR-0010-video-proof-capture-storage-and-review.md) | Video proof capture, storage and review | Accepted |  |
| [ADR-0011](ADR-0011-nutrition-and-health-provider-abstraction-bounded.md) | Nutrition and health: provider abstraction; bounded participation points; provenance | Accepted |  |
| [ADR-0012](ADR-0012-faith-participation-and-privacy.md) | Faith participation and privacy | Accepted |  |
| [ADR-0013](ADR-0013-households-and-youth-modeled-inactive-grant.md) | Households and youth: modeled, inactive, grant nothing | Accepted |  |
| [ADR-0014](ADR-0014-environments-and-distribution.md) | Environments and distribution | Accepted |  |
| [ADR-0015](ADR-0015-ai-assisted-development-workflow.md) | AI-assisted development workflow | Accepted | Supersedes review ADR-016 |
| [ADR-0016](ADR-0016-crash-reporting-and-diagnostics-crashlytics-with.md) | Crash reporting and diagnostics: Crashlytics with redaction | Proposed | Supersedes Blueprint D35 recommendation (Sentry) |
| [ADR-0017](ADR-0017-messaging-boundary.md) | Messaging boundary | Accepted |  |
| [ADR-0018](ADR-0018-authorization-source-membership-documents-claims-optional.md) | Authorization source: membership documents (claims optional cache) | Proposed |  |
| [ADR-0019](ADR-0019-configurable-seasons-and-practice-competitions.md) | Configurable seasons and practice competitions | Accepted | Supersedes Blueprint D27 recommendation |
| [ADR-0020](ADR-0020-planning-hub-blueprint-for-discussion-github-authoritative.md) | Planning hub: Blueprint page for discussion and voting; GitHub decision log authoritative | Proposed | Decides W12 |

## Rejected or superseded proposals from earlier work

| Source | Proposal | Disposition |
|---|---|---|
| Review ADR-003 | Supabase/PostgreSQL system of record | **Rejected**, superseded by ADR-0003 (Firebase, approved direction) |
| Review ADR-006/007 | Drift + outbox; PowerSync later | Outbox kept (ADR-0006); PowerSync not applicable to Firestore |
| Review ADR-012 | No individual points for spiritual practice | **Superseded** by ADR-0012 (participation-only, weights open) |
| Review ADR-014 | No video in MVP | **Superseded** by ADR-0010 |
| Review ADR-010 | Sentry vs Crashlytics | Superseded by ADR-0016 (Proposed) |
| Review ADR-001,002,004,005,008,009,011,013,015,016 | Rebuild, Flutter, groups, ledger, content, governance, deletion, challenge policy, 18+, repo zones | Carried into ADR-0001,0002,0004,0005,0007,0009,0013,0015 and requirements |
