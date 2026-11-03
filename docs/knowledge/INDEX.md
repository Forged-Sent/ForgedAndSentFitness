# Development knowledge index

This is a Git-tracked, Markdown-first second brain. Obsidian may open the repository's docs/ directory as a vault, but Obsidian is a viewing and authoring interface, not a second source of truth. See [lifecycle](LIFECYCLE.md) before archiving material.

## Start here
- [Beginner knowledge home and optional Obsidian vault](../HOME.md)
- [Risk-based approved feature contracts](../features/README.md)
- [Interactive prototype and Atlas knowledge workspace](../development/KNOWLEDGE-WORKSPACE.md)
- [Current verified and unverified state](CURRENT.md)
- [Agent operating model and task handoffs](AGENT-OPERATIONS.md)
- [Flutter targets and cross-platform verification](FLUTTER-PLATFORMS.md)
- [Prototype-to-Flutter traceability](PROTOTYPE-PARITY.md)
- [Flutter AI, Dart MCP and Context7 lookup rules](FLUTTER-AI-DOCS.md)
- [Documentation lifecycle and deprecation](LIFECYCLE.md)
- [Research and primary sources](RESEARCH-2026-11-02.md)
- [Active PR #4 handoff](handoffs/pr4-foundation.md)
- [Handoff template](handoffs/TEMPLATE.md)

## Existing authoritative material
- [Implemented versus planned system architecture](../architecture/SYSTEM.md)
- [Generated Dart code map](../architecture/CODE-MAP.md)
- [Mobile foundation decision](../architecture/ADR-0001-mobile-foundation.md)
- [Emulator-first Firebase decision](../architecture/ADR-0002-emulator-first-firebase.md)
- [Proposed platform-target decision](../architecture/ADR-0003-flutter-targets.md)
- [Existing engineering research](../development/ENGINEERING-RESEARCH.md)
- [Independent review workflow](../development/AI-REVIEW-WORKFLOW.md)
- [Architecture Atlas](../architecture/explorer/README.md)

## Authority, highest first
1. Executed code, tests, SDK/dependency lockfiles and live protected GitHub checks establish what exists and passed.
2. Accepted ADRs and explicitly approved requirements establish design intent, not proof of implementation.
3. Architecture docs and generated inventories explain current boundaries, with planned nodes labeled.
4. Handoffs are dated, branch/SHA-specific snapshots. Revalidate before relying on them.
5. Agent observations and retrieved documentation are provisional evidence until checked.

No autonomous agent can change GitHub protection, release to production or promote a proposal to approved behavior. Do not record member data, secrets, prayers or health details in this public repository.
