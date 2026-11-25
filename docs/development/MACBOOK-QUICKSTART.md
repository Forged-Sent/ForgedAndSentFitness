# Forged & Sent: MacBook quickstart (Git, not ZIP)

**Start here.** You do not need programming experience or a Firebase cloud account. This project uses local demo Firebase emulators. The Flutter app is early: it opens on **Today** with the day's devotional and six tabs, most of which are placeholders.

## First time: get the repository

1. Open Terminal. Run `git --version`. If macOS requests Apple Command Line Tools, approve the official Apple installer and reopen Terminal. You can also use [GitHub Desktop](https://desktop.github.com/) for a graphical clone.
2. Clone the shared project:

```bash
git clone https://github.com/Forged-Sent/ForgedAndSentFitness.git
cd ForgedAndSentFitness
git status
```

Already have a clone? Reuse it: check `git status`, then `git switch main`, `git fetch origin`, `git pull --ff-only`. Never force-reset unsaved work.

**Testing an open pull request before it merges** (advanced): `git fetch origin pull/<number>/head:pr<number>-test`, then `git switch pr<number>-test`; return with `git switch main`. Everyone else stays on `main`.

## Set up and run (double-click only)

Open the cloned `ForgedAndSentFitness` folder in **Finder**. Then open `launchers`, then `mac`, and double-click the files in number order:

1. **`1 - Set up this computer.command`** sets up VS Code, Node, GitHub CLI, the local Firebase CLI, JDK 21 and other development tools. Follow the official Command Line Tools and Homebrew instructions when asked; Homebrew's signed `.pkg` installer on its [official releases](https://github.com/Homebrew/brew/releases) may be easier than a Terminal install. Pick any optional AI assistants you use (or none) and set a Git name/email when prompted (a GitHub noreply address is fine). When the install finishes it offers **Try it now**: it starts practice Firebase, opens the app connected to it, asks what you saw and prints a checklist. It also asks whether to set up **iPhone testing**: Xcode from the App Store (your Apple ID, about 40 GB), the iOS simulator, CocoaPods and a local iOS build; afterwards use `launchers/mac/more/Run app on iPhone simulator.command`. You answer Apple's own prompts (Apple ID, Xcode license, Mac password) yourself. Android on a Mac is not automated yet. Safe to rerun.
2. **`2 - Run the app.command`** opens the Flutter app in Chrome, on its **Today** page.
3. **`3 - Start practice Firebase.command`** and **`4 - Run app with practice Firebase.command`** are explained in the next section.
4. **`5 - Check my setup.command`** explains anything missing.

Prefer a menu? Double-click **`START-MAC.command`** in the main folder instead, or from Terminal run `bash START-MAC.command`.

Only want to look at the app, not edit it? Use `launchers/mac/more/Preview-only setup.command` instead of step 1. No AI subscription is required; Codex, Claude Code, Copilot and Antigravity are all optional.

With your consent, the setup can add the project's Flutter SDK folder to your `~/.zprofile` PATH. Reopen Terminal and check `flutter --version`. If you decline, use `~/develop/flutter/bin/flutter` explicitly for manual commands.

## Test demo Firebase

Start `launchers/mac/3 - Start practice Firebase.command` in a separate Terminal window. Wait until it says **All emulators ready! It is now safe to connect your app.** If it instead says a port "is already in use" ("Are you running another copy of the emulator suite?"), close the other emulator window or development server, or restart the computer, and try again. Don't edit `firebase.json`. Then run `launchers/mac/4 - Run app with practice Firebase.command` in another window. In the app, open **Settings** (the round person button at the top right of Today), scroll to **This build** and tap **Build status**. Confirm it says **Verified local Auth, Firestore and Storage emulators (demo-forgedandsent).**

Neither script requires `firebase login` or a cloud project. Stop one emulator and restart the app to verify visible failure without cloud fallback.

## Your first small contribution

Use **[FIRST-CONTRIBUTION.md](FIRST-CONTRIBUTION.md)**, a shared Windows/Mac guide using VS Code Source Control, not Windows-only shell aliases. Ask for an organization/repository invitation before pushing to the shared repository; without it, use a fork and PR.

Run `launchers/mac/5 - Check my setup.command` for installed-tool diagnostics, and `launchers/mac/more/Architecture Atlas.command` to generate the offline Atlas. Open **MCP: List Servers** in VS Code and verify real connections rather than assuming configured means working.

You can run `flutter analyze` and `flutter test` from `mobile` after PATH is enabled (or use the full SDK path). Android on a Mac needs manual Android Studio setup. iPhone simulator testing is the optional step 1 question (or `START-MAC.command` > 8 > 5); Xcode comes from the App Store with your own Apple ID.

## iPhone simulator problems

`launchers/mac/more/Run app on iPhone simulator.command` boots the newest iPhone simulator, builds the app and opens it on **Today**. It uses practice Firebase when all three emulators are running and Preview mode otherwise. Three things have broken it on a real Mac; the launcher and **Check my setup** now handle or report each one.

| What you see | Why | What to do |
|---|---|---|
| `resource fork, Finder information, or similar detritus not allowed` during the Xcode build | The project folder is inside a folder that iCloud (or another cloud service) syncs, usually Desktop or Documents. Xcode cannot code-sign files there | Close your editors, move the whole project folder to a folder that is not synced, for example `~/Developer`, and run the launcher from there. Setup, the launcher and **Check my setup** (`ProjectFolder`) warn when the folder is synced |
| `Unable to find application named 'Simulator'` | Xcode 27 has no Simulator.app. Its simulator window is **DeviceHub** (`/Applications/Xcode.app/Contents/Applications/DeviceHub.app`) | Nothing: the launcher opens Simulator.app when Xcode has it and DeviceHub otherwise. With neither, it says so and keeps going; the simulator runs without a window and you can open it from Xcode > Window > Devices and Simulators |
| `Failed to copy plugin cloud_firestore` with `rsync: [Receiver] mkdir ... SourcePackages ... failed` | Homebrew's `rsync` is ahead of Apple's `/usr/bin/rsync` on PATH and does not create the missing `mobile/build/ios/SourcePackages` folder | Nothing when you use the launcher: it creates the folder first. For a manual `flutter pub get` or `flutter run`, run `mkdir -p mobile/build/ios/SourcePackages` from the project folder first, also after `flutter clean` |
| `Xcode 26.2 or newer is needed (Firebase iOS SDK)` | The Firebase iOS SDK does not build with an older Xcode | Update Xcode in the App Store, then `START-MAC.command` > 8 > 5. **Check my setup** reports this as `XcodeVersion` |

If macOS says a launcher "cannot be opened", right-click it and choose **Open**, then **Open** again; or use System Settings > Privacy & Security > Open Anyway for just that file; or run it from Terminal, for example `bash "launchers/mac/1 - Set up this computer.command"`. Never globally disable Gatekeeper or remove quarantine.

More detail: [Firebase emulators](FIREBASE-EMULATOR.md), [Architecture Atlas](../architecture/explorer/README.md), [optional AI review](AI-REVIEW-WORKFLOW.md).
