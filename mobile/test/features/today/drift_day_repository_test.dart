import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/features/today/data/drift_day_repository.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/storage/app_database.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';

import 'day_repository_contract.dart';

/// A folder that is deleted when the test ends.
Future<Directory> temporaryFolder() async {
  final folder = await Directory.systemTemp.createTemp('fs-s1-test-');
  addTearDown(() async {
    if (await folder.exists()) await folder.delete(recursive: true);
  });
  return folder;
}

void main() {
  group('DriftDayRepository', () {
    dayRepositoryContract(() async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      return DriftDayRepository(database);
    });
  });

  group('DriftDayRepository on a real SQLite file', () {
    test(
      'complete, close the database, reopen: still complete (P05 acceptance 1)',
      () async {
        final folder = await temporaryFolder();
        final first = await openLocalStoreIn(folder, background: false);
        final ownerId = first.ownerId;
        expect(first.days.durable, isTrue);

        await first.days.record(
          amen('e1', DateTime(2026, 11, 12, 6, 30), owner: ownerId),
        );
        await first.close();

        final reopened = await openLocalStoreIn(folder, background: false);
        addTearDown(reopened.close);

        expect(reopened.ownerId, ownerId);
        final record = await reopened.days.watchDay(ownerId, nov12).first;
        expect(record.isDone(devotional), isTrue);
        expect(
          await reopened.days.eventsFor(ownerId, nov12, devotional),
          hasLength(1),
        );
        expect(await reopened.days.watchDoneByDay(ownerId).first, {
          nov12: {devotional},
        });
      },
    );

    test('replaying an event after a reopen still stores it once', () async {
      final folder = await temporaryFolder();
      final first = await openLocalStoreIn(folder, background: false);
      final event = amen(
        'e1',
        DateTime(2026, 11, 12, 6, 30),
        owner: first.ownerId,
      );
      await first.days.record(event);
      await first.close();

      final reopened = await openLocalStoreIn(folder, background: false);
      addTearDown(reopened.close);

      expect(await reopened.days.record(event), RecordOutcome.duplicate);
      expect(
        await reopened.days.eventsFor(reopened.ownerId, nov12, devotional),
        hasLength(1),
      );
    });

    test('the counter carries on after a reopen', () async {
      final folder = await temporaryFolder();
      final first = await openLocalStoreIn(folder, background: false);
      final ownerId = first.ownerId;
      await first.days.record(
        amen('e1', DateTime(2026, 11, 12, 6, 30), owner: ownerId),
      );
      await first.close();

      final reopened = await openLocalStoreIn(folder, background: false);
      addTearDown(reopened.close);
      await reopened.days.record(
        amen('e2', DateTime(2026, 11, 13, 6, 30), owner: ownerId),
      );

      final one = await reopened.days.watchDay(ownerId, nov12).first;
      final two = await reopened.days.watchDay(ownerId, nov13).first;
      expect(
        two.items[devotional]!.latestCounter,
        one.items[devotional]!.latestCounter + 1,
      );
    });

    test('the event and its day state are stored together', () async {
      final folder = await temporaryFolder();
      final database = openAppDatabase(
        File('${folder.path}/together.sqlite'),
        background: false,
      );
      addTearDown(database.close);
      final repository = DriftDayRepository(database);

      await repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30)));

      final events = await database.select(database.completionEvents).get();
      final states = await database.select(database.dayStates).get();
      expect(events, hasLength(1));
      expect(states, hasLength(1));
      expect(states.single.latestEventId, events.single.id);
      expect(states.single.latestCounter, events.single.counter);
      expect(states.single.day, '2026-11-12');
      expect(events.single.tappedAtUtcMs, isPositive);
    });

    test(
      'if the day state cannot be written, the event is not stored either',
      () async {
        final folder = await temporaryFolder();
        final database = openAppDatabase(
          File('${folder.path}/atomic.sqlite'),
          background: false,
        );
        addTearDown(database.close);
        final repository = DriftDayRepository(database);
        // Create the schema, then make every write to day_states fail.
        await database.select(database.dayStates).get();
        await database.customStatement(
          'CREATE TRIGGER refuse_day_state BEFORE INSERT ON day_states '
          "BEGIN SELECT RAISE(ABORT, 'refused by the test'); END;",
        );

        await expectLater(
          repository.record(amen('e1', DateTime(2026, 11, 12, 6, 30))),
          throwsA(anything),
        );

        expect(await database.select(database.completionEvents).get(), isEmpty);
        expect(await database.select(database.dayStates).get(), isEmpty);
      },
    );
  });

  group('the local profile (decision Q10)', () {
    final idForm = RegExp(r'^local-[0-9a-f-]{36}$');

    test('first launch makes an id; later launches reuse it', () async {
      final folder = await temporaryFolder();

      final first = await loadOrCreateLocalProfileId(folder);
      final second = await loadOrCreateLocalProfileId(folder);

      expect(first, matches(idForm));
      expect(second, first);
    });

    test(
      'two installs get different ids and different database files',
      () async {
        final a = await temporaryFolder();
        final b = await temporaryFolder();

        final idA = await loadOrCreateLocalProfileId(a);
        final idB = await loadOrCreateLocalProfileId(b);

        expect(idA, isNot(idB));
        expect(databaseFileFor(a, idA).path, endsWith('forged_$idA.sqlite'));
        expect(
          databaseFileFor(a, idA).path,
          isNot(databaseFileFor(a, idB).path),
        );
      },
    );

    test(
      'a damaged profile file is an error, not a fresh empty profile',
      () async {
        final folder = await temporaryFolder();
        await File('${folder.path}/local_profile_id').writeAsString('../etc');

        await expectLater(
          loadOrCreateLocalProfileId(folder),
          throwsA(isA<StateError>()),
        );
      },
    );

    test(
      'opening the store creates the profile and its database file',
      () async {
        final folder = await temporaryFolder();

        final store = await openLocalStoreIn(folder, background: false);
        addTearDown(store.close);
        await store.days.watchDay(store.ownerId, nov12).first;

        expect(store.ownerId, matches(idForm));
        expect(await databaseFileFor(folder, store.ownerId).exists(), isTrue);
      },
    );
  });
}
