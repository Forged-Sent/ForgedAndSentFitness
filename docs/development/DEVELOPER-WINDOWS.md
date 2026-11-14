# Forged & Sent: developer setup on Windows

## PowerShell 7 (automatic)

**PowerShell 7.6 LTS or newer is the standard for this repo.** The double-click .cmd entrypoints begin with the built-in Windows PowerShell 5.1 only to run tooling/windows/bootstrap-pwsh.ps1. The bootstrap checks for pwsh, installs or updates PowerShell using the official WinGet ID Microsoft.PowerShell, checks it is at least 7.6, and launches all developer scripts with pwsh.exe. Windows PowerShell 5.1 stays installed; don't remove it. The launchers do not permanently change execution policy.

The full and preview installers check for updates. `launchers/windows/2 - Run the app.cmd` does not check for updates every time. If WinGet/App Installer is missing, installer permission is declined, or a restart is needed, the wizard prints a clear fix and stops rather than silently using 5.1.

Run pwsh --version to check it yourself. VS Code now defaults to the PowerShell 7 terminal for this workspace. PowerShell 7 is installed side-by-side with 5.1.

Official installation instructions: https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows

## Two setups, for different teammates

- Preview-only: run `launchers/windows/more/Preview-only setup.cmd`, then `launchers/windows/2 - Run the app.cmd`. This opens the Flutter starter in Chrome, without accounts.
- Full development: run `launchers/windows/1 - Set up this computer.cmd`, then `launchers/windows/5 - Check my setup.cmd` and `launchers/windows/2 - Run the app.cmd`.
- Optional Android phone development: run `launchers/windows/more/Android setup.cmd`. Complete Android Studio setup, licenses and device pairing yourself.
- Local iOS builds require a Mac and Xcode.

Use your existing **Git clone**. For normal setup, run `git status`, `git switch main`, `git fetch origin`, and `git pull --ff-only`. Only if you have no clone: `git clone https://github.com/Forged-Sent/ForgedAndSentFitness.git`. Do not overwrite or force-reset local work. Only run scripts from this repository when you trust them. Corporate security restrictions should not be bypassed.

## What full setup adds

- Node.js LTS/npm, GitHub CLI, local Firebase CLI, Python 3.11+ and JDK 21.
- Playwright MCP package is fetched by the pinned project launcher on first use; no global installation.
- VS Code extensions: Dart, Flutter, GitHub Pull Requests, YAML, EditorConfig and PowerShell. The extensions for any AI assistants you pick in setup are added too (Codex, Claude Code, Copilot); Antigravity is a terminal CLI (`agy`) installed with WinGet.
- Optional Codex and Claude Code command-line tools, using project-scoped `.codex/config.toml` / `.mcp.json` (no global registration).
- Shared VS Code MCP configuration, committed at .vscode/mcp.json.

Tools are reused when found; project-scoped MCPs depend on Node and require user trust and live handshakes; rerun setup safely after restarts or network failures. Windows may show installation prompts. Script success does not prove cloud accounts, Android SDK licenses, or MCP sessions are authenticated.

## Guided first run

Start with **START-WINDOWS.cmd**. The wizard offers developer/preview installation, account sign-ins, MCP setup, launching the app, and an explicit "check everything" command that explains each missing dependency and gives a repair step.

It generates a **secret-free AI troubleshooting prompt** in the Windows temporary folder and offers to copy it to the clipboard. It does not paste or send it automatically. See docs/development/FIRST-RUN-TROUBLESHOOTING.md.

## MCP integrations

The project VS Code MCP file configures three default servers (no Firebase cloud MCP):

1. Dart MCP: analyzer, tests and Flutter app context via dart mcp-server. Runs from the Flutter SDK.
2. No Firebase cloud MCP is installed by default. The Firebase CLI runs the local Auth, Firestore and Storage emulators using the fake `demo-forgedandsent` project; no account or login is required.
3. Playwright MCP: browser automation against Chrome for Flutter web UI.
4. GitHub hosted MCP, Figma, Maestro and Google Developer Knowledge are **optional**, documented in [MCP security](MCP-SECURITY.md); they are not loaded at first run.

**Safety:** MCP providers can execute code or access external data. VS Code asks you to trust servers. Firebase cloud MCP is deliberately absent. DEV cloud authorization is a separate Maintainer opt-in. No Firebase project or API key is created by this bootstrap.

The shared .vscode/mcp.json is for VS Code and Copilot. Claude uses .mcp.json and Codex uses .codex/config.toml after trust. Gemini CLI has no project configuration; its settings were archived on 2026-11-10 (see the [archive README](../knowledge/archive/2026-11-10-copilot-gemini-rules/README.md)). The audited optional manifests provide Google Developer Knowledge through a masked key prompt only when the maintainer explicitly opts in. No global Firebase/cloud MCP registration is performed.

## Sign-in after setup

1. Open the repository folder in VS Code.
2. Sign into GitHub so you can publish a branch and open a draft PR.
3. Sign in only to the AI assistants you selected, if you want AI-assisted work. All of them are optional.
4. Use VS Code Command Palette > MCP: List Servers to verify Dart, Context7 and Playwright. Configured alone does not mean connected.
5. Do not run `firebase login` as a Contributor. The local demo emulators need no login; cloud DEV access is separately provisioned later.
6. Run `launchers/windows/2 - Run the app.cmd` for plain Flutter Preview. To test live demo Firebase, start `launchers/windows/3 - Start practice Firebase.cmd`, then `launchers/windows/4 - Run app with practice Firebase.cmd` in a second window. Leave both consoles open.

Follow the cross-platform [first-contribution guide](FIRST-CONTRIBUTION.md) to create a branch, edit one line, run tests and open a Draft PR. A free public GitHub Actions runner does not make Claude/Codex/Copilot usage free. No agent is authorized to deploy, commit secrets, or change accepted architecture just because its extension is installed.

## Flutter/Dart agent skills

The existing project has agent rules and skills. Flutter offers additional official plugins and skills. Installing them can modify repository files, so this bootstrap **does not silently overwrite existing agent instructions**.

A project owner can review official Flutter plugin instructions at:
https://docs.flutter.dev/ai/get-started

Examples, to run in a dedicated branch after review:

    npx skills add flutter/agent-plugins --skill '*' --agent universal --yes
    npx skills add dart-lang/skills --skill '*' --agent universal --yes

Claude Code official plugin:

    claude plugin marketplace add flutter/agent-plugins
    claude plugin install dart-flutter@dart-flutter

Codex official plugin:

    codex plugin marketplace add flutter/agent-plugins
    codex plugin add dart-flutter@dart-flutter

Review and commit only intentional skill changes. The Flutter app still needs further work; the bootstrap starts a foundation screen, not the existing full HTML application.

## Verification and support

`launchers/windows/5 - Check my setup.cmd` checks local executables, key VS Code extensions, and MCP JSON structure. It writes a diagnostics-only report to the TEMP folder. It cannot prove MCP handshakes, logins, or a fresh machine installation succeeded.

For errors, send a screenshot and the diagnostics report, **never API keys or credentials**.

Sources:
- Flutter MCP and skills: https://docs.flutter.dev/ai/get-started
- VS Code MCP configuration: https://code.visualstudio.com/docs/agents/reference/mcp-configuration
- Firebase MCP: https://firebase.google.com/docs/ai-assistance/mcp-server
- Playwright MCP: https://github.com/microsoft/playwright/blob/main/docs/src/getting-started-mcp.md
- GitHub MCP read-only endpoint: https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md
