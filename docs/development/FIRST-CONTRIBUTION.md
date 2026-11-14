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
4. **Make a tiny change.** Give your assistant this prompt:

   > In `mobile/lib/src/app/forged_sent_app.dart`, on the Build status page, change only the sentence "Flutter foundation is ready for the first devotional workout." to "Practice edit: my first change." Do not change any other text, behavior, tests, access rules or files. Explain what changed and show me the diff before saving.

   To see that sentence in the running app: open **Settings** (the round person button at the top right of Today), scroll to **This build** and tap **Build status**. Leave the headline "Faith. Training. Brotherhood." alone: a test checks it word for word, so changing it makes `flutter test` fail.

5. **Review before saving.** In VS Code, open **Source Control**. Click the changed file and compare the red/green lines. Make sure only that one sentence changed. Undo any unrelated edits.
6. **Check the Flutter app.** Open VS Code's terminal from the **Terminal** menu, then:

```sh
cd mobile
flutter analyze
flutter test
```

   Both commands should finish without errors. If `flutter` is missing, rerun Contributor diagnostics. On Mac, reopen Terminal after enabling Flutter PATH. You may also launch the app with `launchers/windows/2 - Run the app.cmd` (Windows) or `launchers/mac/2 - Run the app.command` (Mac).
7. **Set Git identity, once.** If your first commit says "Please tell me who you are", configure a name and email using the guided wizard or [Git basics](GIT-101.md). Your GitHub noreply email keeps your personal email off public commits.
8. **Commit your change.** Back in Source Control, enter `Practice: my first change` and select **Commit**. If you see a Gitleaks or Dart formatting warning, follow its fix instructions; don't bypass hooks.
9. **Publish safely.** Select **Publish Branch**. The first time, VS Code asks you to **sign in to GitHub** in your browser; approve it. If you aren't a project collaborator yet, VS Code offers **Create Fork**: choose it, and your branch is published to your own copy of the project. Do not force-push.
10. **Open a Draft PR.** Use the **GitHub Pull Requests** VS Code extension (or GitHub's website). Set the target to `Forged-Sent/ForgedAndSentFitness:main` (also when you published to a fork). Choose **Draft** and explain this is a practice change.
11. **Watch CI.** In the PR, open **Checks** and find required `ci-gate`. Green means automated checks passed; red means click the failing job and inspect the error. If a PR from a fork shows checks **waiting for approval**, that's a GitHub safety step for new contributors: the maintainer clicks **Approve and run** once. Never bypass required CI.

    **Expected for this practice change:** the `policy` job, and so `ci-gate`, is red with a message like *"forged_sent_app.dart changed but docs/knowledge/WORK.md did not"*. Real app changes must update their row on the work board in the same pull request; a practice edit has no row. Every other job should be green. Because the change touches `mobile/`, the optional **Claude Code Review** check also runs on it (from a fork it cannot sign in, so it may show as failed). It is not required; ignore it for a practice PR.
12. **You're finished for today.** Leave the PR as a Draft. A maintainer makes the merge decision; agents must not merge automatically. On your next day, open the same clone and branch, check Git status, and keep working. No reinstall needed.

## What "ready" means

You can launch Flutter in Chrome, see the local demo Firebase emulators verified on the app's Build status page, run analysis and tests, use any AI assistants you picked, inspect Source Control, and open a draft PR. A configured MCP server isn't "working" until it connects and lists tools.

For an optional Git-backed knowledge workspace, open [the knowledge home](../HOME.md) in VS Code, GitHub or Obsidian (vault root: docs/). Double-click `launchers/windows/more/Knowledge workspace.cmd` or `launchers/mac/more/Knowledge workspace.command` to view the live HTML prototype and regenerated Atlas on loopback. This is not needed for your first Flutter contribution. See [knowledge workspace safety and acceptance](KNOWLEDGE-WORKSPACE.md).

For a more detailed source map, double-click `launchers/windows/more/Architecture Atlas.cmd` or `launchers/mac/more/Architecture Atlas.command`. For local Firebase, follow [Firebase emulator testing](FIREBASE-EMULATOR.md). Neither requires a cloud account.

If the Git command reports divergence, if a setup step asks for unexpected credentials, or if a tool wants to push to `main`, stop and ask for help rather than resetting anything.
