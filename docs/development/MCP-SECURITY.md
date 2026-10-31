# Default AI tool access and project scope

**Contributor default:** no Firebase cloud MCP. An authenticated Firebase CLI is
not a safe authorization boundary for a demo project. Keep production credentials
off developer machines. Firebase Local Emulator Suite arrives in PR #4.

The common workspace MCP list is Dart, Playwright, Maestro, Context7, Figma,
and read-only GitHub. Google Developer Knowledge is available in VS Code through
a local masked API-key prompt. Claude uses .mcp.json; Codex uses trusted
.codex/config.toml. Some remote services require personal authorization and
may not be usable on all accounts.

Do not run the legacy global MCP registration process. Repo configuration is
reviewable and reduces accidental tool leakage into unrelated projects.
**Configured is not Connected:** mark a tool Ready only after an actual MCP
initialize and tools/list exchange. A file and executable check means configured.

Maintainers may later add narrowly scoped DEV cloud MCP through a separate,
reviewed opt-in. No Firebase CLI login occurs in the Contributor wizard.
Review ADR-0002 and never give production access to agents or colleagues.

The three local stdio MCPs use an allowlisted Node 18+ launcher (`tooling/mcp/launch.mjs`) on Windows and macOS. It can launch Dart, Playwright, or optional Maestro; never Firebase cloud MCP. An installed/declared tool is **not** marked Ready until a live protocol handshake succeeds. Mac setup uses project-scoped configurations; no global MCP registrations.
