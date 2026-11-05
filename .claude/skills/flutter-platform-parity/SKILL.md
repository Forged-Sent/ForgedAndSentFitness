---
name: flutter-platform-parity
description: Port one HTML prototype behavior into a testable Flutter vertical slice and prove support separately for Android, iOS, web and future desktop hosts.
---
# Flutter platform and prototype parity review

1. Read AGENTS.md, mobile/AGENTS.md, docs/knowledge/INDEX.md, PROTOTYPE-PARITY.md, FLUTTER-PLATFORMS.md and the accepted architecture ADRs.
2. Inspect index.html at a named commit and identify the real UI behavior; never invent prototype functions or call an archived snapshot current.
3. Describe approved user experience, failure/empty/offline states, accessibility and responsive sizes before implementation. The HTML B/window.claude adapter is not a backend authorization model.
4. Define view/view-model/repository boundaries and unit/widget tests, with fake data first. Firebase/native plugin APIs must remain in services/adapters and should be checked against actual lockfile/platform support.
5. Protect private data and group isolation; preserve idempotent durable events and server-authoritative competition. Do not enable youth or production Firebase.
6. Independently verify each target; supported Flutter platforms are not proof that this app/plugin compiles there. iOS/macOS require macOS; Windows requires Windows tooling; Linux requires Linux tooling.
7. Run the applicable analyzer/tests/build on available host, record commands/results plus NOT VERIFIED platform checks. No signing, deployment, push or self-merge.
8. Capture source SHA, findings and next steps in docs/knowledge/handoffs/ and update architecture/code map if boundaries or Dart declarations changed.
Trusted docs: https://docs.flutter.dev/app-architecture/recommendations and https://docs.flutter.dev/reference/supported-platforms
