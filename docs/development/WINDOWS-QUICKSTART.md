# Forged & Sent: Windows quickstart using Git

This is the **current PR #4 test procedure**, not the complete fitness app. No Firebase or Google Cloud account is needed for the local Flutter preview or the local Firebase emulators. A real DEV/PROD Firebase project will be configured in later work.

## 1. Open your existing Git checkout

If you have already cloned the repository, **do not download another ZIP and do not clone a second copy**. Open PowerShell or the VS Code terminal in your existing `ForgedAndSentFitness` folder.

Check for local unsaved changes before switching branches:

```powershell
git status
git fetch origin
git switch feature/contributor-emulator-onboarding
git pull --ff-only
```

The feature branch is PR #4. If `git switch` reports an unknown local branch, run `git switch --track origin/feature/contributor-emulator-onboarding` instead. Do not discard local edits or force-reset a branch. If Git reports conflicts or divergence, stop and resolve them first.

**Only if you have never cloned the repository:** install Git for Windows, then run:

```powershell
git clone --branch feature/contributor-emulator-onboarding https://github.com/Forged-Sent/ForgedAndSentFitness.git
cd ForgedAndSentFitness
```

The default `main` branch contains merged PR #3, but not unmerged PR #4.

## 2. Preview the Flutter starter

From File Explorer in the cloned repository, double-click `FIRST-RUN-WINDOWS.cmd`. Select **Preview** to install/verify the web build tools, then use the wizard's **Run Flutter in Chrome** option (or `RUN-APP.cmd`).

The screen should show **Forged & Sent / Faith. Training. Brotherhood.** This is a starter UI, not the full HTML prototype.

Windows PowerShell 5.1 is used only to bootstrap supported PowerShell 7; it is not removed. Allow only intentional trusted installer prompts. Re-running setup should reuse existing tools.

## 3. Contributor and local Firebase

Return to `FIRST-RUN-WINDOWS.cmd` and select **Contributor**. This installs/checks VS Code, GitHub CLI, Node, Firebase CLI, JDK 21, FlutterFire CLI, and project tools. It does **not** run `firebase login`, `flutterfire configure`, or deploy to cloud Firebase.

Double-click `START-EMULATORS-WINDOWS.cmd` and keep that console open. In a **second** console double-click `RUN-EMULATOR-APP-WINDOWS.cmd`. The app should verify live local Auth (9099), Firestore (8080) and Storage (9199) communication using the project ID `demo-forgedandsent`.

If one emulator is stopped, a subsequent app startup should show an error instead of silently connecting to the cloud.

## 4. Diagnostics and engineering tools

- Run `VERIFY-DEVELOPER-WINDOWS.cmd` or the wizard's **Check everything** option.
- Open the repository in VS Code. Use **MCP: List Servers**; a configured MCP is **not** verified until it successfully initializes and lists tools.
- Run `ARCHITECTURE-WINDOWS.cmd` and try source search, clickable components and documentation.
- Run `flutter analyze` and `flutter test` from the `mobile` directory.
- Optionally run `REVIEW-WINDOWS.cmd --dry-run`; actual Codex/Claude/Gemini AI review is opt-in.
- For Android testing, choose **Mobile** in the wizard (or run `SETUP-ANDROID.cmd`). Complete Android Studio SDK setup, licenses, and emulator/device pairing yourself.

Check the Git working tree after setup with `git status`. Generated Flutter host folders are intentionally ignored, and the setup should not rewrite tracked sources.

## When something fails

Do not bypass corporate security policy or share credentials. The wizard can produce a redacted Ask AI troubleshooting report in `%TEMP%`, which you review before pasting into an assistant.

See [Windows developer setup](DEVELOPER-WINDOWS.md), [Firebase emulator testing](FIREBASE-EMULATOR.md), and [Git basics](GIT-101.md).
