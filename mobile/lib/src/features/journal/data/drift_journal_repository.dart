import 'package:drift/drift.dart';

import '../../../core/local_date.dart';
import '../../../storage/app_database.dart';
import '../domain/journal_entry.dart';
import 'journal_body_codec.dart';
import 'journal_repository.dart';

/// Journal entries in the member's SQLite file, through Drift.
///
/// A change and the entry it produces are written in one transaction, so
/// the app can never show an entry as saved without the row that holds
/// it. The text passes through [JournalBodyCodec] on its way in and out.
/// A change that fails is reported as a bare [JournalStoreFailure]: the
/// database's own error is dropped, because it can quote what he wrote.
class DriftJournalRepository implements JournalRepository {
  DriftJournalRepository(
    this._db, {
    JournalBodyCodec codec = const PlainJournalBodyCodec(),
  }) : _codec = codec;

  final AppDatabase _db;
  final JournalBodyCodec _codec;

  @override
  bool get durable => true;

  @override
  Stream<List<JournalEntry>> watchEntries(String ownerId) {
    final query = _db.select(_db.journalEntries)
      ..where((t) => t.ownerId.equals(ownerId) & t.deletedAtUtcMs.isNull())
      ..orderBy([
        (t) => OrderingTerm.desc(t.createdAtUtcMs),
        (t) => OrderingTerm.desc(t.id),
      ]);
    return query.watch().map((rows) => rows.map(_entry).toList());
  }

  @override
  Future<JournalEntry?> entry(String ownerId, String entryId) async {
    final row = await _row(entryId);
    if (row == null || row.ownerId != ownerId || row.deletedAtUtcMs != null) {
      return null;
    }
    return _entry(row);
  }

  @override
  Future<JournalOutcome> apply(JournalChange change) async {
    try {
      return await _apply(change);
    } catch (_) {
      // SQLite's error text can quote the values of the statement that
      // failed, his words among them. It goes no further than here.
      throw const JournalStoreFailure();
    }
  }

  Future<JournalOutcome> _apply(JournalChange change) {
    return _db.transaction(() async {
      final stored = await (_db.select(
        _db.journalChanges,
      )..where((t) => t.id.equals(change.id))).getSingleOrNull();
      if (stored != null) return JournalOutcome.duplicate;

      final current = await _row(change.entryId);
      if (current != null &&
          (current.deletedAtUtcMs != null ||
              current.ownerId != change.ownerId)) {
        return JournalOutcome.entryGone;
      }

      final atMs = change.atUtc.millisecondsSinceEpoch;
      final int revision;
      switch (change.kind) {
        case JournalChangeKind.save:
          revision = (current?.revision ?? 0) + 1;
          if (current == null) {
            await _db
                .into(_db.journalEntries)
                .insert(
                  JournalEntriesCompanion.insert(
                    id: change.entryId,
                    ownerId: change.ownerId,
                    day: change.day.iso,
                    createdAtUtcMs: atMs,
                    utcOffsetMinutes: change.utcOffset.inMinutes,
                    body: _codec.encode(change.text),
                    bodyFormat: _codec.format,
                    source: change.source.stored,
                    prompt: change.prompt,
                    revision: revision,
                  ),
                );
          } else {
            await (_db.update(
              _db.journalEntries,
            )..where((t) => t.id.equals(change.entryId))).write(
              JournalEntriesCompanion(
                body: Value(_codec.encode(change.text)),
                bodyFormat: Value(_codec.format),
                editedAtUtcMs: Value(atMs),
                revision: Value(revision),
              ),
            );
          }
        case JournalChangeKind.delete:
          if (current == null) return JournalOutcome.entryGone;
          revision = current.revision + 1;
          // The words go; the row stays so a later sync can say it is gone.
          await (_db.update(
            _db.journalEntries,
          )..where((t) => t.id.equals(change.entryId))).write(
            JournalEntriesCompanion(
              body: const Value(''),
              bodyFormat: Value(_codec.format),
              prompt: const Value(''),
              deletedAtUtcMs: Value(atMs),
              revision: Value(revision),
            ),
          );
      }

      // The next place in this database's order of journal changes. SQLite
      // runs one write transaction at a time, so two changes cannot get the
      // same one; the unique index would refuse it if they did.
      final highest = _db.journalChanges.counter.max();
      final last = await (_db.selectOnly(
        _db.journalChanges,
      )..addColumns([highest])).map((row) => row.read(highest)).getSingle();

      await _db
          .into(_db.journalChanges)
          .insert(
            JournalChangesCompanion.insert(
              id: change.id,
              ownerId: change.ownerId,
              entryId: change.entryId,
              kind: change.kind.stored,
              revision: revision,
              counter: (last ?? 0) + 1,
              atUtcMs: atMs,
              utcOffsetMinutes: change.utcOffset.inMinutes,
            ),
          );
      return JournalOutcome.applied;
    });
  }

  @override
  Future<List<StoredJournalChange>> changesFor(
    String ownerId,
    String entryId,
  ) async {
    final query = _db.select(_db.journalChanges)
      ..where((t) => t.ownerId.equals(ownerId) & t.entryId.equals(entryId))
      ..orderBy([(t) => OrderingTerm.asc(t.counter)]);
    final rows = await query.get();
    return <StoredJournalChange>[
      for (final row in rows)
        StoredJournalChange(
          id: row.id,
          kind: JournalChangeKind.values.firstWhere(
            (kind) => kind.stored == row.kind,
          ),
          revision: row.revision,
          counter: row.counter,
        ),
    ];
  }

  Future<JournalEntryRow?> _row(String entryId) => (_db.select(
    _db.journalEntries,
  )..where((t) => t.id.equals(entryId))).getSingleOrNull();

  JournalEntry _entry(JournalEntryRow row) => JournalEntry(
    id: row.id,
    ownerId: row.ownerId,
    day: LocalDate.parse(row.day),
    // The instant and the offset come back as they were stored. Neither is
    // folded into the other.
    createdAtUtc: DateTime.fromMillisecondsSinceEpoch(
      row.createdAtUtcMs,
      isUtc: true,
    ),
    utcOffset: Duration(minutes: row.utcOffsetMinutes),
    text: _codec.decode(row.body, row.bodyFormat),
    source: JournalSource.parse(row.source),
    prompt: row.prompt,
    revision: row.revision,
    editedAtUtc: row.editedAtUtcMs == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(row.editedAtUtcMs!, isUtc: true),
  );
}
