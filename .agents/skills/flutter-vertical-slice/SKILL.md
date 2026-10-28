---
name: flutter-vertical-slice
description: Implement and verify one Forged & Sent Flutter feature end-to-end, especially when adding a new screen, repository interface or local workflow.
---
1. Read AGENTS.md, the relevant architecture decision and requested acceptance criteria.
2. Specify UI, application command, domain model and data repository interface before coding.
3. Keep state updates recoverable; for an offline action record an idempotent local event before showing completion.
4. Add a widget or unit test for success, failure and a meaningful boundary case.
5. Run Flutter format, analyze and tests. Document unrun checks.
6. Open a small PR. Do not change Firebase rules or scoring unreviewed.
