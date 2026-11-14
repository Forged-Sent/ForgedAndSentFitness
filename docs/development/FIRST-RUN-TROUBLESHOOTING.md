# Forged & Sent: guided Windows onboarding and AI help

## PowerShell 7 (automatic)

**PowerShell 7.6 LTS or newer is the standard for this repo.** The double-click .cmd entrypoints begin with the built-in Windows PowerShell 5.1 only to run tooling/windows/bootstrap-pwsh.ps1. The bootstrap checks for pwsh, installs or updates PowerShell using the official WinGet ID Microsoft.PowerShell, checks it is at least 7.6, and launches all developer scripts with pwsh.exe. Windows PowerShell 5.1 stays installed; don't remove it. The launchers do not permanently change execution policy.

The full and preview installers check for updates. `launchers/windows/2 - Run the app.cmd` does not check for updates every time. If WinGet/App Installer is missing, installer permission is declined, or a restart is needed, the wizard prints a clear fix and stops rather than silently using 5.1.

Run pwsh --version to check it yourself. VS Code now defaults to the PowerShell 7 terminal for this workspace. PowerShell 7 is installed side-by-side with 5.1.

Official installation instructions: https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows

## One entry point for everyone

Open the **existing Git clone**, switch to `main` (`git switch main`, `git fetch origin`, `git pull --ff-only`). Then double-click **START-WINDOWS.cmd** (Mac: **START-MAC.command**). No ZIP is needed. If you do not have a clone, follow [Windows quickstart](WINDOWS-QUICKSTART.md) to install Git and clone the repository. Always preserve uncommitted work before switching.

The wizard keeps the primary choices short:

| Option | What it does |
| --- | --- |
| 1 | Set up this computer: Contributor tools, any optional AI assistants, and Git identity (same as `launchers/<os>/1 - Set up this computer`) |
| 2 | Run Flutter in Chrome (same as launcher 2) |
| 3 | Start practice Firebase (the demo emulators) in a **separate** window (launcher 3) |
| 4 | Run Flutter against practice Firebase, after option 3 reports ready (launcher 4) |
| 5 | Check my setup: missing tools with WHY/FIX explanations (launcher 5) |
| 6 | Preview-only setup (view the app without editing tools) |
| 7 | Open VS Code and the [first contribution guide](FIRST-CONTRIBUTION.md) |
| 8 | Advanced: Android, GitHub sign-in, Git identity, project MCP locations |

The Flutter app is early: it opens on Today with the day's devotional; the other tabs are placeholders. Most of the HTML prototype is not migrated yet ([parity](../knowledge/PROTOTYPE-PARITY.md)).

## AI and MCP tools

Contributor setup lets you pick **any combination** of optional assistants (Codex, Claude Code, GitHub Copilot, Google's Antigravity CLI) or none; type the numbers, for example `2,4`. No paid AI subscription is required to compile Flutter. The default MCP files configure only **Dart, Playwright and Context7**. Each must initialize and return tools/list before it is considered connected.

GitHub read-only MCP, Figma, Maestro and Google Developer Knowledge are **advanced opt-ins**; see [MCP security](MCP-SECURITY.md) and the project's audited `mcp-optional.example` manifests. A Google Developer Knowledge key is never required for the normal setup. No cloud Firebase MCP or PROD credentials are enabled.

Maestro requires an actual mobile device/emulator; its Windows installer uses a version-pinned release ZIP **for the Maestro tool only**. You never download the Forged & Sent repository as a ZIP.

## The setup tells you why it failed

Run menu option 5 or `launchers/windows/5 - Check my setup.cmd`. The diagnostic prints lines like:

[MISSING] Python
 WHY: Python 3.11+ is required to generate the Architecture Atlas.
 FIX: Run Contributor setup, restart the terminal and retry.

It creates two files in the Windows temporary folder:
- ForgedAndSent-Diagnostics-YYYYMMDD-HHMMSS.txt: a detailed local report
- ForgedAndSent-AskAI-YYYYMMDD-HHMMSS.txt: a safe, ready-to-paste troubleshooting prompt

The wizard offers to **copy the AI prompt to the clipboard**, but it does **not send anything to an AI service automatically**. Review it before sharing. The prompt contains only named issue codes, short explanations, and recommended fixes, not token values, email addresses, project IDs, environment variables, or private file paths.

## Common reasons for failure

| Problem | Reason | What to do |
|---|---|---|
| WinGet not found | App Installer missing or Windows update pending | Install/update App Installer in Microsoft Store, restart |
| Flutter not found | SDK download failed, PATH not refreshed | Rerun setup, restart terminal |
| Android build unavailable | Android Studio, SDK licenses or emulator not ready | Run `launchers/windows/more/Android setup.cmd`, complete first-run wizard and licenses |
| Python missing | Python 3.11+ is not available for Atlas/review | Rerun Contributor setup, reopen terminal |
| Git identity missing | A new Git install cannot label commits | Use wizard > More options > Git name/email (GitHub noreply is fine) |
| Maestro missing (optional) | Mobile-only CLI or Java not installed | Install Mobile tools only when you need native device tests |
| Firebase cloud MCP unavailable | Disabled deliberately for Contributors | Use the local practice Firebase (emulators) now; a separate cloud DEV project can be created later |
| Figma MCP won't connect (optional) | Figma access not provisioned | Only enable the optional server after authorizing Figma |
| Google Knowledge 401/403 (optional) | Google Cloud API access missing | Leave this optional server disabled unless you need it |
| GitHub MCP won't connect (optional) | OAuth not granted | Use VS Code Source Control and GitHub login for PRs; enable read-only MCP later if desired |
| Context7 unavailable | Internet, service or API quota | Check network and provider status |
| VS Code MCP missing | Wrong workspace, restricted trust or extension support | Open the cloned repository folder, review trust, run MCP: List Servers |
| AI extension missing | Your chosen assistant was not installed or authorized | Rerun Contributor setup and select that assistant, or install its official VS Code extension |
| Company laptop blocks setup | Organization installation restrictions | Ask IT; never bypass enterprise policies |

## What should you ask AI?

The generated AskAI prompt is ready to paste into Claude, Codex, or ChatGPT. It asks for the **smallest next repair step**, then asks for a fresh diagnostic. It never asks AI to bypass security restrictions or read private keys.

## Security and validation limits

- The script avoids saving credentials or invoking paid services automatically.
- MCP tools are powerful; review per-tool permissions, especially Firebase write/deploy access.
- The GitHub connection is read-only.
- Diagnostics confirm presence/config only, not live MCP protocol handshakes.
- Windows CI performs PowerShell syntax and synthetic diagnostics tests, but cannot simulate a fresh colleague workstation with every interactive sign-in.
- No developer needs the owner's private Linux server.

Official docs:
https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli
https://developers.figma.com/docs/figma-mcp-server/remote-server-installation/
https://developers.google.com/knowledge/mcp
https://context7.com/docs/resources/troubleshooting
https://code.visualstudio.com/docs/agents/reference/mcp-configuration
