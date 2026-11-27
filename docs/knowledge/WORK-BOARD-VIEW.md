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
- [x] **"Save to my journal" stays in view while he writes**
	**Note:** None for the maintainer beyond his review. Found on 2026-11-22 when a taller keyboard made the journal restart test miss its tap; reproduced and fixed at his direction of 2026-11-23, with tests that failed first. The journal restart test's tap waits until the button is where a tap lands. No change to what is stored
	**Branch or PR:** branch `claude/journal-save-in-view`
	[Edit this row in WORK](WORK.md)
- [x] **Journal never loses typing**
	**Note:** Run it on a phone. Both were review findings on S2 that the maintainer marked required before any pilot (2026-11-19). The second was reproduced first, in a widget test, on Today and on Walk. Tested on screen only, in widget tests on Windows; not on an emulator or a phone
	**Branch or PR:** branch `claude/journal-never-loses-typing`
	[Edit this row in WORK](WORK.md)
- [x] **Lockfile-only pull requests pass the review check**
	**Note:** None. Unblocks Dependabot [#66](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/66). Without `--dry-run` such a change still gets no PASS and no review record, and `--verify` still fails
	**Branch or PR:** branch `claude/review-lockfile-dry-run`
	[Edit this row in WORK](WORK.md)
- [x] **Push from a worktree runs the local checks**
	**Note:** None. A branch cut before this merges keeps the older hook until it merges `main`. Not run on Windows
	**Branch or PR:** branch `claude/pre-push-hook-worktrees`
	[Edit this row in WORK](WORK.md)
- [x] **Host wording left over from the generated hosts**
	**Note:** None. Checked on 2026-11-19 in a debug simulator build installed on one iPhone 17 simulator (iOS 27.2): the installed app reports the display name "Forged & Sent", and the home screen shows that name under the icon. Nothing ran on a physical iPhone. The Mac setup script's wording was fixed earlier by `claude/bootstrap-test-readiness`
	**Branch or PR:** branch `claude/ios-restart-check`
	[Edit this row in WORK](WORK.md)
- [x] **Native hosts**
	**Note:** None. iOS is built by CI's `ios-simulator` job. On 2026-11-19 a debug simulator build was also made on the maintainer's Mac (Xcode 27.2, Flutter 3.47.8), installed on one iPhone 17 simulator (iOS 27.2) and opened on Today. Nothing has run on a physical iPhone. Release signing is a row under Later
	**Branch or PR:** branch `codex/native-host-acceptance`
	[Edit this row in WORK](WORK.md)
- [x] **S0 Design foundation**
	**Note:** None. Fuel, Board and Rally are titled placeholders; Walk is the journal (S2) and Train was built in S3. The round header buttons do nothing yet, except two on Today: the profile button opens Settings (S1), and the pen opens a new journal entry (S2). The shell has run on one Android emulator, in the S1 and S3 restart tests; not on a phone
	**Branch or PR:** branch `claude/s0-design-foundation`
	[Edit this row in WORK](WORK.md)
- [x] **S1 Today and Devotional**
	**Note:** None. Two boxes work: the devotional box, and since S3 the Workout box, which opens Train and checks itself when a workout is finished there; on a day his plan holds no workout it says so ("Rest day", "Plan starts Monday", "Plan complete") and is not counted. The other five are shown as not active yet. Complete, kill, relaunch passed on 2026-11-12 on one Android emulator on the maintainer's workstation, made from the Android 36 system image (Android 16); not on a phone, and not in CI. On iOS, complete, kill, relaunch passed on 2026-11-19 on one iPhone 17 simulator (iOS 27.2) on the maintainer's Mac; not on a physical iPhone, and not in CI. It passed after the helper that reads to the end was changed to bring Amen onto the screen before the tap; the Android run passed again with that change on 2026-11-20, on the S3 build
	**Branch or PR:** branch `claude/s1-today-devotional`
	[Edit this row in WORK](WORK.md)
- [x] **S1b v254 readings**
	**Note:** None. All 366 dates; the verse references and all scripture text are unchanged; the Sent and Spirit-led tags are shown as words only. Body text and scripture lost a stray letter spacing, so body text breaks where the prototype's does, on every screen; Today's mission line is balanced as the prototype's is; all 14 golden images were redrawn. Not run on a phone or an emulator: nothing that is saved changed
	**Branch or PR:** branch `claude/s1b-v254-readings`
	[Edit this row in WORK](WORK.md)
- [x] **S3 Workout logging**
	**Note:** The maintainer approved the [contract](../features/workout-logging/feature.md), FNS-004, on 2026-11-22, confirmed the rules taken from the prototype as built and approved the golden images. Two things he wants before any pilot are rows under Later: an alert when the rest timer reaches zero, and a field in `seed/` for whether a lift needs a weight. His six decisions of 2026-11-13 are recorded in the contract and built. The database is at schema version 3, after the journal's version 2, with tested migrations from versions 1 and 2; the contract is FNS-004. Start, two sets, kill, relaunch, finish passed on 2026-11-13 on one Android emulator on the maintainer's workstation, made from the Android 36 system image (Android 16). On 2026-11-20, on that emulator, this build was installed over a build of `main` that held two journal entries and a completed day: the file went from version 2 to version 3 with all of it intact, a workout was started, and everything was still there after a kill and relaunch (the upgrade test under `mobile/integration_test/`). Not on a phone, and not in CI. iOS is built only by CI. No plan setup or editor: every member gets the Forged program, a full gym, rest on Sunday and lifting on Monday, Wednesday and Friday
	**Branch or PR:** branch `claude/s3-workout-logging`
	[Edit this row in WORK](WORK.md)
- [x] **Finish closes the set boxes**
	**Note:** None for the maintainer beyond his review. The finding of the hosted review of [#85](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/85) that was open when #85 merged; fixed at his direction of 2026-11-23, with tests that failed first. No change to what is stored
	**Branch or PR:** branch `claude/finish-closes-set-boxes`
	[Edit this row in WORK](WORK.md)
- [x] **Add or remove a set during a workout**
	**Note:** The maintainer: approve the addition to the [contract](../features/workout-logging/feature.md), which is marked there as proposed and added after his approval of FNS-004, and look at the two redrawn golden images (logging sets, dark and light), which are **not approved**. Built to his rules of 2026-11-22. While a workout is being finished, "Add set" and "Remove" take nothing, as the set boxes do. No change to the database: an added set is a row in the session's existing set table. Not on a phone
	**Branch or PR:** branch `claude/s3-add-remove-set`
	[Edit this row in WORK](WORK.md)
- [x] **Supersets are shown grouped together**
	**Note:** The maintainer: approve the addition to the [contract](../features/workout-logging/feature.md), marked there as proposed and added after his approval of FNS-004, and look at six golden images, which are **not approved**: two new ones of the group, and four redrawn because the group is in view (the workout before it is started, and the prayer over it). The pair comes from the day's `superset` mark in `seed/workouts.json`, not from the prescription's words. By his decision of 2026-11-23 the mark is copied into the session when it starts: one new column, **database schema version 4**, with tested migrations from versions 1, 2 and 3. A workout started before this build is left ungrouped. The rest timer rules and the summary are unchanged. Built on top of the add-a-set branch. Not on a phone
	**Branch or PR:** branch `claude/s3-supersets-grouped`
	[Edit this row in WORK](WORK.md)
- [x] **The upgrade device test runs on any day of the week**
	**Note:** None for the maintainer beyond his review. Test code and documents only: nothing under `mobile/lib/` changed. On 2026-11-22, a Sunday, the test as it was failed in part 2 (no workout to start), and the changed test passed on the emulator without its date being touched. The older build has no way to be given a clock, so part 1 starts it as its `main()` does with the clock put in beside the store. His decision of 2026-11-21
	**Branch or PR:** branch `claude/upgrade-test-any-day`
	[Edit this row in WORK](WORK.md)
- [x] **A started workout opens without the program**
	**Note:** None. The workout page reads the stored session first, and asks for the plan and the program only on a day with no session. It answers the one Medium finding of the Codex review of [#94](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/94), and its two Low findings in the page's tests, by the maintainer's decision of 2026-11-26. No schema change. Not on a phone
	**Branch or PR:** branch `claude/started-workout-without-program`
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
- [x] **The reading's labels without slashes; Crossway's current notice**
	**Note:** The maintainer: look at the ten redrawn golden images (the eight reading images and the two of "Write it down"), which are drawn and **not approved**. Both changes are his decisions of 2026-11-21 after trying the app by hand. The notice was read from Crossway's permissions page that day; the notice stays under the verse. The prototype is unchanged
	**Branch or PR:** branch `claude/devotional-labels-esv-notice`
	[Edit this row in WORK](WORK.md)
- [x] **iPhone simulator launcher works with Xcode 27**
	**Note:** None. Run on 2026-11-18 on the maintainer's Mac (macOS 27.2, Xcode 27.2, iPhone 17 simulator, iOS 27.2) in Preview mode, from an empty `SourcePackages` folder. Not run: practice-Firebase mode on the simulator, an Xcode that still has Simulator.app, a Mac with no window app, and a physical iPhone
	**Branch or PR:** branch `claude/ios-simulator-launcher`
	[Edit this row in WORK](WORK.md)


## Later

- [ ] **Reorder exercises within a workout**
	**Prompt:** No prompt yet. Asked for by the maintainer on 2026-11-21, after [#85](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/85). Needs a decision: whether the new order holds for that one session only, and whether the two exercises of a superset move as one
	[Edit this row in WORK](WORK.md)
- [ ] **An optional or extra activity on a rest day**
	**Prompt:** No prompt yet. Asked for by the maintainer on 2026-11-21, after [#85](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/85). Needs a decision: what it is (the plan's optional fourth day, or any activity he names) and whether it checks a box on Today
	[Edit this row in WORK](WORK.md)
- [ ] **The rest timer alerts at zero, also when the phone is locked**
	**Prompt:** No prompt yet. **Required before any pilot** (the maintainer, 2026-11-22). Found in S3; this row was "The rest timer is heard". It needs the maintainer's decision first: a notification permission, and most likely a new dependency. The options were written up for him on 2026-11-22. Read `docs/knowledge/FLUTTER-PLATFORMS.md` first
	[Edit this row in WORK](WORK.md)
- [ ] **Whether a lift needs a weight comes from `seed/`**
	**Prompt:** No prompt yet. **Required before any pilot** (the maintainer, 2026-11-22). `seed/` is the one source (decision L11): the field is added there, and the bundled copy and the copy inside `index.html` follow by their scripts. A list of the movements where the name gives a doubtful answer was written up for him on 2026-11-22
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
- [ ] **Scripture licence**
	**Prompt:** No prompt yet. Owner: the maintainer; his own to-do, in his words of 2026-11-21. Decision Q7. Until he settles it, work goes on as if permission is in place. This row replaces "ESV permission confirmed for an app", and since 2026-11-22, at his direction, "The workout prayer's scripture echoes"
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
- [ ] **Movements have stable ids**
	**Prompt:** No prompt yet. Found in S3. Do it before any movement is renamed: give each movement an id in `seed/`, store it with new sessions, and map the names already stored
	[Edit this row in WORK](WORK.md)
- [ ] **A workout that is never finished**
	**Prompt:** No prompt yet. Found in S3. Needs a decision: how long a session may stay open, and what happens to it then
	[Edit this row in WORK](WORK.md)
- [ ] **The box he is typing in keeps the keyboard when "That did not save" appears**
	**Prompt:** No prompt yet. Found in S3 while holding Finish for an unsaved set. Not blocking: give the rows of the page's list keys of their own, and test that the box keeps the keyboard
	[Edit this row in WORK](WORK.md)
- [ ] **Plan setup and editor**
	**Prompt:** No prompt yet. Out of scope for S3 (prompt P07)
	[Edit this row in WORK](WORK.md)
- [ ] **Medicine Ball Slam's instructions agree with themselves**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `mobile/assets/content/movements.json`, which is a copy of `seed/movements.json`; S3 did not edit seed content. Owner: the maintainer. The app does not show how-to text yet
	[Edit this row in WORK](WORK.md)
- [ ] **"Dumbbells Only" names need only dumbbells**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `mobile/assets/content/movements.json`, a copy of `seed/movements.json`; S3 did not edit seed content. Owner: the maintainer. Not reachable in the app yet: every member has the Full Gym setup until there is a plan editor
	[Edit this row in WORK](WORK.md)
- [ ] **Pause Deadlift's instructions agree with themselves**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `mobile/assets/content/movements.json`, a copy of `seed/movements.json`; S3 did not edit seed content. Owner: the maintainer. The app shows neither text yet
	[Edit this row in WORK](WORK.md)
- [ ] **Pause Squat's hold is one length**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `mobile/assets/content/movements.json`, a copy of `seed/movements.json`; S3 did not edit seed content. Owner: the maintainer. The app shows the name and not the cue yet
	[Edit this row in WORK](WORK.md)
- [ ] **Shuttle Run's distance is one distance**
	**Prompt:** No prompt yet. Review finding (Codex, medium) on `mobile/assets/content/movements.json`, a copy of `seed/movements.json`; S3 did not edit seed content. Owner: the maintainer. The app does not show how-to text yet
	[Edit this row in WORK](WORK.md)
- [ ] **Workout text styles and marks join the shared sets**
	**Prompt:** No prompt yet. Found in S3. Not blocking; do it after that branch has merged
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
- [ ] **`flutter-ai-review` on unlabeled tooling pull requests**
	**Prompt:** No prompt yet. Not blocking: only `ci-gate` is required
	[Edit this row in WORK](WORK.md)




%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,false,false,false,false],"show-checkboxes":false,"show-add-list":false,"show-archive-all":false}
```
%%