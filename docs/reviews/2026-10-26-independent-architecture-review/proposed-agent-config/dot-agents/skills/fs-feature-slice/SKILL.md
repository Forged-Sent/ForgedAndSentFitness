---
name: fs-feature-slice
description: Add or extend a Forged & Sent Flutter feature as a vertical slice (UI, view model, repository, Drift, outbox) following the feature-first MVVM conventions. Use when implementing any FS requirement inside app/lib/features. Not for schema, ruleset or content changes.
---
# Add a feature slice

1. Confirm the task names one FS requirement id and the feature directory you may touch.
2. Layout: `app/lib/features/<name>/{api.dart, ui/, data/, domain/?}`. Create `domain/` only for a rule you will unit-test.
3. Repository interface first (`data/<name>_repository.dart`), returning `Result<T, AppFailure>`.
   Implement local (Drift DAO) and remote (Supabase wrapper from `core/network`) sources behind it.
4. Writes: Drift transaction first → `OutboxWriter.enqueue(...)` with a client UUIDv7. Never call the network from UI or view models.
5. View model: `Notifier`/`AsyncNotifier`; expose an immutable `freezed` state with explicit `offline`, `pending`, `error` variants.
6. Cross-feature reads only through the other feature's `api.dart`.
7. Tests (same PR): view model unit tests; widget tests for loading/empty/error/offline/data; repository tests on in-memory Drift. Name tests `FS-XXX-nnn: ...`.
8. Run `melos run analyze && melos run test`. Fix all analyzer findings; do not add ignores without a comment linking an issue.
9. If you need a new table, column, RPC, ruleset field or content field: stop; that is `fs-db-migration` / `fs-scoring-rule-change` / `fs-content-validate` work in a separate PR.
