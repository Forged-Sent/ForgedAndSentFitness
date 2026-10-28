# Forged & Sent mobile (Flutter)

Minimal Flutter foundation intended for human review.

## Bootstrap
```sh
flutter create --platforms=android,ios --project-name=forged_and_sent --org=com.forgedandsent .
flutter pub get
flutter analyze
flutter test
flutter run
```

Until the generated platform projects are committed, CI generates the Android host in the job workspace. This is a **temporary step**.

## Scope
Current home screen is only a smoke-test scaffold. It does not connect to Firebase, implement offline persistence, or use the legacy app's private data. Start real development with a vertical slice using fake repository adapters, then add backend integration after a group-access ADR and security tests.
