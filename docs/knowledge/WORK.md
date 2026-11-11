# Work board

The one board for this project. Each pull request edits its own row **in the same pull request, written as it will be true once that pull request merges**. Nothing here records CI or merge state; open the linked pull request or the [live list](https://github.com/Forged-Sent/ForgedAndSentFitness/pulls) for that.

Plan and reasoning: [prototype-to-Flutter review](../reviews/2026-11-10-prototype-to-flutter/00-START-HERE.md). Prompts for each row: [agent prompts](../reviews/2026-11-10-prototype-to-flutter/03-AGENT-PROMPTS.md).

## Now

| Step | What a man can see when it is done | State | Branch or PR | Next action |
|---|---|---|---|---|
| Decisions | Nothing yet; this unblocks the rest | **Done** | branch `chore/review-rules-and-dashboard` | None; the answers are on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page |
| CI accepts images and fonts | Nothing yet; without it the required check fails every pull request below | **Done** | [#54](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/54) | — |
| Publish review and rules cleanup | The dashboard, board and rules on `main` | **Done** | branch `chore/review-rules-and-dashboard` | — |
| Agents may merge after review | Nothing on screen; app and docs pull requests that pass independent review no longer wait for the maintainer | **Next** | — | Run prompt [P13](../reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md) after its merge check is fixed (see Later) |
| Native hosts | The app builds for Android and iOS from committed host projects | **Next** | local branch `codex/native-host-acceptance`, no PR yet | Run prompt [P03](../reviews/2026-11-10-prototype-to-flutter/prompts/P03-native-hosts-pr.md) |
| S0 Design foundation | The app opens looking like the prototype: brand bar, hero header, six-tab bar | **Next** | — | Run prompt [P04](../reviews/2026-11-10-prototype-to-flutter/prompts/P04-S0-design-foundation-and-shell.md) after the hosts merge |
| S1 Today and Devotional | Today and today's real devotional; Amen is still checked after a restart | **Next** | — | Run prompt [P05](../reviews/2026-11-10-prototype-to-flutter/prompts/P05-S1-today-and-devotional.md) after S0 and after the completion-event key is fixed (see Later) |

## Later

| Step | What a man can see when it is done | Prompt |
|---|---|---|
| Archive Copilot and Gemini rule files | Nothing on screen; fewer rule files to keep in step, recoverable later | [P14](../reviews/2026-11-10-prototype-to-flutter/prompts/P14-archive-copilot-and-gemini-rules.md), any time after P01 |
| S2 Private journal | "Write it down" saves to a private journal | [P06](../reviews/2026-11-10-prototype-to-flutter/prompts/P06-S2-private-journal.md) |
| S3 Workout logging | Log today's workout; nothing lost if the app is killed | [P07](../reviews/2026-11-10-prototype-to-flutter/prompts/P07-S3-workout-logging.md) |
| S4 Sign-in, groups, first board | Sign in and see a server-computed board for his group | [P08](../reviews/2026-11-10-prototype-to-flutter/prompts/P08-S4-contract-identity-groups-board.md), then [P09](../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md), after the account-switch claim is fixed (two rows down) |
| Fix the merge check in prompt P13 | Nothing on screen; the check counts only a finished, independent review tied to the head commit. As written in step 4, any comment that contains the commit SHA and the word "review" would count | No prompt yet. Review finding (Codex, medium) on [P13](../reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md). Do it before P13 runs |
| Fix the completion-event key in the review | Nothing on screen; an undo and a second completion can both be stored. As written in journey J1, the event row is keyed by (owner, date, item), which allows one event per item per day | No prompt yet. Review finding (Codex, medium) on [07-ARCHITECTURE](../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md) and the full report. Do it before P05 runs |
| Fix the account-switch claim in the review | Nothing on screen; the review says what happens to Firestore's cache and listeners when the account changes. As written, one Drift file per user is said to prevent leaks "by construction", which covers Drift only | No prompt yet. Review finding (Codex, medium) on [07-ARCHITECTURE](../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), section 5.4. Do it before P08 runs |
| Dashboard lists branches whose GitHub branch was deleted | Nothing on screen; such a branch is listed when it still holds commits that are not on `main`. Today it is skipped, so work on it can go unseen | No prompt yet. Review finding (Codex, medium) on `tooling/knowledge/live_status.py`. Not blocking |
| Dashboard waits for GitHub's conflict check | Nothing on screen; a pull request is not called ready while GitHub is still working out whether it conflicts. Seen once, for a moment after `main` moved | No prompt yet. Not blocking: the next refresh corrects it |
| Local Linux checks reach the Python floor | Nothing on screen; the whole `policy` job runs in WSL. Today WSL has Python 3.10 and `tooling/policy` needs 3.11 or newer, so its two commands fail there | No prompt yet. Not blocking: GitHub runs the job on a newer Python |
| `flutter-ai-review` on unlabeled tooling pull requests | Nothing on screen; a pull request that touches `tooling/review/` or the workflows and has no `authorship:` label no longer shows a failed check by default | No prompt yet. Not blocking: only `ci-gate` is required |

## Paused

| Work | Why | Resume when |
|---|---|---|
| Hosted AI review gate (PR #48, [handoff](handoffs/flutter-ai-review-gate.md)) | It guards an app with almost no code yet. `ci-gate` stays required | S4 adds sign-in, rules or scoring |
| Synthetic Today demo (local branch `codex/today-demo-contract`) | Replaced by S1, which reuses its view model and test patterns | Not resumed; S1 supersedes it |
| Architecture Atlas upkeep, Obsidian first-use pilot | Not on the path to a feature | After S1 |
| Binary assets in review | Images and fonts are pinned by hash, not inspected, and the hosted review gate still refuses them | Resume when the hosted review gate is picked up again: give it the same allow-list and have a person or an image-capable reviewer sign off new images |

## How to update this page

- Starting a row: set State to **In progress** and add your branch.
- Finishing a row: in the pull request that finishes it, set State to **Done** and write the next row's next action.
- Do not add "open", "merged" or "CI green". Link the pull request.
- CI fails a pull request that changes `mobile/lib/`, `firebase/` or `functions/` without changing this file.
