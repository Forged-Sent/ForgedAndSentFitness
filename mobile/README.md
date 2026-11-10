# Forged & Sent mobile (Flutter)

Minimal Flutter foundation intended for human review.

## Bootstrap
```sh
flutter create --platforms=web --project-name=forged_and_sent --org=com.forgedandsent .
flutter pub get
flutter analyze
flutter test
flutter run
```

Preview only requires the generated web host, which stays temporary and git-ignored, as do desktop hosts and `.metadata`.

`android/` and `ios/` are committed. They are Flutter 3.47.8 template output (`--org=com.forgedandsent --project-name=forged_and_sent`; Android `applicationId` `com.forgedandsent.forged_and_sent`, iOS bundle ID `com.forgedandsent.forgedAndSent`, iOS deployment target 15.0), with one reviewed customization: the ADR-0002 Android Network Security Configuration. `android/app/src/main/AndroidManifest.xml` references `@xml/network_security_config`; `android/app/src/main/res/xml/network_security_config.xml` blocks cleartext for every host (`base-config cleartextTrafficPermitted="false"`), so main, profile and release builds block cleartext on all supported API levels (minSdk 24; without it API 24-27 would allow cleartext by default). Debug builds use the same-named overlay `android/app/src/debug/res/xml/network_security_config.xml`, which keeps that base and allows HTTP only to the Android Emulator host `10.0.2.2`. Re-running `flutter create` only adds missing files; it does not rewrite committed ones. Local files (`local.properties`, Gradle wrappers, `Pods/`, `Flutter/ephemeral/`, generated plugin registrants) stay ignored by the hosts' own `.gitignore` files.

What is not done yet: release signing (Android release builds still use the template's debug key), final store identifiers, any `google-services.json` or `GoogleService-Info.plist` (Firebase stays emulator-only, see ADR-0002), a committed iOS `Podfile`, and runs on any emulator or device (the network security policy has only been checked in the built debug, profile and release APKs, not exercised on a device or emulator, including API 24-27). Physical devices using `FNS_EMULATOR_HOST=<LAN IP>` are not covered by the debug policy and would need a separate reviewed change. iOS builds need macOS/Xcode.

## Scope
Current home screen is only a smoke-test scaffold. In emulator mode (`FS_ENV=emulator`) it signs in anonymously to the local practice Firebase and checks Firestore and Storage; it never connects to cloud Firebase, implements no offline persistence, and uses none of the legacy app's private data. Start real development with a vertical slice using fake repository adapters, then add backend integration after a group-access ADR and security tests.
