# Bundled personal engineering shells

- `windows/`: Forge Shell 2.0 for PowerShell 7.
- `macos/`: Forge Mac 1.0 for native zsh and Python's standard library.

These are versioned source copies of the personal-shell packages developed for this project. Machine audits, personal settings, notes, history, backup snapshots and previous validation results are excluded. New users receive neutral defaults; the repository installers remember their own checkout on first installation.

Use [the optional setup guide](../../docs/development/SHELL-SETUP.md) instead of sourcing repository files into a profile. Windows `tooling/windows/forge-shell.ps1` and Mac `tooling/macos/forge-shell.sh` handle the opt-in step and user installation.

When changing commands, update the matching command sheet under `docs/development/shell/`. For Windows source edits, run `scripts/Build-Module.ps1` to refresh `Forge.Runtime.psm1`. Run package tests plus onboarding tests; the relevant platform CI lane also tests the bundled shell.
