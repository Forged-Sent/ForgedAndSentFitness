# Forge Mac — your terminal external brain

**Brain blank? Type `dash`. Remember the idea? Type `helpme <word>`.**

A general-purpose engineering shell with an optional Forged & Sent layer. It uses native **zsh**, Python's standard library, and local SQLite storage. The command tools work in iTerm2, Ghostty, Apple's Terminal, and a zsh terminal in VS Code.

## Recommended terminal

Start with **iTerm2 + zsh**. Its graphical profiles and settings suit a discoverable workspace. This package adds **Forge Graphite** and **Forge Ember** profiles using Menlo at 14 points. Select one from iTerm2's **Profiles** menu; your current default stays selected until you change it.

**Ghostty** is a good alternative if you prefer a leaner terminal with text configuration. Matching styling is included. You can change terminal apps later without replacing this shell.

The terminal app is the window. zsh is the shell. Forge supplies the commands and prompt. PowerShell, Oh My Zsh, a Nerd Font, and paid terminal software are not required.

## Install on your Mac

Requirements: macOS, zsh, and Python **3.10+**. Current iTerm2 releases require macOS 13+. Homebrew is convenient for optional tools, but is not required by the core. Normal Apple Silicon and Intel Homebrew paths are supported; check Homebrew's current OS/hardware support requirements if using an older Mac.

1. Open your existing project clone. For guided opt-in setup, use `START-MAC.command > 8 > 6`. For manual package installation:
2. Open Terminal or iTerm2:

   ```zsh
   cd /path/to/ForgedAndSentFitness/tooling/forge-shell/macos
   ```

3. To install the recommended tools, set up Homebrew from [brew.sh](https://brew.sh) if needed, then:

   ```zsh
   zsh install-tools.zsh
   zsh install-tools.zsh --apply
   ```

   The first command previews. The second installs Python, ripgrep, fzf, autosuggestions, syntax highlighting, and iTerm2.
   Choose Ghostty with `zsh install-tools.zsh --apply ghostty`, or tools only with `none`.
   Skip this step if Python is already available and you want the core's fallback menus/search.

4. Preview and apply the shell configuration:

   ```zsh
   zsh install.zsh
   zsh install.zsh --apply
   ```

   Ghostty: `zsh install.zsh --terminal ghostty --apply`.
   Terminal.app / VS Code without global terminal styling: `zsh install.zsh --terminal none --apply`.

5. Open a **new zsh tab**. In iTerm2 choose **Profiles → Forge Graphite**. Try:

   ```zsh
   ph
   dash
   helpme
   ```

The installer backs up changed files, appends a marked `.zshrc` loader, and copies the package into `~/.config/forge-mac`. It does not change your login shell or install tools automatically.

If you use `ZDOTDIR`, run the wrapper from that zsh session. For a symlinked `.zshrc`, use the manual loader instructions below.

## First useful commands

| When your brain says… | Type |
|---|---|
| “Give me choices.” | `dash` |
| “What was I doing?” | `session resume` |
| “Park this side quest.” | `todo 'Check reconnect after lunch'` |
| “I learned something.” | `note 'Fails only after sleep'` |
| “One small block.” | `focus 15` |
| “Take me there.” | `jump` |
| “Remember this folder.” | `mark work` |
| “Find that file.” | `ff workout` |
| “Find that text.” | `ftext 'TODO\|FIXME' .` |
| “What changed?” | `gst` |
| “Too much prompt.” | `forge prompt minimal` |
| “Leave a breadcrumb.” | `session save 'Next: test the retry path'` |

See [CHEAT-SHEET.md](CHEAT-SHEET.md) for every command.

## Included tools

- Bookmarks, fuzzy/recent navigation, workspace discovery, and scratch folders.
- Project-tagged tasks/notes, resumable checkpoints, and a quiet focus countdown.
- File/text search, JSON, clipboard, hashes, ZIP creation/extraction, and size reports.
- TCP ports, connection checks, SSH aliases, process search, USB/serial inspection, and Mac system information.
- Base64/URL conversions, Python environments, and loopback-only development servers.
- Git inspection, explicit staging, and confirmed commits. `gpsh` displays guidance without pushing.
- Rich/minimal prompts, cached background Git status, and steel/ember themes.
- Completion, prefix history, search, and optional autosuggestions/syntax highlighting.

Native tools such as `head`, `tail -f`, `grep`, `find`, `df`, `du`, and `kill` remain native. Captures stay local; they are not synced into Obsidian.

## Windows-to-Mac differences

| Windows | Mac |
|---|---|
| `done 1,3` | `tdone 1 3` — `done` is a zsh keyword |
| `hash file.zip` | `hashfile file.zip` — preserve the zsh builtin |
| `-WhatIf` | `--dry-run` on supported Git, Trash, and project actions |
| `todos -Project` / `-All` | `todos --project` / `--all` |
| `focus -Stop` | `focus --stop` |
| `fs run -Emulator` | `fs run --emulator` |
| `fs format -Apply` | `fs format --apply` |
| `forge config EnableFzf false` | `forge config fzf false` |
| `Alt+H` / `Alt+D` | `Ctrl+X H` / `Ctrl+X D` |
| PowerShell object pipelines | zsh text pipelines and Unix tools |

`forgeshell` is the canonical command. Shortcuts are added only when names are free. If you already use the Foundry `forge` executable, invoke `forgeshell config` for this package. If `ll` or `z` already exists, use `forgeshell ll` or `forgeshell jump`.

PowerShell-specific `err` and `refreshpath` are not copied; use the previous command's output and `pathcheck`.

## Keyboard and history

- **Tab:** completion.
- **Up / Down:** history matching the prefix you typed.
- **Ctrl+R:** history search.
- **Ctrl+X**, then **H:** insert `helpme `.
- **Ctrl+X**, then **D:** insert `dash`.
- fzf menus: type, arrows, Enter, Esc. Fallback menus: numbered choices.
- Optional autosuggestions: Right Arrow accepts the suggestion with its default bindings.

A leading space keeps a line out of saved zsh history. Forge also filters capture commands and common credential patterns. In-memory history and other programs can still retain input; use your secret manager for credentials.

## Make it yours

Choose individual commands from these examples:

```zsh
forge theme auto
forge theme normal
forge theme forged
forge prompt rich
forge prompt minimal
forge prompt off
forge config
forge config fzf false
forge config git_status false
forge config directory_history false
forge config plugins false
forge config workspace_roots '["/Users/YOURNAME/Developer","/Users/YOURNAME/Projects"]'
reloadforge
```

`prompt off` restores the earlier prompt. Theme/detail changes affect the next prompt. Open a fresh tab after disabling shortcuts, editing, or optional plugins.

Minimal mode shows the folder and timer without Git probes. Rich mode adds cached repository/branch details. Status refreshes in the background and appears on a later prompt; no fetch runs. The countdown updates at a new prompt and is not an OS alarm.

Settings: `theme`, `prompt`, `git_status`, `fzf`, `directory_history`, `editing`, `shortcuts`, `plugins`, `git_cache_seconds` (2–120), `default_project`, `workspace_roots`, `flutter_sdk`. They live in `~/.config/forge-mac/settings.json`; missing values use defaults.

## Optional Forged & Sent layer

Enter your **existing Mac checkout**:

```zsh
cd /path/to/ForgedAndSentFitness
forge project
fs doctor
```

Now the `fs` commands work from anywhere. Inside a recognized checkout/worktree, that checkout takes precedence over the remembered default. The general tools do not require this project.

Run/Firebase/iOS commands use the existing `tooling/macos` launchers. Follow the repository's setup instructions for Flutter, Xcode, Java, Firebase, and platform hosts. The audited launchers use `~/develop/flutter`; keep `flutter_sdk` aligned.

```zsh
# Terminal A
fs firebase
# Terminal B, once the emulators are ready
fs run --emulator
```

`fs ios` uses the iPhone simulator launcher. `fs preview` builds the separate HTML prototype. `fs format` checks files; `fs format --apply` writes on a feature branch. `fs branch` requires a clean tree and confirmation to switch an existing branch.

## Recovery and uninstall

Start an unconfigured shell if startup breaks:

```zsh
/bin/zsh -f
```

Preview targeted removal:

```zsh
zsh ~/.config/forge-mac/install.zsh --uninstall
```

Add `--apply` to remove the marked loader and unchanged managed styling. Notes, tasks, settings, package, and backups remain. Customized iTerm2 dynamic profile files remain.

To restore one exact installation transaction:

```zsh
zsh ~/.config/forge-mac/install.zsh --restore ~/.local/state/forge-mac/backups/BACKUP-ID
```

Add `--apply` after reviewing it. Exact restore refuses to overwrite files edited since that transaction. Use targeted uninstall when keeping later edits.

Manual setup for symlinked dotfiles:

1. Copy the package to `~/.config/forge-mac`.
2. Add this to your actual zsh configuration:

   ```zsh
   [[ -r "$HOME/.config/forge-mac/forge.zsh" ]] && source "$HOME/.config/forge-mac/forge.zsh"
   ```

3. iTerm2 styling: copy `themes/Forge-Mac.json` into `~/Library/Application Support/iTerm2/DynamicProfiles/`.
4. Ghostty styling: add `config-file = /Users/YOURNAME/.config/forge-mac/themes/graphite.ghostty` to the configuration opened by Ghostty.

Set `FORGE_DISABLE=1` in the parent environment to skip Forge at startup.

## Validation and limits

Python tests and a zsh smoke suite run in isolated fixtures. The repository CI runs both on macOS; consult the checks for the commit you are using.

**NOT VERIFIED on a physical Mac:** terminal rendering, clipboard, Finder Trash, hardware queries, Homebrew installation, optional plugin interaction, and live Flutter/Firebase/iOS launches.

After installation:

```zsh
ph
ptest
zsh -dfi ~/.config/forge-mac/tests/smoke.zsh
```

The smoke script uses a temporary home; it does not touch your real notes/settings and retains its fixture for inspection. For a visual check, try `dash`, Tab, and both prompt modes in a new terminal profile.

## Primary documentation

Reviewed 2026-11-12.

- [iTerm2 Dynamic Profiles](https://iterm2.com/documentation-dynamic-profiles.html)
- [iTerm2 downloads and macOS requirements](https://iterm2.com/downloads.html)
- [Ghostty configuration](https://ghostty.org/docs/config)
- [Ghostty themes](https://ghostty.org/docs/features/theme)
- [Zsh hooks](https://zsh.sourceforge.io/Doc/Release/User-Contributions.html)
- [Zsh history](https://zsh.sourceforge.io/Doc/Release/Options.html#History)
- [Homebrew requirements](https://docs.brew.sh/Installation)
- [Autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- [Syntax highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
