# Optional engineering shell — Windows and Mac

> [!tip] One command when your brain goes blank
> After installation, open a new terminal tab and type **`dash`**.
> The shell gives you menus, bookmarks, local tasks/notes, a focus timer, file search and engineering utilities for **any project**. `fs` adds optional Forged & Sent shortcuts.

## Choose during setup

Windows and Mac Preview/Contributor setup ask:

**“Would you like the ADHD-friendly engineering shell? [y/N]”**

Press **Enter to skip**. Choose **yes** to install it after the main setup succeeds. Colors and extra packages are separate choices, also off by default. Skipping does not affect Flutter or contribution tools. CI and redirected input skip this offer.

Already set up? Open **START-WINDOWS.cmd** or **START-MAC.command**, then **8 → 6**. Or double-click **Optional engineering shell** under `launchers/windows/more` or `launchers/mac/more`.

| Your computer | Personal shell | Optional appearance | Optional tools |
|---|---|---|---|
| Windows | PowerShell 7; the launcher uses the project's PowerShell bootstrap | Windows Terminal Graphite/Ember and Forge Command Center; optionally VS Code terminal colors/font | User-scoped ripgrep and fzf through WinGet |
| Mac | Native zsh + Python 3.10+; setup installs Python if needed | iTerm2 Graphite/Ember profiles, or Ghostty colors; keeping current colors works too | Homebrew ripgrep, fzf, suggestions/highlighting and the selected terminal app |

**Mac choice:** iTerm2 + zsh is the suggested starting point for graphical profiles. Ghostty is included if you prefer text configuration. Apple's Terminal and VS Code's zsh terminal can use the core commands without changing apps. Selecting colors only writes their configuration; select extra tools to install a missing terminal app too.

## Your command sheets

- [Windows — all 47 commands, project actions and shortcuts](shell/WINDOWS-COMMANDS.md)
- [Mac — all 60 commands, project actions and shortcuts](shell/MAC-COMMANDS.md)

These are project-vault reference notes. Your captured tasks and notes stay in your personal home folder.

| Need | Both systems | Difference |
|---|---|---|
| Remember what you were doing | `session resume` | Save with `session save 'Next: test retry'` |
| Park a side quest | `todo 'Check this later'` | Complete: Windows `done 1`; Mac `tdone 1` |
| Work for a small block | `focus 15` | Stop: Windows `focus -Stop`; Mac `focus --stop` |
| Go somewhere | `jump`, `mark work` | Works outside this project too |
| Find source text | `ftext 'TODO' .` | ripgrep is optional |
| Return to this checkout | `fs go` | Run `forge project` inside another checkout to remember it |
| Lower visual noise | `forge prompt minimal` | Mac also supports `forge prompt off` |

On Mac, if a name such as `forge` or `z` already belongs to another tool, it is preserved. Use `forgeshell config` or `forgeshell jump` instead.

## What installation changes

The repository carries both source packages under `tooling/forge-shell/windows` and `tooling/forge-shell/macos`. Installers copy them to your home folder, so the shell does not depend on keeping a particular checkout.

| Item | Windows | Mac |
|---|---|---|
| Package and settings | `$HOME\.config\powershell`; `config/settings.json` | `~/.config/forge-mac`; `settings.json` |
| Startup loader | Actual `$PROFILE.CurrentUserAllHosts` for PowerShell 7, including redirected Documents | `~/.zshrc`, or `$ZDOTDIR/.zshrc` when exported |
| Personal captures | Package `data/*.json` | `~/.local/state/forge-mac/brain.sqlite3` |
| Backups | Package `backups/` | `~/.local/state/forge-mac/backups/` |

Existing profile content remains around a marked loader. Reinstalling updates code and preserves existing preferences, captures and bookmarks. A fresh install remembers the checkout you used for setup; the active Forged & Sent worktree takes precedence when you are inside one. No branch changes or personal data import happen at startup.

Styling has its own backups. Windows preserves terminal defaults and VS Code editor styling. iTerm2 adds named profiles; select **Profiles → Forge Graphite** to use one. Ghostty adds a marked theme include. Homebrew/WinGet packages are managed separately.

## Manual installation

Run from the repository root. These commands explicitly opt in to the **core shell**, with no extra styling or optional tools:

```powershell
# Windows: PowerShell 7.6+
.\tooling\windows\forge-shell.ps1 -Apply -WhatIf
.\tooling\windows\forge-shell.ps1 -Apply
```

```bash
# Mac: run interactively for the offer, or explicitly install core only.
bash tooling/macos/forge-shell.sh --offer
bash tooling/macos/forge-shell.sh --apply
```

For custom `ZDOTDIR`, run `zsh tooling/forge-shell/macos/install.zsh --terminal none --apply --project-root "$PWD"` from that zsh session. For a symlinked `.zshrc`, follow the [Mac package manual-loader instructions](../../tooling/forge-shell/macos/README.md#recovery-and-uninstall).

Use the standalone launchers to add the shell after a failed or skipped setup. The base Windows `setup.ps1` and Mac `setup.sh --ci` remain suitable for unattended preview checks.

## Undo or troubleshoot

Start a clean shell: Windows `pwsh -NoProfile`; Mac `/bin/zsh -f`.

```powershell
# Preview removal; omit -WhatIf to remove the managed loader/styling.
& "$HOME\.config\powershell\Uninstall.ps1" -WhatIf
```

```zsh
# Preview removal; add --apply to remove the managed loader/styling.
zsh ~/.config/forge-mac/install.zsh --uninstall
```

Data and backups remain. Uninstall does not remove packages installed by WinGet or Homebrew. Exact backup restoration refuses to overwrite later edits; see the [Windows recovery guide](../../tooling/forge-shell/windows/RECOVERY.md) or [Mac recovery guide](../../tooling/forge-shell/macos/README.md#recovery-and-uninstall).

Type `ph` for health checks and `ptest` for isolated command tests. Mac terminal rendering, clipboard, Finder Trash, hardware queries, optional plugins and live Flutter/Firebase/iOS launch behavior need a hands-on Mac check; automated shell tests do not establish those.
