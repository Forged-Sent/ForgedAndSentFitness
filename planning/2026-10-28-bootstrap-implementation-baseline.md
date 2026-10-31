# Bootstrap implementation baseline, 2026-10-28

Status: AGREED, replaces feature expansion. Reference: 2026-10-27 PR #3 bootstrap review.

## PR #3: fix, remove, test only
All P1 and material P2 review findings; harden Maestro installation; correct Windows MCP invocations/idempotency; REMOVE cloud Firebase MCP from default VS Code and Claude/Codex; profile-aware diagnostic state model; reliable WinGet; isolate VS Code extension failures; PSScriptAnalyzer/Pester and meaningful Windows CI; Flutter web build; always-present ci-gate; CODEOWNERS and repository security docs; ADR-0002.

## PR #4: new capabilities
Preview/Contributor/Mobile/Maintainer working profiles; JDK 21 and local Firebase demo emulators; FlutterFire CLI never auto-configured; runtime emulator-only app wiring; Android mobile testing; project-friendly Git functions, hooks/tasks/Git 101; optional DEV cloud MCP for Maintainers; iOS CI and clean-machine end-to-end acceptance.

## Merge gate
Protect main in the Forged-Sent organization now; both @Chadillac12 and @sfcsmithc-afk are named in CODEOWNERS. Require ci-gate and code-owner approval only after PR #3 merges and both humans' repository write/review permissions are confirmed. Windows lint/CI and Flutter web/Android tests pass; complete clean-VM smoke test before colleague onboarding. No production Firebase access to developer workstations.

## Organization transfer update (2026-10-30)
Repository is `Forged-Sent/ForgedAndSentFitness`. Existing draft PR #3 survived the transfer. The ChatGPT GitHub integration has been authorized for organization repository writes. No repository ruleset currently exists, so an organization admin must enable the main pull-request requirement, force-push/deletion protections, and secret scanning/push protection through GitHub's security settings.

## Approved scope extension, 2026-10-30
The user explicitly requested equivalent MacBook bootstrap support in PR #3. This narrowly authorizes Mac browser Preview / Contributor launchers, safe local developer dependency installation, read-only diagnostic models, portable Dart/Playwright/optional Maestro MCP launchers, macOS Flutter web CI and documentation. Full Firebase emulator wiring, JDK21, Android and iOS simulator provisioning, and complete Mobile/Maintainer profiles remain PR #4. No default Firebase cloud MCP, automatic credentials, or direct main writes are permitted.
