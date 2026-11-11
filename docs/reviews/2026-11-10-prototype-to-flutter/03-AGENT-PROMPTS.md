---
title: "Agent prompts"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](00-START-HERE.md) · Back: [Build plan](02-BUILD-PLAN.md) · Next: [Findings](04-FINDINGS.md)

# Agent prompts

> [!IMPORTANT] How this works
> 1. Fill in your answers once on the [Decisions](01-DECISIONS.md) page.
> 2. Open a prompt page, copy the box, paste it into Codex or Claude Code.
> 3. Each prompt tells the agent to read the Decisions page. Change an answer there and every prompt uses the new one. You never edit prompt text, except the two highlighted fill-ins on P10 and P11.

## All prompts, in order

| # | Prompt | Step | Run when | You fill in | Reads answers |
|---|---|---|---|---|---|
| P01 | [Publish the review, my decisions and the rules cleanup](prompts/P01-publish-review-and-record-decisions.md) | Decide | You filled in the five TODO answers on the Decisions page | Nothing | Q1, Q2, Q5, Q6, Q7 |
| P02 | [Reconcile the two prototype forks](prompts/P02-reconcile-prototype-baseline.md) | Decide | P01 merged | Nothing | Q1 |
| P03 | [Publish the Android and iOS hosts](prompts/P03-native-hosts-pr.md) | Prepare | P12 merged: the host projects contain launcher icons | Nothing | None |
| P04 | [Design foundation and tab shell](prompts/P04-S0-design-foundation-and-shell.md) | S0 | P12 merged | Nothing | Q1 |
| P05 | [Today and Devotional, real and saved](prompts/P05-S1-today-and-devotional.md) | S1 | P04 merged | Nothing | Q5, Q6, Q7, Q9, Q10 |
| P06 | [Private journal](prompts/P06-S2-private-journal.md) | S2 | P05 merged | Nothing | Q8 |
| P07 | [Workout logging, one program](prompts/P07-S3-workout-logging.md) | S3 | P05 merged | Nothing | Q11, L11 |
| P08 | [S4 contract: sign-in, groups, first shared board (design only)](prompts/P08-S4-contract-identity-groups-board.md) | S4 | P05 merged | Nothing | Q2, Q3, Q4, Q9, Q10 |
| P09 | [S4 implementation](prompts/P09-S4-implement-identity-groups-board.md) | S4 | P08 merged and you changed its status to approved | Nothing | Q2, Q3, Q4 |
| P10 | [Independent review of a PR (give to the other AI)](prompts/P10-independent-review.md) | Any | An open PR written by a different agent than the one you paste this into | ==`<<FILL: PR number>>`==, ==`<<FILL: step>>`== | None |
| P11 | [Fix review findings (one round)](prompts/P11-address-review-findings.md) | Any | A review from P10 exists on the PR | ==`<<FILL: PR number>>`== | None |
| P12 | [Let CI accept reviewed images and fonts](prompts/P12-let-ci-accept-binary-assets.md) | Prepare | A2 answered on the Decisions page | Nothing | A2 |
| P13 | [Let agents merge after independent review](prompts/P13-let-agents-merge-after-review.md) | Prepare | P01 merged: this edits the rule files P01 publishes | Nothing | A3 |
| P14 | [Archive the Copilot and Gemini rule files](prompts/P14-archive-copilot-and-gemini-rules.md) | Prepare | P01 merged | Nothing | A1 |
| P00 | [Orchestrator kickoff: Claude builds, Codex reviews](prompts/P00-orchestrator-kickoff.md) | Run everything | Every answer on the Decisions page is filled in | Nothing | None |

## One prompt per pull request

- [ ] [P01](prompts/P01-publish-review-and-record-decisions.md) Publish the review, decisions and rules cleanup
- [ ] [P02](prompts/P02-reconcile-prototype-baseline.md) Reconcile the prototype forks (only if Q1 says so)
- [ ] [P03](prompts/P03-native-hosts-pr.md) Publish the native hosts
- [ ] [P04](prompts/P04-S0-design-foundation-and-shell.md) S0 design foundation and shell
- [ ] [P05](prompts/P05-S1-today-and-devotional.md) S1 Today and Devotional
- [ ] [P06](prompts/P06-S2-private-journal.md) S2 private journal
- [ ] [P07](prompts/P07-S3-workout-logging.md) S3 workout logging
- [ ] [P08](prompts/P08-S4-contract-identity-groups-board.md) S4 contract
- [ ] [P09](prompts/P09-S4-implement-identity-groups-board.md) S4 implementation
- [ ] [P10](prompts/P10-independent-review.md) Independent review, any PR
- [ ] [P11](prompts/P11-address-review-findings.md) Fix review findings, any PR
- [ ] [P12](prompts/P12-let-ci-accept-binary-assets.md) Let CI accept images and fonts. **Run this one first**
- [ ] [P13](prompts/P13-let-agents-merge-after-review.md) Let agents merge after independent review (optional; after P01)
- [ ] [P14](prompts/P14-archive-copilot-and-gemini-rules.md) Archive the Copilot and Gemini rule files (any time after P01)

> [!TIP] Run them all from one session
> [P00](prompts/P00-orchestrator-kickoff.md) starts Claude Code as the orchestrator: it runs the prompts in order, has Codex review each change, and stops for your pushes and merges.

## Why not one big prompt

"Fix the issues in the review" fails in a predictable way. The top blockers are missing product decisions, and an agent told to fix them will either invent the rules or write more process documents.

## What every prompt here does on purpose

| Technique | Why |
|---|---|
| Leads with what a man can see and do | Keeps the agent on the product instead of scaffolding |
| Reads your answers from one file | You fill things in once; nothing goes stale in a pasted prompt |
| Says "if the answer is TODO, stop and ask" | Prevents invented scoring and privacy rules |
| Lists acceptance criteria as tests | You can check "done" without reading the diff |
| Names what is out of scope | The default drift in this repo is toward tooling and docs |
| Asks for a plan first on build steps | Two minutes of reading catches a wrong direction early |
| Asks for command output and NOT VERIFIED labels | Evidence instead of claims, using the label your repo already uses |
| Never pushes without you | Matches the agent push rule in `AGENTS.md` |

## Where findings get fixed

Most findings are not tasks for today. They become acceptance criteria on the step that touches them.

| Findings | Fixed by |
|---|---|
| Q1, Q2, Q5, Q6, Q7 | You, on the [Decisions](01-DECISIONS.md) page |
| B1 forked prototype | P01, and P02 if you reconcile |
| B2 decisions not on `main` | P01 |
| B3 no path to parity, B6 effort on process | The new work board, already written; P01 publishes it |
| B4 no design system | P04 |
| B5 repository contract | P05 |
| L6 silent saves, L9 streak | P05 |
| L7 history keyed by position, L8 midnight, L12 first-week gap | P07 |
| L1 client scoring, L2 shared data, L5 membership | P08 and P09 |
| L3 report and block, L4 deletion | The later Rally and Settings steps; not yet prompted |
| A13 CI rejects images and fonts | P12, after you answer A2 |
| A1 to A11 agent rules, skills, status pages | Already changed in your main checkout, uncommitted; P01 publishes them. See the [audit](09-AGENT-RULES-AUDIT.md) |
