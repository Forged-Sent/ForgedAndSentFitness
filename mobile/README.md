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

What is not done yet: release signing (Android release builds still use the template's debug key), final store identifiers, any `google-services.json` or `GoogleService-Info.plist` (Firebase stays emulator-only, see ADR-0002), a committed iOS `Podfile`, and runs on a physical device; the only emulator run so far is the S1 restart test, below (the network security policy has only been checked in the built debug, profile and release APKs, not exercised on a device or emulator, including API 24-27). Physical devices using `FNS_EMULATOR_HOST=<LAN IP>` are not covered by the debug policy and would need a separate reviewed change. iOS builds need macOS/Xcode.

## Scope
The app opens on the six-tab shell from build step S0: the brand bar, the hero header and the tab bar, in dark and light, with bundled fonts. Since build step S1, Today shows the date, the mission line, a progress ring and the day's boxes, and the devotional box opens the day's reading; Amen is saved in the member's own SQLite file on the phone and is still there after a restart. Since build step S3, Train shows this week of the Forged program, and a day's workout can be started through the workout prayer, logged set by set with a rest timer, and finished; the Workout box on Today then checks itself, and a workout in progress survives the app being killed. The other four tabs are placeholders, the other five boxes are shown as not active yet, and nothing is sent anywhere. Colors, type and shared widgets live in `lib/src/design/` and are described in `docs/design/DESIGN-SYSTEM.md`; where the fonts, the hero photograph and the bundled readings came from is in `assets/SOURCES.md`. What the feature promises is in `docs/features/today-devotional/feature.md`.

The developer status page (Today's round profile button, then Build status) is the smoke test. In emulator mode (`FS_ENV=emulator`) the app signs in anonymously to the local practice Firebase and checks Firestore and Storage, and if that check fails the app opens on the status page and says so. It never connects to cloud Firebase, and uses none of the legacy app's private data. Start real development with a vertical slice using fake repository adapters, then add backend integration after a group-access ADR and security tests.


## Generated code

The Drift schema code, `lib/src/storage/app_database.g.dart`, is generated and committed. CI does not generate it. After changing a table in `lib/src/storage/app_database.dart`:

```sh
dart run build_runner build
```

### Changing a table means a new schema version

The database is at schema version 2. A member's file may be at any earlier version, so every change to a table is a migration, and it is tested. The schema of each version is frozen in `drift_schemas/`. After changing a table:

1. Raise `schemaVersion` in `lib/src/storage/app_database.dart` and add a step to `_upgradeSteps` there.
2. Regenerate, in this order:

```sh
dart run build_runner build
dart run drift_dev schema dump lib/src/storage/app_database.dart drift_schemas/
dart run drift_dev schema steps drift_schemas/ lib/src/storage/app_database.steps.dart
dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/storage/generated_migrations/
```

3. Add the new version to `test/storage/migration_test.dart`.

`lib/src/storage/app_database.steps.dart` and everything under `test/storage/generated_migrations/` are generated and committed. Never edit a frozen schema file of a version that has shipped.

## Bundled workout content

`assets/content/workouts_forged.json`, `movements.json` and `workout_prayer.json` are copies: the first two of files under `seed/`, the third of the `WORKOUT_PRAYER` list inside `index.html`. They are made by a script, never typed, and `test/features/workout/workout_library_test.dart` fails if a copy says anything its source does not. `assets/SOURCES.md` says how each was made.

## The restart tests on an Android emulator

There are two, each in two halves. This section is about the first; the workout's is the next section.

Two files under `integration_test/` prove that a checked devotional box survives the app being killed. A test cannot outlive the app it runs in, so the test is in two halves, run one after the other with the app's process stopped in between. Both start the real app with its real database file.

```sh
flutter emulators --launch <emulator id>
flutter test integration_test/restart_1_complete_test.dart -d <device id> --no-uninstall
flutter test integration_test/restart_2_verify_test.dart -d <device id>
```

The first reads to the end, says Amen and leaves the app installed. The second starts a new process, expects the box to be checked, and uninstalls the app. Run both on the same day: a box checked before midnight is, correctly, not checked the next day. No CI lane has an emulator, so this test runs only where someone runs it. It last passed on 2026-11-12 on an emulator made for this test, `FS_S1_Restart_API_36`, from the installed `system-images;android-36;google_apis_playstore;x86_64` image (Android 16, API 36).

## The workout restart test

Two more files prove that a workout in progress survives the app being killed (prompt P07, acceptance 5: start, two sets, kill, relaunch, finish).

```sh
flutter emulators --launch <emulator id>
flutter test integration_test/workout_restart_1_start_test.dart -d <device id> --no-uninstall
flutter test integration_test/workout_restart_2_finish_test.dart -d <device id>
```

The first starts today's workout through the prayer, types two sets, checks that they are already in the database file, and leaves the app installed with the workout in progress. The second starts a new process, expects the two sets in their boxes and a clock that shows the real time since the first run's Amen, finishes the workout, and expects a locked summary and the Workout box on Today checked. It uninstalls the app.

- **Start with the app not installed.** The first half expects a new install with no workout stored.
- **The clock.** A workout can be started only on a day that has one, and logging weights needs a lifting day. So both halves start the app with its clock moved forward by whole days to the next Monday, Wednesday or Friday; on those days it is not moved at all. The clock still runs. Run both halves on the same real day, and not across midnight.
- **A release build cannot be given a clock.** `startApp` passes the clock through `clockForStart`, which throws in release mode; `test/app/start_clock_test.dart` tests that, and that nothing else in the app can set the clock. These two files run in debug mode.

No CI lane has an emulator, so this test too runs only where someone runs it. It last passed on 2026-11-13 on `FS_S1_Restart_API_36` (Android 16, API 36), a Friday, so the clock was not moved.

## Where each of P07's acceptance items is tested

| # | Acceptance item | Test |
|---|---|---|
| 1 | Kill mid-set and relaunch: every entered set present and the clock correct | On a real SQLite file: `test/features/workout/drift_workout_repository_test.dart`, "kill mid-set and relaunch: every entered set is there and the clock is right (P07 acceptance 1)". On the screen: `test/features/workout/workout_page_test.dart`, group "kill mid-set and relaunch (P07 acceptance 1, on the screen)". On the emulator: item 5 |
| 2 | Finish twice: one completion | `test/features/workout/workout_repository_contract.dart`, "twice records one completion (P07 acceptance 2)", run against both stores by `drift_workout_repository_test.dart` and `memory_workout_repository_test.dart`. On the screen: `workout_page_test.dart`, "twice records one completion (P07 acceptance 2)" |
| 3 | A session started at 23:50 can be finished at 00:10 | `workout_repository_contract.dart`, "a session started at 23:50 can be finished at 00:10, and it belongs to the day it started on (P07 acceptance 3)", against both stores. On the screen: `workout_page_test.dart`, group "a session started at 23:50 can be finished at 00:10 (P07 acceptance 3, review finding U2)" |
| 4 | Changing the plan afterwards does not alter the finished session | `workout_repository_contract.dart`, "changing the plan afterwards does not alter the finished session (P07 acceptance 4)", against both stores. On the screen: `workout_page_test.dart`, group "changing the plan afterwards (P07 acceptance 4)" |
| 5 | One integration test on the Android emulator: start, two sets, kill, relaunch, finish | `integration_test/workout_restart_1_start_test.dart`, then `integration_test/workout_restart_2_finish_test.dart` |
