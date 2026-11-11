# Work board

The one board for this project. Each pull request edits its own row **in the same pull request, written as it will be true once that pull request merges**. Nothing here records CI or merge state; open the linked pull request or the [live list](https://github.com/Forged-Sent/ForgedAndSentFitness/pulls) for that.

**Board view:** [five lanes, one card per row](WORK-BOARD-VIEW.md). It and the block at the top of [HOME](../HOME.md) are generated from this page; see **How to update this page** at the bottom.

Plan and reasoning: [prototype-to-Flutter review](../reviews/2026-11-10-prototype-to-flutter/00-START-HERE.md). Prompts for each row: [agent prompts](../reviews/2026-11-10-prototype-to-flutter/03-AGENT-PROMPTS.md).

## Now

| Step | What a man can see when it is done | State | Branch or PR | Next action |
|---|---|---|---|---|
| Decisions | Nothing yet; this unblocks the rest | **Done** | branch `chore/review-rules-and-dashboard` | None; the answers are on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page |
| CI accepts images and fonts | Nothing yet; without it the required check fails every pull request below | **Done** | [#54](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/54) | — |
| Publish review and rules cleanup | The dashboard, board and rules on `main` | **Done** | branch `chore/review-rules-and-dashboard` | — |
| Obsidian focus workspace | HOME opens with one next action; this board shows as five lanes in Obsidian, generated from this page | **Done** | branch `claude/obsidian-adhd-workspace` | Set the Homepage plugin to open HOME: one command, in the [Obsidian setup guide](OBSIDIAN-SETUP.md) under Set up once per vault |
| Agents may merge after review | Nothing on screen; app and docs pull requests that pass independent review no longer wait for the maintainer | **Next** | — | Run prompt [P13](../reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md) after its merge check is fixed (see Later) |
| Native hosts | The app builds for Android and iOS from committed host projects | **Done** | branch `codex/native-host-acceptance` | None. iOS is built only by CI's `ios-simulator` job: it has not been built locally, and there is no simulator or physical-device run yet. Release signing is a row under Later |
| S0 Design foundation | The app opens looking like the prototype: brand bar, hero header, six-tab bar | **Next** | — | Run prompt [P04](../reviews/2026-11-10-prototype-to-flutter/prompts/P04-S0-design-foundation-and-shell.md) |
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
| Android release signing | Nothing on screen; a release build is signed with its own release key. Today the release build type uses the debug signing config, so a release build must not be distributed | No prompt yet. Do it before anything is distributed |
| Onboarding tests pass on a Windows workstation | Nothing on screen; the Mac shell tests in `tooling/onboarding` run on Windows. Today Python's bare `bash` starts WSL's, which cannot open `C:\` paths, so 16 of the 29 tests fail there | No prompt yet. Not blocking: they pass in WSL and on GitHub |
| Pinned Flutter first on the maintainer's PATH | Nothing on screen; typing `flutter` on the maintainer's workstation runs the pinned 3.47.8. Today an older 3.44.8 at `C:\ws_c\flutter` comes first; the pinned SDK is the one setup installed in the user folder | No prompt yet. Not blocking: the launchers and VS Code use the pinned SDK, and agents put it first for their own commands |
| Host wording left over from the generated hosts | Nothing on screen; the Mac setup script no longer calls the iOS host git-ignored, and the iOS display name says "Forged & Sent" like Android (today "Forged And Sent") | No prompt yet. Not blocking; needs a Mac to check |
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
- After any edit to a row, run `python tooling/knowledge/work_board.py --write` and commit the regenerated [board view](WORK-BOARD-VIEW.md) and `docs/HOME.md` with it. `python tooling/knowledge/check.py` and CI fail when they do not match this page.
- Lanes on the board view: **Next** is State Next; **In progress** is State In progress; **Done** is State Done; **Waiting** is the Paused table, or State Blocked, Decision needed or Review; **Later** is the Later table. Any other State is an error.
- A waiting row says why it waits and what resumes it. A Next or In progress row needs a next action that starts with a verb.
- Row order is priority. HOME recommends the first In progress row, or the first Next row when nothing is in progress.
- Dragging a card in Obsidian does not change this page; the next refresh puts the card back.
- Remove a Done row once it is old news. Its outcome stays in its pull request and in Git history.
- Do not add "open", "merged" or "CI green". Link the pull request.
- CI fails a pull request that changes `mobile/lib/`, `firebase/` or `functions/` without changing this file, and any pull request whose branch is named on this page.
- Maintainer: edit a row here in Obsidian and leave it. The dashboard lists the edit under Needs your attention, and the next agent session publishes it as a pull request for your merge.
