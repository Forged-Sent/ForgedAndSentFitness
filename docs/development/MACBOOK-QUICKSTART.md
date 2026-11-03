# Forged & Sent: MacBook quickstart using Git

This document tests the unmerged PR #4 development foundation on your Mac. Local Flutter preview and the Firebase emulator suite need **no Firebase account, cloud project, Firebase login or paid plan**.

## 1. Update your existing Git clone

Use the repository you already cloned. Open Terminal in the `ForgedAndSentFitness` directory:

```bash
git status
git fetch origin
git switch feature/contributor-emulator-onboarding
git pull --ff-only
```

If this is your first checkout of the feature branch and `git switch` doesn't find it, run `git switch --track origin/feature/contributor-emulator-onboarding`. Resolve any local edits before switching. Never force-reset just to run setup.

If you have not cloned the repository yet, install Apple's Command Line Tools if prompted and run:

```bash
git clone --branch feature/contributor-emulator-onboarding https://github.com/Forged-Sent/ForgedAndSentFitness.git
cd ForgedAndSentFitness
```

Normal `main` currently contains PR #3 only. Keep PR #4's feature branch selected for testing.

## 2. Preview setup

Double-click `FIRST-RUN-MAC.command` from Finder, or run it from the repository folder using `bash FIRST-RUN-MAC.command`.

Choose **Set up browser Preview**. If Command Line Tools or Homebrew is missing, the wizard directs you through their official, user-approved installation. It reuses existing tools and pins Flutter 3.47.8 at `~/develop/flutter`. It will not overwrite a different SDK.

Then launch `RUN-APP-MAC.command` to open the small Flutter starter screen in Chrome.

## 3. Contributor and Firebase emulator tests

Choose **Set up Contributor tools** or double-click `SETUP-DEVELOPER-MAC.command`. This adds Node.js, GitHub CLI, Firebase CLI 15.34.2, a usable JDK 21, and optional Codex/Claude CLIs. It does **not** authenticate with Firebase or deploy anything. The demo app connection is already implemented in PR #4.

Open `START-EMULATORS-MAC.command` in its **own Terminal window**. Leave it running. Then run `RUN-EMULATOR-APP-MAC.command` in another window. Both are also available as choices 7 and 8 in `FIRST-RUN-MAC.command`.

Successful emulator-mode startup verifies the local Auth, Firestore and Storage services. If an emulator is missing, the app should display an error rather than try cloud Firebase.

Equivalent manual commands, if needed:

```bash
# Terminal 1, from the repository root
firebase emulators:start --project demo-forgedandsent --only auth,firestore,storage
```

```bash
# Terminal 2, from the repository root
cd mobile
flutter pub get
flutter run -d chrome --dart-define=FS_ENV=emulator
```

The launchers select the dedicated JDK 21 even if your normal shell uses a different Java version.

## 4. Validate the workstation

Run `VERIFY-DEVELOPER-MAC.command` and inspect the report. Diagnostics confirm installed tools and may check emulator TCP ports, but they cannot independently certify the Flutter service handshake or live MCP authorization.

Open the repo in VS Code and verify the configured Dart/Playwright/MCP servers with real initialize and tools/list calls. Use `ARCHITECTURE-MAC.command` to generate the offline architecture explorer, then test source navigation and documentation.

Run `flutter analyze` and `flutter test` in the `mobile` folder. The setup scripts support **Preview and Contributor** on Mac. Android Studio, full Xcode/iOS simulator setup, native device operation and Maestro are separate manual workflows. Passing hosted Mac CI is not proof that your own Mac's first-time installs work.

## Mac-specific safety and troubleshooting

- Do not disable Gatekeeper or globally remove quarantine flags. If Finder blocks a trusted launcher, use System Settings > Privacy & Security > Open Anyway for that file, or invoke `bash FIRST-RUN-MAC.command` from Terminal.
- Homebrew's first installation and Apple's Command Line Tools need your approval; the repository does not silently execute a remotely downloaded installer.
- The SDK and Firebase CLI may require network access for installation, but using local demo emulators does not require Firebase cloud credentials.
- GitHub, Codex and Claude have their own optional sign-ins. No Google/Firebase cloud sign-in is required for local emulators.

See [Firebase emulator testing](FIREBASE-EMULATOR.md), [review workflow](AI-REVIEW-WORKFLOW.md), and [Architecture Atlas](../architecture/explorer/README.md).
