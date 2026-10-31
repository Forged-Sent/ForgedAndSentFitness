# MacBook setup | Forged & Sent

The draft PR #3 Mac foundation supports the same safe starting experience as Windows: a guided launcher, web Preview, local developer tools, read-only diagnostics, and project-scoped AI integrations. Full device testing belongs to PR #4.

## Quick start without typing terminal commands

1. Download the entire feature branch ZIP for preview, or clone the repo properly if you will contribute changes.
2. Double-click **FIRST-RUN-MAC.command** in Finder. Alternatively use **SETUP-MAC.command** for browser Preview or **SETUP-DEVELOPER-MAC.command** for Contributor tools.
3. If prompted, approve installation of Apple's Command Line Tools and reopen the launcher after completion.
4. If Homebrew is missing, the wizard opens https://brew.sh. Install it once using the official instructions, then reopen the launcher. On Apple Silicon, Homebrew offers a signed .pkg on its official releases page. The project never silently executes a downloaded installer script.
5. The wizard installs or reuses Chrome, VS Code, and the pinned Flutter 3.47.8 SDK. Contributor also installs Node.js, GitHub CLI, Codex CLI, Claude Code, and Firebase CLI 15.34.2 for **future local emulators**.
6. Double-click **RUN-APP-MAC.command** to open the starter Flutter preview in Chrome. **VERIFY-DEVELOPER-MAC.command** reports missing or optional tools with repair instructions.

The setup checks for already-installed tools, is safe to rerun, and does not delete an existing Flutter SDK. VS Code uses a workspace `dart.flutterSdkPath` pointing to `~/develop/flutter`, so Finder/Dock launches can locate the SDK without shell PATH changes. Contributor requires Node.js 20+. If a different SDK occupies your dedicated Flutter folder, setup reports the mismatch rather than overwriting it.

Mac setup requires macOS and either Apple Silicon or a supported Intel Mac. Flutter is deprecating Intel-hosted development, so Apple Silicon is preferable for future Flutter versions.

## What is intentionally NOT automatic

- Homebrew's first installation needs user approval. No remote shell installer is automatically downloaded or run.
- Mac's Xcode Command Line Tools can prompt through Apple's own installer. Full Xcode, iOS simulators, Android Studio/SDK, Java 21 and Maestro mobile flows are for PR #4.
- No Firebase cloud login, production keys, Firebase cloud MCP, or automatic flutterfire configure.
- GitHub, Claude, Codex, Figma and other services each require your own intentional account authorization.
- No global shell profile modifications, no direct pushes to main, and no bypass of macOS security settings.
- The Flutter browser preview is still a **starter scaffold**, not the finished Forged & Sent mobile application.

## MCP compatibility

Shared project configurations support Windows and Mac using a portable, allowlisted Node launcher. Supported local servers: Dart, Playwright and optional Maestro. Remote servers: read-only GitHub, Context7, Figma, and (in VS Code) Google Developer Knowledge with a masked API key prompt.

The **Preview** profile does not install Node.js. Local Dart/Playwright/Maestro MCP entries use the Node launcher and therefore cannot start until Node.js is available (normally after choosing **Contributor**). A declared server has status **ConfiguredNotConnected** until a live MCP initialize and tools/list handshake has succeeded. Missing optional Mobile tools must not fail Preview. The Contributor profile remains explicitly incomplete until PR #4 implements Firebase Local Emulator Suite app wiring.

## Troubleshooting

| Symptom | Safe next step |
| --- | --- |
| Apple developer tools installer opens | Complete it and rerun first-run |
| Homebrew missing | Install from https://brew.sh, then rerun |
| Different Flutter version found | Do not delete it. Ask a maintainer to align the SDK to 3.47.8 |
| Gatekeeper blocks downloaded file | Verify the repository is trusted and move the extracted folder out of Downloads; use System Settings → Privacy & Security → Open Anyway for the first launcher only. Alternatively open Terminal, type `bash ` (with a space), drag FIRST-RUN-MAC.command into Terminal and press Return. Never disable Gatekeeper or strip quarantine attributes |
| Missing VS Code or Chrome | Run SETUP-MAC.command or install through their official site |
| GitHub / Codex / Claude sign-in missing | Sign in separately from the provider's normal interface |
| MCP says ConfiguredNotConnected | Start it from your editor and verify tools/list |
| EmulatorWiring says NotApplicable | Expected until PR #4. Do not claim real Firebase integration |
| Installer reports blocked network or software restrictions | Retry after restoring connectivity or ask IT for package manager permission, with no credential sharing |

## Verification policy

PR #3 adds macos-15 shell syntax and simulated-profile self-tests, portable Node MCP unit tests, and an actual Flutter browser build. These checks do not run the Homebrew/Command Line Tools first-install flow. Hosted-runner checks **do not prove** that a clean personal MacBook can complete the entire first-time experience. We still need a real fresh Mac test and a rerun without reinstalls before inviting colleagues.

The canonical repository is https://github.com/Forged-Sent/ForgedAndSentFitness; keep all changes on a reviewed feature branch, not main.
