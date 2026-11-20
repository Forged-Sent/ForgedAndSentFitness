import 'dart:async';

import '../domain/journal_entry.dart';
import 'journal_repository.dart';

/// Journal entries held in memory only. Everything is gone when the app
/// closes.
///
/// Used where there is no SQLite file: the web preview (ADR-0005: web is a
/// development preview and must not claim to save) and widget tests. It
/// follows the same rules as the Drift store; one set of tests runs
/// against both.
class MemoryJournalRepository implements JournalRepository {
  final Map<String, JournalEntry> _entries = <String, JournalEntry>{};
  final Set<String> _deleted = <String>{};
  final List<(String ownerId, String entryId, StoredJournalChange change)>
  _changes = <(String, String, StoredJournalChange)>[];
  final StreamController<void> _changed = StreamController<void>.broadcast();
  int _counter = 0;

  @override
  bool get durable => false;

  @override
  Stream<List<JournalEntry>> watchEntries(String ownerId) {
    return Stream<List<JournalEntry>>.multi((controller) {
      controller.add(_list(ownerId));
      final changes = _changed.stream.listen(
        (_) => controller.add(_list(ownerId)),
      );
      controller.onCancel = changes.cancel;
    });
  }

  @override
  Future<JournalEntry?> entry(String ownerId, String entryId) async {
    final found = _entries[entryId];
    return found != null && found.ownerId == ownerId ? found : null;
  }

  @override
  Future<JournalOutcome> apply(JournalChange change) async {
    final current = _entries[change.entryId];
    for (final (owner, entry, stored) in _changes) {
      if (stored.id != change.id) continue;
      // The same rules as the Drift store: only its own owner and entry
      // may hear that a change is stored, and a save whose entry he has
      // deleted since is not "saved".
      if (owner != change.ownerId || entry != change.entryId) {
        return JournalOutcome.entryGone;
      }
      if (change.kind == JournalChangeKind.save && current == null) {
        return JournalOutcome.entryGone;
      }
      return JournalOutcome.duplicate;
    }
    if (_deleted.contains(change.entryId) ||
        (current != null && current.ownerId != change.ownerId)) {
      return JournalOutcome.entryGone;
    }

    // The same rule as the Drift store: a writer that may be out of date
    // does not replace words that were changed somewhere else since.
    if (change.kind == JournalChangeKind.save &&
        change.guarded &&
        current != null &&
        current.revision != change.baseRevision) {
      final known = change.knownChanges ?? const <String>{};
      final ofEntry = _changes.where((c) => c.$2 == change.entryId);
      if (ofEntry.isEmpty || !known.contains(ofEntry.last.$3.id)) {
        return JournalOutcome.changedElsewhere;
      }
    }

    final int revision;
    switch (change.kind) {
      case JournalChangeKind.save:
        revision = (current?.revision ?? 0) + 1;
        _entries[change.entryId] = current == null
            ? JournalEntry(
                id: change.entryId,
                ownerId: change.ownerId,
                day: change.day,
                createdAtUtc: change.atUtc,
                utcOffset: change.utcOffset,
                text: change.text,
                source: change.source,
                prompt: change.prompt,
                revision: revision,
              )
            : JournalEntry(
                id: current.id,
                ownerId: current.ownerId,
                day: current.day,
                createdAtUtc: current.createdAtUtc,
                utcOffset: current.utcOffset,
                text: change.text,
                source: current.source,
                prompt: current.prompt,
                revision: revision,
                editedAtUtc: change.atUtc,
              );
      case JournalChangeKind.delete:
        if (current == null) return JournalOutcome.entryGone;
        revision = current.revision + 1;
        _entries.remove(change.entryId);
        _deleted.add(change.entryId);
    }

    _counter++;
    _changes.add((
      change.ownerId,
      change.entryId,
      StoredJournalChange(
        id: change.id,
        kind: change.kind,
        revision: revision,
        counter: _counter,
      ),
    ));
    _changed.add(null);
    return JournalOutcome.applied;
  }

  @override
  Future<List<StoredJournalChange>> changesFor(
    String ownerId,
    String entryId,
  ) async => <StoredJournalChange>[
    for (final (owner, entry, change) in _changes)
      if (owner == ownerId && entry == entryId) change,
  ];

  List<JournalEntry> _list(String ownerId) {
    final entries =
        _entries.values.where((entry) => entry.ownerId == ownerId).toList()
          ..sort(newestFirst);
    return List<JournalEntry>.unmodifiable(entries);
  }
}

/// Newest first by the time first saved; entries saved in the same
/// millisecond keep a fixed order by id.
int newestFirst(JournalEntry a, JournalEntry b) {
  final byTime = b.createdAtUtc.compareTo(a.createdAtUtc);
  return byTime != 0 ? byTime : b.id.compareTo(a.id);
}
