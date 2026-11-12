import 'package:drift/drift.dart';

import '../../../core/local_date.dart';
import '../../../storage/app_database.dart';
import '../domain/completion_event.dart';
import 'day_repository.dart';

/// The day's boxes in the member's SQLite file, through Drift.
///
/// An event and the day state it produces are written in one transaction,
/// so the app can never show a box as checked without the event that
/// checked it, or the reverse.
class DriftDayRepository implements DayRepository {
  DriftDayRepository(this._db);

  final AppDatabase _db;

  @override
  bool get durable => true;

  @override
  Stream<DayRecord> watchDay(String ownerId, LocalDate day) {
    final query = _db.select(_db.dayStates)
      ..where((t) => t.ownerId.equals(ownerId) & t.day.equals(day.iso));
    return query.watch().map(
      (rows) => DayRecord(
        ownerId: ownerId,
        day: day,
        items: <String, ItemState>{
          for (final row in rows) row.item: _state(row),
        },
      ),
    );
  }

  @override
  Stream<Map<LocalDate, Set<String>>> watchDoneByDay(String ownerId) {
    final query = _db.select(_db.dayStates)
      ..where((t) => t.ownerId.equals(ownerId) & t.done.equals(true));
    return query.watch().map((rows) {
      final byDay = <LocalDate, Set<String>>{};
      for (final row in rows) {
        byDay.putIfAbsent(LocalDate.parse(row.day), () => <String>{})
          ..add(row.item);
      }
      return byDay;
    });
  }

  @override
  Future<RecordOutcome> record(CompletionEvent event) {
    return _db.transaction(() async {
      final stored = await (_db.select(
        _db.completionEvents,
      )..where((t) => t.id.equals(event.id))).getSingleOrNull();
      final current = await _stateRow(event.ownerId, event.day, event.item);

      final outcome = decideOutcome(
        event: event,
        idAlreadyStored: stored != null,
        current: current == null ? null : _state(current),
      );
      if (outcome != RecordOutcome.applied) return outcome;

      // The next place in this database's order of events. SQLite runs one
      // write transaction at a time, so two events cannot get the same one;
      // the unique index would refuse it if they did.
      final highest = _db.completionEvents.counter.max();
      final last = await (_db.selectOnly(
        _db.completionEvents,
      )..addColumns([highest])).map((row) => row.read(highest)).getSingle();
      final counter = (last ?? 0) + 1;

      await _db
          .into(_db.completionEvents)
          .insert(
            CompletionEventsCompanion.insert(
              id: event.id,
              ownerId: event.ownerId,
              day: event.day.iso,
              item: event.item,
              done: event.done,
              counter: counter,
              tappedAtUtcMs: event.tappedAt.toUtc().millisecondsSinceEpoch,
              utcOffsetMinutes: event.tappedAt.timeZoneOffset.inMinutes,
              replacesEventId: Value(event.replacesEventId),
            ),
          );
      await _db
          .into(_db.dayStates)
          .insertOnConflictUpdate(
            DayStatesCompanion.insert(
              ownerId: event.ownerId,
              day: event.day.iso,
              item: event.item,
              done: event.done,
              latestEventId: event.id,
              latestCounter: counter,
            ),
          );
      return RecordOutcome.applied;
    });
  }

  @override
  Future<List<CompletionEvent>> eventsFor(
    String ownerId,
    LocalDate day,
    String item,
  ) async {
    final query = _db.select(_db.completionEvents)
      ..where(
        (t) =>
            t.ownerId.equals(ownerId) &
            t.day.equals(day.iso) &
            t.item.equals(item),
      )
      ..orderBy([(t) => OrderingTerm.asc(t.counter)]);
    final rows = await query.get();
    return <CompletionEvent>[
      for (final row in rows)
        CompletionEvent(
          id: row.id,
          ownerId: row.ownerId,
          day: LocalDate.parse(row.day),
          item: row.item,
          done: row.done,
          // The tap's wall-clock time: the stored instant moved by the
          // stored offset. Flagged UTC only because Dart has no other way
          // to carry "local time somewhere else".
          tappedAt: DateTime.fromMillisecondsSinceEpoch(
            row.tappedAtUtcMs,
            isUtc: true,
          ).add(Duration(minutes: row.utcOffsetMinutes)),
          replacesEventId: row.replacesEventId,
        ),
    ];
  }

  Future<DayStateRow?> _stateRow(String ownerId, LocalDate day, String item) {
    final query = _db.select(_db.dayStates)
      ..where(
        (t) =>
            t.ownerId.equals(ownerId) &
            t.day.equals(day.iso) &
            t.item.equals(item),
      );
    return query.getSingleOrNull();
  }

  static ItemState _state(DayStateRow row) => ItemState(
    done: row.done,
    latestEventId: row.latestEventId,
    latestCounter: row.latestCounter,
  );
}
