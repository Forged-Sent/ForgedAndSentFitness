# Knowledge lifecycle and safe deprecation

This policy applies to project knowledge notes, ADRs, agent skills, generated maps and prototype archives; it **does not** authorize deleting source code or historical prototype snapshots.

## New knowledge
- At session close, update the existing task handoff with outcome, checks, blockers and next action; create a new note only for a distinct task or durable research record. The coordinator summarizes changed state in CURRENT/WORK, linking the authoritative record instead of copying it.
- Imported research belongs in a dated archive with provenance and an operational successor link. Preserve the original snapshot; this does not mark its proposals accepted or its observations current. HISTORY is the discovery index; INDEX/HOME/CURRENT point to HISTORY rather than individual archived bodies.
- Prefer editing the relevant existing page rather than copying facts into a second "memory".
- For lasting decisions, create an ADR with Status: Proposed, Accepted or Superseded and a reason; get product/architecture approval before marking Accepted.
- For transient progress, use `docs/knowledge/handoffs/<task>.md` with status, date, owner and exact branch/SHA. Do not rewrite handoffs from other active branches.
- For public repository notes, omit personal content, private user records, secrets, tokens and health/prayer data.

## Retire material without losing provenance
1. Detect staleness by comparing the note with source and tests at a known SHA. Age alone is not proof of obsolescence.
2. Identify the canonical successor and all backlinks (Markdown links, agent rules, Architecture Atlas, code comments, PRs).
3. In a reviewable PR, mark the old note **superseded**, add the successor link and dated rationale. Update INDEX.md and inbound links in the same PR.
4. Only after references are migrated, move non-ADR knowledge to `docs/knowledge/archive/` with `status: archived` metadata and a successor pointer. Git history remains the recovery path.
5. Never silently erase an accepted ADR, generated CODE-MAP or `versions/app-vN.html` history. For ADRs add a new ADR and mark the old decision Superseded; for generated files regenerate using their owner tooling.
6. Re-run `python3 tooling/knowledge/check.py`, policy/architecture checks and relevant tests. Never mark an untested migration verified.

## Obsidian use
For the selected repository-backed workspace, HOME is the human dashboard and INDEX is the agent entrypoint. WORK is the only place work status is edited; `WORK-BOARD-VIEW.md` and the focus block at the top of HOME are generated from it by `tooling/knowledge/work_board.py` and are regenerated, never archived or edited. Open the dedicated `docs/` vault. Archives are available in the file browser but excluded from normal agent startup/search scope. These retrieval rules guide agents; they are not a filesystem access restriction.

Open `docs/` as an Obsidian vault. Version-control Markdown, not local Obsidian state: `**/.obsidian/` and `**/.trash/` are Git-ignored. Obsidian is optional, and native Markdown links work without it. Do not introduce a second externally synced knowledge database or grant an Obsidian MCP unrestricted write access. A future MCP proposal needs a scoped, read-only proof before any write permissions.

## Retiring executable code and old scaffolding
For non-archival source files, first map every import, runtime caller, test, CI path and supported-platform build reference. Introduce the replacement behind a small tested interface or compatibility adapter, migrate callers, then delete only proven-dead code in a dedicated reviewable PR. Check migrations on supported platforms; an unused Dart symbol or lexical Atlas edge alone is not proof that an integration is safe to delete. Record the removal's commit/PR and user-visible behavior in the relevant handoff. Do not delete prototype `versions/` snapshots or alter stored event schemas without a migration plan.

## Handoff/status state
For active task handoffs, the required YAML fields are `status` (active, completed or superseded), `updated` (YYYY-MM-DD), `owner`, `source_ref`, and `source_sha` (40-character Git SHA). Template files are exempt from validation. On merge, set completed and reference the merge PR. For abandoned work, set superseded and link the replacement. The check script verifies syntax, local references and that the active index doesn't point to archive files; it does not certify the content itself.
