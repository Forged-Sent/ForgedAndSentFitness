---
kind: feature-spec
feature_id: FNS-003
status: proposed
risk: high
owner: maintainer
source_ref: claude/s2-private-journal
source_sha: 1c1339b25dad47a5760ea7b7eb4ab12fb260c4c4
approved_by: none
test_plan: journal store rules against the Drift and in-memory stores, close and reopen on a real SQLite file, a forced save failure and its retry, schema migration from version 1, the box under the reading, the Journal page and the entry page as widget tests, a privacy test that records every platform message and every printed line, golden images at 390x844 in dark and light, one Android emulator run of write, kill, relaunch
verified_tests: mobile/test/features/journal/journal_entry_test.dart, mobile/test/features/journal/drift_journal_repository_test.dart, mobile/test/features/journal/memory_journal_repository_test.dart, mobile/test/features/journal/write_it_down_test.dart, mobile/test/features/journal/journal_page_test.dart, mobile/test/features/journal/journal_privacy_test.dart, mobile/test/features/journal/journal_golden_test.dart, mobile/test/storage/schema_migration_test.dart, mobile/integration_test/journal_restart_1_write_test.dart, mobile/integration_test/journal_restart_2_verify_test.dart
implementation_paths: mobile/lib/src/features/journal, mobile/lib/src/storage/app_database.dart, mobile/drift_schemas, mobile/lib/src/design/fs_text_area.dart, mobile/lib/src/app/local_store.dart, mobile/lib/src/app/fs_router.dart
verification: see the pull request that adds this page for the commands and their output
---

# Private journal, kept on the device

Build step S2 of the [prototype-to-Flutter review](../../reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md), built from prompt [P06](../../reviews/2026-11-10-prototype-to-flutter/prompts/P06-S2-private-journal.md). Design: [design.md](design.md). Tasks and evidence: [tasks.md](tasks.md).

This page is a draft written by the agent that built the step. It is **proposed, not approved**: only the maintainer approves it. It is filed as high risk because the journal is private data.

## Approved user outcome and scope

The decision it rests on is the maintainer's Q8 answer on the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page: "Device-only with manual export for the pilot. But architect for future case of sync and encrypted (Don't design so that this change would be a complete rework)". Prompt P06 sets the scope and the acceptance tests.

**What he sees**

- **Under the day's reading**, after Act and before Amen: "Write it down". It shows the reading's reflection question, a box with the hint "Answer it honestly. Only you can read this.", and "Save to my journal". Under it: "Today's reflection question starts the entry. Private, and never scored."
- **After a save:** "Saved to your journal. Only you can read it.", the box is empty again, and a "My journal" button opens the Journal page.
- **The Journal page:** "My journal", his entries newest first. Each shows when it was written ("Today · Devotional", "Today · 7:30 AM", "Yesterday", "Tue, Nov 3") and its first 220 characters. "New entry" starts one. With nothing written it says how to start.
- **An entry:** its date and time, the reflection question if it answers one, his words in a box, "Save changes", "Close", and "Delete this entry", which needs a second tap ("Tap again to delete this entry"). The wording promises no more than the app does: see "Deleted words on disk" below.
- **Ways in:** the Walk tab, which is the journal (the maintainer's decision of 2026-11-17: the journal lives on Walk, as in v254, without the Brothers and Prayers parts until they exist); the "My journal" button after a save; "Open my journal" in Settings; and the pen in Today's header, which opens a new entry. The Walk tab and the page under Today are the same page over the same entries; on Walk it is the tab's first page and has no Back. Settings says: "Private. It is not sent to any server, and it is never scored." It does not say "on this phone only", because of the open backup question below.
- **Writing is optional.** Amen does not look at the box. The devotional can be completed with the box empty, with an unsaved draft in it, or when the journal cannot save at all.

**Out of scope (prompt P06):** prayer tabs, tags, search, export, sync, sharing. Also not built: "On this day", the saved card with its shortcuts, the pen on the four placeholder tabs and on Walk.

## Authorization, privacy and data ownership

- **Owner.** An entry belongs to one owner. Before sign-in the owner is the local profile (decision Q10). Each owner has his own database file, and the store also refuses a read or a change that names another owner.
- **Where it is kept (Q8).** In his SQLite file in the app's private folder on the phone, and nowhere else. Not encrypted. Nothing is sent to a server, and there is no account to send it to yet.
- **Never shared, scored or logged.** Journal text is not part of any shared document, score, log line or analytics event. Nothing in the journal feature imports Firebase; the Firebase connector imports nothing from the app. No scoring exists yet; Today's rules and stores do not read the journal. Printing an entry or a change shows its length, not its words.
- **Delete.** Deleting empties the entry's text and its question in the database row and marks the row deleted. The row stays, empty, for a later sync.
- **Web preview.** Nothing is saved, and every journal screen says "Nothing you write here is saved."

**Decided by the maintainer on 2026-11-17** (while approving an earlier plan for this step, on the Windows workstation): the phone's own backups stay on, and "device-only" means never on our servers and never in scoring; sign-out is decided in step S4. Item 1 below is therefore answered and kept here for the facts; items 2 to 4 are open.

**Unknown, so not approved. BLOCKED on the maintainer:**

1. **Phone backups: answered, they stay on.** Checked on 2026-11-19 in the host projects and the `path_provider` source, not by making and restoring a backup. Android: the manifest sets no `android:allowBackup`, `fullBackupContent` or `dataExtractionRules`, and the database is under `getFilesDir()`, which Auto Backup includes; with his phone's backup on, the file goes to his Google account and travels in a device-to-device transfer. iOS: the file is in `Library/Application Support`, which iCloud Backup and a computer backup include, and nothing sets the exclude-from-backup flag. So a man's journal, not encrypted by the app, can be in his own Google or iCloud backup. The other choices were to turn backups off for the app (which also stops Today's completions being restored on a new phone) or to exclude only the database. Not changed in this step.
2. **Sign-out.** Q8's question also asked whether the journal is kept after sign-out. The answer does not say. There is no sign-in yet (step S4), so nothing is built either way.
3. **Deleted words on disk.** SQLite does not overwrite freed space by default, so the bytes of a deleted entry may remain in the file until that space is reused. `PRAGMA secure_delete` would overwrite them, at some cost on every delete. Not decided.
4. **Export.** Q8 names a manual export for the pilot. P06 leaves export out of this step; nothing schedules it yet.

## Failure, offline and migration behavior

- **Everything is local**, so there is no offline case: the journal works the same with no network.
- **The database refuses a change:** the store reports a failure that carries nothing. The database's own error, which can quote his words, is dropped inside the store and never reaches a screen, a log or a crash report.
- **A save fails:** his text stays in the box, the screen says "That did not save. Your entry is still here. Try again.", and nothing is stored. It never says "Saved".
- **Retry:** a new entry gets its id and its time at the first save attempt and keeps both through every retry. A retry can only write that same entry. This holds also when the first attempt was in fact stored and only its answer was lost.
- **He changed the entry in his journal while its draft was still in the box.** This can happen only after a save that was stored without its answer coming back: the box still holds the draft, and the entry is in his journal. If he changes the entry there and then saves different words from the box, the box's older draft does not replace his edit. Nothing is written; the box keeps his words and says "These words are not saved. The entry they belonged to was changed or deleted in your journal. Saving now writes a separate entry." The next save does that. Saving the very same words again changes nothing, and the edit stands.
- **Discard:** after a failed save under the reading, "Discard draft and start a different entry" (second tap: "Tap again to discard this draft") empties the box; what he writes next is a different entry.
- **Saving on its way:** the button says "Saving…" and takes no second tap. On the entry page he also cannot leave until the save or the delete has answered: Close, Back in the page's bar and Android's back all wait, so a failure still finds his words on screen and tells him.
- **Empty:** "Write something first." Nothing is stored.
- **Length:** the box stops at 4000, counted as the prototype counts (UTF-16 code units, so an emoji is two or more), and never cuts a character in half.
- **Midnight while writing:** the entry answers the question he began with, and is filed under the date he saved it.
- **A delete fails:** "That did not delete. Your entry is still here. Try again." and it asks again before it deletes.
- **Day boundary (Q9):** an entry is filed under the phone's local date at its first save attempt.
- **An entry that is gone** (opened by an old link): "This entry is no longer in your journal."
- **A row stored in a form this build cannot read** (written by a later build): the journal shows "Your journal could not be read." It does not show garbage, and the error names the format, never the contents.
- **Migration:** the database goes from schema version 1 to 2. A phone that ran step S1 keeps its completions and settings and gains the journal tables. Each version's schema is frozen in `mobile/drift_schemas/`, and a test checks that the upgraded file has exactly the frozen version 2. A build from before this step cannot open a version 2 file and leaves it untouched.
- **Leaving an entry without saving** keeps nothing, as closing the prototype's dialog does. A draft under the reading is kept while the app is open, and is gone when the app is closed.
- **Accessibility:** the boxes have a spoken name; the result of a save is a live region; nothing overflows at 1.3 and 2.0 times the text size on a 320 by 568 screen.

## Evidence and traceability

- **Prototype source:** `index.html` on `main` at `1c1339b`: `jrDraftId`, `jrWrite`, `jrSave`, `jrAction` (lines 10344 to 10404), the box under the reading (`#jr-devo`, line 2177, wired at line 10538), `openJournal` (line 10418) and `drawJournalPage` (line 10548). Journey J3 in the review's [architecture page](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md).
- **ADR:** [ADR-0005](../../architecture/ADR-0005-flutter-client-stack.md), with its section "Added in build step S2".
- **Checks actually run, and those not run:** in [tasks.md](tasks.md) and in the pull request description.

## Design and task files

- [design.md](design.md)
- [tasks.md](tasks.md)
