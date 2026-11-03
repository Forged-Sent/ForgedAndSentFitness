# Forged & Sent: development profiles and platform support

The four outcome-based profiles are currently automated on **Windows**.

| Profile | Purpose | Windows | Mac |
| --- | --- | --- | --- |
| Preview | Flutter web in Chrome | Guided | Guided |
| Contributor | VS Code, Node, GitHub CLI, Firebase CLI, JDK 21 and demo emulators | Guided | Guided; live emulator acceptance manual |
| Mobile | Android Studio/SDK/licensing and Maestro | Guided setup plus manual device steps | Manual platform setup |
| Maintainer | Separately authorized DEV cloud administration | IAM not provisioned automatically | IAM not provisioned automatically |

Use a **Git clone**, not a ZIP copy, for development. Use `main` for normal onboarding after PR #4 merges; for testing the open Draft first, see the explicit PR checkout in the quickstarts. Keep local changes safe when switching branches.

Neither Preview nor Contributor requires a Firebase account or cloud Firebase project. The `demo-forgedandsent` suite runs locally only.

On Windows start `START-EMULATORS-WINDOWS.cmd`, then `RUN-EMULATOR-APP-WINDOWS.cmd` in another window.

On Mac start `START-EMULATORS-MAC.command`, then `RUN-EMULATOR-APP-MAC.command` in another window. Mac Contributor setup installs a dedicated JDK 21 without changing global Java settings.

Tools being installed does not prove that emulators, device workflows or MCP handshakes are working. Verify live operation independently. The setup never automatically runs `firebase login`, `flutterfire configure`, accepts SDK licenses, or deploys to production.

Beginner default MCPs are Dart, Playwright and Context7. Advanced accounts/device tools are opt-in; see [MCP security](MCP-SECURITY.md). The two setup wizards each offer **one** optional AI assistant rather than installing several by default.
