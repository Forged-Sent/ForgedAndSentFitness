# Architecture Atlas: interactive, offline system explorer

Open the architecture as a **real webpage**, not a static image. The HTML/CSS/JavaScript lives in this folder; a Python generator builds a catalog from the currently checked-out repository. No CDN, external libraries, network access or login is required to view it.

## One-click entrypoints

- **Windows:** double-click `ARCHITECTURE-WINDOWS.cmd` from the repository root.
- **Mac:** double-click `ARCHITECTURE-MAC.command` from the repository root.
- **Any OS:** `python3 tooling/architecture/build_explorer.py --write`, then open `build/architecture-explorer/Architecture-Atlas.html` in a browser. This **single HTML file** contains its own styling, JavaScript and generated catalog, so it can be emailed or shared without companion files.
- **GitHub Actions:** each PR run produces a downloadable `forged-sent-architecture-atlas` artifact. Download and extract the entire artifact, then open `Architecture-Atlas.html` locally. It is fully self-contained. The archive also includes `index.html`, `site.css`, `site.js` and generated `data.js` for conventional web hosting.

Use a real Git clone and Python 3.11+ (provided by the current onboarding scripts). The generator reads `git ls-files` and therefore covers **every tracked path** in that revision, including docs, tools, agent skills, tests, seed data and all archived HTML snapshots. It does not include ignored, untracked, secret, or external private files.

## What can I click?

1. **System map:** pick Implemented, Planned or Delivery. Click each component to view responsibilities, notes, owned source files, interfaces and linked components. Current and proposed boundaries are explicitly separated.
2. **Source explorer:** search filename, symbol, or description. The default hides archived snapshots to keep the list manageable, but choose **Everything** to reveal all tracked files. File details show detected declarations, excerpts (for reasonably small text files), source-line links, dependencies, reverse references and external imports.
3. **Agent playbook:** open Codex/Claude/Gemini skills and choose who authored the change. The website prepares the appropriate independent review command for copying; it never runs an AI model or spends tokens.
4. **Getting started:** choose Windows or Mac and copy setup, architecture-generation, and review commands.
5. **Documentation Library:** read the complete original tracked Markdown documents in the browser with headings, tables, code blocks, an on-page contents menu, and links back to exact Git source lines. Mermaid diagram sources direct you to the interactive system map.

## Keyboard shortcuts

| Key | Action |
|---|---|
| `/` | Focus file/function search |
| `?` | Show shortcut reference |
| `1` / `g` | System map |
| `2` / `f` | Source explorer |
| `3` / `a` | Agent playbook |
| `4` | Getting started |
| `5` / `d` | Documentation Library | 
| `j` / `k` | Move through filtered source files |
| `+` / `-` | Zoom architecture map |
| `0` | Reset map zoom |
| `Enter` / `Space` | Activate focused graph node or button |
| `Esc` | Close detail drawer or shortcuts |

Keyboard shortcuts do not intercept text typed into an input or dropdown.

## How the source index is built

- **Files:** all entries from `git ls-files`, sorted, classified and made searchable. Large archives remain in the index but their multi-megabyte source is deliberately not embedded.
- **Documentation:** all tracked Markdown files are embedded for safe in-browser reading. The browser renders a restricted subset without executing raw HTML or linked code.
- **Definitions:** Python AST for classes/functions and docstrings; best-effort Dart, JS, PowerShell, shell, YAML CI jobs and Markdown headings from text patterns; JSON config keys for selected files. Names and source line numbers link to the exact Git revision used by the generator.
- **Dependencies:** explicit Dart/JS imports, best-effort Python local imports, Markdown links and lexical file path mentions. Every edge has a kind and confidence label. The reverse index shows which tracked files refer to a given path.
- **Behaviors:** descriptions in `model.json` are a **human-maintained** glossary for selected key functions and components; a declaration without a vetted description is identified as undocumented, never filled with invented behavior.
- **Planned features:** sourced from `docs/architecture/SYSTEM.md` and maintained in `model.json`. They are not detected as implemented.

### Important limitations

The site is an **explainable source inventory**, not a complete language-server, compiler AST, runtime call graph, dependency injection resolver, or execution tracer. Python functions are AST-based; Dart and shell symbol detection is lexical and can miss constructors, closures, generated symbols and dynamic calls. A line that mentions a path is not necessarily a build/runtime dependency. These are labeled as `mentions path` rather than `import`. No inference is presented as a verified runtime call.

**Never publish credentials or personal records** into repository files or `model.json`. This site and the GitHub Actions artifact are based on the public repository. Code excerpts with recognizable private-key/token markers are suppressed, but this is not a comprehensive secret scanner.

## Keeping the map accurate

- Actual code inventory is regenerated **every CI run**, so no hand editing of generated `data.js` is needed.
- To refresh locally: `python3 tooling/architecture/build_explorer.py --write`.
- To validate model-file references: `python3 tooling/architecture/build_explorer.py --check`.
- When creating a new architectural boundary, update `docs/architecture/SYSTEM.md`, `docs/architecture/explorer/model.json`, and (for lasting decisions) an ADR in the same PR.
- When changing Dart imports or function declarations, also refresh `docs/architecture/CODE-MAP.md` using `python3 tooling/architecture/generate.py --write` as already enforced by CI.
- The `architecture-atlas` CI job builds the site and uploads a preview artifact. Required `ci-gate` fails if generation or validation fails.

## Hosting

The artifact works without a web server when extracted on a computer. Publishing a live URL with GitHub Pages is optional and **not enabled by these files**. If you choose to publish it later, serve the generated `build/architecture-explorer` directory from a separate trusted Pages deployment workflow; do not accidentally replace the existing root `index.html` prototype. Official publishing guidance: https://docs.github.com/en/pages/getting-started-with-github-pages/creating-a-github-pages-site
