---
name: fs-architecture-review
description: Checklist for reviewing a Forged & Sent diff against Accepted ADRs, AGENTS.md invariants and module boundaries. Preloaded by the architecture-reviewer subagent; invoke directly in Codex for reviews.
---
# Architecture review checklist

Run `git diff --stat <base>...HEAD`, `python3 tools/validate_architecture.py` and `tools/check_zones.sh <base>`. Cite file:line for every finding.

1. **Boundaries:**
   - Features import other features only via `api.dart`.
   - `core` never imports `features`.
   - `fs_domain` has no Flutter or Firebase imports.
2. **Offline:**
   - Writes go through Drift and the outbox.
   - Ids are created before the first write.
   - No debounce on local commits.
   - No dropped errors.
3. **Firebase:**
   - Group-scoped, paginated queries only.
   - No whole-collection listeners.
   - No client writes to privileged collections.
   - Functions are idempotent.
4. **Privacy:**
   - Journal and prayer content never read outside the owner.
   - Push payloads carry no content.
   - New fields are classified.
5. **Safety:**
   - No reading or typing during exertion.
   - No incentives for volume, under-eating or disclosure.
6. **Decisions:**
   - Read `docs/planning/decision-log.yaml`. Any change that contradicts an `approved` or `implemented` DEC entry → **BLOCK** and ask for an amendment proposal that cites the DEC id. Never accept a silent reversal.
   - The diff must not touch `decision-log.yaml` unless the PR is a human-owned `contract-change`.
   - Only Accepted ADRs bind.
   - Anything relying on a Proposed ADR, an Open OD or an unruled workshop item (W01–W12) → ESCALATE.
7. **Size and scope:** one FS id, ≤ ~400 changed lines, tests included.
