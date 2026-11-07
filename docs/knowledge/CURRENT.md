# Current project state

Curated 2026-11-05. Orientation, not live CI or accepted product policy. Read [WORK](WORK.md) next; [HISTORY](HISTORY.md) is reference only.

## Verified baseline

- Audited main `60b9f5de11b1a1074b921ee26ae68fb3c3e7228d` is the PR #4 merge: Flutter shell, demo Firebase wiring/rules tests, onboarding, architecture tools and CI. Production features/durable workout persistence remain unimplemented at that baseline.
- Prototype source matched main; audit was static, with no browser/Artifact/native test.
- Live reads in this organization task: #26 head `1c6160c368466d9c5ea814f9c5a1454fffa7fcdb` and #30 head `1ef8ce67ae15f78801e234f71aaad20511a9c913` are open **non-draft**. #30 stacks on #26. Current CI was not rechecked here.
- Dashboard/archive/coordinator updates were prepared from #30's head for publication to that existing PR, authorized by the user November 5. Check the live PR for the published head and CI; this note does not claim the PR is merged.

## Decisions

**Confirmed by the user November 5:** dedicated repository-backed Obsidian vault for organization/history and fast agent startup. This follows #30's `docs/` vault convention. Current notes come first; archives answer specific historical questions.

**Also confirmed:** multiple possible orchestrators selected by task, with agents handling implementation/review. The [routing workflow](AGENT-WORKSPACE.md#coordinator-routing) supports Astra/Opus and Sol/Sonnet candidate families; exact availability is checked per session. The user label Open remains unresolved, not a guessed model. The new task-coordinator skill implements the session procedure; embedded Obsidian dispatch remains a separate unverified integration.

**Still proposed:** Riverpod + go_router + Drift; Android/iOS production with web preview; owner-only durable devotional completion first. Existing ADR-0001/0002 establish Flutter/Firebase direction, not these additional approvals. The historical blueprint provides rationale/packages, not approval.

## Next actions and limits

Review this task's [handoff](handoffs/obsidian-current-and-history.md); integrate #26/#30 and record the three decisions before runtime work. Verify actual branch/main/PR checks at every task start; snapshots cannot authorize pushes/releases.

PR #4 physical onboarding was maintainer-reported; device round-trip and some launcher/MCP checks remained NOT VERIFIED. No production Firebase/security model is certified. Claude was installed but unauthenticated during the audit. Connected Obsidian MCP pointed to a personal vault, so no project writes used it.

Coordinator updates this page for changed milestones/decisions/blockers/evidence. Detailed task state stays in WORK/handoffs. This task adds no runtime feature, cloud login, deployment or paid service.
