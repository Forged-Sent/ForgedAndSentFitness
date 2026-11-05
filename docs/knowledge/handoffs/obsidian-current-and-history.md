---
status: active
updated: 2026-11-05
owner: Codex
stage: Review
profile: routine
coordinator_model: not-reported-by-host
coordinator_provider: codex
author_providers: [codex]
next_action: Review the proposed agent workspace and validate the Obsidian UI pilot
source_ref: codex/obsidian-current-and-history
source_sha: 1ef8ce67ae15f78801e234f71aaad20511a9c913
---
# Repository-backed Obsidian organization

## Goal and acceptance

User selected repository-backed Obsidian organization/history, fast agent startup and easy human tracking. Reuse #26/#30. HOME must lead to current/work; startup is bounded; tasks name owner/blocker/next action; four audit artifacts retain provenance; history stays out of default context; knowledge/architecture checks pass.

## Source and ownership

Local branch starts at PR #30 above in `C:/ws_c/ForgedAndSentFitness-knowledge`. Original dirty checkout is untouched. No user files moved/deleted; existing artifact/root copies remain pending reviewed consolidation. The user subsequently authorized adding these changes to an existing PR. Publication target: [PR #30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30), branch `feature/obsidian-knowledge-workspace-20261103`; the PR commit list and check runs establish publication/CI evidence, not this preparation snapshot.

## Work performed

Reworked HOME/INDEX/CURRENT; added WORK/HISTORY; imported dated audit packet with original hashes. Organization is authorized; architecture proposals remain unapproved.

Follow-up: user clarified the friend will run agent sessions and asked for established plugins/processes plus orchestration, implementers, independent reviewers and appropriate skills/research. Added AGENT-WORKSPACE recommendation and START-SESSION prompt; prepared a core Bases view over existing active handoffs, using `stage` for progress and `status` for lifecycle. Two primary-source research notes are in the dated archive and indexed through HISTORY. No community plugin installed; views and embedded integration still need a real Obsidian pilot. An embedded chat prompt is not a completed multi-agent orchestration integration.

The Base YAML parsed successfully with existing PyYAML; its active-handoff filter and table/Kanban types were checked. This is not Obsidian rendering validation. Research subagents supplied evidence, not independent code approval. Their detailed findings are proposals.

Latest user instruction authorizes task-based coordinator alternatives. Created task-coordinator skill and mirrored it for Claude; replaced Astra-only preference with auto/routine/deep/research/named-model routing. A delegated implementation agent updated START-SESSION and the handoff template. Both root and delegated author use the Codex provider; exact model IDs were not reported in this session, so none are invented. These edits are one routine documentation/skill task, not proof of cross-provider orchestration. Open is preserved as an unresolved label. Coordinator/model and task profile are visible properties in the Base. Historical snapshots remain unchanged.

## Verification

Multi-coordinator follow-up: skill-creator quick validation PASS; 19 knowledge tests and 2 skill-sync tests PASS; policy/link/skill parity checks PASS; Base properties match handoff metadata; staged architecture check and review dry-run PASS. A fresh-context read-only agent simulated routine routing, unavailable named-model handling, and quota handoff with two author providers/stale review. It found one missing-review wording ambiguity, corrected to allow authorized local preparation while retaining NOT VERIFIED coverage for maintainer decision. This is behavioral simulation by another Codex agent, not independent cross-provider code review, live model switching or Obsidian UI validation. No push/merge/installation occurred.

Executed November 5 on the local staged changes based on the source SHA above:

- `python tooling/knowledge/check.py`: PASS.
- `python -m unittest discover -s tooling/knowledge -p 'test_*.py' -v`: all 19 PASS.
- `python tooling/policy/check.py`: PASS.
- `python tooling/skills/sync.py --check`: PASS.
- `python tooling/architecture/generate.py --check`: PASS.
- `python tooling/architecture/build_explorer.py --check`: PASS, including staged new archive paths.
- `git diff --check`: PASS.
- `python tooling/review/review.py --dry-run --base 1ef8ce67ae15f78801e234f71aaad20511a9c913`: PASS, two complete slices; no AI calls. This is review preparation, not independent review.

Obsidian UI, preview server, mobile/emulator/device behavior NOT VERIFIED. Remote Obsidian MCP points to another personal vault. No runtime code changed. Imported archival text dominates this documentation diff.

## Next action

Open the checkout's `docs` folder as a dedicated Obsidian vault, then HOME. Review the update on PR #30, which remains stacked on #26; a human decides merge after required checks. Runtime roadmap waits for consequential decisions. Keep original root/artifact copies until the user confirms integration; they are not the ongoing source of truth.
