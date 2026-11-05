# Knowledge workspace: Obsidian, prototype and Architecture Atlas

**Purpose:** read one Git-controlled knowledge base and interact with the actual prototype and generated Atlas, without copying either HTML source into the vault.

## What is already real

- `docs/` contains the Markdown knowledge base; [HOME.md](../HOME.md) is the beginner entrypoint. Obsidian is optional.
- The actual JavaScript-heavy prototype remains at repository-root `index.html`. It is not the Flutter application and not a production backend.
- `tooling/architecture/build_explorer.py` generates the Architecture Atlas at `build/architecture-explorer/Architecture-Atlas.html`. The generated directory is ignored by Git.
- The new preview server exposes only an explicit list of public HTML/Atlas files, not the whole repository.

## Windows

1. Use a **Git clone** set up with `launchers/windows/1 - Set up this computer.cmd` (Contributor). Python 3.11+ is required.
2. Double-click `launchers/windows/more/Knowledge workspace.cmd` in File Explorer. Keep its terminal window open while browsing. It regenerates the Atlas and starts a loopback-only server.
3. Open the printed landing URL in Chrome/Edge, or in **desktop** Obsidian's core Web viewer. If you use Obsidian, open the `docs` folder as a vault and select **Open web page** in Web viewer; paste the URL.
4. Test the prototype's menus and JavaScript controls (see [what the prototype can and cannot do here](#what-the-prototype-can-and-cannot-do-here)), and the Atlas tabs, source search and documentation.
5. To stop, close the terminal window. Ctrl+C also works; if Windows asks `Terminate batch job (Y/N)?`, answer **Y**.

## Mac

1. Use a Git clone set up with `launchers/mac/1 - Set up this computer.command` (Contributor). Python 3.11+ is required.
2. Double-click `launchers/mac/more/Knowledge workspace.command` (or run `bash "launchers/mac/more/Knowledge workspace.command"` from Terminal). Keep its terminal window open.
3. Open the printed URL in Safari/Chrome or **desktop** Obsidian's core Web viewer, with `docs/` as the vault.
4. Repeat the interaction checks. To stop, press Ctrl+C or close the Terminal window. If Finder blocks the script, inspect the file and use Terminal rather than disabling system security globally.

## Local URLs

- Landing page: http://127.0.0.1:43117/
- Actual prototype: http://127.0.0.1:43117/index.html
- Generated Atlas: http://127.0.0.1:43117/build/architecture-explorer/Architecture-Atlas.html

The server does **not** start Firebase, access production accounts, install plugins, or write to the prototype. The only generated files are under the already-ignored `build/architecture-explorer/` directory. Only one preview can own port 43117. A second launch stops with **"Port 43117 is already in use"** instead of sharing the port (on Windows the server requests exclusive ownership). Close the other preview window and retry; if you just closed one, wait about a minute. Never trust a page on this port unless a preview window says it is serving.

## What the prototype can and cannot do here

The root `index.html` is the **authoritative prototype artifact**, served exactly as checked out. It was built to run inside the Claude-hosted runtime (`window.claude`) with that runtime's `/_blob/` media service, and neither exists on this loopback server.

| Works here | Expected to be missing here |
|---|---|
| Layout, navigation, menus and other in-page JavaScript | Sign-in identity and member profile |
| Static content and styling (web fonts load from the network if online) | Saved data and persistence between sessions |
| Inspecting the exact checked-out HTML | Shared posts, team feeds and other sharing |
| | Uploaded photos, avatars, banners and PDFs (`/_blob/` returns 404) |

In the browser console, expect a 404 for `/favicon.ico` and, when offline, failed Google Fonts requests; both are harmless. The page itself shows messages such as "Sign in to claude.ai to check off boxes" and "No standard tasks yet".

**Missing identity, persistence, sharing or uploaded media in this view is expected. It does not indicate a Firebase or Flutter failure.** Do not widen the server or add a `/_blob/` route to "fix" it; this viewer stays a small read-only file server.

To click through those flows with in-memory fake data, use the existing mock preview: run `python3 dev/make_preview.py` and open `dev/preview.html` in a browser. It is generated from `index.html` (never edit it by hand), resets on reload, still shows no uploaded media, and is never proof of real identity, storage or sharing.

## Security and limitations

- Bound to IPv4 `127.0.0.1`, with a strict Host check and allowlist. It denies `.git`, `.env`, docs, source, secrets, directory listings, symlink escapes and arbitrary paths.
- It is a **read-only HTTP file server**, not an authenticated app. The prototype's JavaScript executes in the viewer/browser. Do not enter real credentials, personal fitness/faith data, or secrets into it. Network-loaded third-party resources, if any, need separate review.
- Obsidian community plugins have broad permissions. No plugin installation, Obsidian Git automation, MCPVault, Agent Client, Claudian, or automatic Git sync is required. Keep personal notes in a separate private vault.
- Standard Markdown links to localhost may open in your external browser. To keep a page **inside Obsidian**, paste its URL into the official Web viewer. The viewer and browser are fallback alternatives, not proof of equivalent sandbox behavior.
- CI runs the server's unit tests on Linux, Windows and macOS, starts the real `serve_project.py` process on each, and checks on Windows that a second listener cannot share the port. **Double-click/Finder launch, the `.cmd` launcher itself, Obsidian Web viewer interactions, browser console and live prototype behavior are NOT VERIFIED until a person tests them.** Obsidian is not installed by CI, and Web viewer is desktop-only.

## Acceptance checklist on both operating systems

1. First run and rerun succeed without installing new tools or requiring Firebase cloud login. Launching a **second** preview while one is running is rejected with "Port 43117 is already in use".
2. Both URLs load from the **checked-out branch**, no second editable copy of the prototype/Atlas exists, and refresh reflects source changes after regenerating the Atlas.
3. Click actual prototype navigation and JavaScript controls. Confirm that what is missing matches [the documented limits](#what-the-prototype-can-and-cannot-do-here) exactly (identity, persistence, sharing, `/_blob/` media) and nothing else breaks. Record any external-network dependency.
4. In Atlas test all five views, search, a source detail, documentation, and keyboard shortcuts `/`, `1` through `5`, `?`.
5. Request `/.git/config`, `/docs/HOME.md` and `/seed/` and confirm rejection. Stop server and confirm URLs no longer respond.
6. Repeat in Obsidian Web viewer and external browser; record differences, screenshots, OS/version and tested Git SHA.

**Fallback:** the existing `launchers/windows/more/Architecture Atlas.cmd` or `launchers/mac/more/Architecture Atlas.command` opens the self-contained Atlas offline; the original `index.html` can be opened in a regular browser when compatible. No localhost or Obsidian integration is required to continue Flutter development.

## Next phases and rollback

This follow-up was stacked on PR #26 (PR #4 is merged); merge it after PR #26. Physical onboarding acceptance for PR #4 is recorded in [CURRENT.md](../knowledge/CURRENT.md); the checklist above for this preview is still a person-run test. Phase 1 is this optional docs vault landing and risk-based contract templates; phase 2 is this minimal localhost preview and launcher; phase 3 is deterministic feature metadata checks in CI. Advanced worktree automation, an environment doctor, read-only MCPVault trial, Obsidian Bases dashboards and RAG are **deferred** until the basic path is physically verified. Rollback is to remove the two launchers/server and use existing offline Atlas/browser paths; Markdown and Git history remain intact.
