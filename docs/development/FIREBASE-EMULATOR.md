# Local-only Firebase developer testing

**You do not need to create a Firebase account or Firebase/Google Cloud project for these tests.** The Firebase CLI runs Auth, Firestore and Storage emulators on your own machine, using the deliberately fake project `demo-forgedandsent`. No `firebase login` or `flutterfire configure` is needed.

Use a Git clone of `main` after PR #4 merges. To test the open Draft before merge, follow the PR #4 checkout note in the Windows/Mac quickstart. Install the Contributor tools for your operating system.

## Windows, one-click launchers

1. Double-click `launchers/windows/3 - Start practice Firebase.cmd` and leave the console running until it says **All emulators ready! It is now safe to connect your app.**
2. In a separate console, double-click `launchers/windows/4 - Run app with practice Firebase.cmd`.

## Mac, one-click launchers

1. Run `launchers/mac/1 - Set up this computer.command` once to install/reuse JDK 21 and the local Firebase CLI.
2. Double-click `launchers/mac/3 - Start practice Firebase.command` and keep Terminal open until it says **All emulators ready! It is now safe to connect your app.**
3. In a **second** Terminal window, run `launchers/mac/4 - Run app with practice Firebase.command`.

The Mac wizard offers those actions as menu choices 5 and 6. If it instead says a port "is already in use" ("Are you running another copy of the emulator suite?"), close the other emulator window or development server, or restart the computer, and try again. Don't edit `firebase.json`.

## Manual commands on either computer

From the repository root:

```sh
firebase emulators:start --project demo-forgedandsent --only auth,firestore,storage
```

With those emulators running, from `mobile/`:

```sh
flutter pub get
flutter run -d chrome --dart-define=FS_ENV=emulator
```

The SDK uses demo-only options, connects to local Auth on port **9099**, Firestore on **8080**, and Storage on **9199**, and makes real requests to all three before displaying a verified status. Failure produces a visible error, **not cloud fallback**.

The `developer_smoke` Firestore collection and Storage path accept only the authenticated owner. Everything else is denied by the demo rules. Mandatory CI includes positive and negative emulator security-rule tests, but these rules are **not production authorization for the real fitness app**.

Browser/desktop emulators use `127.0.0.1`. The Android Emulator's host default is `10.0.2.2`. Physical Android devices require deliberate host/network changes, for example `--dart-define=FNS_EMULATOR_HOST=YOUR-LAN-IP`, and firewall review before exposing any local emulator.

Do not deploy with these demo settings. A separate Firebase DEV project, Auth providers, application registration, least-privilege IAM, and production-quality Firestore/Storage policies will be needed before testing real multi-user cloud flows. Those tasks are **later work**, not prerequisites for PR #4 workstation acceptance.
