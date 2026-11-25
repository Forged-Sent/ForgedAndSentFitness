# Local Git checks

Contributor setup installs Gitleaks (WinGet ID Gitleaks.Gitleaks) and
sets the repository-only core.hooksPath to .githooks. The hooks block
main commits/pushes, reject staged files over 5 MB, run Gitleaks,
enforce Dart formatting, analyze Flutter code and run tests.

Hooks can be bypassed. They are convenience only; the GitHub main
ruleset and required CI gate provide authoritative protection.

## Pushing from a worktree

The pre-push hook works the same from the first clone and from a linked
worktree (`git worktree add`). Each checkout runs the copy of the hook
on its own branch, so a branch cut before this fix keeps the older hook
until it merges `main`.

In a linked worktree git hands a hook the variable `GIT_DIR`. Flutter
reads its own version by running git inside its SDK folder, and with
`GIT_DIR` inherited it read this repository instead: it reported
"The current Flutter SDK version is 0.0.0-unknown", could not resolve
packages, and the push failed before any check ran. The hook now clears
git's repository variables for the two Flutter commands only.

`tooling/onboarding/test_git_hooks.py` runs the hook through a real
`git push` to a temporary local repository, from both kinds of checkout,
with a stand-in for Flutter. It checks that a push goes through when
analyze and the tests pass, and is refused when either fails.

The scripts use Git for Windows' bundled sh. If installed in an
extracted ZIP, hooks do not activate because there is no .git folder.
Clone via the guided wizard before making contributions.
