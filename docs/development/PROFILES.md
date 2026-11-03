# Forged & Sent: development profiles and platform support

The four outcome-based profiles are currently automated on **Windows**.

| Profile | Purpose | Windows | Mac |
| --- | --- | --- | --- |
| Preview | Flutter web in Chrome | Guided | Guided |
| Contributor | VS Code, Node, GitHub CLI, Firebase CLI, JDK 21 and demo emulators | Guided | Guided; live emulator acceptance manual |
| Mobile | Android Studio/SDK/licensing and Maestro | Guided setup plus manual device steps | Manual platform setup |
| Maintainer | Separately authorized DEV cloud administration | IAM not provisioned automatically | IAM not provisioned automatically |

Use a **Git clone**, not a ZIP copy, for development. For PR #4 testing, select `feature/contributor-emulator-onboarding`. Keep local changes safe when switching branches.

Neither Preview nor Contributor requires a Firebase account or cloud Firebase project. The `demo-forgedandsent` suite runs locally only.

On Windows start `START-EMULATORS-WINDOWS.cmd`, then `RUN-EMULATOR-APP-WINDOWS.cmd` in another window.

On Mac start `START-EMULATORS-MAC.command`, then `RUN-EMULATOR-APP-MAC.command` in another window. Mac Contributor setup installs a dedicated JDK 21 without changing global Java settings.

Tools being installed does not prove that emulators, device workflows or MCP handshakes are working. Verify live operation independently. The setup never automatically runs `firebase login`, `flutterfire configure`, accepts SDK licenses, or deploys to production.
