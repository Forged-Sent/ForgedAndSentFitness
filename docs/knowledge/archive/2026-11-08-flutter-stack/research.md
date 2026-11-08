---
status: archived
updated: 2026-11-08
owner: Codex coordinator, with initial Claude research pass
source_ref: codex/flutter-stack-adr
source_sha: 61e1b7d73e7ad58d75b29e70f13bc768e96430ca
superseded_by: docs/architecture/ADR-0005-flutter-client-stack.md
---

# Flutter client stack research — 2026-11-08

Status: source-checked input for [ADR-0005](../../../architecture/ADR-0005-flutter-client-stack.md). Claude made the first research pass but could not fetch live documentation in its session. The Codex coordinator checked the claims below against the linked first-party pages and the local toolchain. This note is background; agents should start with the ADR and [CURRENT](../../CURRENT.md).

## Current project and toolchain

The Flutter client is a scaffold. `mobile/pubspec.yaml` allows Dart `>=3.9.0`; its committed lockfile requires Dart `>=3.13.0`. CI pins Flutter `3.47.8` in `.github/workflows/ci-gate.yml`. This Windows machine has Flutter `3.44.8` / Dart `3.12.2`; `flutter pub get` resolved packages by changing seven transitive lock entries, so that local change was reverted. Analysis and all five existing Flutter tests passed after resolution, but the local and CI dependency graphs are not yet aligned. Upgrade or pin the project toolchain deliberately before adding packages.

A local `dart pub add --dry-run` with the existing Firebase pins resolved `flutter_riverpod 3.5.0`, `go_router 18.1.3`, `drift 2.35.3`, `path_provider 2.1.6`, `drift_dev 2.35.2` and `build_runner 2.15.1`. It made no tracked change. This proves only that the package solver accepted the local Dart 3.12 toolchain; it is not an Android, iOS or web build test. Current package pages list the minimum Dart versions: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod/versions) 3.5.0 requires 3.12; [go_router](https://pub.dev/packages/go_router/versions) 18.1.3 requires 3.12; [drift](https://pub.dev/packages/drift/versions) 2.35.3 and [drift_dev](https://pub.dev/packages/drift_dev/versions) 2.35.2 require 3.10. A package PR must align `pubspec.yaml` with its chosen versions and commit a lockfile generated with the agreed SDK.

## Options and recommendation

| Concern | Choice | Reason and limit |
|---|---|---|
| State and dependency injection | **Riverpod**, manual providers initially | Flutter [recommends separated views, view models and repositories](https://docs.flutter.dev/app-architecture/recommendations), but does not require Riverpod; its own `ChangeNotifier` guidance is conditional and it recommends `provider` for injection. Riverpod offers [provider overrides in tests](https://riverpod.dev/docs/how_to/testing) and explicit async loading/error state. Keep business rules in plain Dart services and repositories. Do not use Riverpod's optional persistence as the event outbox. |
| Navigation | **go_router** | Flutter [recommends go_router for most apps](https://docs.flutter.dev/app-architecture/recommendations). Its [package page](https://pub.dev/packages/go_router) documents URL routes, deep links and redirects. A redirect improves UX; server authorization remains separate. Native deep-link behavior needs reviewed Android/iOS hosts and device tests. |
| Durable local events | **Drift over native SQLite** | Flutter's [offline-first guide](https://docs.flutter.dev/app-architecture/design-patterns/offline-first) describes local-first writes with later synchronization. Drift provides [transactions, generated query types and migrations](https://pub.dev/packages/drift), and [native Android/iOS support](https://drift.simonbinder.eu/platforms/). Use a unique event ID and a transaction to save the event and local state; server deduplication remains a later backend contract. |

For native storage, use `drift/native.dart` with `NativeDatabase.createInBackground` and `path_provider`. Drift's [native guide](https://drift.simonbinder.eu/platforms/vm/) recommends background database work and says recent versions do not require separate SQLite library packages. The convenience package [drift_flutter 0.3.1](https://pub.dev/packages/drift_flutter) currently lists `sqlcipher_flutter_libs` and `sqlite3_flutter_libs` as dependencies; the local resolver showed both as end-of-life packages. The direct native setup avoids that dependency path. This is a dependency-graph choice, not a claim that `drift_flutter` is broken.

Web persistence is a separate adapter: Drift's [web guide](https://drift.simonbinder.eu/platforms/web/) requires SQLite WASM and worker assets. Until browser persistence is built and tested, web remains a clearly labeled preview with fake data and no durability claim. Native Android/iOS are the initial delivery targets; desktop remains proposed in [ADR-0003](../../../architecture/ADR-0003-flutter-targets.md).

## Verification required in the implementation PR

Use real temporary SQLite files to prove duplicate event IDs store once, data survives close/reopen, and a schema migration preserves it. Run unit/widget tests, Android build and emulator smoke; run iOS simulator build on macOS. Test provider overrides and routing separately. Record web behavior as not verified until the WASM adapter is exercised. Decide sign-out retention and protection of sensitive local fields before storing real prayers, injuries or measurements. No client score is authoritative, and no cloud Firebase credentials or PROD deployment are part of this stack decision.
