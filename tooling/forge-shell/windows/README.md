# Forge Shell 2.0

**One command when your brain goes blank: `dash`.**

Open a new PowerShell 7 tab. Type `helpme` for a short starting list, `helpme git` or `helpme flutter` for focused help, and `keys` for shortcuts. Nothing opens automatically at startup.

## Learn these 15 first

| Command | When to use it |
|---|---|
| `dash` | Choose a workflow without remembering syntax |
| `helpme flutter` | Find a command, description and example |
| `fs go` | Return to the current or remembered Forged & Sent checkout |
| `fs mobile` | Work in the Flutter app |
| `fs status` | Reorient: branch and changed files |
| `fs run` | Start the repository's Chrome app workflow |
| `fs test` | Run Flutter tests with the project SDK |
| `fs analyze` | Run Flutter analysis |
| `jump` | Search bookmarks and recently visited directories |
| `mark mobile` | Save the current folder for later |
| `ff '*workout*'` | Find a file by part of its name |
| `ftext 'FS_ENV' mobile` | Search source text |
| `todo 'Check emulator reconnect'` | Capture a task without changing context |
| `note 'Reproduce after a cold restart'` | Keep a project-tagged engineering note |
| `ph` | Diagnose your shell and optional tools |

## Read the prompt

Rich mode:

```text
FORGED & SENT | mobile | feature/onboarding ~2 +1 ?0 ahead:1 | Flutter
>
```

Minimal mode:

```text
FORGED & SENT | mobile | feature/onboarding >
```

`~` counts unstaged tracked entries; `+` counts staged entries; `?` counts untracked entries (Git may summarize a whole directory as one entry). A file can have both staged and unstaged changes. `clean` means the cached status was clean. `*` means it is refreshing. `[checking]` means status is not ready yet, not that the checkout is clean. `ahead` and `behind` use local tracking references; the prompt never fetches. `CONFLICT` and `! failed` identify problems. `ADMIN` appears only in an elevated shell.

The first prompt reads HEAD directly, including linked worktrees. Rich status runs asynchronously, refreshes at most every five seconds, and times out without blocking input. Minimal mode avoids status subprocesses. Repository names and branch labels are stripped of terminal control characters.

Graphite, soft white and steel blue provide the baseline. Inside Forged & Sent, the prompt accent becomes ember orange from the repository's later prototype palette. Gold marks attention, green marks success, and red marks failure. Both terminal schemes share the same dark background, so moving between projects does not flash the screen.

## Everyday workflows

### Start or resume

```powershell
fs go
fs status
todos -Project
session resume
```

`fs` chooses the Forged & Sent checkout containing your current directory. Outside the project it uses the remembered default, initially the checkout where you accepted installation. To change that default, enter your preferred checkout and run `forge project`. It never switches branches or moves you automatically on profile load.

`projects` discovers configured workspace roots and their immediate child repositories, plus previously visited repositories. `projects -List` returns objects. Add another root with `forge config WorkspaceRoots @('C:\Projects', 'D:\source')`.

### Run Flutter and local Firebase

```powershell
fs doctor
fs run -WhatIf
fs run
# In a separate terminal when Firebase behavior is needed:
fs firebase
fs run -Emulator
fs test
fs analyze
fs format
fs format -Apply -WhatIf
```

Project commands use the installed `~/develop/flutter` SDK, matching the audited launcher and CI pin. `fs doctor` exposes a different SDK on PATH. Neither global PATH nor your other projects' SDKs are changed.

`fs run` uses the existing launcher and can run `flutter pub get`; initialize a missing web host explicitly from the repository instructions. Emulator startup checks Java 21 first, so the existing launcher's installer path is not entered when Java is missing. Firebase stays on `demo-forgedandsent` with loopback hosts. There is no deploy/login command in this namespace.

`fs preview` regenerates `dev/preview.html` and opens the behavioral HTML prototype. It is not a production Firebase test. `fs architecture` opens the generated Architecture Atlas or runs its existing generator launcher.

### Review changes

```powershell
fs diff
fs branch
fs pr
fs ci
gad mobile/lib/example.dart -WhatIf
gmsg 'fix: explain the change' -WhatIf
```

`fs branch` requires a clean tree and confirmation before switching an existing branch. It does not create or delete branches. `gad` stages explicit paths; `gmsg` commits already-staged changes with confirmation. Both refuse main/master/production/prod and detached HEAD. Git hooks still run. `gpsh` shows push requirements and executes no push. Repository protections remain authoritative.

### Capture and recover focus

```powershell
todo 'Verify the offline retry path'
todos
done 1
todos -All
note 'Failure happens after the second reconnect'
notes reconnect
recent-notes 5
session save 'Next: test reconnect with pending writes'
session resume
focus 25
focus -Stop
```

Notes and tasks carry the current repository path. Session checkpoints remember location, branch label and your next action; resuming changes only the folder. The focus timer is a nonblocking in-session countdown, with a completed label on the next prompt. It is not an OS notification or persistent scheduler.

Data uses locked read/modify/write operations and atomic JSON replacement, so two shells can capture tasks safely. A `.previous` copy preserves the preceding data version. Malformed data is retained and writes stop until repaired. Nothing is synchronized or uploaded by Forge.

### Navigate and investigate

| Intent | Command |
|---|---|
| Quick folders | `jump home`, `jump downloads`, `jump desktop`, `jump onedrive`, `jump work` |
| Fuzzy folder switch | `jump workout` or `z workout`; no argument opens a picker |
| Persistent quick access | `mark name`, `marks`, `qa`, `unmark name -WhatIf` |
| Create and enter | `mkcd 'folder with spaces'` |
| Return / parent | `back`, `up 2` |
| Find text | `ftext 'pattern' .` (`ft` still means Format-Table) |
| Port conflict | `port 8080`; no processes are killed |
| TCP availability | `netcheck localhost 8080` |
| PATH precedence | `pathcheck`; `refreshpath -WhatIf` previews a session-only refresh |
| Environment inventory | `envshow flutter`; values are always hidden |
| Last error | `err` |
| SSH hosts | `sshgo`, `sshgo user@host` |
| JSON | `jview file.json`, or `'{"ready":true}' \| jview` |
| Clipboard | `cliptools path`, `cliptools get`, `cliptools set 'text'`; native `clip.exe` stays available |
| Exact file comparison | `hash file.zip`, `comparefile before.json after.json` |
| Scratch work | `tempwork`; folders remain until you remove them |
| Safer removal | `trash 'file.txt' -WhatIf`, then `trash 'file.txt'` with confirmation |

Without ripgrep, searches skip generated trees and symbolic links and stop at 20,000 files. Text fallback skips common binary/credential filenames and files above 2 MB. Narrow the directory or install ripgrep for large trees. Search tools are not secret scanners; inspect sensitive files deliberately with appropriate tools.

## Keyboard and menus

| Key | Action |
|---|---|
| Tab | Completion menu; `fs` and `forge` actions and bookmarks complete |
| Up / Down | Search history matching your current prefix |
| Ctrl+R | Reverse history search |
| F2 | Toggle inline and list predictions in PSReadLine |
| Alt+H | Insert `helpme ` without running it |
| Alt+D | Insert `dash` without running it |
| Menu: type, arrows, Enter, Esc | Filter, select, run, cancel |

The native picker is always available in a normal interactive console. If fzf exists, Forge uses it on demand. Redirected and unsupported hosts get readable lists rather than a hanging key reader. Host applications can intercept shortcuts; `keys` reports actual PSReadLine bindings.

## Customize without editing code

```powershell
forge theme auto             # normal outside the project; ember inside
forge theme normal
forge theme forged
forge prompt minimal
forge prompt rich
forge config EnableGitStatus false
forge config EnableDirectoryHistory false
forge config EnableFzf false
forge config PredictionView ListView
forge config NerdIcons true  # only after selecting an installed Nerd Font
reloadforge
```

`forge config` lists settings. Invalid types and unknown options are refused. `-WhatIf` works for configuration writes. Theme and prompt mode take effect on the next prompt; editing and enable/disable changes require `reloadforge`. Settings are in `config/settings.json`.

Windows Terminal receives two named schemes and an optional **Forge Command Center** profile. VS Code receives only terminal colors, a font family and a named terminal profile; editor styling and default profile are preserved. The repository's own VS Code terminal can override the prompt after profiles run. Choose **Forge Command Center** explicitly or type `reloadforge`; no tracked settings need editing.

## Install, maintain and recover

```powershell
& "$HOME\.config\powershell\Install.ps1" -WhatIf
& "$HOME\.config\powershell\Install.ps1"
ptest
forge benchmark
& "$HOME\.config\powershell\Configure-Terminals.ps1"       # preview files only
& "$HOME\.config\powershell\Configure-Terminals.ps1" -Apply # approval before global app changes
& "$HOME\.config\powershell\Install-OptionalTools.ps1" -WhatIf
& "$HOME\.config\powershell\Uninstall.ps1" -WhatIf
```

The all-hosts loader is added to the actual redirected Documents location discovered through `$PROFILE`. Both console and VS Code PowerShell hosts can load it. Windows PowerShell 5.1 stays unchanged. The implementation is local under `.config/powershell`, not OneDrive; only the small loader is in redirected Documents.

Modules are maintained as `Core`, `Prompt`, `Editing`, `Catalog`, `Navigation`, `Productivity`, `Engineering` and `Project` source files. `scripts/Build-Module.ps1` produces a single runtime module to reduce file-loading cost. Edit the sources, not `Forge.Runtime.psm1`; `reloadforge` and the installer rebuild and parse it. `ptest` checks that the runtime is current.

Use `ph` for health, `ptest` for isolated integration tests, and `forge benchmark` for fresh-process timings. Reports live at `data/validation.json` and `data/benchmark.json`. Testing does not deploy, push, start Firebase, run app builds, or change your app checkout. Interactive hosts and elevated operation are reported separately from simulated checks.

For a broken startup, launch `pwsh -NoProfile`, then run `Uninstall.ps1` or follow [RECOVERY.md](RECOVERY.md). Set `FORGE_DISABLE=1` in a parent process to skip Forge. Uninstall removes the marked loader; exact theme rollback refuses to overwrite later edits. Data and backups are retained intentionally. Optional packages remain separately manageable by WinGet.

## Privacy and history

No startup network calls, telemetry, transcripts, history exports, cloud sync or environment-value logging are added. PSReadLine skips lines with common credential terms, key-shaped strings, a leading space, or note/task capture commands. A filter cannot recognize every secret, and PowerShell's separate in-memory session history may still contain command text. Supply credentials through your existing secret manager, not literal command lines. Existing history is neither read nor rewritten during installation.

In the repository, see `docs/development/SHELL-SETUP.md` and `docs/development/shell/WINDOWS-COMMANDS.md` for optional setup and the complete command guide.
