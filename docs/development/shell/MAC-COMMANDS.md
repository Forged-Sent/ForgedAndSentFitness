---
title: Forge Mac - ADHD Command Cheat Sheet
aliases: [Mac Terminal External Brain, Forge zsh Commands]
tags: [adhd, macos, terminal, engineering, cheat-sheet]
profile_version: 1.0.0
updated: 2026-11-12
---

# 🧠 Forge Mac — ADHD Command Cheat Sheet

> [!tip] Brain buffering?
> **`dash`** gives you choices. **`helpme <word>`** finds the command.
> One useful action is enough to get moving.

**Native zsh. General engineering tools. Optional Forged & Sent layer.**
Use iTerm2, Ghostty, Terminal.app, or VS Code's zsh terminal.

## Pick your current brain state

| Right now… | Type |
|---|---|
| “Where was I?” | `session resume` |
| “Park the side quest.” | `todo 'Check this later'` |
| “Remember the discovery.” | `note 'Only fails after sleep'` |
| “Give me 15 minutes.” | `focus 15` |
| “Take me somewhere.” | `jump` |
| “Find a file.” | `ff workout` |
| “What changed?” | `gst` |
| “Something is odd.” | `ph` |

## Start small and leave a breadcrumb

```zsh
todos --project
focus 15
```

Before switching away:

```zsh
session save 'Next: test the retry with one pending item'
```

Later, `session resume` returns to the folder and shows the saved next action.
It does not switch branches. Tasks/notes/checkpoints stay in Forge's local database, separate from Obsidian.

## Every command


### Discover

| Command | What it does | Example |
|---|---|---|
| `dash` | Choose a task from the command center | `dash` |
| `helpme` | Find commands by intent | `helpme files` |
| `keys` | Show keyboard shortcuts | `keys` |

### Settings

| Command | What it does | Example |
|---|---|---|
| `forge` | Settings, theme, prompt, reload and diagnostics | `forge config` |
| `ph` | Check installed tools and local state | `ph` |
| `ptest` | Run the isolated package tests | `ptest` |
| `reloadforge` | Reload this shell configuration | `reloadforge` |

### Folders

| Command | What it does | Example |
|---|---|---|
| `jump` | Pick a bookmark or recent folder | `jump` |
| `z` | Short form of jump | `z mobile` |
| `qa` | Managed quick folders | `qa downloads` |
| `mark` | Save a named folder | `mark vault ~/Documents/Vault` |
| `marks` | List bookmarks | `marks` |
| `unmark` | Remove a saved bookmark | `unmark old` |
| `projects` | Find a local repository | `projects --list` |
| `back` | Previous folder in this shell | `back` |
| `up` | Go up one or more levels | `up 2` |
| `mkcd` | Create a folder and enter it | `mkcd 'scratch idea'` |

### Files

| Command | What it does | Example |
|---|---|---|
| `ll` | Readable folder listing | `ll` |
| `ff` | Find filenames | `ff '*.swift' .` |
| `ftext` | Search text using a regular expression | `ftext 'TODO\|FIXME' .` |
| `hashfile` | SHA-256 of a file | `hashfile file.zip` |
| `comparefile` | Compare two files by SHA-256 | `comparefile a.json b.json` |
| `tempwork` | Create and enter a persistent scratch folder | `tempwork` |
| `trash` | Move to Finder Trash after confirmation | `trash old.txt --dry-run` |
| `bigfiles` | Largest files below a folder | `bigfiles . 15` |
| `dirsize` | Size of each immediate child folder | `dirsize .` |
| `zipto` | Create a new ZIP without overwriting | `zipto backup.zip src README.md` |
| `unzipto` | Extract a ZIP into a new folder safely | `unzipto backup.zip restored` |

### Capture

| Command | What it does | Example |
|---|---|---|
| `todo` | Capture a local task | `todo 'Check reconnect'` |
| `todos` | Show tasks | `todos --project` |
| `tdone` | Complete task IDs; done is a zsh keyword | `tdone 1 3` |
| `note` | Save an engineering observation | `note 'Fails after sleep'` |
| `notes` | Search saved notes | `notes reconnect` |
| `recent-notes` | Show the newest notes | `recent-notes 5` |

### Focus

| Command | What it does | Example |
|---|---|---|
| `session` | Save or resume the next useful action | `session save 'Next: test retry'` |
| `focus` | Quiet in-shell countdown | `focus 15` |
| `recent-command` | Recall commands in this shell | `recent-command flutter` |

### System

| Command | What it does | Example |
|---|---|---|
| `port` | Who is listening on this TCP port? | `port 8080` |
| `netcheck` | Test a TCP endpoint | `netcheck localhost 8080` |
| `pathcheck` | Show PATH order and missing/duplicate entries | `pathcheck` |
| `envshow` | List environment names, hiding their values | `envshow flutter` |
| `sshgo` | Pick an SSH host or connect by name | `sshgo` |
| `sysinfo` | Show Mac hardware and operating system | `sysinfo` |
| `serialports` | List serial device paths | `serialports` |
| `usbinfo` | Show connected USB devices | `usbinfo` |
| `procfind` | Find running processes | `procfind python` |

### Data

| Command | What it does | Example |
|---|---|---|
| `jview` | Format JSON from a file or standard input | `jview config.json` |
| `cliptools` | Copy path, read, or set clipboard text | `cliptools path` |
| `b64` | Encode UTF-8 text as Base64 | `b64 'hello'` |
| `unb64` | Decode Base64 as UTF-8 | `unb64 aGVsbG8=` |
| `urlencode` | Encode a URL component | `urlencode 'a b/c'` |
| `urldecode` | Decode a URL component | `urldecode 'a%20b'` |
| `uuidgenx` | Generate a UUID | `uuidgenx` |

### Python

| Command | What it does | Example |
|---|---|---|
| `serve` | Serve a folder on loopback only | `serve 8000 .` |
| `venv` | Create and activate a Python virtual environment | `venv .venv` |

### Git

| Command | What it does | Example |
|---|---|---|
| `gst` | Git status in this repository | `gst` |
| `gad` | Stage explicit paths on a feature branch | `gad src/example.py --dry-run` |
| `gmsg` | Commit staged changes with confirmation | `gmsg 'fix: retry'` |
| `gpsh` | Show guidance without pushing | `gpsh` |

### Forged & Sent

| Command | What it does | Example |
|---|---|---|
| `fs` | Optional project workflows | `fs help` |

**60 catalog commands.** All shortcuts also work as `forgeshell COMMAND`.

Existing aliases/executables are preserved. If a short name is already taken, use the `forgeshell` form.

## Capture options

| Command | Meaning |
|---|---|
| `todos` | Open tasks across projects |
| `todos --project` | Only this project |
| `todos --all` | Include completed tasks |
| `tdone 1 3` | Complete these task IDs |
| `notes retry --project` | Search this project's notes |
| `recent-notes 5` | Five newest notes |
| `session` / `session summary` | Current folder/project and open task count |
| `session save 'Next: …'` | Save a checkpoint |
| `session list` | List checkpoints |
| `session resume retry` | Filter the checkpoint picker |
| `focus` / `focus 15` | 25 minutes by default, or a chosen 1–180 minutes |
| `focus --stop` | Clear the countdown |

The focus timer is in this shell and updates at the next prompt; it is not an OS notification.
Recent-command recall is limited to this shell's in-memory history and does not replay anything.

## Navigation options

```zsh
mark mobile
mark vault ~/Documents/MyVault
marks
jump mobile
jump downloads
projects --list
up 2
mkcd 'scratch idea'
back
```

`jump`, `z`, and `qa` share the same managed bookmarks.
Built-ins: home, desktop, documents, downloads, and fs once a default project is set.
`unmark name` confirms before removing your saved bookmark.

## Files and data

```zsh
ff '*.swift' .
ftext 'TODO|FIXME' .
jview config.json --minify
printf '{"ready":true}' | jview
cliptools path
cliptools get
cliptools set 'copied text'
comparefile before.json after.json
zipto backup.zip src README.md
unzipto backup.zip new-folder
trash old.txt --dry-run
```

ZIP extraction uses a new destination and rejects traversal paths and symlinks.
Scratch folders persist. `trash path` uses Finder Trash and asks first.
Native log helpers remain available: `head file.log` and `tail -f file.log`.

## Python work

```zsh
venv .venv
python --version
deactivate
serve 8000 .
```

`venv` creates or activates that environment. `serve` binds only to `127.0.0.1`; Ctrl+C stops it.

## Optional Forged and Sent

First enter the existing Mac checkout and run `forge project`.
The current recognized checkout/worktree wins over that default.

| Command | Job |
|---|---|
| `fs` / `fs help` / `fs menu` | List the project actions |
| `fs go` | Enter the checkout |
| `fs mobile` | Enter mobile |
| `fs status` | Branch and changes |
| `fs doctor` | Checkout, SDK/CI, platform host, and emulator port checks |
| `fs run` | Repository Chrome preview launcher |
| `fs run --emulator` | Chrome against local demo Firebase |
| `fs ios` | Repository iPhone simulator launcher |
| `fs firebase` | Repository local demo Firebase launcher |
| `fs test` | Flutter tests |
| `fs analyze` | Flutter analysis |
| `fs format` | Check Dart formatting without writing |
| `fs format --apply` | Apply formatting on a feature branch |
| `fs preview` | Build and open the HTML prototype |
| `fs docs` / `fs docs emulator` | Pick docs or search their text |
| `fs architecture` | Generate and open the Architecture Atlas |
| `fs open` | Open checkout in VS Code |
| `fs diff` | Review unstaged changes |
| `fs branch` / `fs branch feature/name` | Confirm a clean-tree switch to an existing branch |
| `fs pr` | GitHub pull requests |
| `fs ci` | GitHub Actions runs |

Use `--dry-run` to preview launch/write actions, for example `fs run --dry-run`.
The repo's Mac setup must already have installed its prerequisites. The audited launchers use `~/develop/flutter`.
Start `fs firebase` in one terminal; wait for readiness, then `fs run --emulator` in another.

## Git

```zsh
gst
git diff --cached
gad src/example.py --dry-run
gmsg 'fix: explain the change' --dry-run
gpsh
```

Remove `--dry-run` to stage/commit. Staging uses explicit paths; commits ask first.
Protected branches and detached HEAD are refused. `gpsh` only displays guidance.

## Keyboard

| Key | Action |
|---|---|
| Tab | Completion |
| Up / Down | Prefix history |
| Ctrl+R | History search |
| Ctrl+X, then H | Insert helpme |
| Ctrl+X, then D | Insert dash |
| Picker type/arrows/Enter/Esc | Filter/select/choose/cancel with fzf |

Without fzf, pick a numbered choice. Optional autosuggestions and syntax highlighting load when installed.
A leading space skips saved history; filtering is not a substitute for a secret manager.

## Quieter or brighter

```zsh
forge theme auto
forge theme normal
forge theme forged
forge prompt minimal
forge prompt rich
forge prompt off
forge config
forge context
reloadforge
```

Choose one theme/mode. `prompt off` restores your earlier prompt.
Rich mode uses cached background Git information. Minimal mode skips Git probes.
`~` = unstaged tracked entries, `+` = staged entries, `?` = untracked entries.
“checking” means status is not ready. Status never fetches remote changes.

> [!example]- Settings you can change
> `forge config fzf false`
>
> `forge config git_status false`
>
> `forge config directory_history false`
>
> `forge config plugins false`
>
> `forge config editing false`
>
> `forge config shortcuts false`
>
> `forge config git_cache_seconds 10`
>
> `forge config workspace_roots '["/Users/YOURNAME/Developer"]'`
>
> `forge config flutter_sdk '/Users/YOURNAME/develop/flutter'`
>
> `forge project` remembers the current project. Open a fresh tab after disabling plugins/editing/shortcuts.

## Recovery

`ph` checks the shell. `ptest` runs isolated tests.

If startup breaks: `/bin/zsh -f`.

Preview uninstall:

```zsh
zsh ~/.config/forge-mac/install.zsh --uninstall
```

Add `--apply` to remove the managed loader/styling while keeping your data.

Package/settings: `~/.config/forge-mac`.
Tasks, notes, bookmarks, visits, checkpoints: `~/.local/state/forge-mac/brain.sqlite3`.
Backups: `~/.local/state/forge-mac/backups`.

## Windows muscle memory

- `done` becomes **`tdone`** because done is zsh syntax.
- `hash` becomes **`hashfile`** to keep the native builtin.
- `-WhatIf` becomes **`--dry-run`** on supported actions.
- `-Project` / `-All` become **`--project` / `--all`**.
- `-Emulator` / `-Apply` become **`--emulator` / `--apply`**.

The Python and zsh tests were run away from a physical Mac. Mac rendering, clipboard, Finder Trash,
hardware queries, optional plugins, and live project launches still need verification on your Mac.
See README.md in the setup package and the repository CI checks for the commit you are using.

[Setup and uninstall](../SHELL-SETUP.md). Source: `tooling/forge-shell/macos` in this repository.
