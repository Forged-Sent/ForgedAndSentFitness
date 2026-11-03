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

**While PR #4 is still unmerged:** an advanced tester may explicitly choose the PR branch using `git fetch origin pull/4/head:pr4-workstation-test` and `git switch pr4-workstation-test`. This is for reviewing PR #4 *before* it lands. All normal contributor instructions use `main` so they remain valid after merge.

## Setup and preview

From the cloned folder, double-click `FIRST-RUN-WINDOWS.cmd`. Choose **Preview**, approve only trusted installer prompts, and launch `RUN-APP.cmd` to see the small Forged & Sent screen in Chrome.

To make changes, run the wizard again and choose **Contributor**. It installs/checks Flutter, VS Code, Node, GitHub CLI, Firebase CLI, JDK 21, Python 3, and developer guardrails. The wizard helps set a Git commit name and email. Use your GitHub `noreply` address if you prefer not to publish your personal email.

Choose **one** AI assistant to sign into if desired. Codex, Claude and Copilot are alternatives, not three required subscriptions. Flutter/Dart tools are independent of a paid AI plan.

## Verify local Firebase

1. Open `START-EMULATORS-WINDOWS.cmd` and keep that window running. Wait until the Firebase CLI reports the services are ready.
2. In another window open `RUN-EMULATOR-APP-WINDOWS.cmd`.
3. Confirm the Flutter screen reports verified local Auth, Firestore and Storage. Stopping one emulator and starting the app again must produce an error, **never cloud fallback**.

No Firebase account, `firebase login`, `flutterfire configure`, or production credentials are required.

## Your first small contribution

Follow **[FIRST-CONTRIBUTION.md](FIRST-CONTRIBUTION.md)** for a graphical Windows/Mac route: VS Code Source Control, one harmless edit, Flutter tests, a new branch, draft PR and GitHub `ci-gate`. Ask the maintainer for GitHub organization/repository write access before trying to publish a branch; without it, use the normal fork/PR route.

Use `VERIFY-DEVELOPER-WINDOWS.cmd` to diagnose missing tools, `ARCHITECTURE-WINDOWS.cmd` for the offline Architecture Atlas, and `REVIEW-WINDOWS.cmd` for **optional** non-author AI review.

Optional Android development requires Android Studio, SDK licenses and a configured emulator/device; Windows cannot run the iOS simulator.

If setup cannot finish, rerun it and use the wizard's redacted Ask AI report. Never share passwords or API keys or disable company security controls.

More detail: [developer setup](DEVELOPER-WINDOWS.md), [Firebase emulators](FIREBASE-EMULATOR.md), [troubleshooting](FIRST-RUN-TROUBLESHOOTING.md).
