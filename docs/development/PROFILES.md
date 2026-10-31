# Outcome-based Windows onboarding

**Preview:** Git, Chrome, Flutter. Ready when Chrome app launches.
**Contributor:** Preview + VS Code, Node, GitHub CLI, Firebase CLI,
JDK 21, FlutterFire CLI, and demo local emulators. No Firebase login.
Ready when app and tests run locally and a draft PR can be created.
**Mobile:** Contributor + Android Studio/SDK/licenses and Maestro.
Ready when app and one Maestro flow pass on a real emulator/device.
**Maintainer:** Mobile plus separately granted DEV-only IAM; no PROD
credentials on developer workstations. Cloud Firebase MCP is not default.

Run START-EMULATORS-WINDOWS.cmd before launching emulator-mode Flutter.
The SDK explicitly rejects any cloud Firebase environment in this branch.
The installer never runs flutterfire configure or accepts SDK licenses.
