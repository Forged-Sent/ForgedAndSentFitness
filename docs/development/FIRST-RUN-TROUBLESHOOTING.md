# Forged & Sent: guided Windows onboarding and AI help

## PowerShell 7 (automatic)

**PowerShell 7.6 LTS or newer is the standard for this repo.** The double-click .cmd entrypoints begin with the built-in Windows PowerShell 5.1 only to run tooling/windows/bootstrap-pwsh.ps1. The bootstrap checks for pwsh, installs or updates PowerShell using the official WinGet ID Microsoft.PowerShell, checks it is at least 7.6, and launches all developer scripts with pwsh.exe. Windows PowerShell 5.1 stays installed; don't remove it. The launchers do not permanently change execution policy.

The full and preview installers check for updates. RUN-APP.cmd does not check for updates every time. If WinGet/App Installer is missing, installer permission is declined, or a restart is needed, the wizard prints a clear fix and stops rather than silently using 5.1.

Run pwsh --version to check it yourself. VS Code now defaults to the PowerShell 7 terminal for this workspace. PowerShell 7 is installed side-by-side with 5.1.

Official installation instructions: https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows

## One entry point for everyone

Extract the ZIP of the reviewed feature branch into a normal folder (not inside Downloads ZIP preview), then double-click **FIRST-RUN-WINDOWS.cmd**.

The menu is designed for people who are not software developers:

| Option | Purpose |
|---|---|
| 1 | Full development setup / repair: Flutter, VS Code, CLI tools, MCPs, AI extensions, optional Android Studio |
| 2 | Preview only: installs fewer dependencies, then launch in Chrome |
| 3 | Check requirements: prints each missing component, why it is needed, and how to fix it |
| 4 | Sign into GitHub and Firebase only if requested; never enters passwords in a script |
| 5 | Open VS Code and guide MCP trust/authorization |
| 6 | Launch the Flutter starter in Chrome |
| 7 | Open troubleshooting instructions |

The initial Flutter app is a basic starter screen. The original web prototype is not yet migrated.

## Installed/configured MCP servers

The version-controlled VS Code MCP configuration contains **eight** integrations and intentionally **no Sentry**:

1. Dart / Flutter MCP (local Dart SDK)
2. Firebase MCP (Node.js CLI, authenticated when explicitly approved)
3. Playwright MCP (Node.js, Chrome)
4. GitHub hosted MCP (read-only, OAuth)
5. Context7 hosted MCP (current programming documentation)
6. Figma hosted MCP (OAuth)
7. Maestro CLI MCP (local Java 17+, plus Android emulator/phone for actual tests)
8. Google Developer Knowledge hosted MCP (Google Cloud project + API enabled + personal API key)

The last four are not required merely to preview the app. Remote MCPs may require network access, terms, a paid plan or quota. Installing a config does not mean a server is authenticated or connected.

**Google key handling:** VS Code will prompt for the key as a password field, based on an input variable in mcp.json. Never paste it into a repository file, issue, or AI conversation. Enable Google Developer Knowledge API and create a restricted personal key in your Google Cloud account before attempting connection.

**Maestro:** Native Windows installation uses the official GitHub ZIP and Java 17 JDK. It does not provide an Android emulator by itself. Android Studio and device pairing are optional separate steps. A Mac is required for iOS simulator work.

## The setup tells you why it failed

Run menu option 3 or VERIFY-DEVELOPER-WINDOWS.cmd. The diagnostic prints lines like:

[MISSING] Maestro
 WHY: Maestro CLI is missing, so Android/iOS UI automation MCP cannot start.
 FIX: Rerun developer setup and verify Java 17.

It creates two files in the Windows temporary folder:
- ForgedAndSent-Diagnostics-YYYYMMDD-HHMMSS.txt: a detailed local report
- ForgedAndSent-AskAI-YYYYMMDD-HHMMSS.txt: a safe, ready-to-paste troubleshooting prompt

The wizard offers to **copy the AI prompt to the clipboard**, but it does **not send anything to an AI service automatically**. Review it before sharing. The prompt contains only named issue codes, short explanations, and recommended fixes, not token values, email addresses, project IDs, environment variables, or private file paths.

## Common reasons for failure

| Problem | Reason | What to do |
|---|---|---|
| WinGet not found | App Installer missing or Windows update pending | Install/update App Installer in Microsoft Store, restart |
| Flutter not found | SDK download failed, PATH not refreshed | Rerun setup, restart terminal |
| Android build unavailable | Android Studio, SDK licenses or emulator not ready | Run SETUP-ANDROID.cmd, complete first-run wizard and licenses |
| Maestro missing | Native CLI ZIP or Java 17 install failed | Rerun developer setup, check Java/WinGet and download restrictions |
| Firebase MCP won't connect | Firebase CLI, login or project permissions missing | Run firebase login and select DEV project |
| Figma MCP won't connect | Figma account authorization pending | Start server in VS Code, sign into Figma |
| Google Knowledge 401/403 | Google Cloud API not enabled or invalid/restricted key | Enable Developer Knowledge API, create/restrict API key, reconnect |
| GitHub MCP won't connect | OAuth not granted | Sign in to GitHub and reauthorize read-only MCP |
| Context7 unavailable | Internet, service or API quota | Check network and provider status |
| VS Code MCP missing | Wrong workspace, restricted trust or extension support | Open extracted repository folder, review trust, run MCP: List Servers |
| Claude/Codex extension missing | Store/network/IT policy or account plan | Reinstall from VS Code Extensions; sign in individually |
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
