# Knowledge workspace: Obsidian, prototype and Architecture Atlas

**Purpose:** read one Git-controlled knowledge base and interact with the actual prototype and generated Atlas, without copying either HTML source into the vault.

## What is already real

- `docs/` contains the Markdown knowledge base; [HOME.md](../HOME.md) is the beginner entrypoint. Obsidian is optional.
- The actual JavaScript-heavy prototype remains at repository-root `index.html`. It is not the Flutter application and not a production backend.
- `tooling/architecture/build_explorer.py` generates the Architecture Atlas at `build/architecture-explorer/Architecture-Atlas.html`. The generated directory is ignored by Git.
- The new preview server exposes only an explicit list of public HTML/Atlas files, not the whole repository.

## Windows

1. Use a **Git clone** and the existing `FIRST-RUN-WINDOWS.cmd` Contributor setup. Python 3.11+ is required.
2. Double-click `OPEN-KNOWLEDGE-WINDOWS.cmd` from the repository root. Keep its terminal window open while browsing. It regenerates the Atlas and starts a loopback-only server.
3. Open the printed landing URL in Chrome/Edge, or in Obsidian's **core Web viewer**. If you use Obsidian, open the `docs` folder as a vault and select **Open web page** in Web viewer; paste the URL.
4. Test the prototype's real menus and JavaScript controls, and the Atlas tabs, source search and documentation. Closing the terminal stops the server.

## Mac

1. Use a Git clone and the existing `FIRST-RUN-MAC.command` Contributor setup. Python 3.11+ is required.
2. Double-click `OPEN-KNOWLEDGE-MAC.command` (or run `bash OPEN-KNOWLEDGE-MAC.command` from Terminal). Keep its terminal window open.
3. Open the printed URL in Safari/Chrome or Obsidian's core Web viewer, with `docs/` as the vault.
4. Repeat the interaction checks. Quit with Ctrl+C. If Finder blocks the script, inspect the file and use Terminal rather than disabling system security globally.

## Local URLs

- Landing page: http://127.0.0.1:43117/
- Actual prototype: http://127.0.0.1:43117/index.html
- Generated Atlas: http://127.0.0.1:43117/build/architecture-explorer/Architecture-Atlas.html

The server does **not** start Firebase, access production accounts, install plugins, or write to the prototype. The only generated files are under the already-ignored `build/architecture-explorer/` directory. If port 43117 is occupied, stop the old process; do not use an untrusted process claiming to be the project preview.

## Security and limitations

- Bound to IPv4 `127.0.0.1`, with a strict Host check and allowlist. It denies `.git`, `.env`, docs, source, secrets, directory listings, symlink escapes and arbitrary paths.
- It is a **read-only HTTP file server**, not an authenticated app. The prototype's JavaScript executes in the viewer/browser. Do not enter real credentials, personal fitness/faith data, or secrets into it. Network-loaded third-party resources, if any, need separate review.
- Obsidian community plugins have broad permissions. No plugin installation, Obsidian Git automation, MCPVault, Agent Client, Claudian, or automatic Git sync is required. Keep personal notes in a separate private vault.
- Standard Markdown links to localhost may open in your external browser. To keep a page **inside Obsidian**, paste its URL into the official Web viewer. The viewer and browser are fallback alternatives, not proof of equivalent sandbox behavior.
- This PR provides static server unit tests and CI. **Actual Windows/Mac Finder launch, Obsidian Web viewer JavaScript interactions, browser console, offline assets and live prototype behavior are NOT VERIFIED until a person tests them.** Obsidian is not installed by CI.

## Acceptance checklist on both operating systems

1. First run and rerun succeed without installing new tools or requiring Firebase cloud login.
2. Both URLs load from the **checked-out branch**, no second editable copy of the prototype/Atlas exists, and refresh reflects source changes after regenerating the Atlas.
3. Click actual prototype navigation and JavaScript controls; confirm images, relative assets and expected UI states. Record any external-network dependency.
4. In Atlas test all five views, search, a source detail, documentation, and keyboard shortcuts `/`, `1` through `5`, `?`.
5. Request `/.git/config`, `/docs/HOME.md` and `/seed/` and confirm rejection. Stop server and confirm URLs no longer respond.
6. Repeat in Obsidian Web viewer and external browser; record differences, screenshots, OS/version and tested Git SHA.

**Fallback:** the existing `ARCHITECTURE-WINDOWS.cmd` or `ARCHITECTURE-MAC.command` opens the self-contained Atlas offline; the original `index.html` can be opened in a regular browser when compatible. No localhost or Obsidian integration is required to continue Flutter development.

## Next phases and rollback

This is a follow-up stacked on PR #26, which is stacked on PR #4. **Do not merge before those bases stabilize and physical onboarding acceptance is recorded.** Phase 1 is this optional docs vault landing and risk-based contract templates; phase 2 is this minimal localhost preview and launcher; phase 3 is deterministic feature metadata checks in CI. Advanced worktree automation, an environment doctor, read-only MCPVault trial, Obsidian Bases dashboards and RAG are **deferred** until the basic path is physically verified. Rollback is to remove the two launchers/server and use existing offline Atlas/browser paths; Markdown and Git history remain intact.
