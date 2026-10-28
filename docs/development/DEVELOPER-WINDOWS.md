# Forged & Sent: developer setup on Windows

## PowerShell 7 (automatic)

**PowerShell 7.6 LTS or newer is the standard for this repo.** The double-click .cmd entrypoints begin with the built-in Windows PowerShell 5.1 only to run tooling/windows/bootstrap-pwsh.ps1. The bootstrap checks for pwsh, installs or updates PowerShell using the official WinGet ID Microsoft.PowerShell, checks it is at least 7.6, and launches all developer scripts with pwsh.exe. Windows PowerShell 5.1 stays installed; don't remove it. The launchers do not permanently change execution policy.

The full and preview installers check for updates. RUN-APP.cmd does not check for updates every time. If WinGet/App Installer is missing, installer permission is declined, or a restart is needed, the wizard prints a clear fix and stops rather than silently using 5.1.

Run pwsh --version to check it yourself. VS Code now defaults to the PowerShell 7 terminal for this workspace. PowerShell 7 is installed side-by-side with 5.1.

Official installation instructions: https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows

## Two setups, for different teammates

- Preview-only: run SETUP-WINDOWS.cmd, then RUN-APP.cmd. This opens the Flutter starter in Chrome, without accounts.
- Full development: run SETUP-DEVELOPER-WINDOWS.cmd, then VERIFY-DEVELOPER-WINDOWS.cmd and RUN-APP.cmd.
- Optional Android phone development: run SETUP-ANDROID.cmd. Complete Android Studio setup, licenses and device pairing yourself.
- Local iOS builds require a Mac and Xcode.

Download the GitHub branch ZIP and **extract all** before double-clicking the script. Only run scripts from a repository you trust. If an installer or corporate security policy blocks setup, stop and ask for help rather than disabling security software.

## What full setup adds

- Node.js LTS/npm, GitHub CLI and Firebase CLI.
- Playwright MCP npm package.
- VS Code extensions: Dart, Flutter, GitHub Copilot, Copilot Chat, GitHub Pull Requests, Codex, Claude Code, YAML, EditorConfig and PowerShell.
- Optional Codex and Claude Code command-line tools, with the Dart MCP registered for each when supported.
- Shared VS Code MCP configuration, committed at .vscode/mcp.json.

Tools are reused when found; rerun setup safely after restarts or network failures. Windows may show installation prompts. Script success does not prove cloud accounts, Android SDK licenses, or MCP sessions are authenticated.

## Guided first run

Start with **FIRST-RUN-WINDOWS.cmd**. The wizard offers developer/preview installation, account sign-ins, MCP setup, launching the app, and an explicit "check everything" command that explains each missing dependency and gives a repair step.

It generates a **secret-free AI troubleshooting prompt** in the Windows temporary folder and offers to copy it to the clipboard. It does not paste or send it automatically. See docs/development/FIRST-RUN-TROUBLESHOOTING.md.

## MCP integrations

The project VS Code MCP file configures seven servers (no Firebase cloud MCP):

1. Dart MCP: analyzer, tests and Flutter app context via dart mcp-server. Runs from the Flutter SDK.
2. No Firebase cloud MCP is installed by default. Firebase CLI itself is retained for future local emulators (PR #4).
3. Playwright MCP: browser automation against Chrome for Flutter web UI.
4. GitHub hosted MCP: read-only repository/issue/PR context via OAuth.

**Safety:** MCP providers can execute code or access external data. VS Code asks you to trust servers. Firebase cloud MCP is deliberately absent. DEV cloud authorization belongs to Maintainer opt-in in PR #4. No Firebase project or API key is created by this bootstrap.

The shared .vscode/mcp.json works for VS Code and Copilot. Claude uses the project-scoped .mcp.json and Codex uses .codex/config.toml after trust. No user-global Firebase/cloud MCP is registered. Google Developer Knowledge prompts for a masked API key in VS Code.

## Sign-in after setup

1. Open the repository folder in VS Code.
2. Sign into GitHub and Copilot if you have an eligible plan.
3. Open the Codex extension and sign in with your account, if eligible.
4. Open the Claude Code extension and sign in with your own account, if eligible.
5. Use VS Code Command Palette > MCP: List Servers to review and start project MCPs.
6. Do not run firebase login as a Contributor. PR #4 includes the local emulators; DEV cloud credentials are Maintainer-only and separately approved.
7. Run RUN-APP.cmd for the Flutter browser preview. Keep the command window open while testing.

A free public GitHub Actions runner does not make Claude/Codex/Copilot usage free. No agent is authorized to deploy, commit secrets, or change accepted architecture just because its extension is installed.

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

VERIFY-DEVELOPER-WINDOWS.cmd checks local executables, key VS Code extensions, and MCP JSON structure. It writes a diagnostics-only report to the TEMP folder. It cannot prove MCP handshakes, logins, or a fresh machine installation succeeded.

For errors, send a screenshot and the diagnostics report, **never API keys or credentials**.

Sources:
- Flutter MCP and skills: https://docs.flutter.dev/ai/get-started
- VS Code MCP configuration: https://code.visualstudio.com/docs/agents/reference/mcp-configuration
- Firebase MCP: https://firebase.google.com/docs/ai-assistance/mcp-server
- Playwright MCP: https://github.com/microsoft/playwright/blob/main/docs/src/getting-started-mcp.md
- GitHub MCP read-only endpoint: https://github.com/github/github-mcp-server/blob/main/docs/remote-server.md
