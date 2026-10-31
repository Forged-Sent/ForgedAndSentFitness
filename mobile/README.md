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

Preview only requires the generated web host. CI also generates Android temporarily to validate the debug APK. Native Android/iOS host projects will be reviewed and committed in PR #4. Do not check in the interim platform folders from a local `flutter create`.

## Scope
Current home screen is only a smoke-test scaffold. It does not connect to Firebase, implement offline persistence, or use the legacy app's private data. Start real development with a vertical slice using fake repository adapters, then add backend integration after a group-access ADR and security tests.
