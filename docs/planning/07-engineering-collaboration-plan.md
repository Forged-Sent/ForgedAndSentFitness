# 07 · Engineering collaboration plan

Most of this is already enforced on the reconciliation branch (ADR-0014, ADR-0015, `AGENTS.md`, `.github/`). This page states the whole plan in one place and adds what was missing: the decision guard and the "freeze before agents work alone" list.

## Repository

| Choice | Recommendation | Why |
|---|---|---|
| Repos | **One repository** (monorepo): `app/`, `packages/fs_domain/`, `functions/`, `firebase/`, `contracts/`, `content/`, `docs/`, `tools/`, and the prototype at the root | Contracts and rules change together with the code that uses them; a single CI |
| Default branch | `main`, protected: PR required, checks required, no force-push | — |
| Branches | `feat/FS-XXX-nnn-slug`, `fix/…`, `arch/…`, `content/…` | Ties work to requirements |
| Worktrees | One implementer agent per worktree and branch; humans can share | Prevents agents editing the same files |
| Merge strategy | Squash merge; PR title = conventional commit with the FS id | Readable history |

## Documentation standards

- Markdown, one topic per file, with a table at the top for status and sources.
- Every doc says what it **is** (approved, recommended, open).
- ADRs use the template in `docs/adr/README.md`. Requirements and tests are YAML (validator-checked).
- Diagrams are Mermaid next to the docs and must render in CI.
- Owner decisions go in `docs/planning/decision-log.yaml`.

## Reviews

| Change type | Human reviewers | Agent reviewers |
|---|---|---|
| Protected zone (ADRs, requirements, contracts, rules, indexes, scoring, approved content, **decision log**) | **Both owners** (CODEOWNERS) | architecture + security |
| Feature slice | One owner | architecture-reviewer (if more than one feature changes) |
| Firebase or Functions | One owner | security-privacy-reviewer |
| Faith content | Named pastor or elder (W08) + one owner | faith-content-reviewer flags only |
| Fitness content | Named fitness reviewer + one owner | — |

## Testing and CI

| Layer | What | When |
|---|---|---|
| Domain | Pure Dart unit + golden tests (engine, scoring parity, program equivalence) | Every PR |
| App | Widget tests; integration tests (airplane mode, kill/resume) on an emulator | Every PR (unit and widget); nightly (integration) |
| Rules | Firestore and Storage emulator tests (`firebase/tests/rules`) | Every PR touching `firebase/` or contracts |
| Functions | Jest + firebase-functions-test (idempotency, ledger) | Every PR touching `functions/` |
| Architecture | `validate_architecture.py`, zone guard, Mermaid render | Every PR |
| Security | Rules matrix, secret scanning, Dependabot, App Check enforcement in staging | Every PR / weekly |

## Data and schema changes

Any collection, field or rule change is a `contract-change`:

1. An ADR reference.
2. Updated `02-data-architecture-firestore.md` and contracts.
3. Rules tests.
4. Both owners approve.
5. A migration note if documents exist (Firestore has no schema, so readers must tolerate old shapes for one release).

## Release management

| Lane | Trigger | Audience |
|---|---|---|
| dev | Merge to `main` | Developers (App Distribution) |
| staging | Tag `vX.Y.Z-rc.N` | Testers (App Distribution, TestFlight internal) |
| prod | Tag `vX.Y.Z` + manual approval | Pilot (TestFlight external) → stores (M5) |

Release checklist per tag: changelog, rules deployed first, Functions second, app third; Remote Config flags reviewed; rollback noted.

## Must be final before agents implement independently

| # | Item | Where | Status |
|---|---|---|---|
| 1 | Reconciliation branch merged by both owners; ADR statuses ratified or set to Proposed | PR #1 | **Open** |
| 2 | Planning hub operating: decision log in `main`, labels and issue forms installed, hub v4 shared with both owners | `09-planning-hub-spec.md` §7 | **Ready to run** (needs push + bootstrap script) |
| 3 | W01, W02, W07, W12 answered (M1 shape) | Hub → decision log | Open |
| 4 | OD-08 Drift, OD-15 location, OD-19 App Check, ADR-0016, ADR-0018 accepted | ADRs | Open (recommendations given) |
| 5 | Rules tests green in CI (P0-4) | `firebase/tests/rules` | Not yet run |
| 6 | CODEOWNERS second handle + branch protection (P0-5) | `.github/CODEOWNERS` | Open |
| 7 | Contracts for M1 payloads (session, set, experience run, journal entry) | `contracts/` | To write in PR 9–10 |
| 8 | Firebase projects created (dev, staging, prod) with the chosen location | Firebase console | Open |

## Two collaborators, any AI tool

Nothing here requires both people to use the same assistant:

- `AGENTS.md` is read natively by Codex, and by Claude Code through `CLAUDE.md`.
- Skills live canonically in `.agents/skills/` and are mirrored to `.claude/skills/`.
- Every gate is a script or CI check, not an assistant feature.
- The hub works from any browser with a claude.ai account; GitHub works for anyone with a GitHub account.
