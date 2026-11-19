# Private journal: design

Part of [FNS-003](requirements.md). Proposed, not approved.

## Data

Two tables in the member's Drift database (`mobile/lib/src/storage/app_database.dart`), added at schema version 2.

| Table | One row is | Key | Holds text |
|---|---|---|---|
| `journal_entries` | What one entry says now | Entry id: a UUID made once on the phone | Yes: `body` and `prompt` |
| `journal_changes` | One save or one delete, in order | Change id: a UUID made per tap | No |

`journal_entries` columns: `id`, `owner_id`, `day` (local date first saved), `created_at_utc_ms` and `utc_offset_minutes` (the instant and the phone's offset, kept apart as completions are), `body`, `body_format`, `source` (`devotional` or `pen`), `prompt` (the reflection question), `edited_at_utc_ms`, `deleted_at_utc_ms`, `revision`.

`journal_changes` columns: `id`, `owner_id`, `entry_id`, `kind` (`save` or `delete`), `revision` (the entry's revision after the change), `counter` (unique, this database's order of journal changes), `at_utc_ms`, `utc_offset_minutes`.

**One transaction.** `JournalRepository.apply(change)` writes the change row and the entry row together or not at all. The screen says "Saved" only after it returns.

**Rules**, the same in the Drift store and the in-memory one, held by one set of tests run against both:

- A save for an id with no entry makes the entry.
- A save for an existing entry replaces its text, sets the edited time and raises the revision. Its day, created time, source and question do not change.
- A delete empties `body` and `prompt`, sets the deleted time and raises the revision.
- A change whose id is already stored changes nothing. The screens use this: trying the same words again after a failed save sends the same change id, so a save that was stored without its answer coming back is not stored a second time. Different words are a new change to the same entry.
- A change to a deleted entry, or to another owner's entry, changes nothing.

## Why this shape (decision Q8)

Q8 asks for device-only storage now, and a design that sync and encryption can be added to without a rework.

- **Encryption later.** The text passes through `JournalBodyCodec` at the repository, and each row records the format it was written in (`plain-v1` today). An encrypting codec is a second implementation that still reads `plain-v1` rows and re-writes them on the next save. No table, repository interface, view model or screen changes. A test does this with a stand-in codec.
- **Sync later.** Entries have stable client-made ids and a revision; deletes leave an empty tombstone; `journal_changes` is the ordered list a sync would send from. None of that is sent anywhere today.
- **Why the change list holds no text.** An append-only log that carried the words would keep them after he deleted the entry.

**Considered and not chosen:** one table with upsert by id (enough for "a retry never makes a second entry", but nothing for a sync to work from, and it departs from the event-plus-state rule the project uses for completions); events that carry the text (deleted words would live on in the log).

**Migration.** Version 1 to 2 creates both tables inside one transaction and skips a table that already exists, so an update that was cut off partway finishes on the next launch instead of failing on every launch. The schema of each version is frozen as a file in `mobile/drift_schemas/` (`drift_dev schema dump`), and `schema_migration_test.dart` uses Drift's schema verifier to check that a version 1 file ends up with exactly the frozen version 2, and that a new install has the same. The commands are in `mobile/README.md`. Build step S3, on a local branch that is not on GitHub, freezes the same version 1 file and also calls its own tables version 2; whichever of the two steps merges second becomes version 3.

**Known limit, accepted for this step.** If a save under the reading was stored without its answer coming back, and he then edits that same entry on the Journal page before retrying the draft, the retry replaces the edit with the draft's words. It needs a failed answer and two screens used in a particular order on one phone. A sync will need a revision check here anyway.

## Trust boundaries

- The journal feature and `mobile/lib/src/storage/` import no Firebase SDK. `mobile/lib/src/firebase/` imports nothing from the app, so it cannot reach an entry. A test fails if either changes.
- Failures are caught without logging the error, because a database error message can quote the statement's values. The Drift store goes one step further and never lets that error out: `apply` catches whatever the database throws and throws a bare `JournalStoreFailure`, so a later caller that logs or reports errors cannot carry his words off. Tests refuse an insert, an update and a delete and check the error that comes back.
- `JournalEntry.toString`, `JournalChange.toString` and the database row class `JournalEntryRow` (written by hand for this reason) print lengths, not words. Drift's generated `JournalEntriesCompanion`, the object a write is built from, still prints its values; nothing prints one, and no app code prints or logs at all, which a test holds.

## Screens and state

| Screen | File | State |
|---|---|---|
| "Write it down" under the reading | `features/journal/presentation/write_it_down.dart` | `devotionalDraftProvider`: text, status (idle, empty, saving, saved, failed), and the entry id and time made at the first save attempt |
| Journal page, `/today/journal` | `journal_page.dart` | `journalEntriesProvider`, a stream from the store |
| Entry page, `/today/journal/new` and `/today/journal/entry/:entryId` | `journal_entry_page.dart` | Its own: the box, busy, message, and for a new entry the id and time made at the first save attempt |

The shared box is `FsTextArea` in the design system. Its length limit and the save's are the same measure, UTF-16 code units, as the prototype's `maxlength` is, so the box never accepts what the save refuses. An edit in the middle of a full box is refused, not made to fit by cutting words from the end. The box asks the keyboard not to learn from what is typed (`enableIMEPersonalizedLearning: false`); Android keyboards honor that, and iOS has no such setting.

**Which question an entry answers.** The draft takes the reflection question on screen when he begins to write and keeps it. If midnight passes and the page moves to the next day's reading before he saves, the box still shows, and the entry still records, the question he was answering. The entry is filed under the date of the save (decision Q9).

**The reading's scroll.** A text box scrolls inside itself. The reading unlocks Amen when its own scroll reaches the end, so it now ignores scroll events that come from a box inside it. Without that, the empty journal box (which has nothing to scroll) unlocked Amen at once; the existing Amen tests caught it.

## Differences from the prototype

| Difference | Kind |
|---|---|
| The editor is a page, not a dialog | Platform adaptation: keyboard and Android back |
| Discard takes a second tap instead of a confirm box | Adaptation: the app has no dialog component yet (`FsDialog` is planned) |
| No 15-second deadline and no "still awaiting confirmation" state | Adaptation: a local transaction commits or fails at once; the prototype waits on a network write |
| After saving an entry from the pen he lands on the Journal page, not on a "Saved to your journal" card | Reduced for this step |
| The saved message has no check mark glyph | Adaptation: a screen reader would read the glyph |
| Empty-state text names "New entry" and today's reading, not "the pen at the top of any page" | The pen works only on Today so far |
| Tags, prayer tabs, search, "On this day", sharing | Out of scope in P06 |
