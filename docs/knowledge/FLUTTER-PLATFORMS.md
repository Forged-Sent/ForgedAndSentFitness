# Flutter platform strategy and verification matrix

**Direction:** One Flutter/Dart application with shared presentation, domain contracts and data adapters. Android and iOS are the first shipping targets. Web is a valuable early testing/preview target. Windows, Linux and macOS desktop are explicit architectural goals, not currently certified deliverables. See [proposed ADR](../architecture/ADR-0003-flutter-targets.md).

Flutter supports all six target families, but a Flutter package or Firebase plugin can have different platform support. Shared Dart code does not remove platform host projects, native signing, secure storage, permissions, integrations or distinct release/testing processes.

| Target | Typical build host | Proof of support before calling it ready | Current claim |
|---|---|---|---|
| Android | Windows, macOS or Linux with Android SDK | analyzer + unit/widget tests; debug APK; emulator/device integration; native permissions | Template host committed in `mobile/android/` plus the ADR-0002 network security policy (main config blocks cleartext for all hosts on API 24+; debug overlay adds only `10.0.2.2`); debug, profile and release APKs built locally on Windows with Flutter 3.47.8 and their packaged `network_security_config` inspected (profile/release: base cleartext false, no exceptions; debug: base false plus `10.0.2.2`). CI's `flutter` job also builds the debug APK from the committed host. Since build step S1 the app has run on one Android emulator: the restart test (`mobile/integration_test/`) passed on 2026-11-12 on an emulator made for this test, `FS_S1_Restart_API_36`, from the installed `system-images;android-36;google_apis_playstore;x86_64` image (Android 16, API 36), started from Windows. A physical device, any other Android version, the Firebase emulator connection from a device, and release signing are NOT VERIFIED |
| iOS | macOS + Xcode | unsigned simulator build; physical device tests; separate signed distribution | Template host committed in `mobile/ios/` (generated on Windows, deployment target 15.0). It is built only by CI's `ios-simulator` job, as an unsigned simulator app. It has not been built locally, and there is no simulator or physical-device run yet |
| Web | Any supported build host/browser | web build; Chrome/Firefox/Safari responsive and keyboard checks; browser limits | Foundation preview target, not feature parity. Since build step S1 the web build opens no database: it keeps the day in memory and says on screen that nothing is saved (ADR-0005) |
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
- Native hosts (android/, ios/, web/, windows/, linux/, macos/) must be generated/committed through reviewed changes with reproducible configuration; no unattended blanket `flutter create --platforms` that modifies tracked hosts. Android and iOS are committed. Web and desktop hosts and `.metadata` stay git-ignored, because `flutter create` rewrites `.metadata` whenever it adds a platform. The setup/CI `flutter create` calls were checked to leave committed host files byte-identical.

## Packages with native parts (since build step S1)

| Package | What it needs on the device | Android | iOS | Web |
|---|---|---|---|---|
| `sqlite3` 3.5.2 (through `drift` 2.35.4) | SQLite itself, supplied by the package's build hook. No `sqlite3_flutter_libs` | The debug APK built on Windows contains `libsqlite3.so` for arm64-v8a, armeabi-v7a and x86_64; the x86_64 one ran in the emulator test above | Built only by CI's `ios-simulator` job; never run | Not used: the web build opens no database |
| `path_provider` 2.1.6 | The app's own support and temporary folders | Used to place the database file and SQLite's temporary files | Built only by CI; never run | Not used |

On the development host, `flutter test` gets SQLite the same way: `mobile/test/storage/sqlite_available_test.dart` fails on a machine where the hook did not supply it.

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
