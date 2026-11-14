# Your first Forged & Sent contribution

**One friendly path, on Windows or Mac.** You do not need to know Flutter, Firebase, Git commands, or MCPs in advance. This is a small practice change, not a production feature.

## What you need

- The public repository cloned with Git (see [Windows](WINDOWS-QUICKSTART.md) or [Mac](MACBOOK-QUICKSTART.md)).
- Contributor setup completed, with the project opened in Visual Studio Code.
- A free GitHub account. If you plan to push to the shared `Forged-Sent` repository, ask the maintainer to invite you as a collaborator. Otherwise use a fork and open a PR back to the shared repo.
- Optional: any AI assistants you already use: Codex, Claude Code, GitHub Copilot or Antigravity CLI (Google Gemini). Pick one, several or none.
- No Firebase cloud account or paid AI plan is required for a first practice edit.

## Follow this once

1. **Open the correct project.** In VS Code select **File > Open Folder** and choose `ForgedAndSentFitness`. Open **Source Control** (branch icon). Confirm there are no unexpected unsaved edits.
2. **Create your own branch before editing.** Click the current branch name in VS Code's bottom bar (normally `main`). Choose **Create new branch...** and name it `feature/my-first-change`. Do not edit or commit directly on `main`.
3. **Choose your assistant, if desired.** Open the assistant extension you already use. Sign in through its official account flow. You can also complete the next step by hand.
4. **Make a tiny change.** Open [`docs/development/PRACTICE-GUESTBOOK.md`](PRACTICE-GUESTBOOK.md) and add one line at the end of its list, for example `- Your first name: one sentence about why you are here.` Save the file. Or give your assistant this prompt:

   > In `docs/development/PRACTICE-GUESTBOOK.md`, add one line at the end of the "Sign the guestbook" list: "- <my first name>: <one sentence>". Do not change any other line or file. Show me the diff before saving.

   This practice change is a page, not app code, on purpose: it cannot break the app, and its pull request can go fully green. App changes come later and have extra rules (for example, they must update their row on the [work board](../knowledge/WORK.md)).

5. **Review before saving.** In VS Code, open **Source Control**. Click the changed file and compare the red/green lines. Make sure only your one new line changed. Undo any unrelated edits.
6. **Check that your computer can build and test the app.** Your change did not touch the app, but every real change runs these two commands first, so practise them now. Open VS Code's terminal from the **Terminal** menu, then:

```sh
cd mobile
flutter analyze
flutter test
```

   Both commands should finish without errors. If `flutter` is missing, rerun Contributor diagnostics. On Mac, reopen Terminal after enabling Flutter PATH. Then go back to the main folder with `cd ..`. You may also launch the app with `launchers/windows/2 - Run the app.cmd` (Windows) or `launchers/mac/2 - Run the app.command` (Mac).
7. **Set Git identity, once.** If your first commit says "Please tell me who you are", configure a name and email using the guided wizard or [Git basics](GIT-101.md). Your GitHub noreply email keeps your personal email off public commits.
8. **Commit your change.** Back in Source Control, enter `Practice: sign the guestbook` and select **Commit**. If you see a Gitleaks or Dart formatting warning, follow its fix instructions; don't bypass hooks.
9. **Publish safely.** Select **Publish Branch**. The first time, VS Code asks you to **sign in to GitHub** in your browser; approve it. If you aren't a project collaborator yet, VS Code offers **Create Fork**: choose it, and your branch is published to your own copy of the project. Do not force-push.
10. **Open a Draft PR.** Use the **GitHub Pull Requests** VS Code extension (or GitHub's website). Set the target to `Forged-Sent/ForgedAndSentFitness:main` (also when you published to a fork). Choose **Draft** and explain this is a practice change.
11. **Watch CI.** In the PR, open **Checks** and find required `ci-gate`. Green means automated checks passed; red means click the failing job and inspect the error. For the guestbook change, `ci-gate` should go green within a few minutes; the app's Flutter, Windows and Mac jobs are skipped because no app file changed. If a PR from a fork shows checks **waiting for approval**, that's a GitHub safety step for new contributors: the maintainer clicks **Approve and run** once. Never bypass required CI.
12. **You're finished for today.** Leave the PR as a Draft. A maintainer makes the merge decision; agents must not merge automatically. On your next day, open the same clone and branch, check Git status, and keep working. No reinstall needed.

## What "ready" means

You can launch Flutter in Chrome, see the local demo Firebase emulators verified on the app's Build status page, run analysis and tests, use any AI assistants you picked, inspect Source Control, and open a draft PR. A configured MCP server isn't "working" until it connects and lists tools.

For an optional Git-backed knowledge workspace, open [the knowledge home](../HOME.md) in VS Code, GitHub or Obsidian (vault root: docs/). Double-click `launchers/windows/more/Knowledge workspace.cmd` or `launchers/mac/more/Knowledge workspace.command` to view the live HTML prototype and regenerated Atlas on loopback. This is not needed for your first Flutter contribution. See [knowledge workspace safety and acceptance](KNOWLEDGE-WORKSPACE.md).

For a more detailed source map, double-click `launchers/windows/more/Architecture Atlas.cmd` or `launchers/mac/more/Architecture Atlas.command`. For local Firebase, follow [Firebase emulator testing](FIREBASE-EMULATOR.md). Neither requires a cloud account.

If the Git command reports divergence, if a setup step asks for unexpected credentials, or if a tool wants to push to `main`, stop and ask for help rather than resetting anything.
