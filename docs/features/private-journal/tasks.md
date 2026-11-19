# Private journal: tasks and evidence

Part of [FNS-003](requirements.md). Proposed, not approved. Commands and their output are in the pull request description.

## Built

| Task | Where | Test |
|---|---|---|
| Entry, change and text rules | `mobile/lib/src/features/journal/domain/journal_entry.dart` | `journal_entry_test.dart` |
| Store interface, Drift store, in-memory store, text codec | `mobile/lib/src/features/journal/data/` | `journal_repository_contract.dart` run by `drift_journal_repository_test.dart` and `memory_journal_repository_test.dart` |
| Schema version 2 and its migration | `mobile/lib/src/storage/app_database.dart` | `mobile/test/storage/schema_migration_test.dart` |
| "Write it down" under the reading | `write_it_down.dart`, `devotional_page.dart` | `write_it_down_test.dart` |
| Journal page and entry page, routes, ways in | `journal_page.dart`, `journal_entry_page.dart`, `fs_router.dart`, `settings_page.dart`, `today_page.dart` | `journal_page_test.dart` |
| `FsTextArea` | `mobile/lib/src/design/fs_text_area.dart` | Used by every journal widget test |

## Prompt P06 acceptance

| # | Acceptance | Test |
|---|---|---|
| 1 | Save, close the database, reopen: the entry is there | `drift_journal_repository_test.dart`: "save, close the database, reopen: the entry is there" |
| 2 | Force a save failure: text is kept, retry works, exactly one entry | Store: "a save that fails stores nothing, and the retry stores exactly one entry" (a database trigger refuses the write). Screen: `write_it_down_test.dart`, group "a save that fails", including the case where the first attempt was stored and its answer lost; `journal_page_test.dart` for the entry page |
| 3 | Edit and delete work and survive restart | Store: "an edit and a delete both survive a restart". Screen: groups "editing an entry" and "deleting an entry" |
| 4 | A test proves no journal field is passed to any Firebase call | `journal_privacy_test.dart`: import rules for the journal, the database and the Firebase connector; and a run that writes, edits and deletes while recording every platform message, which finds none to a Firebase plugin and his words on no channel but the keyboard's |
| 5 | Completing the devotional does not depend on writing anything | `write_it_down_test.dart`, group "the devotional does not depend on the journal" |

## Negative tests

- Another owner cannot read, change or delete an entry.
- A deleted entry cannot be written again.
- A change sent twice is applied once, also after closing and reopening the file.
- A failed edit and a failed delete leave the entry as it was.
- Typing in the box does not unlock Amen.
- A row in an unknown stored format is an error, not shown text.
- The change list has no column that could hold text.
- Nothing is printed that contains his words, by `print` or `debugPrint`, also when a save fails; a control test shows the capture sees both.
- A save that was stored without its answer coming back is not stored twice by the retry (revision stays 1, one change in the list).
- A database whose update was cut off after the first new table still opens, twice.
- An entry of emoji at the length limit saves; typing past the limit stops at it.
- A draft begun before midnight is saved with the question it was begun under.
- A database row prints its length, not its words.

## Not done, and why

| Item | State |
|---|---|
| Golden images at 390x844, dark and light | The tests exist (`journal_golden_test.dart`, eight images). Each is skipped off Windows, as Today's are, and on Windows until its image exists. The images are not drawn: this step was built on a Mac. The two end-of-reading images from S1 need redrawing too, because the reading now has the journal box above Amen |
| Run on a phone or an Android emulator | Not run. No Android toolchain on the Mac that built it. On 2026-11-19, on one iPhone 17 simulator (iOS 27.2), an entry written under the reading was saved, shown on the Journal page, and still there after the app's process was stopped and the app started again. That was a one-off run with a test that is not in the repository; no committed test covers the journal across a restart on a device |
| Text scaling at 1.3x | Covered by widget tests at 1.3 and 2.0, not by eye |
| Keyboard over the box, safe areas | Not checked on a device |
| Phone backups, sign-out, secure delete, export | Open decisions; see [requirements.md](requirements.md) |

## Rollback

The step adds two tables and changes none. Removing the feature's screens leaves the tables unused. A build older than this one was written for a version 1 database and has no rule for a version 2 file; what it does with one has not been tested. Do not ship an older build over this one.
