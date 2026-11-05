# Forged & Sent: Windows quickstart (Git, not ZIP)

**Start here.** You do not need programming experience or a Firebase account. The local `demo-forgedandsent` Auth, Firestore and Storage emulators never touch real cloud data. The Flutter screen is currently a starter, not the completed fitness app.

## First time: get the repository

1. Install [Git for Windows](https://git-scm.com/install/windows) if `git --version` does not work. You can also choose [GitHub Desktop](https://desktop.github.com/) for a graphical clone, but the developer scripts require the Git command-line executable.
2. In PowerShell or VS Code Terminal, run:

```powershell
git clone https://github.com/Forged-Sent/ForgedAndSentFitness.git
cd ForgedAndSentFitness
git status
```

If you've already cloned it, **reuse that folder**. Do not download a ZIP or make a second checkout. Check `git status` first, then `git switch main`, `git fetch origin` and `git pull --ff-only`. If Git reports unsaved changes or divergence, stop rather than resetting or deleting work.

**While PR #4 is still unmerged:** an advanced tester may explicitly choose the PR branch using `git fetch origin pull/4/head:pr4-workstation-test` and `git switch pr4-workstation-test`. To pick up later PR updates while on that branch, run `git pull --ff-only origin pull/4/head`. This is for reviewing PR #4 *before* it lands. All normal contributor instructions use `main` so they remain valid after merge.

## Set up and run (double-click only)

Open the cloned `ForgedAndSentFitness` folder in **File Explorer**. Then open `launchers`, then `windows`, and double-click the files in number order:

1. **`1 - Set up this computer.cmd`** installs or reuses Flutter, VS Code, Node, GitHub CLI, Firebase CLI, JDK 21, Python 3 and developer guardrails. Approve only trusted installer prompts. It asks which optional AI assistants you use (any combination, or none) and helps set a Git commit name and email (a GitHub `noreply` address is fine). Safe to rerun.
2. **`2 - Run the app.cmd`** opens the small Forged & Sent screen in Chrome.
3. **`3 - Start practice Firebase.cmd`** and **`4 - Run app with practice Firebase.cmd`** are explained in the next section.
4. **`5 - Check my setup.cmd`** explains anything missing, with a WHY and FIX line for each item.

Prefer a menu? Double-click **`START-WINDOWS.cmd`** in the main folder instead; it offers the same steps plus extras. If Windows SmartScreen appears, choose **More info**, then **Run anyway**, only for these project files.

Only want to look at the app, not edit it? Use `launchers/windows/more/Preview-only setup.cmd` instead of step 1.

Codex, Claude Code, Copilot and Antigravity are all optional; pick only the ones you already have accounts for. Flutter/Dart tools are independent of a paid AI plan.

## Verify local Firebase

1. Open `launchers/windows/3 - Start practice Firebase.cmd` and keep that window running. Wait until it says **All emulators ready! It is now safe to connect your app.** If it instead says a port "is already in use" ("Are you running another copy of the emulator suite?"), close the other emulator window or development server, or restart the computer, and try again. Don't edit `firebase.json`.
2. In another window open `launchers/windows/4 - Run app with practice Firebase.cmd`.
3. Confirm the Flutter screen reports verified local Auth, Firestore and Storage. Stopping one emulator and starting the app again must produce an error, **never cloud fallback**.

No Firebase account, `firebase login`, `flutterfire configure`, or production credentials are required.

## Your first small contribution

Follow **[FIRST-CONTRIBUTION.md](FIRST-CONTRIBUTION.md)** for a graphical Windows/Mac route: VS Code Source Control, one harmless edit, Flutter tests, a new branch, draft PR and GitHub `ci-gate`. Ask the maintainer for GitHub organization/repository write access before trying to publish a branch; without it, use the normal fork/PR route.

Use `launchers/windows/5 - Check my setup.cmd` to diagnose missing tools, `launchers/windows/more/Architecture Atlas.cmd` for the offline Architecture Atlas, and `launchers/windows/more/AI code review.cmd` for **optional** non-author AI review.

Optional Android development requires Android Studio, SDK licenses and a configured emulator/device; Windows cannot run the iOS simulator.

If setup cannot finish, rerun it and use the wizard's redacted Ask AI report. Never share passwords or API keys or disable company security controls.

More detail: [developer setup](DEVELOPER-WINDOWS.md), [Firebase emulators](FIREBASE-EMULATOR.md), [troubleshooting](FIRST-RUN-TROUBLESHOOTING.md).
