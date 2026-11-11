---
title: "P10 Independent review of a PR (give to the other AI)"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P10 · Independent review of a PR (give to the other AI)

> [!IMPORTANT] Before you paste
> - [ ] An open PR written by a different agent than the one you paste this into

## What you fill in

Replace these in the prompt text before you paste. Everything else comes from the Decisions page.

| Find this | Put in |
|---|---|
| ==`<<FILL: PR number>>`== | The pull request to review |
| ==`<<FILL: step>>`== | Which build step it implements, for example S1 |

## The prompt

Copy everything in the box.

```text
Read first, in this order:
1. AGENTS.md (and mobile/AGENTS.md for any Flutter work).
2. docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md
   - The "Your answers" table holds my decisions. Use them exactly as written.
   - Any answer that still contains TODO is unanswered. If this task needs
     it, stop and ask me. Do not choose for me.
   - The "Run settings" table holds the SDK version, branches and paths.
3. docs/reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md, the step named below.

You did not write this change. Review PR #<<FILL: PR number>>, which
implements step <<FILL: step>>. Read-only: do not push, edit, approve or
merge.

Use the independent-code-review skill. For rules, auth, scoring or private
data also use firebase-security-review.

Check, in this order:
1. Does it deliver the user-visible goal of that step? Run it if you can.
2. Is each acceptance criterion covered by a test that would fail if the
   behavior broke? Name any criterion with no real test.
3. Does anything contradict my answers in 01-DECISIONS.md, or decide
   something I have not decided?
4. Private data: can journal text, body data or another user's data reach
   a shared document, a log, or a Firebase call?
5. Scope: any tooling, docs or abstractions that the step did not ask for?
6. Docs are part of done: are the WORK.md row, the PROTOTYPE-PARITY rows,
   the feature contract and the design or architecture pages updated in
   this PR, and do they say only what will be true once it merges?
7. Run flutter analyze and flutter test on the PR head and paste the
   output.

Report findings as a table: severity, file and line, evidence, smallest
fix. Separate confirmed defects from risks and from preferences. If you
could not run something, say NOT VERIFIED.
```

## When it comes back, check

- [ ] The reviewer is a different provider than the author
- [ ] Findings cite file and line
- [ ] Test output is pasted
