import '../domain/journal_entry.dart';

/// The boundary between the journal screens and wherever entries are kept.
///
/// Plain Dart. The app uses the Drift implementation on a phone and the
/// in-memory one in the web preview and in widget tests. Decision Q8:
/// entries are kept on the device only. Nothing here, and nothing behind
/// it, talks to Firebase.
abstract interface class JournalRepository {
  /// Whether what is saved survives closing the app. False only for the
  /// in-memory store, and the screens say so.
  bool get durable;

  /// One owner's entries that have not been deleted, newest first: the
  /// current list at once, then again after every change.
  Stream<List<JournalEntry>> watchEntries(String ownerId);

  /// One entry, or null if there is none with this id or it was deleted.
  Future<JournalEntry?> entry(String ownerId, String entryId);

  /// Stores [change] and brings its entry up to date in one transaction.
  ///
  /// A save for an id with no entry makes the entry. A save for an existing
  /// entry replaces its text. A delete empties the entry and marks it
  /// deleted. A change whose id is already stored changes nothing, and so
  /// does any change to an entry that was deleted. A save that names the
  /// changes its writer knows of ([JournalChange.knownChanges]) changes
  /// nothing if the entry was changed by any other change since.
  ///
  /// Throws a [JournalStoreFailure] if the transaction did not commit;
  /// nothing is stored then.
  Future<JournalOutcome> apply(JournalChange change);

  /// Every stored change for one entry, oldest first, as (change id, kind,
  /// revision). For tests and for later sync; no screen reads it.
  Future<List<StoredJournalChange>> changesFor(String ownerId, String entryId);
}

/// A journal change that was not stored.
///
/// It carries no detail on purpose. The database's own error can quote the
/// values of the statement that failed, which are his words, and whatever
/// catches this may print it or send it somewhere.
class JournalStoreFailure implements Exception {
  const JournalStoreFailure();

  @override
  String toString() =>
      'JournalStoreFailure: the journal change was not stored.';
}

/// A row of the change list. It carries no text.
class StoredJournalChange {
  const StoredJournalChange({
    required this.id,
    required this.kind,
    required this.revision,
    required this.counter,
  });

  final String id;
  final JournalChangeKind kind;

  /// The entry's revision once this change was applied.
  final int revision;

  /// This change's place in this database's order of journal changes.
  final int counter;
}
