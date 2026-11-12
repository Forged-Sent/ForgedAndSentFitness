---
title: Forge Shell 2.0 - ADHD Command Cheat Sheet
aliases:
  - Forge PowerShell Cheat Sheet
  - ADHD PowerShell Commands
  - Forge External Brain
tags:
  - powershell
  - engineering
  - adhd
  - cheat-sheet
  - forged-and-sent
profile_version: 2.0.0
updated: 2026-11-12
status: current
---

# 🧠 Forge Shell 2.0 — ADHD Command Cheat Sheet

> [!tip] Brain buffering? Start here.
> Type **`dash`**. Pick what you want to do.
> Remember the idea but not the command? Try **`helpme git`**, **`helpme flutter`**, or **`helpme note`**.
> You only need the next useful command.

**For the optional Forge Shell in PowerShell 7.** All **47 exported commands**, every `fs` / `forge` action, keyboard shortcuts, and maintenance scripts. Examples use sample text and paths; replace those with yours.

## Pick your current brain state

| Right now… | Type this | You get |
|---|---|---|
| 🧭 “Where was I?” | `session resume` | Saved folder + next action |
| 🔥 “Back to Forged & Sent.” | `fs go` | The current or remembered checkout |
| 👀 “What changed?” | `fs status` | Branch + changed files |
| 📝 “Side quest! Save it.” | `todo 'Check reconnect later'` | A task you can stop holding in your head |
| ⏱️ “One small work block.” | `focus 15` | A quiet countdown in your prompt |
| 🔎 “Where is that thing?” | `ff workout` | Matching filenames |
| 🩺 “Something is weird.” | `ph` | Shell health and tool availability |
| 🧘 “Too much on screen.” | `forge prompt minimal` | A quieter prompt |

**Jump to:** [[#Learn these 15 first|15 starters]] · [[#Find a command|Help]] · [[#Forged and Sent|Project]] · [[#Move around|Folders]] · [[#Find files and text|Search]] · [[#Capture and resume|External brain]] · [[#Git without surprises|Git]] · [[#Engineering tools|Tools]] · [[#Keyboard shortcuts|Keys]] · [[#Make it feel right|Settings]] · [[#When something breaks|Recovery]] · [[#Complete command index|All 47]]

## Learn these 15 first

> [!example]- Open when you want the starter set
> | Command | Job |
> |---|---|
> | `dash` | Choose from the command center |
> | `helpme flutter` | Find help by topic |
> | `fs go` | Return to the project |
> | `fs mobile` | Enter the Flutter app |
> | `fs status` | See branch and changes |
> | `fs run` | Launch the Chrome app preview |
> | `fs test` | Run Flutter tests |
> | `fs analyze` | Run Flutter analysis |
> | `jump` | Pick a bookmark or recent folder |
> | `mark mobile` | Remember this folder |
> | `ff workout` | Find a file |
> | `ftext 'FS_ENV' mobile` | Find text in source |
> | `todo 'Check emulator reconnect'` | Park a task |
> | `note 'Reproduce after a cold restart'` | Capture an observation |
> | `ph` | Check the shell |

## Tiny workflows

### Start with one next action

```powershell
fs go
fs status
todos -Project
focus 15
```

If you saved a checkpoint last time, start with `session resume` instead. Pick **one** task.

### Leave a breadcrumb before switching away

```powershell
session save 'Next: reproduce reconnect with one pending workout'
```

Later:

```powershell
session resume
```

The checkpoint remembers the folder, branch label, time, and your next action. Resuming returns to the **folder**; check `fs status` before continuing on a branch.

### Check the Flutter app

```powershell
fs doctor
fs test
fs analyze
fs format
```

`fs format` checks formatting without rewriting files. Exit code 1 means formatting changes are needed. To write them on a feature branch, preview with `fs format -Apply -WhatIf`, then run `fs format -Apply`.

### Run with local Firebase

In terminal A:

```powershell
fs firebase
```

Wait for the emulator launcher to report readiness. In terminal B:

```powershell
fs run -Emulator
```

For the regular Chrome preview, use `fs run`. `fs doctor` helps diagnose Java, SDK, web-host, and port prerequisites.

## Find a command

| Command | What it does |
|---|---|
| `dash` | Open the searchable command center |
| `dash 'Notes and TODOs'` | Jump into a category |
| `helpme` | Show the 15 starting commands |
| `helpme git` | Search command names, descriptions, categories, and examples |
| `helpme -Raw` | Return the whole catalog as PowerShell objects |
| `helpme flutter -Raw` | Return just matching catalog entries |
| `keys` | Show shortcuts and the active PSReadLine bindings |
| `fs` or `fs menu` | Open the Forged & Sent command menu |
| `fs help` | Show project command help |
| `forge` or `forge help` | Show settings help |
| `forge docs` | Open the installed full README |

Dashboard categories: **Projects**, **Git**, **Forged & Sent**, **Flutter/Firebase**, **Files and navigation**, **Notes and TODOs**, **System tools**, **Recent activity**, **Settings and themes**, **Help and keyboard shortcuts**.

In a picker: **type → arrows → Enter**. **Esc** cancels. Some choices ask for text or confirmation before acting.

## Forged and Sent

> [!info] Which checkout?
> Inside a recognized Forged & Sent checkout, `fs` uses that checkout, including a linked worktree. Outside it, `fs` uses your remembered default.
> Enter your preferred checkout and run `forge project` to change the default. Run `forge context` to see what was detected.

### Navigate and inspect

| Command | What it does |
|---|---|
| `fs go` | Enter the project root |
| `fs mobile` | Enter its `mobile` folder |
| `fs status` | Show branch + short Git status |
| `fs doctor` | Check configured Flutter versus CI/PATH, tools, Java 21, emulator ports, and web host |
| `fs open` | Open this checkout in a new VS Code window |
| `fs docs` | Pick a project Markdown document |
| `fs docs emulator` | Search project documentation text |
| `fs architecture` | Open the Architecture Atlas; run the existing launcher if it needs generating |
| `fs preview` | Regenerate and open the HTML behavioral prototype |

### Run and check

| Command | What it does |
|---|---|
| `fs run` | Run the repository's Chrome preview launcher; dependencies may refresh |
| `fs run -Emulator` | Run Chrome against the local demo Firebase emulators |
| `fs firebase` | Start the repository's local demo emulators |
| `fs test` | Run Flutter tests from `mobile` |
| `fs analyze` | Run Flutter analysis from `mobile` |
| `fs format` | Check Dart formatting in `lib` and `test` |
| `fs format -Apply` | Write formatting changes on a feature branch |

**Preview launch/write actions:** `fs run -WhatIf`, `fs firebase -WhatIf`, `fs preview -WhatIf`, `fs format -Apply -WhatIf`.

The configured project SDK is `$HOME\develop\flutter`. A direct `flutter` command can select a different SDK through PATH; `fs doctor` exposes that difference. The launcher requires an existing web host. Firebase uses `demo-forgedandsent` with loopback hosts and Java 21. The HTML prototype is separate from the Flutter app.

### Branches and remote status

| Command | What it does |
|---|---|
| `fs diff` | Show unstaged change statistics and the diff |
| `fs branch` | Pick an existing local branch; switch requires a clean tree and confirmation |
| `fs branch 'feature/my-task'` | Request a switch to that existing local branch |
| `fs pr` | List pull requests through the installed GitHub CLI |
| `fs ci` | List recent GitHub Actions runs |

`fs pr` and `fs ci` contact GitHub on demand and need working `gh` access. Branch creation and pushing follow the repository's contributor workflow.

## Move around

| I want to… | Command | Detail |
|---|---|---|
| Pick a folder | `jump` | Bookmarks + recent/frequent folders |
| Go to a saved folder | `jump mobile` | Exact bookmark, or fuzzy matching |
| Go to a literal path | `jump 'C:\path with spaces'` | Existing directories only |
| Use the short fuzzy form | `z mobile` | Same navigation as `jump` |
| Open managed quick access | `qa` or `qa downloads` | Same bookmarks; Explorer pins are separate |
| Save this folder | `mark mobile` | Persistent named bookmark |
| Save another folder | `mark vault 'C:\Projects\Notes'` | No need to navigate there first |
| List saved places | `marks` or `marks mob` | Includes built-in quick folders |
| Forget a saved bookmark | `unmark old-project` | Confirms; built-in folders remain |
| Return to the last folder | `back` | Previous folder in this shell |
| Move to a parent | `up` or `up 2` | One level by default; accepts 1–20 |
| Create and enter a folder | `mkcd 'scratch experiment'` | Supports `-WhatIf` |
| Pick a project | `projects` | Workspace roots, immediate child repos, and visited repos |
| Filter the project picker | `projects -Query fitness` | Starts with matching text |
| List projects as objects | `projects -List` | Does not change directory |
| List this folder | `ll` or `ll 'C:\path'` | Folders first, then files |

Built-in destinations: `jump home`, `jump desktop`, `jump documents`, `jump downloads`, `jump onedrive` when available, `jump work`, and `jump fs`.

Bookmark names start with a letter and use letters, numbers, underscores, or hyphens, up to 40 characters. Quote paths containing spaces.

## Find files and text

| Command | Use it for |
|---|---|
| `ff` | List searchable files below the current folder |
| `ff workout` | Filenames/paths containing “workout” |
| `ff '*.dart' mobile` | A filename pattern within a folder |
| `ftext 'FS_ENV' mobile` | Find source text with file and line information |
| `ftext 'TODO\|FIXME' .` | Search using a regular expression |
| `ftext 'timeout' '.\logs\app.log'` | Search one file |

**Memory hook: `ff` = find file; `ftext` = find text.** PowerShell's `ft` still means **Format-Table**.

Ripgrep accelerates search when available. Without it, the native fallback skips generated trees and links, stops at 20,000 files, and skips large/binary/key files for text searches. Narrow the path when a search is too broad.

## Capture and resume

> [!tip] Parking lot for side quests
> `todo` stores something to **do**. `note` stores something you **learned**. `session save` stores the **next action to return to**.

### Tasks and notes

| Command | What it does |
|---|---|
| `todo 'Check reconnect after sleep'` | Capture a task tagged with the current repository |
| `todos` | Show all open tasks across projects |
| `todos -Project` | Show only open tasks for the current repository |
| `todos -All` | Include completed tasks |
| `todos -All -Project` | Show this repository's open + completed tasks |
| `done 1` | Complete task ID 1 |
| `done 1,3` | Complete several task IDs |
| `note 'Only fails after the second reconnect'` | Save an engineering observation |
| `notes` | Show notes, newest first |
| `notes reconnect` | Find notes containing matching text |
| `notes -Project` | Show notes for the current repository |
| `notes reconnect -Project` | Search within this repository's notes |
| `recent-notes` | Show the latest 10 notes |
| `recent-notes 5` | Show a chosen count, from 1–100 |

Use IDs from `todos` when marking tasks complete. These captures live in Forge's local JSON data; **they do not automatically create or update Obsidian notes**.

### Checkpoints and focus

| Command | What it does |
|---|---|
| `session` or `session summary` | Current folder, repo, open task count, and session command count |
| `session save 'Next: test offline retry'` | Save the next action and current location |
| `session list` | List saved checkpoints |
| `session resume` | Pick a checkpoint and return to its folder |
| `session resume retry` | Start the picker with matching text |
| `focus` | Start a 25-minute countdown |
| `focus 15` | Start a custom 1–180 minute countdown |
| `focus -Stop` | Clear the countdown |
| `recent-command` | Show the latest 15 eligible commands from this shell |
| `recent-command flutter` | Filter this shell's history |
| `recent-command -Count 30` | Show up to 30 eligible commands; accepts 1–100 |

The timer is nonblocking and lives in this shell. Completion appears on the next prompt; there is no OS notification. Checkpoints retain the latest 50 saves. `recent-command` displays history without replaying it.

## Git without surprises

| Command | What it does |
|---|---|
| `gst` | Short Git status in the repository you are currently in |
| `gad 'mobile/lib/example.dart' -WhatIf` | Preview staging an explicit path |
| `gad 'mobile/lib/example.dart'` | Stage that path on a feature branch |
| `gmsg 'fix: explain the change' -WhatIf` | Preview committing already-staged changes |
| `gmsg 'fix: explain the change'` | Commit staged changes, with confirmation and normal hooks |
| `gpsh` | Show push requirements and guidance; executes no push |

`gad` and `gmsg` refuse protected branches and detached HEAD. `gad .` is refused: choose explicit paths. `fs diff` shows **unstaged** changes; use `git diff --cached` from the relevant checkout for **staged** changes.

## Engineering tools

### “What is broken?”

| Command | What it does |
|---|---|
| `ph` or `forge doctor` | Check shell, profile, data, configuration, and optional tools |
| `ptest` or `forge test` | Run Forge's isolated validation suite |
| `err` | Summarize the latest PowerShell error |
| `err 1` | Summarize the previous error; index 0 is newest |
| `port` | List listening TCP ports and owning processes |
| `port 8080` | Identify the process listening on one port |
| `netcheck` | Test TCP connection to `127.0.0.1:8080` |
| `netcheck localhost 9099` | Test a chosen host and port |
| `pathcheck` | Show PATH precedence, missing entries, and duplicates |
| `refreshpath -WhatIf` | Preview refreshing this shell's PATH |
| `refreshpath` | Replace this session's PATH with Machine + User PATH |
| `envshow` or `envshow flutter` | List environment variable names and lengths; values stay hidden |
| `sshgo` | Pick an SSH host alias from your SSH config |
| `sshgo user@host` | Connect using the installed SSH client |

`port` inspects without stopping processes. `refreshpath` discards temporary session-only PATH additions; it does not edit Windows environment settings. A listening port shows that something is there, not that the application is healthy.

### JSON, clipboard, files

| Command | What it does |
|---|---|
| `jview '.\config.json'` | Pretty-print a JSON file |
| `jview '.\config.json' -Minify` | Output compact JSON |
| `'{"ready":true}' \| jview` | Format JSON from the pipeline |
| `cliptools` or `cliptools path` | Copy the current folder path |
| `cliptools get` | Show clipboard text |
| `cliptools set 'text'` | Replace clipboard text |
| `hash '.\file.zip'` | Calculate its SHA-256 hash |
| `comparefile '.\before.json' '.\after.json'` | Compare SHA-256 hashes; report `Identical` |
| `tempwork` | Create and enter a new scratch folder |
| `trash '.\scratch.txt' -WhatIf` | Preview recycling a file/folder |
| `trash '.\scratch.txt'` | Move it to the Windows Recycle Bin, with confirmation |

`jview` outputs JSON; it does not rewrite the source file. Scratch folders persist until you remove them. `trash` refuses protected locations such as drive roots, your home/current folder, repository roots, `.git`, and links.

## Keyboard shortcuts

| Key | What it does |
|---|---|
| **Tab** | Show completion choices; try typing `fs an` then Tab |
| **Up / Down** | Search history matching what you have already typed |
| **Ctrl+R** | Search command history backwards |
| **F2** | Switch inline/list predictions |
| **Alt+H** | Insert `helpme `; press Enter when ready |
| **Alt+D** | Insert `dash`; press Enter when ready |
| **Type / arrows / Enter / Esc** | Filter / select / choose / cancel inside menus |

`keys` reports actual bindings. The terminal app may intercept a shortcut. Menus use fzf when available and a native picker otherwise.

A **leading space** keeps a line out of PSReadLine's saved history. Forge also filters common secret patterns and capture commands. PowerShell's separate in-memory history can still contain input; use your secret manager for credentials.

## Read the prompt

```text
FORGED & SENT | mobile | feature/onboarding ~2 +1 ?0 ahead:1 | Flutter
>
```

| Signal | Meaning |
|---|---|
| Steel blue / ember orange | Normal context / Forged & Sent context in auto mode |
| Folder + branch | Where this shell is working |
| `~2` | Two unstaged tracked entries |
| `+1` | One staged entry |
| `?3` | Three untracked entries; Git may summarize an entire directory |
| `clean` | The cached Git status was clean |
| `[checking]` | Status is not available yet |
| `*` | A status refresh is in progress |
| `ahead` / `behind` | Compared with local tracking references; the prompt does not fetch |
| `CONFLICT` | Git reports conflicts |
| `! failed` | The previous command failed |
| `ADMIN` | This shell is elevated |
| Focus countdown | Time left in this shell's focus block |

A file can contribute to both staged and unstaged counts. Rich status refreshes asynchronously; it is a useful cue, with `fs status` available for a fresh check.

## Make it feel right

### Themes and prompt detail

| Command | Result |
|---|---|
| `forge theme` | Show the current theme and choices |
| `forge theme auto` | Steel blue normally, ember inside Forged & Sent |
| `forge theme normal` | Keep the normal accent |
| `forge theme forged` | Keep the ember accent |
| `forge prompt` | Show the current prompt mode and choices |
| `forge prompt minimal` | One-line prompt; skip rich Git status subprocesses |
| `forge prompt rich` | Two-line prompt with more context |
| `forge config` | List all settings |
| `forge context` | Show the detected repository/worktree context |
| `forge project` | Remember the current Forged & Sent checkout |
| `reloadforge` or `forge reload` | Rebuild and reload the module |
| `forge benchmark` | Measure startup and prompt timings in fresh processes |

Theme and prompt-detail changes take effect on the next prompt. Run `reloadforge` after editing or enable/disable changes.

**Windows Terminal / VS Code:** choose the **Forge Command Center** terminal profile. If the repository's VS Code startup shell replaces the prompt, run `reloadforge`.

> [!example]- All configurable settings
> Use `forge config Name Value`. Boolean values are `true` or `false`; `-WhatIf` previews a setting change.
>
> | Setting | Example / accepted values |
> |---|---|
> | `Theme` | `forge config Theme auto` — auto / normal / forged |
> | `PromptMode` | `forge config PromptMode minimal` — minimal / rich |
> | `EnablePrompt` | `forge config EnablePrompt true` |
> | `EnableGitStatus` | `forge config EnableGitStatus false` |
> | `EnableEditing` | `forge config EnableEditing true` |
> | `EnableDirectoryHistory` | `forge config EnableDirectoryHistory false` |
> | `EnableFzf` | `forge config EnableFzf false` |
> | `NerdIcons` | `forge config NerdIcons false` — use true only with a suitable installed font |
> | `GitCacheSeconds` | `forge config GitCacheSeconds 5` — 2–120 |
> | `GitTimeoutMs` | `forge config GitTimeoutMs 1500` — 100–5000 |
> | `PredictionView` | `forge config PredictionView ListView` — InlineView / ListView |
> | `DefaultProject` | Prefer `forge project` from the checkout you want |
> | `WorkspaceRoots` | `forge config WorkspaceRoots @('C:\Projects','D:\source')` |
> | `FlutterSdk` | `forge config FlutterSdk '$HOME\develop\flutter'` |
>
> WorkspaceRoots replaces the full root list. Keep the entries you still want. `SchemaVersion` is an internal format marker, not a daily customization.

## When something breaks

| Symptom | Next useful command/action |
|---|---|
| “Command not found” in an old terminal | Open a fresh PowerShell 7 tab; then `ph` |
| Prompt disappeared in VS Code | `reloadforge`, or select **Forge Command Center** |
| Wrong project | `forge context`; enter the intended checkout, then `forge project` |
| Wrong Flutter / launch prerequisites | `fs doctor` |
| Port already in use | `port 8080` |
| A new tool is missing from PATH | `pathcheck`, then `refreshpath` if appropriate |
| Something threw an error | `err` |
| Suspect a broken configuration/module | `ph`, then `ptest` |
| Startup itself is broken | Launch `pwsh -NoProfile`, then use the recovery scripts below |

### Maintenance scripts

> [!example]- Installation, styling, import, and rollback
> These are separate scripts under `$HOME\.config\powershell`. Preview supported changes with `-WhatIf`.
>
> **Install or repair the profile loader:**
>
> ```powershell
> & "$HOME\.config\powershell\Install.ps1" -WhatIf
> ```
>
> Run the same command without `-WhatIf` to apply.
>
> **Preview terminal styling files:**
>
> ```powershell
> & "$HOME\.config\powershell\Configure-Terminals.ps1"
> ```
>
> Add `-Apply` to write Terminal + VS Code settings, with backup. Add `-TerminalOnly` to limit it to Windows Terminal.
>
> **Optional ripgrep / fzf installer:**
>
> ```powershell
> & "$HOME\.config\powershell\Install-OptionalTools.ps1" -WhatIf
> ```
>
> The script targets the pinned user-scoped portable versions. `-Tool ripgrep` or `-Tool fzf` selects one; omitting `-WhatIf` installs with confirmation.
>
> **Import older saved data:**
>
> ```powershell
> & "$HOME\.config\powershell\Import-LegacyData.ps1" -WhatIf
> ```
>
> Omit `-WhatIf` to apply. Default source: `$HOME\.adhd-powershell`; use `-Source 'C:\path'` for another directory. Existing destination data is skipped. Legacy Markdown notes are preserved as a separate file.
>
> **Remove the profile loader and roll back managed styling:**
>
> ```powershell
> & "$HOME\.config\powershell\Uninstall.ps1" -WhatIf
> ```
>
> Omit `-WhatIf` to apply. Add `-ProfileOnly` to leave styling installed. Open a new shell afterward. Data, source files, backups, and separately installed tools remain.
>
> **Restore one exact backup transaction:**
>
> ```powershell
> & "$HOME\.config\powershell\Restore.ps1" -Backup "$HOME\.config\powershell\backups\BACKUP-ID" -WhatIf
> ```
>
> Replace `BACKUP-ID` with a directory printed by your installation. Omit `-WhatIf` to restore with confirmation. Restore refuses files edited since installation; `-Force` explicitly overwrites those later edits, so normally leave it off.
>
> **Rebuild the generated runtime after source edits:**
>
> ```powershell
> & "$HOME\.config\powershell\scripts\Build-Module.ps1"
> ```
>
> `reloadforge` also rebuilds and reloads it. Edit module source files, not `Forge.Runtime.psm1`.
>
> For full recovery instructions, open `$HOME\.config\powershell\RECOVERY.md`. Setting the environment variable `FORGE_DISABLE=1` in the parent process skips Forge on startup.

## Where your stuff lives

| Item | Location |
|---|---|
| Installed shell package | `$HOME\.config\powershell` |
| Settings | `config\settings.json` under that package |
| Tasks, notes, bookmarks, visits, checkpoints | `data\*.json` |
| Previous saved data version | Corresponding `.previous` copy |
| Scratch folders | `data\scratch` |
| Validation and timing reports | `data\validation.json`, `data\benchmark.json` |
| Installation backups | `backups` |
| All-hosts profile loader | `$PROFILE.CurrentUserAllHosts` |
| This note | `docs/development/shell/WINDOWS-COMMANDS.md` in this project vault |

Forge stores captures locally. This Obsidian note is a reference; it does not mirror the task or note databases.

## Complete command index

All **47** exported Forge commands, grouped for quick scanning:

| Area | Commands |
|---|---|
| Discover and manage · 8 | `dash`, `helpme`, `keys`, `fs`, `forge`, `ph`, `ptest`, `reloadforge` |
| Navigate and search · 13 | `jump`, `z`, `qa`, `mark`, `marks`, `unmark`, `back`, `up`, `mkcd`, `projects`, `ff`, `ftext`, `ll` |
| Capture and focus · 9 | `todo`, `todos`, `done`, `note`, `notes`, `recent-notes`, `session`, `focus`, `recent-command` |
| Engineering · 13 | `port`, `err`, `pathcheck`, `refreshpath`, `envshow`, `netcheck`, `sshgo`, `jview`, `cliptools`, `hash`, `comparefile`, `tempwork`, `trash` |
| Git · 4 | `gst`, `gad`, `gmsg`, `gpsh` |

**Version note:** this guide describes Forge Shell 2.0. Notable changes: `ftext` for text search, `cliptools path` for copying a path, `forge config` for settings, and `Alt+D` for the dashboard.

Source of truth: `tooling/forge-shell/windows` in this repository. [Setup and uninstall](../SHELL-SETUP.md).

[[#Pick your current brain state|↑ Back to the next useful command]]
