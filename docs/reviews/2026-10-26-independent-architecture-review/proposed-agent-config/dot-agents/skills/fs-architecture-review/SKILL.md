---
name: fs-architecture-review
description: Checklist for reviewing a Forged & Sent diff for architectural conformance (ADRs, layering, import boundaries, offline and scoring invariants). Used by the architecture-reviewer subagent in Claude Code and invoked directly in Codex for reviews.
---
# Architecture review checklist

Run: `git diff --stat <base>...HEAD`, `tools/check_zones.sh <base>`, `dart analyze`.
Check each item; cite file:line for every finding.
1. Import boundaries: features import other features only via `api.dart`; `core` never imports `features`; `fs_domain` has no Flutter imports.
2. Data flow: UI → view model → repository → (Drift + outbox | remote). No network calls from features. No Supabase types above `data/`.
3. Offline: user actions persist locally before acknowledging; new mutations have client ids and idempotent server handling.
4. Authority: no client-computed points written anywhere; no deadline checks using device time for authoritative decisions.
5. Errors: no swallowed exceptions; failures mapped to `AppFailure`; user-visible states for offline/error.
6. Privacy: new fields classified; defaults private for health/prayer/reflection/body data; nothing sensitive logged.
7. ADRs: change consistent with accepted ADRs; new architectural choices have a new ADR (proposed) — else ESCALATE.
8. Size: one FS id; ≤ ~400 changed non-generated lines; tests included.
Verdict: APPROVE / REQUEST CHANGES / ESCALATE (ADR conflict or missing decision).
