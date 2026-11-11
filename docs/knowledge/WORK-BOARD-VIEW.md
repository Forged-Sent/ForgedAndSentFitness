---

kanban-plugin: board
view-of: WORK.md
update-by: edit WORK.md then run tooling/knowledge/work_board.py --write

---

## Next

- [ ] **Agents may merge after review**
	**Next:** Run prompt [P13](../reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md) after its merge check is fixed (see Later)
	[Edit this row in WORK](WORK.md)
- [ ] **Native hosts**
	**Next:** Run prompt [P03](../reviews/2026-11-10-prototype-to-flutter/prompts/P03-native-hosts-pr.md)
	**Branch or PR:** local branch `codex/native-host-acceptance`, no PR yet
	[Edit this row in WORK](WORK.md)
- [ ] **S0 Design foundation**
	**Next:** Run prompt [P04](../reviews/2026-11-10-prototype-to-flutter/prompts/P04-S0-design-foundation-and-shell.md) after the hosts merge
	[Edit this row in WORK](WORK.md)
- [ ] **S1 Today and Devotional**
	**Next:** Run prompt [P05](../reviews/2026-11-10-prototype-to-flutter/prompts/P05-S1-today-and-devotional.md) after S0 and after the completion-event key is fixed (see Later)
	[Edit this row in WORK](WORK.md)


## In progress



## Waiting

- [ ] **Hosted AI review gate (PR #48, [handoff](handoffs/flutter-ai-review-gate.md))**
	**Waiting on:** It guards an app with almost no code yet. `ci-gate` stays required
	**Unblocks when:** S4 adds sign-in, rules or scoring
	[Edit this row in WORK](WORK.md)
- [ ] **Synthetic Today demo (local branch `codex/today-demo-contract`)**
	**Waiting on:** Replaced by S1, which reuses its view model and test patterns
	**Unblocks when:** Not resumed; S1 supersedes it
	[Edit this row in WORK](WORK.md)
- [ ] **Architecture Atlas upkeep, Obsidian first-use pilot**
	**Waiting on:** Not on the path to a feature
	**Unblocks when:** After S1
	[Edit this row in WORK](WORK.md)
- [ ] **Binary assets in review**
	**Waiting on:** Images and fonts are pinned by hash, not inspected, and the hosted review gate still refuses them
	**Unblocks when:** Resume when the hosted review gate is picked up again: give it the same allow-list and have a person or an image-capable reviewer sign off new images
	[Edit this row in WORK](WORK.md)


## Done

**Complete**
- [x] **Decisions**
	**Note:** None; the answers are on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page
	**Branch or PR:** branch `chore/review-rules-and-dashboard`
	[Edit this row in WORK](WORK.md)
- [x] **CI accepts images and fonts**
	**Branch or PR:** [#54](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/54)
	[Edit this row in WORK](WORK.md)
- [x] **Publish review and rules cleanup**
	**Branch or PR:** branch `chore/review-rules-and-dashboard`
	[Edit this row in WORK](WORK.md)
- [x] **Obsidian focus workspace**
	**Note:** Set the Homepage plugin to open HOME: one command, in the [Obsidian setup guide](OBSIDIAN-SETUP.md) under Set up once per vault
	**Branch or PR:** branch `claude/obsidian-adhd-workspace`
	[Edit this row in WORK](WORK.md)


## Later

- [ ] **Archive Copilot and Gemini rule files**
	**Prompt:** [P14](../reviews/2026-11-10-prototype-to-flutter/prompts/P14-archive-copilot-and-gemini-rules.md), any time after P01
	[Edit this row in WORK](WORK.md)
- [ ] **S2 Private journal**
	**Prompt:** [P06](../reviews/2026-11-10-prototype-to-flutter/prompts/P06-S2-private-journal.md)
	[Edit this row in WORK](WORK.md)
- [ ] **S3 Workout logging**
	**Prompt:** [P07](../reviews/2026-11-10-prototype-to-flutter/prompts/P07-S3-workout-logging.md)
	[Edit this row in WORK](WORK.md)
- [ ] **S4 Sign-in, groups, first board**
	**Prompt:** [P08](../reviews/2026-11-10-prototype-to-flutter/prompts/P08-S4-contract-identity-groups-board.md), then [P09](../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md), after the account-switch claim is fixed (two rows down)
	[Edit this row in WORK](WORK.md)
- [ ] **Fix the merge check in prompt P13**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on [P13](../reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md). Do it before P13 runs
	[Edit this row in WORK](WORK.md)
- [ ] **Fix the completion-event key in the review**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on [07-ARCHITECTURE](../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md) and the full report. Do it before P05 runs
	[Edit this row in WORK](WORK.md)
- [ ] **Fix the account-switch claim in the review**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on [07-ARCHITECTURE](../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), section 5.4. Do it before P08 runs
	[Edit this row in WORK](WORK.md)
- [ ] **Dashboard lists branches whose GitHub branch was deleted**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `tooling/knowledge/live_status.py`. Not blocking
	[Edit this row in WORK](WORK.md)
- [ ] **Dashboard waits for GitHub's conflict check**
	**Prompt:** No prompt yet. Not blocking: the next refresh corrects it
	[Edit this row in WORK](WORK.md)
- [ ] **Local Linux checks reach the Python floor**
	**Prompt:** No prompt yet. Not blocking: GitHub runs the job on a newer Python
	[Edit this row in WORK](WORK.md)
- [ ] **`flutter-ai-review` on unlabeled tooling pull requests**
	**Prompt:** No prompt yet. Not blocking: only `ci-gate` is required
	[Edit this row in WORK](WORK.md)




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false],"show-checkboxes":false,"show-add-list":false,"show-archive-all":false}
```
%%