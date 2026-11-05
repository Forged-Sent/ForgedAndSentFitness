# Local Git checks

Contributor setup installs Gitleaks (WinGet ID Gitleaks.Gitleaks) and
sets the repository-only core.hooksPath to .githooks. The hooks block
main commits/pushes, reject staged files over 5 MB, run Gitleaks,
enforce Dart formatting, analyze Flutter code and run tests.

Hooks can be bypassed. They are convenience only; the GitHub main
ruleset and required CI gate provide authoritative protection.

The scripts use Git for Windows' bundled sh. If installed in an
extracted ZIP, hooks do not activate because there is no .git folder.
Clone via the guided wizard before making contributions.
