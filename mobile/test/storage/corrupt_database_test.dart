import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/app/open_local_store.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';

import '../support/fs_test_support.dart';

/// A folder that is deleted when the test ends.
Directory temporaryFolder() {
  final folder = Directory.systemTemp.createTempSync('fs-s1-corrupt-');
  addTearDown(() {
    if (folder.existsSync()) folder.deleteSync(recursive: true);
  });
  return folder;
}

/// A profile whose database file is not a database: 4 KB of text where
/// SQLite expects its header.
Future<File> corruptDatabaseIn(Directory folder) async {
  final ownerId = await loadOrCreateLocalProfileId(folder);
  final file = databaseFileFor(folder, ownerId);
  await file.writeAsString('this is not a database. ' * 170, flush: true);
  return file;
}

void main() {
  group('a database file that cannot be read is found at start-up', () {
    test(
      'a corrupt file makes opening the store fail, not a later read',
      () async {
        final folder = temporaryFolder();
        await corruptDatabaseIn(folder);

        await expectLater(
          openLocalStoreIn(folder, background: false),
          throwsA(anything),
        );
      },
    );

    test(
      'the same on a background isolate, which is how the app opens it',
      () async {
        final folder = temporaryFolder();
        await corruptDatabaseIn(folder);

        await expectLater(openLocalStoreIn(folder), throwsA(anything));
      },
    );

    test('the corrupt file is closed again, and left as it was', () async {
      final folder = temporaryFolder();
      final file = await corruptDatabaseIn(folder);
      final before = await file.readAsBytes();

      await expectLater(
        openLocalStoreIn(folder, background: false),
        throwsA(anything),
      );

      // Nothing was written over it: whatever can be recovered still can.
      expect(await file.readAsBytes(), before);
      // And it is not held open. On Windows an open file cannot be deleted.
      await file.delete();
      expect(await file.exists(), isFalse);
    });

    test('a path that cannot be opened as a file fails the same way', () async {
      final folder = temporaryFolder();
      final ownerId = await loadOrCreateLocalProfileId(folder);
      // A folder sits where the database file should be.
      await Directory(databaseFileFor(folder, ownerId).path).create();

      await expectLater(
        openLocalStoreIn(folder, background: false),
        throwsA(anything),
      );
    });

    test(
      'a healthy file opens, and what was saved in it is still there',
      () async {
        final folder = temporaryFolder();
        final first = await openLocalStoreIn(folder, background: false);
        await first.days.record(
          CompletionEvent.complete(
            id: 'e1',
            ownerId: first.ownerId,
            item: DayItems.devotional,
            tappedAt: DateTime(2026, 11, 12, 6, 30),
          ),
        );
        await first.close();

        final again = await openLocalStoreIn(folder, background: false);
        addTearDown(again.close);

        final record = await again.days
            .watchDay(again.ownerId, const LocalDate(2026, 11, 12))
            .first;
        expect(record.isDone(DayItems.devotional), isTrue);
      },
    );
  });

  group('start-up with a store that cannot be opened', () {
    test(
      'falls back to a store that keeps nothing, and says it failed',
      () async {
        final folder = temporaryFolder();
        await corruptDatabaseIn(folder);

        final startup = await openLocalStoreOrFallback(
          () => openLocalStoreIn(folder, background: false),
        );

        expect(startup.storageFailed, isTrue);
        expect(startup.store.days.durable, isFalse);
      },
    );

    test(
      'with a healthy file it is the real store, and nothing failed',
      () async {
        final folder = temporaryFolder();

        final startup = await openLocalStoreOrFallback(
          () => openLocalStoreIn(folder, background: false),
        );
        addTearDown(startup.store.close);

        expect(startup.storageFailed, isFalse);
        expect(startup.store.days.durable, isTrue);
      },
    );

    testWidgets(
      'with a corrupt database file the app opens on the status page and says nothing is saved',
      (tester) async {
        // Opening the file is real file work, done outside the test's fake
        // clock; this is what `main` does before the first frame.
        final startup = (await tester.runAsync(() async {
          final folder = temporaryFolder();
          await corruptDatabaseIn(folder);
          return openLocalStoreOrFallback(
            () => openLocalStoreIn(folder, background: false),
          );
        }))!;
        expect(startup.storageFailed, isTrue);

        await pumpApp(
          tester,
          store: startup.store,
          storageFailed: startup.storageFailed,
        );

        // The status page is the first thing on screen, and it says so.
        expect(find.byType(FoundationHomeScreen), findsOneWidget);
        expect(
          find.text(
            'Local storage could not be opened. Nothing is saved on this '
            'device.',
          ),
          findsOneWidget,
        );
        expect(find.text('Close the app and open it again.'), findsOneWidget);
        // It is not reported as a load error to retry, nor as an emulator
        // problem.
        expect(find.text('Today could not be loaded.'), findsNothing);
        expect(find.textContaining('emulator'), findsNothing);

        // Today still works, and says the same where the boxes are.
        await systemBack(tester);
        await systemBack(tester);
        expect(find.byType(TodayPage), findsOneWidget);
        expect(find.text(notSavedNotice), findsOneWidget);
        expect(find.text('Today could not be loaded.'), findsNothing);
      },
    );
  });
}
