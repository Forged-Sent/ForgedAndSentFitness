# Local-only Firebase developer testing

**You do not need to create a Firebase account or Firebase/Google Cloud project for these tests.** The Firebase CLI runs Auth, Firestore and Storage emulators on your own machine, using the deliberately fake project `demo-forgedandsent`. No `firebase login` or `flutterfire configure` is needed.

First use Git to check out PR #4's branch: `feature/contributor-emulator-onboarding`. Install the Contributor tools for your operating system.

## Windows, one-click launchers

1. Double-click `START-EMULATORS-WINDOWS.cmd` and leave the console running.
2. In a separate console, double-click `RUN-EMULATOR-APP-WINDOWS.cmd`.

## Mac, one-click launchers

1. Run `SETUP-DEVELOPER-MAC.command` once to install/reuse JDK 21 and the local Firebase CLI.
2. Double-click `START-EMULATORS-MAC.command` and keep Terminal open.
3. In a **second** Terminal window, run `RUN-EMULATOR-APP-MAC.command`.

The Mac wizard offers those actions as menu choices 7 and 8.

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
