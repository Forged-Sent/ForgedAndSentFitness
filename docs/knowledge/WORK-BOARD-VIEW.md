---

kanban-plugin: board
view-of: WORK.md
update-by: edit WORK.md then run tooling/knowledge/work_board.py --write

---

## Next

- [ ] **Agents may merge after review**
	**Next:** Run prompt [P13](../reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md)
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
- [x] **Project 101 teaching path**
	**Note:** Use the 25-minute course and manual lesson checklist. Commands are source-checked; the friend's Windows/Mac/device walkthrough and Obsidian rendering still need to be exercised
	**Branch or PR:** [#63](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/63)
	[Edit this row in WORK](WORK.md)
- [x] **Decisions**
	**Note:** None; the answers are on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page
	**Branch or PR:** branch `chore/review-rules-and-dashboard`
	[Edit this row in WORK](WORK.md)
- [x] **Phase 0 decisions on `main`**
	**Note:** ADR-0008 (membership documents) stays Proposed until S4b starts, as the maintainer decided on 2026-11-19. Maintainer: the Decisions page still says `main` has ADR-0001 to ADR-0005; only the maintainer edits that page. Prompt P13 now names ADR-0010 for its record
	**Branch or PR:** branch `claude/adr-phase0-carry-forward`
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
- [x] **S2 Private journal**
	**Note:** Run it on a phone. Kept on the device only and not encrypted (Q8); the first change to the database schema, with a migration tested against the frozen schema of each version. The phone's own backup includes the database file, journal text with it: the maintainer decided on 2026-11-17 to leave phone backups on. Write, kill, relaunch passed on 2026-11-19 on one Android emulator on the maintainer's workstation (`FS_S1_Restart_API_36`, Android 16), with a test that is in the repository, and once by hand on one iPhone 17 simulator (iOS 27.2); not on a phone, and not in CI. The golden images are drawn and compared on Windows only. Not built: prayer tabs, tags, search, export, sync. Review findings the maintainer deferred to S4a on 2026-11-19, listed in pull request #77: the store is not bound to the owner of the file it opened; two cases that need a change of owner while the app is open; the privacy test looks for an entry's words in outgoing messages and not its question or ids; three gaps in tests (the device test's sentence is the same every run, the interrupted-upgrade test has no row to lose, the refused-write test on the background isolate does not see that isolate's own output); Drift's generated write object prints its fields if formatted
	**Branch or PR:** branch `claude/s2-private-journal`
	[Edit this row in WORK](WORK.md)
- [x] **Journal never loses typing**
	**Note:** Run it on a phone. Both were review findings on S2 that the maintainer marked required before any pilot (2026-11-19). The second was reproduced first, in a widget test, on Today and on Walk. Tested on screen only, in widget tests on Windows; not on an emulator or a phone
	**Branch or PR:** branch `claude/journal-never-loses-typing`
	[Edit this row in WORK](WORK.md)
- [x] **Lockfile-only pull requests pass the review check**
	**Note:** None. Unblocks Dependabot [#66](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/66). Without `--dry-run` such a change still gets no PASS and no review record, and `--verify` still fails
	**Branch or PR:** branch `claude/review-lockfile-dry-run`
	[Edit this row in WORK](WORK.md)
- [x] **Native hosts**
	**Note:** None. iOS is built only by CI's `ios-simulator` job: it has not been built locally, and there is no simulator or physical-device run yet. Release signing is a row under Later
	**Branch or PR:** branch `codex/native-host-acceptance`
	[Edit this row in WORK](WORK.md)
- [x] **S0 Design foundation**
	**Note:** None. Fuel, Train, Walk, Board and Rally are titled placeholders; the round header buttons do nothing yet. Not run on a phone or an emulator
	**Branch or PR:** branch `claude/s0-design-foundation`
	[Edit this row in WORK](WORK.md)
- [x] **S1 Today and Devotional**
	**Note:** None. Only the devotional box works; the other six are shown as not active yet. Complete, kill, relaunch passed on 2026-11-12 on one Android emulator on the maintainer's workstation, made from the Android 36 system image (Android 16); not on a phone, and not in CI. iOS is built only by CI
	**Branch or PR:** branch `claude/s1-today-devotional`
	[Edit this row in WORK](WORK.md)
- [x] **S1b v254 readings**
	**Note:** None. All 366 dates; the verse references and all scripture text are unchanged; the Sent and Spirit-led tags are shown as words only. Body text and scripture lost a stray letter spacing, so body text breaks where the prototype's does, on every screen; Today's mission line is balanced as the prototype's is; all 14 golden images were redrawn. Not run on a phone or an emulator: nothing that is saved changed
	**Branch or PR:** branch `claude/s1b-v254-readings`
	[Edit this row in WORK](WORK.md)
- [x] **Setup scripts and guides match the six-tab app**
	**Note:** Physical run on a fresh Windows PC and a Mac: the Try it now walkthrough, Mobile Check my setup, and a second setup run in the same window
	**Branch or PR:** branch `claude/bootstrap-test-readiness`
	[Edit this row in WORK](WORK.md)
- [x] **A setting that cannot be saved says so**
	**Note:** None. The page waits for the store's answer, so a failed write is no longer an unhandled error. Tested with a settings store that refuses to save; not run on a phone or an emulator. No table or schema change
	**Branch or PR:** branch `claude/settings-save-failure`
	[Edit this row in WORK](WORK.md)
- [x] **Preview script runs on a Windows workstation**
	**Note:** None. The script reads `index.html` and writes `dev/preview.html` as UTF-8, whatever the system's own encoding is. A test in `tooling/preview`, which CI runs on Linux, macOS and Windows, keeps it so
	**Branch or PR:** branch `claude/windows-workstation-checks`
	[Edit this row in WORK](WORK.md)
- [x] **Onboarding tests pass on a Windows workstation**
	**Note:** None. On Windows the tests run the Mac scripts with the Bash that Git for Windows ships, not the WSL launcher a bare `bash` starts. Run from WSL in a Windows checkout, the three launcher tests still fail, because `.command` files are checked out there with Windows line ends; that was so before and is not changed here
	**Branch or PR:** branch `claude/windows-workstation-checks`
	[Edit this row in WORK](WORK.md)
- [x] **One source for program and challenge content**
	**Note:** None. The maintainer's choices of 2026-11-19: the two 100-point formula lines are dropped from `seed/weekly-challenges.json`; the generated copy still leaves out RPE/RIR, which `seed/workouts.json` keeps; the workout prayer, camp names and banners, challenge modes and routine patterns moved into `seed/`; the PR points, step goals and step bonus stay in the prototype's code until the official rule set is decided. The branch `workout-library-seed` is set aside: it rewrites the same workout files from a base of 2026-10-24, so reviving it means redoing its edits on top of this, not merging it
	**Branch or PR:** branch `claude/l11-seed-single-source`
	[Edit this row in WORK](WORK.md)


## Later

- [ ] **S3 Workout logging**
	**Prompt:** [P07](../reviews/2026-11-10-prototype-to-flutter/prompts/P07-S3-workout-logging.md)
	[Edit this row in WORK](WORK.md)
- [ ] **S4 Sign-in, groups, first board**
	**Prompt:** [P08](../reviews/2026-11-10-prototype-to-flutter/prompts/P08-S4-contract-identity-groups-board.md), then [P09](../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md)
	[Edit this row in WORK](WORK.md)
- [ ] **Say which unreplaced completion event wins**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on [07-ARCHITECTURE](../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), section 5.8, and the full report. Do it before P08 runs
	[Edit this row in WORK](WORK.md)
- [ ] **Hero photograph's origin and licence**
	**Prompt:** No prompt yet. Found in S0. **High now**, not only before distribution. Owner: the maintainer
	[Edit this row in WORK](WORK.md)
- [ ] **Review the Dependabot alerts on `main`**
	**Prompt:** No prompt yet. Seen in the push output of S1b on 2026-11-12; S1b changed no dependency. Owner: the maintainer
	[Edit this row in WORK](WORK.md)
- [ ] **Reconcile the prototype baseline**
	**Prompt:** [P02](../reviews/2026-11-10-prototype-to-flutter/prompts/P02-reconcile-prototype-baseline.md). Not blocking S1: the theme rules, fonts and hero photo are identical in v254 and `main`. What still differs from v254 is listed on the [parity page](PROTOTYPE-PARITY.md). When this is done, retire the test that compares `seed/devotionals.json` with the readings inside `index.html` (`mobile/test/features/devotional/bundled_content_test.dart`, added in S1b to prove the copy from v254); retire it earlier if a reading is edited in `seed/` first
	[Edit this row in WORK](WORK.md)
- [ ] **CI checks the golden images**
	**Prompt:** No prompt yet. Found in S0. Not blocking
	[Edit this row in WORK](WORK.md)
- [ ] **ESV permission confirmed for an app**
	**Prompt:** No prompt yet. Decision Q7. Owner: the maintainer. Do it before public release
	[Edit this row in WORK](WORK.md)
- [ ] **Check the bundled scripture against a published text**
	**Prompt:** No prompt yet. Asked for by the maintainer in S1b. Do it before public release
	[Edit this row in WORK](WORK.md)
- [ ] **Check the readings' inline scripture**
	**Prompt:** No prompt yet. Found in S1b: the [full list](../features/today-devotional/inline-scripture-in-v254.md). Owner: the maintainer. Do it before public release
	[Edit this row in WORK](WORK.md)
- [ ] **The restart test runs in CI**
	**Prompt:** No prompt yet. Found in S1. Not blocking
	[Edit this row in WORK](WORK.md)
- [ ] **Amen's lock follows the reading on screen**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `mobile/lib/src/features/devotional/presentation/devotional_page.dart`: tie the lock to the date of the reading on screen, refuse Amen while that differs from today's date, and test it with a new day's data that arrives late. Found in S1's last review round and left unfixed at the maintainer's direction
	[Edit this row in WORK](WORK.md)
- [ ] **Recover from a corrupt database file**
	**Prompt:** No prompt yet. Found in S1 while fixing the start-up check (Codex's review of #65 on GitHub). Needs a decision on what to keep and what to tell him
	[Edit this row in WORK](WORK.md)
- [ ] **Local profile adopted at sign-in**
	**Prompt:** Part of S4: [P08](../reviews/2026-11-10-prototype-to-flutter/prompts/P08-S4-contract-identity-groups-board.md), then [P09](../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md)
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
- [ ] **Android release signing**
	**Prompt:** No prompt yet. Do it before anything is distributed
	[Edit this row in WORK](WORK.md)
- [ ] **Host wording left over from the generated hosts**
	**Prompt:** No prompt yet. Not blocking; needs a Mac to check
	[Edit this row in WORK](WORK.md)
- [ ] **`flutter-ai-review` on unlabeled tooling pull requests**
	**Prompt:** No prompt yet. Not blocking: only `ci-gate` is required
	[Edit this row in WORK](WORK.md)




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false],"show-checkboxes":false,"show-add-list":false,"show-archive-all":false}
```
%%