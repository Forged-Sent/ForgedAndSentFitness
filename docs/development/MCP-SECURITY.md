# MCP security and optional tooling

**Default Contributor tools:** Dart, Playwright and Context7. Each is configured in the VS Code, Claude and Codex project files. They still require an actual initialize + tools/list handshake before anyone calls them connected. No cloud Firebase MCP is included. Demo Firebase Auth/Firestore/Storage use the local CLI, not an MCP server.

To reduce confusing first-run errors, GitHub read-only MCP, Figma, Maestro and Google Developer Knowledge are **opt-in**. See the audited example manifests:
- `.vscode/mcp-optional.example.json` for VS Code (includes masked Google API key prompt)
- `.mcp.optional.example.json` for Claude
- `.codex/config.optional.example.toml` for Codex

They are intentionally **not auto-loaded** by the clients. A maintainer can review the needed optional server and explicitly add it to the project/client MCP settings after installing its prerequisites and authorizing the provider. Do not commit personal keys. Client-specific behavior may change; confirm connectivity in **MCP: List Servers** or the provider's equivalent.

You do not need Maestro without a mobile device-testing setup, Figma without a Figma account, or Google Developer Knowledge without its own Google API key. The optional GitHub MCP is read-only; GitHub CLI/VS Code Source Control is sufficient for beginners to create PRs.

The project Node launcher `tooling/mcp/launch.mjs` allowlists Dart, Playwright and optional Maestro. Production Firebase credentials, cloud deployment, auto-login and default cloud Firebase MCP are forbidden. Review ADR-0002 before adding any DEV-only cloud integration.
