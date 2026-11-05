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

On Windows start `launchers/windows/3 - Start practice Firebase.cmd`, then `launchers/windows/4 - Run app with practice Firebase.cmd` in another window.

On Mac start `launchers/mac/3 - Start practice Firebase.command`, then `launchers/mac/4 - Run app with practice Firebase.command` in another window. Mac Contributor setup installs a dedicated JDK 21 without changing global Java settings.

Tools being installed does not prove that emulators, device workflows or MCP handshakes are working. Verify live operation independently. The setup never automatically runs `firebase login`, `flutterfire configure`, accepts SDK licenses, or deploys to production.

Beginner default MCPs are Dart, Playwright and Context7. Advanced accounts/device tools are opt-in; see [MCP security](MCP-SECURITY.md). The setup wizards install no AI assistant by default; the person picks any combination of Codex, Claude Code, GitHub Copilot and Antigravity CLI (or none).
