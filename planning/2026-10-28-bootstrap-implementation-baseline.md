# Bootstrap implementation baseline, 2026-10-28

Status: AGREED, replaces feature expansion. Reference: 2026-10-27 PR #3 bootstrap review.

## PR #3: fix, remove, test only
All P1 and material P2 review findings; harden Maestro installation; correct Windows MCP invocations/idempotency; REMOVE cloud Firebase MCP from default VS Code and Claude/Codex; profile-aware diagnostic state model; reliable WinGet; isolate VS Code extension failures; PSScriptAnalyzer/Pester and meaningful Windows CI; Flutter web build; always-present ci-gate; CODEOWNERS and repository security docs; ADR-0002.

## PR #4: new capabilities
Preview/Contributor/Mobile/Maintainer working profiles; JDK 21 and local Firebase demo emulators; FlutterFire CLI never auto-configured; runtime emulator-only app wiring; Android mobile testing; project-friendly Git functions, hooks/tasks/Git 101; optional DEV cloud MCP for Maintainers; iOS CI and clean-machine end-to-end acceptance.

## Merge gate
Protect main now; enforce ci-gate and code owner approvals only after they exist and a second human owner is named. Windows lint/CI and Flutter web/Android tests pass; complete clean-VM smoke test before colleague onboarding. No production Firebase access to developer workstations.
