# Flutter platform strategy and verification matrix

**Direction:** One Flutter/Dart application with shared presentation, domain contracts and data adapters. Android and iOS are the first shipping targets. Web is a valuable early testing/preview target. Windows, Linux and macOS desktop are explicit architectural goals, not currently certified deliverables. See [proposed ADR](../architecture/ADR-0003-flutter-targets.md).

Flutter supports all six target families, but a Flutter package or Firebase plugin can have different platform support. Shared Dart code does not remove platform host projects, native signing, secure storage, permissions, integrations or distinct release/testing processes.

| Target | Typical build host | Proof of support before calling it ready | Current claim |
|---|---|---|---|
| Android | Windows, macOS or Linux with Android SDK | analyzer + unit/widget tests; debug APK; emulator/device integration; native permissions | Scaffold/CI only; check PR #4 |
| iOS | macOS + Xcode | unsigned simulator build; physical device tests; separate signed distribution | Draft PR #4 CI attempt; NOT VERIFIED |
| Web | Any supported build host/browser | web build; Chrome/Firefox/Safari responsive and keyboard checks; browser limits | Foundation preview target, not feature parity |
| Windows | Windows + Visual Studio C++ desktop workload | native Windows build, smoke test and plugin matrix | Proposed; not enabled |
| Linux | Linux + clang/CMake/Ninja/GTK toolchain | native Linux build, smoke test and plugin matrix | Proposed; not enabled |
| macOS | macOS + Xcode | native macOS build, smoke test and plugin matrix | Proposed; not enabled |

## Implementation boundaries
- Feature-first at `mobile/lib/src/features/`; views send user actions to view models, repositories are data sources of truth, external Firebase/native integrations stay in services/adapters. Add domain use cases only when warranted.
- Prefer responsive/adaptive layouts (phone, tablet, desktop keyboard/mouse); don't equate a large web screen with verified native desktop UX.
- Wrap platform behavior behind capability interfaces (notifications, secure storage, sensors, health, camera, file picking, share sheet); provide meaningful unsupported/fallback states.
- Never enable youth, private health or background collection features merely because a platform API exists.
- State and authorization remain consistent across platforms. All clients untrusted; scoring stays server-authoritative. Offline event ID and durable outbox semantics require tests.
- At each package addition, verify exact version in `mobile/pubspec.lock` and native support for each intended target. Record unsupported platforms before acceptance.
- Native hosts (android/, ios/, web/, windows/, linux/, macos/) must be generated/committed through reviewed changes with reproducible configuration; no unattended blanket `flutter create --platforms` that modifies tracked hosts.

## Validation sequence (not proof these commands ran)
```sh
cd mobile
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
flutter build web --release --no-pub
# After the corresponding native host and toolchain are configured:
flutter build apk --debug --no-pub
flutter build ios --simulator --no-codesign --no-pub   # macOS only
flutter build windows --release --no-pub              # Windows only
flutter build linux --release --no-pub                # Linux only
flutter build macos --release --no-pub                # macOS only
```

Gate features by supported device capabilities, not target platform name alone. Prefer unit/widget tests as fast cross-platform checks plus small integration/smoke tests per host. No CI job may be reported as proven unless its result at the proposed HEAD was checked.

Primary docs: https://docs.flutter.dev/reference/supported-platforms ; https://docs.flutter.dev/platform-integration/desktop ; https://docs.flutter.dev/platform-integration/windows/setup ; https://docs.flutter.dev/platform-integration/linux/setup ; https://docs.flutter.dev/deployment/ios .
