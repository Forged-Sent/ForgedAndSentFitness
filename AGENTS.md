# Forged & Sent: instructions for coding agents (Claude Code and Codex)

**Read this file fully before any change.** CI enforces these rules. `CLAUDE.md` imports this file.

## What this repository is

A **faith-centered devotional workout and brotherhood platform**: individual growth, team accountability, safe fitness competition, private spiritual development, and later expansion into family and church communities.

| Path | What | Status |
|---|---|---|
| `index.html`, `versions/`, `seed/`, `dev/` | Prototype (claude.ai Artifact). **Frozen behavioral reference. Do not edit** without label `legacy-change` | Preserved |
| `docs/architecture/` | **Source of truth** for the production architecture (Flutter + Firebase) | Accepted |
| `docs/adr/` | Decisions. Only `Accepted` ADRs bind you. `Proposed` = do not implement without approval | Protected |
| `docs/requirements/` | `requirements.yaml` (FS-* ids), `test-catalog.yaml` (TC-*), `open-decisions.md` (OD-*) | Protected |
| `docs/diagrams/` | Mermaid sources | — |
| `contracts/` | JSON Schemas and golden fixtures shared by Dart and TypeScript | Protected |
| `firebase/` | `firestore.rules`, `storage.rules`, `firestore.indexes.json`, rules tests | Protected (rules, indexes) |
| `app/`, `packages/fs_domain/`, `functions/`, `tools/` | Production code (created from Phase 1) | — |
| `docs/reviews/` | Historical independent review. **Superseded in part**: its Supabase recommendation is rejected (ADR-0003) | Historical |

## Precedence when documents disagree

1. Human instruction in the task.
2. Accepted ADRs.
3. `docs/requirements/requirements.yaml`.
4. `docs/architecture/*`.
5. Everything else.

If two sources still conflict: **stop, and escalate in the PR description**. Never pick one silently.

## Approved technology (do not substitute)

- **Client:** Flutter/Dart, Riverpod, go_router, freezed/json_serializable, Drift (OD-08 pending confirmation).
- **Backend:** Firebase Auth, Cloud Firestore, Cloud Functions 2nd gen (TypeScript), Cloud Storage, FCM, App Check, Crashlytics, Remote Config, App Distribution.
- **No** Supabase, PostgreSQL, custom servers or personal servers.

## Non-negotiable invariants

1. **Group isolation.** Shared data lives under `groups/{gid}/…`, and every query is group-scoped and paginated. No whole-collection listeners.
2. **Privileged writes are Functions-only:** membership, ledger, standings, snapshots, reviews, moderation actions, rulesets, content manifests.
3. **Facts are create-only** with deterministic or UUIDv7 ids. Event-triggered Functions must be idempotent, because they are at-least-once.
4. **Offline first.** User actions write to Drift, then the outbox. Features never call Firestore directly; they go through `core/sync` and repositories. A set is committed locally before the UI confirms it.
5. **Faith privacy.** `users/{uid}/journal` is owner-only. Never read journal or prayer content for scoring, analytics, notifications or AI. Faith points, if any, are boolean participation only (ADR-0012).
6. **Safety:**
   - No reading or typing during active sets or timed exertion (FS-DWE-003).
   - No points for extra volume, under-eating or weight loss.
   - Proof never requires family members on camera.
7. **Proof media:** never `getDownloadURL()`. Reviewers use the signed-URL Function (ADR-0010).
8. **No silent failure:** no empty `catch`. Map errors to typed failures and keep the user's data.
9. **Time:** `localDate` + IANA tz for days; server `request.time` / `serverTimestamp()` for deadlines. No clock overrides outside debug builds.
10. **Families and youth stay inactive.** Never add access paths for `households`, `guardianLinks` or `conversations` (ADR-0013, ADR-0017).

## Protected zones (single writer; label `contract-change` + `ADR-####` in the PR body + 2 human approvals)

`docs/adr/` · `docs/requirements/` · `contracts/` · `firebase/firestore.rules` · `firebase/storage.rules` · `firebase/firestore.indexes.json` · `functions/src/scoring/` · `content/**/approved.yaml`

If your task needs a change there and doesn't say so: **stop and write a proposal in the PR description.**

## File ownership (one active owner role per PR)

| Area | Owner role | Required reviewers |
|---|---|---|
| `app/lib/features/**`, `app/lib/core/{design,routing,flags}` | flutter-implementer | architecture-reviewer if more than one feature changes |
| `app/lib/core/{db,sync}` | flutter-implementer (sync-specialist when active) | architecture-reviewer + test-engineer |
| `packages/fs_domain/**` | flutter-implementer | architecture-reviewer |
| `functions/**`, `firebase/**` | firebase-backend | security-privacy-reviewer |
| `content/**`, `tools/fs_content/**` | content-engineer | faith-content-reviewer (flags only) + human approver |
| `.github/**`, release lanes | release-engineer | security-privacy-reviewer |
| `docs/**` | architect (human-approved) | architecture-reviewer |

## Task and PR rules

- One requirement id (`FS-XXX-nnn`) per PR. Branch name `feat/FS-XXX-nnn-slug`. Target ≤ 400 changed lines, excluding generated files.
- **2–4 active agent roles per change:** an implementer, plus the reviewers the ownership table requires. Don't invoke the whole catalog.
- One implementer per branch or worktree. Never edit files outside the task's declared paths.
- **No agent merges, approves PRs, approves content, or changes an ADR status.**

## Commands

```bash
python3 tools/validate_architecture.py         # docs, ADRs, requirements, schemas, bans
npm --prefix firebase install && npm --prefix firebase test   # rules tests (emulator)
flutter analyze && flutter test                # from app/ once it exists
npm --prefix functions test                    # once functions/ exists
tools/check_zones.sh origin/main               # protected-zone guard (CI passes labels/body)
python3 tools/sync_skills.py                   # after editing .agents/skills/fs-*
```

## Definition of Done

- Acceptance criteria met.
- Tests named with FS or TC ids.
- Analyzer clean.
- Rules tests green when rules change.
- Docs and ADRs updated if behavior changed.
- Validator green.
- PR template completed (data classification, offline behavior, privacy impact).

## Skills

Project skills live in `.agents/skills/fs-*` (canonical, read by Codex) and are mirrored to `.claude/skills/fs-*` (read by Claude Code):

- `fs-feature-slice`
- `fs-firestore-change`
- `fs-scoring-rule-change`
- `fs-content-validate`
- `fs-architecture-review`
- `fs-security-review`
- `fs-proof-media`

The dart-lang skills (pinned in `skills-lock.json`) cover Dart and Flutter mechanics.
