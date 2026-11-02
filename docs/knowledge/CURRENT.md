# Project continuation entrypoint

**Snapshot:** 2026-11-02. **Verification level:** repository-inspected, CI and physical-device status NOT VERIFIED during this documentation change.

## What exists in the PR #4 branch
- Branch `feature/contributor-emulator-onboarding` is an open draft pull request (#4) based on main as observed on 2026-11-02.
- Flutter foundation is under `mobile/`, including the app shell and emulator runtime scaffold. It is not an implemented feature-complete replacement for `index.html`.
- Separate local Firebase emulator rules/tests, Windows/Mac onboarding, multi-provider advisory review, architecture SYSTEM.md/CODE-MAP.md and offline Architecture Atlas are proposed in that draft.
- The HTML/JavaScript `index.html` remains the behavior and visual-reference prototype. Archived `versions/app-vN.html` files remain append-only.
- Current source was inspected at PR #4 head `edd1d4f0084dad1aa8fd0f27cdd5a6ade91753a4`; later changes require rereading PR metadata and HEAD. The PR #4 branch now integrates main prototype versions through app-v226 at the merge snapshot.

## Do not assume
- Draft PR #4 has merged, CI is green, real emulator/device integration is proven, all MCP handshakes succeed, or desktop hosts compile.
- Production Firebase is configured, production data access is safe, or Flutter implements all prototype features.
- Obsidian, Context7, Claude/Codex/Gemini tooling or Flutter plugins have been installed on any developer workstation solely because configuration exists.

## Resume routine
1. Fetch the current Git branch and latest PR/issues; record new HEAD and current `ci-gate` status.
2. Read `AGENTS.md`, `mobile/AGENTS.md` if relevant, the current ADRs, and this index.
3. Read the single feature's acceptance criteria plus its active handoff; inspect the real Dart files and tests.
4. Implement one vertical slice, then run applicable tests and update evidence in a dated handoff.
5. Regenerate CODE-MAP and Atlas when required; request independent read-only review before proposing merge.

**Next recommended application milestone:** Define one Today/devotional/workout feature contract and a fake repository in Flutter; first resolve state-management and local outbox choices in an ADR. Keep the prototype unchanged until explicit parity tests exist.

This file is an orientation pointer, not a continuously auto-generated truth source. Update it in the same PR that changes major milestones; never auto-rewrite another agent's in-progress note.
