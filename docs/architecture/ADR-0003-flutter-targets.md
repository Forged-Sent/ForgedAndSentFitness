# ADR-0003: Shared Flutter codebase and incremental platform certification

- Status: Proposed, not yet a release commitment
- Date: 2026-11-02
- Decision owner: project maintainers

## Context
The current HTML/JavaScript prototype is a behavior reference. The Flutter scaffold merged in PR #4 targets Android/iOS and web checks, while the long-term product may also serve Windows, Linux and macOS. Flutter supports these platforms, but native hosts and plugins need different toolchains, testing and privacy/permission behavior.

## Proposed decision
Use one Flutter/Dart source for shared application/domain/data contracts across Android, iOS, web, Windows, Linux and macOS; first prioritize Android/iOS functional correctness, while web remains a development/browser preview. Treat desktop as an explicit future compatibility target, not a promise that binaries currently build. Add reviewed native platform hosts and OS-specific CI only after a package compatibility audit and milestone approval.

- Keep UI/views and view models separate from repositories/services. State, identity, scoring, local durable outbox and private data boundaries are shared contracts.
- Use responsive/adaptive layouts and abstract platform capabilities; show controlled unsupported states rather than silent feature loss.
- The prototype is not a source of production code, trusted auth, or automatically accepted business rules.
- Use a feature parity matrix and platform-specific test evidence. Do not announce a target as supported without build, runtime and permission verification.
- Separate emulator-first development from reviewed DEV and PROD environments; no release pipeline or credentials are created by this ADR.

## Implementation status (2026-11-09)
At the maintainer's request, Android and iOS template hosts are committed under `mobile/android/` and `mobile/ios/`. The only edit to template output is the ADR-0002 Android Network Security Configuration: the main config (`src/main/res/xml/`) blocks cleartext for all hosts in main, profile and release builds on every supported API level (minSdk 24), and a same-named debug overlay (`src/debug/res/xml/`) allows cleartext HTTP only to `10.0.2.2`; release and profile builds do not include the exception. This does not change this ADR's Proposed status or certify either platform. Signing, store identifiers, native Firebase configuration and device/simulator runs from the committed hosts remain open, as do the package compatibility audit and milestone approval above. Web and desktop hosts stay uncommitted.

## Alternatives considered
Single platform-specific native applications would duplicate logic and reviews. Wrapping the prototype as a WebView would not address trusted server-side rules, offline events or native integration. Enabling all native hosts immediately would add untested build/toolchain and plugin commitments.

## Consequences and approval gate
This proposal requires maintainer approval to move to Accepted. Implementation and deployment belong to later, scoped PRs; existing ADR-0001/0002 remain authoritative. See [target platform matrix](../knowledge/FLUTTER-PLATFORMS.md), [parity inventory](../knowledge/PROTOTYPE-PARITY.md) and official https://docs.flutter.dev/reference/supported-platforms .
