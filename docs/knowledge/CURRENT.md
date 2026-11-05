# Project continuation entrypoint

**Snapshot:** 2026-11-05. **Verification level:** repository-inspected; `ci-gate` checked at the SHAs named below. Physical-workstation results are as reported by the maintainer and are listed as such.

## What exists on `main`
- PR #4 (contributor onboarding, emulator-first Firebase foundation, Architecture Atlas) **merged** into `main` on 2026-11-05 as merge commit `60b9f5de11b1a1074b921ee26ae68fb3c3e7228d`. Its `ci-gate` was green on all 12 jobs at the merged head `a93407b`, including the unsigned iOS simulator build.
- Flutter foundation is under `mobile/`: the app shell and the emulator runtime (`FS_ENV=emulator`, `demo-forgedandsent`). It is not a feature-complete replacement for `index.html`.
- Beginner setup: `START-WINDOWS.cmd` / `START-MAC.command` at the root and numbered launchers in `launchers/<os>/` (1 set up, 2 run app, 3 practice Firebase, 4 app with practice Firebase, 5 check). Step 1 offers optional AI assistants (any combination), Android (Windows) or iPhone (Mac) testing, and a "Try it now" walkthrough.
- The HTML/JavaScript `index.html` remains the behavior and visual-reference prototype. Archived `versions/app-vN.html` files remain append-only.

## Physical acceptance (maintainer-reported, 2026-11-05)
- Windows: Contributor setup completed; "Check my setup" left only the app round-trip (EmulatorWiring) to confirm by eye.
- Mac: Contributor setup completed after the disk-space and JDK 21 fixes; same single item left.
- NOT VERIFIED: the "Try it now" walkthrough on Windows, the Mac iPhone step, Android on a device or emulator, any Maestro flow (none exist yet), and every MCP `tools/list` handshake.

## Do not assume
- Real device integration is proven, all MCP handshakes succeed, or desktop hosts compile.
- Production Firebase is configured, production data access is safe, or Flutter implements all prototype features.
- Obsidian, Context7, Claude/Codex/Gemini/Antigravity tooling or Flutter plugins are installed on a workstation solely because configuration exists.

## Resume routine
1. Fetch the current Git branch and latest PR/issues; record new HEAD and current `ci-gate` status.
2. Read `AGENTS.md`, `mobile/AGENTS.md` if relevant, the current ADRs, and this index.
3. Read the single feature's acceptance criteria plus its active handoff; inspect the real Dart files and tests.
4. Implement one vertical slice, then run applicable tests and update evidence in a dated handoff.
5. Regenerate CODE-MAP and Atlas when required; optionally request a non-author read-only AI review (recommended for Firebase/Auth/privacy/scoring changes); the maintainer decides the merge.

**Next recommended application milestone:** the walking skeleton with its security spine: Firebase Auth sign-in, group create/invite/join, deny-by-default Firestore rules and an automated emulator test proving one group cannot read another's data. Resolve state-management and local outbox choices in an ADR first. Keep the prototype unchanged until explicit parity tests exist.

This file is an orientation pointer, not a continuously auto-generated truth source. Update it in the same PR that changes major milestones; never auto-rewrite another agent's in-progress note.
