# Forged & Sent: MacBook quickstart (Git, not ZIP)

**Start here.** You do not need programming experience or a Firebase cloud account. This project uses local demo Firebase emulators. The Flutter UI is currently a starter screen.

## First time: get the repository

1. Open Terminal. Run `git --version`. If macOS requests Apple Command Line Tools, approve the official Apple installer and reopen Terminal. You can also use [GitHub Desktop](https://desktop.github.com/) for a graphical clone.
2. Clone the shared project:

```bash
git clone https://github.com/Forged-Sent/ForgedAndSentFitness.git
cd ForgedAndSentFitness
git status
```

Already have a clone? Reuse it: check `git status`, then `git switch main`, `git fetch origin`, `git pull --ff-only`. Never force-reset unsaved work.

**While PR #4 remains a Draft**, a tester can choose its code explicitly: `git fetch origin pull/4/head:pr4-workstation-test`, then `git switch pr4-workstation-test`. The regular instructions intentionally target `main` so they work **after** PR #4 merges.

## Setup and preview

From Finder, double-click `FIRST-RUN-MAC.command`, or from Terminal run `bash FIRST-RUN-MAC.command`. Choose **Preview** and follow the official Command Line Tools and Homebrew instructions. Homebrew's signed `.pkg` installer on its [official releases](https://github.com/Homebrew/brew/releases) may be easier than a Terminal install, if available for your Mac.

Then launch `RUN-APP-MAC.command` to see the Forged & Sent Flutter starter in Chrome.

Choose **Contributor** to set up VS Code, Node, GitHub CLI, local Firebase CLI, JDK 21 and other development tools. Configure a Git name/email when prompted; a GitHub noreply address is fine. Choose **one** optional AI assistant. The setup does not require Codex, Claude and Copilot subscriptions together.

With your consent, the setup can add the project's Flutter SDK folder to your `~/.zprofile` PATH. Reopen Terminal and check `flutter --version`. If you decline, use `~/develop/flutter/bin/flutter` explicitly for manual commands.

## Test demo Firebase

Start `START-EMULATORS-MAC.command` in a separate Terminal window. Wait for emulator readiness, then run `RUN-EMULATOR-APP-MAC.command` in another window. Confirm that the app reports verified local Auth, Firestore and Storage.

Neither script requires `firebase login` or a cloud project. Stop one emulator and restart the app to verify visible failure without cloud fallback.

## Your first small contribution

Use **[FIRST-CONTRIBUTION.md](FIRST-CONTRIBUTION.md)**, a shared Windows/Mac guide using VS Code Source Control, not Windows-only shell aliases. Ask for an organization/repository invitation before pushing to the shared repository; without it, use a fork and PR.

Run `VERIFY-DEVELOPER-MAC.command` for installed-tool diagnostics, and `ARCHITECTURE-MAC.command` to generate the offline Atlas. Open **MCP: List Servers** in VS Code and verify real connections rather than assuming configured means working.

You can run `flutter analyze` and `flutter test` from `mobile` after PATH is enabled (or use the full SDK path). Native Android/iOS simulator builds require separate platform setup; full Xcode and an iOS simulator are not installed by this wizard.

If Gatekeeper blocks a trusted launcher, use System Settings > Privacy & Security > Open Anyway for just that file, or run `bash FIRST-RUN-MAC.command`. Never globally disable Gatekeeper or remove quarantine.

More detail: [Firebase emulators](FIREBASE-EMULATOR.md), [Architecture Atlas](../architecture/explorer/README.md), [optional AI review](AI-REVIEW-WORKFLOW.md).
