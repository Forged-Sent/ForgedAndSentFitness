import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/today/data/day_repository.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';

const String ownerA = 'local-a';
const String ownerB = 'local-b';
const String devotional = DayItems.devotional;

const LocalDate nov11 = LocalDate(2026, 11, 11);
const LocalDate nov12 = LocalDate(2026, 11, 12);
const LocalDate nov13 = LocalDate(2026, 11, 13);

/// A completion of the devotional, tapped at [at].
CompletionEvent amen(
  String id,
  DateTime at, {
  String owner = ownerA,
  String? replaces,
}) => CompletionEvent.complete(
  id: id,
  ownerId: owner,
  item: devotional,
  tappedAt: at,
  replacesEventId: replaces,
);

/// An undo of whatever currently has the devotional checked on [day],
/// tapped at [at], which may be on another day.
Future<CompletionEvent> undoOf(
  DayRepository repository,
  String id,
  LocalDate day,
  DateTime at, {
  String owner = ownerA,
}) async {
  final record = await repository.watchDay(owner, day).first;
  return CompletionEvent.undo(
    id: id,
    ownerId: owner,
    item: devotional,
    day: record.day,
    completion: record.items[devotional]!,
    tappedAt: at,
  );
}

/// The rules every store of the day's boxes must follow. Run against the
/// Drift store and the in-memory one, so the two cannot drift apart.
void dayRepositoryContract(Future<DayRepository> Function() create) {
  late DayRepository repository;

  setUp(() async => repository = await create());

  Future<DayRecord> day(LocalDate date, {String owner = ownerA}) =>
      repository.watchDay(owner, date).first;

  test('a day nobody has touched has no box done', () async {
    final record = await day(nov12);

    expect(record.day, nov12);
    expect(record.ownerId, ownerA);
    expect(record.isDone(devotional), isFalse);
    expect(record.items, isEmpty);
  });

  test('a completion checks the box on the day of the tap', () async {
    final outcome = await repository.record(
      amen('e1', DateTime(2026, 11, 12, 6, 30)),
    );

    expect(outcome, RecordOutcome.applied);
    final record = await day(nov12);
    expect(record.isDone(devotional), isTrue);
    expect(record.items[devotional]!.latestEventId, 'e1');
  });

  test('watchDay sends the new state after each change', () async {
    final states = <bool>[];
    final subscription = repository
        .watchDay(ownerA, nov12)
        .listen((record) => states.add(record.isDone(devotional)));
    addTearDown(subscription.cancel);
    await pumpEventQueue();

    await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));
    await pumpEventQueue();
    await repository.record(
      await undoOf(repository, 'e2', nov12, DateTime(2026, 11, 12, 6, 31)),
    );
    await pumpEventQueue();

    expect(states, <bool>[false, true, false]);
  });

  test(
    'replaying the same event id leaves exactly one completion (P05 acceptance 2)',
    () async {
      final event = amen('e1', DateTime(2026, 11, 12, 6, 30));

      expect(await repository.record(event), RecordOutcome.applied);
      expect(await repository.record(event), RecordOutcome.duplicate);
      expect(await repository.record(event), RecordOutcome.duplicate);

      final events = await repository.eventsFor(ownerA, nov12, devotional);
      expect(events.map((e) => e.id), <String>['e1']);
      expect((await day(nov12)).isDone(devotional), isTrue);
    },
  );

  test('a replayed completion does not re-check a box undone since', () async {
    final first = amen('e1', DateTime(2026, 11, 12, 6, 30));
    await repository.record(first);
    await repository.record(
      await undoOf(repository, 'e2', nov12, DateTime(2026, 11, 12, 6, 40)),
    );

    expect(await repository.record(first), RecordOutcome.duplicate);

    expect((await day(nov12)).isDone(devotional), isFalse);
    expect(await repository.eventsFor(ownerA, nov12, devotional), hasLength(2));
  });

  test(
    'a second tap for the state the box already has stores nothing',
    () async {
      await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));

      final outcome = await repository.record(
        amen('e2', DateTime(2026, 11, 12, 6, 30, 1)),
      );

      expect(outcome, RecordOutcome.alreadyInState);
      final events = await repository.eventsFor(ownerA, nov12, devotional);
      expect(events.map((e) => e.id), <String>['e1']);
      expect((await day(nov12)).isDone(devotional), isTrue);
    },
  );

  test('complete, undo, complete again keeps all three events', () async {
    await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));
    await repository.record(
      await undoOf(repository, 'e2', nov12, DateTime(2026, 11, 12, 6, 40)),
    );
    final afterUndo = await day(nov12);
    await repository.record(
      amen(
        'e3',
        DateTime(2026, 11, 12, 7),
        replaces: afterUndo.items[devotional]!.latestEventId,
      ),
    );

    final events = await repository.eventsFor(ownerA, nov12, devotional);
    expect(events.map((e) => e.id), <String>['e1', 'e2', 'e3']);
    expect(events.map((e) => e.done), <bool>[true, false, true]);
    expect(events.map((e) => e.replacesEventId), <String?>[null, 'e1', 'e2']);
    final record = await day(nov12);
    expect(record.isDone(devotional), isTrue);
    expect(record.items[devotional]!.latestEventId, 'e3');
  });

  test('each stored event gets the next counter', () async {
    await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));
    final first = (await day(nov12)).items[devotional]!.latestCounter;
    await repository.record(
      await undoOf(repository, 'e2', nov12, DateTime(2026, 11, 12, 6, 40)),
    );
    final second = (await day(nov12)).items[devotional]!.latestCounter;
    await repository.record(amen('e3', DateTime(2026, 11, 13, 6)));
    final third = (await day(nov13)).items[devotional]!.latestCounter;

    expect(second, first + 1);
    expect(third, second + 1);
  });

  group('undo after the clock has moved to another day (S1 board row)', () {
    for (final (label, undoTime, otherDay) in <(String, DateTime, LocalDate)>[
      ('back a day', DateTime(2026, 11, 11, 9), nov11),
      ('forward a day', DateTime(2026, 11, 13, 9), nov13),
    ]) {
      test(
        '$label: the box clears on the day the completion was recorded',
        () async {
          await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));

          final undo = await undoOf(repository, 'e2', nov12, undoTime);
          expect(await repository.record(undo), RecordOutcome.applied);

          // The completion's day is cleared, although the tap was on another.
          expect((await day(nov12)).isDone(devotional), isFalse);
          // The day the clock says is untouched: nothing was filed under it.
          expect((await day(otherDay)).items, isEmpty);
          expect(
            await repository.eventsFor(ownerA, otherDay, devotional),
            isEmpty,
          );
          final events = await repository.eventsFor(ownerA, nov12, devotional);
          expect(events.map((e) => e.id), <String>['e1', 'e2']);
          expect(events.last.day, nov12);
          expect(events.last.replacesEventId, 'e1');
        },
      );
    }
  });

  test(
    'the later event wins by counter, not by the time on the phone',
    () async {
      await repository.record(amen('e1', DateTime(2026, 11, 12, 10)));

      // The clock was moved back an hour before the undo: its tap time is
      // earlier than the completion's, and it must still win.
      await repository.record(
        await undoOf(repository, 'e2', nov12, DateTime(2026, 11, 12, 9)),
      );

      expect((await day(nov12)).isDone(devotional), isFalse);
    },
  );

  group(
    'the tap time comes back as the instant and offset it was stored with',
    () {
      for (final (label, instant, offset, tapDay)
          in <(String, DateTime, Duration, LocalDate)>[
            (
              'seven hours behind UTC',
              DateTime.utc(2026, 11, 12, 13, 30),
              const Duration(hours: -7),
              nov12,
            ),
            (
              'five and a half hours ahead, already the next day there',
              DateTime.utc(2026, 11, 11, 20),
              const Duration(hours: 5, minutes: 30),
              nov12,
            ),
            ('at UTC', DateTime.utc(2026, 11, 12, 6, 30), Duration.zero, nov12),
          ]) {
        test(label, () async {
          await repository.record(
            CompletionEvent(
              id: 'e1',
              ownerId: ownerA,
              day: nov12,
              item: devotional,
              done: true,
              tappedAtUtc: instant,
              utcOffset: offset,
            ),
          );

          final stored = (await repository.eventsFor(
            ownerA,
            nov12,
            devotional,
          )).single;
          // The instant is the same instant: not moved by the offset.
          expect(stored.tappedAtUtc.isUtc, isTrue);
          expect(stored.tappedAtUtc, instant);
          expect(
            stored.tappedAtUtc.millisecondsSinceEpoch,
            instant.millisecondsSinceEpoch,
          );
          // The offset is kept beside it, not folded in and not lost.
          expect(stored.utcOffset, offset);
          // Together they give the day the phone showed at the tap.
          expect(stored.tapLocalDate, tapDay);
        });
      }

      test('a completion made from a local time keeps that instant', () async {
        final local = DateTime(2026, 11, 12, 6, 30);
        await repository.record(amen('e1', local));

        final stored = (await repository.eventsFor(
          ownerA,
          nov12,
          devotional,
        )).single;
        expect(stored.tappedAtUtc, local.toUtc());
        expect(stored.utcOffset, local.timeZoneOffset);
        expect(stored.tapLocalDate, nov12);
        expect(stored.day, nov12);
      });
    },
  );

  test('another owner and another day see nothing', () async {
    await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));

    expect((await day(nov12, owner: ownerB)).items, isEmpty);
    expect((await day(nov13)).items, isEmpty);
    expect(await repository.eventsFor(ownerB, nov12, devotional), isEmpty);
  });

  test('watchDoneByDay lists the days that have a done box', () async {
    await repository.record(amen('e1', DateTime(2026, 11, 11, 6)));
    await repository.record(amen('e2', DateTime(2026, 11, 12, 6)));
    await repository.record(
      amen('e3', DateTime(2026, 11, 12, 6), owner: ownerB),
    );

    expect(await repository.watchDoneByDay(ownerA).first, {
      nov11: {devotional},
      nov12: {devotional},
    });

    await repository.record(
      await undoOf(repository, 'e4', nov11, DateTime(2026, 11, 12, 7)),
    );

    expect(await repository.watchDoneByDay(ownerA).first, {
      nov12: {devotional},
    });
  });
}
