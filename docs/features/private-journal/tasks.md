# Private journal: tasks and evidence

Part of [FNS-003](requirements.md). Proposed, not approved. Commands and their output are in the pull request description.

## Built

| Task | Where | Test |
|---|---|---|
| Entry, change and text rules | `mobile/lib/src/features/journal/domain/journal_entry.dart` | `journal_entry_test.dart` |
| Store interface, Drift store, in-memory store, text codec | `mobile/lib/src/features/journal/data/` | `journal_repository_contract.dart` run by `drift_journal_repository_test.dart` and `memory_journal_repository_test.dart` |
| Schema version 2 and its migration | `mobile/lib/src/storage/app_database.dart`; the frozen schemas in `mobile/drift_schemas/` | `mobile/test/storage/schema_migration_test.dart` |
| "Write it down" under the reading | `write_it_down.dart`, `devotional_page.dart` | `write_it_down_test.dart` |
| Journal page and entry page, routes, ways in (the Walk tab among them) | `journal_page.dart`, `journal_entry_page.dart`, `fs_router.dart`, `shell_destinations.dart`, `settings_page.dart`, `today_page.dart` | `journal_page_test.dart`, `mobile/test/app/fs_shell_test.dart` |
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
- A change the database refuses (a new entry, an edit, a delete, a closed store) fails with an error that holds none of his words, also on the background isolate a phone uses, and nothing is printed.
- The upgraded schema is exactly the frozen version 2, and a new install's is the same.
- A build from before the journal cannot open a version 2 file and leaves it as it was.
- The list's 220-character cut never splits an emoji or a flag in two.
- He cannot leave the entry page while a save is on its way; when it then fails, his words and the message are still there.
- A draft he empties before any save lets its question go; the next words answer the question on screen then.
- Another owner sees nothing of an entry's change list.
- A draft whose entry he has since changed in his journal does not replace that edit: nothing is written, the box says so, and the next save is a separate entry. Tested in both stores and on screen; the on-screen test fails without the rule.
- A draft whose entry he has since deleted in his journal never says "Saved", also when the very same words are saved again: the box keeps them and the next save is a new entry. Tested in both stores and on screen; the tests fail without the rule.
- The same entry open on the Walk tab and under Today: the page that saves second does not replace the newer words. It keeps what he typed, says so, and the next save writes a new entry. A page's own save that was stored without its answer does not count as a change from somewhere else. Tested in both stores and on screen; the tests fail without the rule.
- A change that is already stored is admitted only to its own owner and for its own entry.
- The web preview does not say "Saved" after a save.
- The check on what the journal may import knows `cloud_functions` as a Firebase package.
- The Walk tab shows the same entries as the Journal page under Today; an entry can be written, changed and deleted there, and Walk stays the tab he is on.
- A journal golden image that is missing fails its test on Windows.

## Not done, and why

| Item | State |
|---|---|
| Golden images at 390x844, dark and light | Done on 2026-11-19, on Windows: the eight journal images are drawn and the two end-of-reading images are redrawn with the journal box above Amen. They are compared on Windows only, as Today's are, and no CI lane other than the Windows one runs them |
| Run on a phone | Not run on a phone. On an Android emulator: `integration_test/journal_restart_1_write_test.dart` and `journal_restart_2_verify_test.dart` write an entry under the reading, stop the app's process, start it again and find the entry in the journal with every word. Both passed on 2026-11-19 on `FS_S1_Restart_API_36` (Android 16, API 36) on the maintainer's Windows workstation, after the S1 restart pair passed on the same build. On one iPhone 17 simulator (iOS 27.2) the same was done once by hand on 2026-11-19; the committed pair has not been run on iOS. No CI lane has an emulator |
| Text scaling at 1.3x | Covered by widget tests at 1.3 and 2.0, not by eye |
| Keyboard over the box, safe areas | Not checked on a device |
| Phone backups, sign-out, secure delete, export | Open decisions; see [requirements.md](requirements.md) |

## Rollback

The step adds two tables and changes none. Removing the feature's screens leaves the tables unused. A build older than this one was written for a version 1 database and has no rule for a version 2 file: it cannot open one, and it leaves the file as it was, so this build opens it again with everything in it (`schema_migration_test.dart`). On a phone that older build would start without storage and say nothing is saved. Do not ship an older build over this one.
