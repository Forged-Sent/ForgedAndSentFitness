# Forged & Sent developer knowledge

Welcome. **Git stores project decisions and history; code and tests establish what is implemented.** Obsidian is an optional way to read these Markdown files, not a second database or approval authority.

## Start with one path

1. [Set up Windows or Mac](development/START_HERE.md) using the existing first-run wizard.
2. [Read the current knowledge index](knowledge/INDEX.md) and [what is verified](knowledge/CURRENT.md).
3. [Browse the live HTML prototype and Architecture Atlas](development/KNOWLEDGE-WORKSPACE.md). These are interactive webpages, not Markdown previews.
4. [Choose a feature contract](features/README.md) before changing app behavior.
5. [Make your first Draft PR](development/FIRST-CONTRIBUTION.md), with one optional AI assistant and deterministic tests.

## Important boundaries

- The active HTML prototype is the repository-root `index.html`; archived `versions/` files are historical references. Do not copy either into this vault.
- The Architecture Atlas is generated from the checked-out Git revision. It is a source explorer, **not proof of runtime behavior**.
- [Accepted ADRs and design intent](architecture/SYSTEM.md) are different from [observed implementation](architecture/CODE-MAP.md).
- Agents must not invent scoring, membership, privacy, offline sync, authentication or health-data policy. [Product decisions and handoffs](knowledge/AGENT-OPERATIONS.md) require explicit ownership.
- This is a public repository. Never store real member records, private prayers, health information, credentials or personal journals here.

## Optional Obsidian

In Obsidian choose **Open folder as vault** and select this repository's `docs` folder. No community plugin, MCP server, auto-sync or cloud account is required. Keep local `.obsidian/` settings untracked. Standard Markdown links also work on GitHub and in VS Code.

The [Knowledge Workspace guide](development/KNOWLEDGE-WORKSPACE.md) explains the official Web viewer, the loopback preview, its limitations, and a normal-browser fallback.
