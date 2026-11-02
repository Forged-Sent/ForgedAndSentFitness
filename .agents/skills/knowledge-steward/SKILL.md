---
name: knowledge-steward
description: Resume complex work from a versioned handoff, maintain a Git-backed Markdown knowledge base, and deprecate stale notes without erasing audit history.
---
# Knowledge stewardship

1. Read AGENTS.md, docs/knowledge/INDEX.md, CURRENT.md, LIFECYCLE.md and the exact branch or PR HEAD before treating any note as current.
2. Restrict retrieval to the issue's linked requirements, current ADRs, code paths and handoff. Context7 and official docs are reference inputs, never new policies by themselves.
3. Verify alleged implementation against code/tests and current CI. Record date, source_ref, full source_sha, status, owner, checks actually run, blockers and next executable action in a task-specific handoff.
4. Before deprecating a file, search inbound references and identify an approved replacement. Mark superseded with successor and date; move to archive only in a reviewed change after links are updated.
5. Never rewrite historical HTML versions, approved ADR history, generated CODE-MAP, another agent's active note or private user records. Do not authorize or auto-merge.
6. Run python3 tooling/knowledge/check.py, architecture checks and applicable tests; report NOT VERIFIED when checks cannot run.
7. Submit documentation edits in their own small PR or alongside the feature they describe, never as silent auto-updates to main.
