# Engineering research and design decisions

**Date:** 2026-10-31. **Scope:** small, multi-contributor public Flutter/Firebase app with local emulators, Windows/Mac onboarding, multiple AI coding assistants, and no production rollout yet. This is a researched decision record, not a claim that every recommendation is implemented.

## Decision matrix

| Concern | Recommended approach | Alternatives considered | Why / activation threshold |
|---|---|---|---|
| Flutter architecture | MVVM UI (views and view models), repositories as data sources of truth, stateless services, immutable one-way state | Widgets calling Firebase, full Clean Architecture everywhere | Matches official Flutter guidance; add use cases only when cross-repository or complex business logic appears. <https://docs.flutter.dev/app-architecture/guide> |
| State management | Decide by ADR at first real vertical slice; favor simple, testable dependency injection | Riverpod, provider, BLoC | All can work; do not pick a framework merely for agents. Use fakes in tests, preserve repository boundaries. <https://docs.flutter.dev/app-architecture/recommendations> |
| Navigation | Prefer go_router when real navigation is needed | Navigator API, custom routing framework | Flutter recommends go_router for most apps; no need for it in today's foundation screen. <https://docs.flutter.dev/app-architecture/recommendations> |
| Offline data | Local persistent store + outbox with stable event IDs, retries and conflict policy | Firebase cache alone | Workouts can be interrupted or offline; cache is not an authoritative event log. Storage choice needs ADR and crash/restart tests. |
| Identity and authorization | Deny-by-default Firestore/Storage rules, authenticated owner/group data access, emulator positive/negative tests | Client-side checks alone, permissive generic authenticated access | Tests are an independent oracle for access behavior; Cloud Functions/Admin SDK bypass client security rules, so server-side authorization still needed. <https://firebase.google.com/docs/rules/unit-tests> |
| Team scoring | Trusted versioned server function with audit-friendly inputs | Flutter points calculation as authority | Clients and timestamps are untrusted; scores and challenges affect other people. |
| User privacy | Private prayers, personal reflections, physical measurements and injuries separated from group queries | One giant group document | Access needs both field- and query-level least privilege; especially important before youth participation. |
| Development environments | Local demo-* emulators by default; restricted managed DEV and later PROD separately | Direct cloud PROD from contributor machines | Prevents accidental cloud writes, limits credentials, makes repeatable tests possible. |
| AI instructions | One small AGENTS.md plus task-specific version-controlled skills | Long repeated global prompts and per-developer copied instructions | Official Codex and Claude skill discovery supports repository skills and targeted activation. <https://learn.chatgpt.com/docs/build-skills> <https://claude.com/resources/articles/steering-claude-code-skills-hooks-rules-subagents-and-more> |
| Independent reviews | Authoring agent excluded; 2 separate providers if available, blind pass before consensus; strict JSON evidence and unverified state | Author self-review, autonomous AI merge committee | Reduces correlated blind spots but cannot prove correctness or satisfy required human approval. <https://developers.openai.com/blog/custom-code-review-rules-for-codex> |
| Local agent permissions | No write tools for reviewers, temporary review workdir, prompt-only supplied diff, no cloud Firebase MCP | Full-repo agents using privileged tokens | Least privilege; model sandboxing is defense in depth, not a replacement for OS/app permission boundaries. |
| CI | Mandatory stable `ci-gate` aggregates policy, Flutter analysis/test/build, Windows/Mac checks, rules emulator tests | Make every platform child job required | Conditional jobs may skip. The final gate must fail on any failed dependency and itself be required by GitHub ruleset. |
| Dependency integrity | Exact tool pins, committed lockfiles, pinned GitHub Actions SHAs | Floating latest tags or regenerate lockfiles on every install | Reproducibility and supply-chain hygiene. Package upgrades get focused PRs. |
| System diagrams | Version-controlled Mermaid design map + deterministic imported Dart file/symbol inventory | Hand-maintained screenshots, one enormous full-function graph | Intent and implementation must not be conflated; generated code map catches drift and is reviewable as text. |
| Change size | One vertical slice per PR, explicit acceptance criteria and test evidence | Large multi-month agent generated changes | Better code review and reproducibility; this foundational PR is larger only because it sets up developer tooling. |

## Team-specific multi-agent operating modes

**Mode A: a routine UI/content edit.** One builder; format/analyze/test; architecture/code map only when changed; one focused independent review; human decides to merge after `ci-gate`. The default two-reviewer tool may be omitted as long as the missing independent coverage is documented, never misrepresented as a pass.

**Mode B: a new Flutter feature.** Read `flutter-vertical-slice` skill and existing ADRs; define user outcome, error/offline path, repositories and widget/unit tests; two independent provider reviews; run complete platform CI and update SYSTEM.md on boundary changes.

**Mode C: identity, Firebase rules, group membership, private data or scoring.** Model abuse cases first; deny-by-default rules; run emulator negative tests for anonymous, different user, different group, role revoked and malformed input; independent Firebase security review plus another human; do not deploy cloud services without separate approval.

**Mode D: tooling, GitHub CI or agent instructions.** Confirm no secrets or privilege escalation; run lint/policy/skills/code-map checks; verify path classifier covers new files; review all automation from read-only perspective. Ensure agents cannot claim to be authorized to merge.

### What the reviewer can and cannot prove

Deterministic checks validate syntax, imports, tests, known invariants and stale generated docs. AI reviewers can generate useful hypotheses and identify missing edge cases, but their conclusions are not security proofs. Do not give AI reviewers control of production keys, approvals or merge credentials. A passing review means no high-impact finding in that **specific supplied diff and context**; it does not certify unseen code, cloud state or device behavior.

### Recommended evolution after PR #4

1. A small ADR on state management and durable local store; implement one devotional-workout slice with fake repositories and recovery tests.
2. Add a server-domain model (users, groups, membership, workouts, prayers, events, scores), explicit privacy matrix and abuse-case tests.
3. Implement group membership and protected storage on real DEV using well-tested Firebase rules and trusted server functions. Never reuse current developer smoke rules as production rules.
4. Add typed serialization boundaries, crash tests and sync idempotency to the first offline workflow.
5. Add observability, error redaction, app startup traces and CI artifact retention before beta distribution.
6. Add release signing, iOS/Android distribution policies, dependency update cadence and permissions privacy review before any public release.

## Keep the knowledge synchronized

- `AGENTS.md`: short global rules; nested `mobile/AGENTS.md`: Flutter-specific invariants.
- `.agents/skills/<name>/SKILL.md`: canonical reusable workflow; `.claude/skills/` mirrors exactly, verified in CI.
- `CLAUDE.md` and `GEMINI.md`: provider-specific introductions pointing at shared rules and diagrams.
- `docs/architecture/SYSTEM.md`: living current vs planned systems and security boundaries. Edit on design changes.
- `docs/architecture/CODE-MAP.md`: generated actual Dart imports and symbols. Run `python3 tooling/architecture/generate.py --write`, commit and validate.
- `docs/architecture/ADR-*`: decisions that should outlive a feature or engine choice.
- `docs/development/AI-REVIEW-WORKFLOW.md`: human copy/paste walkthrough, reviewer commands, limits and error handling.

## Verification matrix before PR #4 is mergeable

| Gate | Evidence required | Current interpretation |
|---|---|---|
| Rebase | PR base main, no prior foundation duplicated | Completed earlier on branch; confirm PR diff |
| Shared skills | Unit tests and `sync.py --check` | CI must pass, not enough just to commit files |
| Source map | `generate.py --check` and regression tests | CI must pass after Flutter changes |
| Multi-agent invocation | Actual Codex and Claude CLI call on clean Windows/Mac, JSON report, fail-closed cases | Not yet executed; installed CLIs/auth required |
| Firebase rules | Real emulator tests with positive and denied cases | CI required, pending verification |
| iOS | Flutter simulator build on compatible Xcode | CI required, previously failed on older Xcode |
| Android/Windows/Mac | Existing hosted CI plus physical clean workstation acceptance | Hosted CI is not equivalent to first-time beginner onboarding |
| PR governance | `ci-gate` required by server; risk review performed; secrets protection enabled | Human approval currently 0; recommended extra human for high-risk PR |

## Primary research sources

- Flutter app architecture: https://docs.flutter.dev/app-architecture/guide
- Flutter recommendations: https://docs.flutter.dev/app-architecture/recommendations
- Firebase Security Rules tests: https://firebase.google.com/docs/rules/unit-tests
- Codex skills: https://learn.chatgpt.com/docs/build-skills
- Codex CLI: https://learn.chatgpt.com/docs/cli/reference
- OpenAI scope-focused code review rules: https://developers.openai.com/blog/custom-code-review-rules-for-codex
- Claude skills/agents: https://claude.com/resources/articles/steering-claude-code-skills-hooks-rules-subagents-and-more
- Gemini CLI configuration and experimental plan mode: https://github.com/google-gemini/gemini-cli/blob/main/docs/reference/configuration.md
- GitHub secure Actions: https://docs.github.com/en/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions
