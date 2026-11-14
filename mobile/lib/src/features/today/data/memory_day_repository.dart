import 'dart:async';

import '../../../core/local_date.dart';
import '../domain/completion_event.dart';
import 'day_repository.dart';

/// The day's boxes held in memory only. Everything is gone when the app
/// closes.
///
/// Used where there is no SQLite file: the web preview (ADR-0005: web is a
/// development preview and must not claim to save) and widget tests. It
/// follows the same rules as the Drift store, through the same
/// [decideOutcome].
class MemoryDayRepository implements DayRepository {
  final List<CompletionEvent> _events = <CompletionEvent>[];
  final Map<(String, LocalDate, String), ItemState> _states =
      <(String, LocalDate, String), ItemState>{};
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _counter = 0;

  @override
  bool get durable => false;

  @override
  Stream<DayRecord> watchDay(String ownerId, LocalDate day) =>
      _watch(() => _record(ownerId, day));

  @override
  Stream<Map<LocalDate, Set<String>>> watchDoneByDay(String ownerId) =>
      _watch(() => _doneByDay(ownerId));

  @override
  Future<RecordOutcome> record(CompletionEvent event) async {
    final key = (event.ownerId, event.day, event.item);
    final outcome = decideOutcome(
      event: event,
      idAlreadyStored: _events.any((stored) => stored.id == event.id),
      current: _states[key],
    );
    if (outcome != RecordOutcome.applied) return outcome;

    _counter++;
    _events.add(event);
    _states[key] = ItemState(
      done: event.done,
      latestEventId: event.id,
      latestCounter: _counter,
    );
    _changes.add(null);
    return RecordOutcome.applied;
  }

  @override
  Future<List<CompletionEvent>> eventsFor(
    String ownerId,
    LocalDate day,
    String item,
  ) async => <CompletionEvent>[
    for (final event in _events)
      if (event.ownerId == ownerId && event.day == day && event.item == item)
        event,
  ];

  /// The current value at once, then again after every change.
  Stream<T> _watch<T>(T Function() read) {
    return Stream<T>.multi((controller) {
      controller.add(read());
      final changes = _changes.stream.listen((_) => controller.add(read()));
      controller.onCancel = changes.cancel;
    });
  }

  DayRecord _record(String ownerId, LocalDate day) => DayRecord(
    ownerId: ownerId,
    day: day,
    items: <String, ItemState>{
      for (final entry in _states.entries)
        if (entry.key.$1 == ownerId && entry.key.$2 == day)
          entry.key.$3: entry.value,
    },
  );

  Map<LocalDate, Set<String>> _doneByDay(String ownerId) {
    final byDay = <LocalDate, Set<String>>{};
    for (final entry in _states.entries) {
      if (entry.key.$1 == ownerId && entry.value.done) {
        byDay.putIfAbsent(entry.key.$2, () => <String>{}).add(entry.key.$3);
      }
    }
    return byDay;
  }
}
