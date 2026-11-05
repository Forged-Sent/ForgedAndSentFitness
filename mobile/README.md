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

Preview only requires the generated web host. Setup and CI generate temporary, git-ignored hosts (`web`, plus `android` for Mobile setup and `ios` for the Mac iPhone step); committing reviewed native hosts is a later decision (ADR-0003). Do not check in the platform folders from a local `flutter create`.

## Scope
Current home screen is only a smoke-test scaffold. In emulator mode (`FS_ENV=emulator`) it signs in anonymously to the local practice Firebase and checks Firestore and Storage; it never connects to cloud Firebase, implements no offline persistence, and uses none of the legacy app's private data. Start real development with a vertical slice using fake repository adapters, then add backend integration after a group-access ADR and security tests.
