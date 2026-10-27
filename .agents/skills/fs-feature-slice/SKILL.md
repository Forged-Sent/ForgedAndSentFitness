---
name: fs-feature-slice
description: Implement one Forged & Sent Flutter feature slice (UI, view model, repository, Drift, outbox) for a single FS requirement. Use for work in app/lib/features or packages/fs_domain. Not for rules, Functions, contracts or content approvals.
---
# Feature slice

1. Confirm the FS id, the allowed paths and the acceptance criteria. Read the matching sections of `docs/architecture/`.
2. Layout: `app/lib/features/<name>/{api.dart, ui/, data/, domain/?}`. Put rules in `packages/fs_domain` (pure Dart, no Flutter or Firebase imports).
3. Repository interface first, returning `Result<T, Failure>`. The implementation reads Drift (personal data) or Firestore streams (shared data). Writes go **Drift → OutboxWriter**, never straight to Firestore from a feature.
4. IDs: generate a UUIDv7 or deterministic id **before** the first write (see `docs/architecture/05-offline-sync.md`).
5. State: Riverpod `Notifier`/`AsyncNotifier` exposing a freezed state with `loading | empty | data | offlinePending | error` variants.
6. Safety: if the feature runs during a workout, honor the Experience Engine's safety gate. No text input while the state is `active_set` or `timed_interval`.
7. Privacy: classify every new field (private, partner, leaders, group). Journal and prayer text never leaves `users/{uid}/journal`.
8. Tests in the same PR: unit (fs_domain and view model), widget (each state), repository (in-memory Drift). Name tests `FS-…:`.
9. `flutter analyze` clean, `flutter test` green. If a new collection, rule or index is needed, stop: that is `fs-firestore-change` in its own PR.
