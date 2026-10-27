# 08 · AI agent and skill architecture

**Self-critique first.** The reconciliation branch created 8 agent roles and 7 skills before any production code exists. That's more than M1 needs, and your brief warns against exactly this. Most of the roles are cheap (read-only reviewers with a checklist), but the setup should **start smaller and grow on evidence**. The roles stay in the catalog; only the **M1 active set** is used.

## Five layers, in order of trust

| Layer | What | Where | Enforced by |
|---|---|---|---|
| 1. **Human decisions** | Owner rulings, ADR statuses, approvals of content and protected zones | `decision-log.yaml`, `docs/adr/`, PR approvals | CODEOWNERS (both owners); agents may not change them |
| 2. **Deterministic gates** (primary) | Validator, zone guard, rules tests, analyzer, unit, golden and equivalence tests, Mermaid render, **decision guard** | `tools/`, `.github/workflows/` | CI required checks; the Claude Code PreToolUse hook |
| 3. **Project-wide instructions** | Product framing, invariants, approved tech, precedence, file ownership | `AGENTS.md` (+ `CLAUDE.md` import) | Read by both tools; the gates catch what instructions miss |
| 4. **Skills** (how-to) | Repeatable procedures for one kind of change | `.agents/skills/fs-*` → mirrored to `.claude/skills/` | `tools/sync_skills.py` + validator |
| 5. **Agent roles** (who) | Implementer or reviewer personas with tool limits | `.claude/agents/*.md`; in Codex as a reviewer prompt + skill | Tool allow/deny lists; worktree isolation |

Instructions are the weakest layer, so every rule that matters has a gate behind it.

## Active set by milestone

| Role | Kind | M1 | M2 | M3 | M4+ | Purpose |
|---|---|---|---|---|---|---|
| flutter-implementer | builder | ● | ● | ● | ● | `app/`, `packages/fs_domain/` for one FS id |
| firebase-backend | builder | ● | ● | ● | ● | `functions/`, `firebase/` (always contract-change) |
| architecture-reviewer | read-only | ● | ● | ● | ● | ADR, AGENTS and boundary conformance; **decision conflicts** |
| security-privacy-reviewer | read-only | ● | ● | ● | ● | Rules, auth, privacy, proof, health, journal |
| test-engineer | tests only | ● | ● | ● | ● | Missing tests, rules allow/deny, idempotency |
| content-engineer | builder | ● (Forged program) | ○ | ● (challenges) | ● | Content sources and the packager |
| faith-content-reviewer | read-only, flags only | ○ (devotional sample) | ○ | ● (missions) | ○ | Theological and pastoral flags; humans decide |
| release-engineer | builder | ● (lanes) | ○ | ○ | ● (stores) | CI, flavors, distribution, store metadata |

● active · ○ available, activate when a task needs it.

**Not created on purpose:** a sync specialist (offline sync is a skill plus reviewer duty until M1 shows otherwise), a separate fitness-program reviewer (a human fitness reviewer, W08, plus equivalence tests), UI-designer and PM agents.

## Per-role contract (summary)

| Role | Must follow | May modify | Needs human approval | Verifies by | On conflict |
|---|---|---|---|---|---|
| flutter-implementer | AGENTS.md, Accepted ADRs, decision log, `fs-feature-slice` | Declared paths in `app/`, `packages/fs_domain/` | Anything outside the declared paths | `flutter analyze`, tests with TC ids, validator | Stop; write a proposal in the PR |
| firebase-backend | + `fs-firestore-change`, `fs-security-review` | `functions/**`, `firebase/**` | Always (protected zone) | Rules and Functions tests in CI | Stop; propose an ADR amendment |
| content-engineer | `fs-content-validate`, W08 | `content/**` sources, `tools/fs_content/**` | Publishing (`approved.yaml`) | Equivalence and schema validation | Flag to the reviewer |
| reviewers | Their skill checklist | Nothing | — | Report findings with file:line | Report; never fix |
| test-engineer | Test catalog | Test dirs only | — | Tests fail before the fix and pass after | Propose; no implementation edits |
| release-engineer | ADR-0014 | `.github/**`, release lanes | Prod deploys | Dry-run lanes | Stop |

## The decision guard (new)

Your brief: *"AI agents must never silently reverse an approved decision."* The guard has three parts.

1. **Instruction** (`AGENTS.md`, "Approved decisions"): before starting, read `docs/planning/decision-log.yaml`. If the task conflicts with an `approved` or `implemented` entry, **stop**, then open or propose an **amendment** (an issue labeled `amendment` that cites the DEC id) instead of implementing.
2. **Protected file:** `docs/planning/decision-log.yaml` is added to the protected zones (`tools/check_zones.sh`) and to CODEOWNERS for both owners. An agent edit is blocked by the hook, and a PR changing it needs `contract-change` and two approvals.
3. **Validator:** `validate_architecture.py` checks every DEC entry's schema. A decision can't move from `approved` to `rejected` or `superseded` without a `history` entry that has a rationale and `decided_by`. Every `superseded` entry must name its replacement.

## Codex parity

| Need | Claude Code | Codex |
|---|---|---|
| Project instructions | `CLAUDE.md` → `@AGENTS.md` | `AGENTS.md` (native) |
| Skills | `.claude/skills/fs-*` (mirror) | `.agents/skills/fs-*` (canonical) |
| Reviewer roles | Subagents with tool deny-lists | Run the same skill checklist as a separate review task, read-only |
| Zone protection | PreToolUse hook + CI | CI (`check_zones.sh` + CODEOWNERS) |
| Worktrees | `isolation: worktree` | One task branch per worktree (manual) |

## Conflict handling between agents

- **One implementer per branch.** Two implementers never touch the same declared paths at the same time; the PR template lists the paths.
- **Contracts first:** when two slices need the same payload, the contract PR merges first and both slices depend on it.
- **Contract changes are serialized:** only one open `contract-change` PR at a time (the CI zone guard plus a team rule).
- A reviewer finding that contradicts a decision-log entry is escalated to the owners, not fixed by an agent.
