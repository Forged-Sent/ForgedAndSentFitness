import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_progress_ring.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

const List<String> _inactive = <String>[
  't_motto',
  't_comms',
  't_workout',
  't_water',
  't_cal',
  't_steps',
];

FsBoxRow _row(WidgetTester tester, String id) =>
    tester.widget<FsBoxRow>(box(id));

FsProgressRing _ring(WidgetTester tester) =>
    tester.widget<FsProgressRing>(find.byType(FsProgressRing));

void main() {
  setUpAll(loadAppFonts);

  final reading = loadBundledLibrary().forDate(const LocalDate(2026, 11, 10))!;

  testWidgets(
    'Today shows the date, the mission line, the ring and the boxes',
    (tester) async {
      await pumpApp(tester);

      expect(find.text('TUESDAY, NOVEMBER 10'), findsOneWidget);
      expect(find.text('TODAY’S MISSION'), findsOneWidget);
      // November 10 is day 314 of the year; 314 mod 14 is line 6.
      expect(
        find.text('WALK IN STEP WITH THE SPIRIT, THEN GET YOUR REPS IN.'),
        findsOneWidget,
      );
      expect(find.text('START TODAY. GRACE FOR YESTERDAY.'), findsOneWidget);

      expect(_ring(tester).done, 0);
      expect(_ring(tester).total, 7);
      expect(find.text('0/7'), findsOneWidget);
      for (final (label, value) in <(String, String)>[
        ('SPIRIT', '0 OF 2'),
        ('BODY', '0 OF 4'),
        ('BROTHERHOOD', '0 OF 1'),
        ('STREAK', '0 DAYS'),
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
        expect(find.text(value), findsOneWidget, reason: label);
      }

      expect(find.text('Today’s boxes'), findsOneWidget);
      expect(find.byType(FsBoxRow), findsNWidgets(7));
      final devotional = _row(tester, 't_devo');
      expect(devotional.title, 'Daily Devotional');
      expect(devotional.command, 'Stand firm');
      expect(
        devotional.subtitle,
        '${reading.reference}. Tap to open today’s reading',
      );
      expect(devotional.checked, isFalse);
      expect(devotional.onTap, isNotNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'the other boxes are there and visibly not yet active (P05 acceptance 5)',
    (tester) async {
      final handle = tester.ensureSemantics();
      final app = await pumpApp(tester);
      final days = app.store.days as TestDayRepository;

      for (final id in _inactive) {
        await showBox(tester, id);
        final row = _row(tester, id);
        expect(row.onTap, isNull, reason: id);
        expect(row.checked, isFalse, reason: id);
        expect(row.subtitle, 'Not active yet', reason: id);
        expect(row.showChevron, isFalse, reason: id);
        // Drawn faded: half the opacity of the devotional's row.
        expect(
          tester
              .widget<Opacity>(
                find.descendant(of: box(id), matching: find.byType(Opacity)),
              )
              .opacity,
          0.5,
          reason: id,
        );
        // A screen reader hears it as unavailable and is offered no tap.
        expect(
          tester.getSemantics(box(id)),
          isSemantics(
            label: '${row.title}. Not active yet',
            hasEnabledState: true,
            isEnabled: false,
            hasTapAction: false,
          ),
          reason: id,
        );

        await tester.tap(box(id), warnIfMissed: false);
        await tester.pumpAndSettle();
        expect(find.byType(TodayPage), findsOneWidget, reason: id);
        expect(find.byType(DevotionalPage), findsNothing, reason: id);
      }

      // The devotional's row, by contrast, is a button that can be tapped.
      await showBox(tester, 't_devo');
      expect(
        tester.getSemantics(box('t_devo')),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          hasCheckedState: true,
          isChecked: false,
        ),
      );
      expect(
        tester
            .widget<Opacity>(
              find.descendant(
                of: box('t_devo'),
                matching: find.byType(Opacity),
              ),
            )
            .opacity,
        1,
      );
      expect(days.saveAttempts, 0);
      handle.dispose();
    },
  );

  testWidgets('point values are hidden unless the preview switch is on (Q5)', (
    tester,
  ) async {
    await pumpApp(tester);

    for (final id in <String>['t_devo', ..._inactive]) {
      expect(_row(tester, id).points, isNull, reason: id);
    }
    expect(find.textContaining('PTS'), findsNothing);
    expect(find.textContaining('PREVIEW'), findsNothing);
    // No total is shown anywhere: the app scores nothing.
    expect(find.textContaining('WEEK PTS'), findsNothing);
  });

  testWidgets('a checked devotional shows in the ring, the tally and the row', (
    tester,
  ) async {
    final app = await pumpApp(tester);

    await completeDevotional(tester);
    expect(find.byType(TodayPage), findsOneWidget);
    await scrollTodayToTop(tester);

    expect(_ring(tester).done, 1);
    expect(find.text('1/7'), findsOneWidget);
    expect(find.text('1 OF 2'), findsOneWidget);
    expect(find.text('0 OF 4'), findsOneWidget);
    expect(find.text('STREAK: 1 DAY'), findsOneWidget);
    expect(find.text('1 DAY'), findsOneWidget);
    final row = _row(tester, 't_devo');
    expect(row.checked, isTrue);
    expect(row.subtitle, 'Read today');

    final events = await app.store.days.eventsFor(
      app.ownerId,
      const LocalDate(2026, 11, 10),
      DayItems.devotional,
    );
    expect(events.map((e) => e.id), <String>['e1']);
    expect(events.single.done, isTrue);
    expect(events.single.ownerId, 'local-test');
  });

  group('past local midnight Today is a new day (P05 acceptance 3)', () {
    testWidgets('with the app left open', (tester) async {
      final app = await pumpApp(tester);
      await completeDevotional(tester);
      await scrollTodayToTop(tester);
      expect(_row(tester, 't_devo').checked, isTrue);

      // Midnight passes with Today on screen and nobody touching it.
      app.clock.time = DateTime(2026, 11, 11, 0, 0, 5);
      await tester.pump(const Duration(hours: 16, minutes: 31));
      await tester.pumpAndSettle();

      expect(find.text('WEDNESDAY, NOVEMBER 11'), findsOneWidget);
      expect(find.text('TUESDAY, NOVEMBER 10'), findsNothing);
      expect(_row(tester, 't_devo').checked, isFalse);
      expect(_ring(tester).done, 0);
      expect(find.text('0/7'), findsOneWidget);
      // Yesterday counts toward the streak, and today not being done yet
      // does not break it.
      expect(find.text('STREAK: 1 DAY'), findsOneWidget);
      expect(find.text('1 DAY'), findsOneWidget);
      // The new day has its own mission line.
      expect(
        find.text('WALK IN STEP WITH THE SPIRIT, THEN GET YOUR REPS IN.'),
        findsNothing,
      );

      // Checking the new day makes it two.
      await completeDevotional(tester);
      await scrollTodayToTop(tester);
      expect(find.text('STREAK: 2 DAYS'), findsOneWidget);
      expect(
        (await app.savedDoneDays(tester)).keys,
        unorderedEquals(const <LocalDate>[
          LocalDate(2026, 11, 10),
          LocalDate(2026, 11, 11),
        ]),
      );
    });

    testWidgets('when the app is resumed after midnight', (tester) async {
      final app = await pumpApp(tester);
      await completeDevotional(tester);
      await scrollTodayToTop(tester);

      // The phone is put away at night and picked up the next morning. No
      // timer runs while the app is in the background.
      app.clock.time = DateTime(2026, 11, 11, 6, 15);
      await backgroundAndResume(tester);

      expect(find.text('WEDNESDAY, NOVEMBER 11'), findsOneWidget);
      expect(_row(tester, 't_devo').checked, isFalse);
      expect(_ring(tester).done, 0);
      expect(find.text('STREAK: 1 DAY'), findsOneWidget);
    });

    testWidgets('a day missed in between ends the streak', (tester) async {
      final app = await pumpApp(tester);
      await completeDevotional(tester);
      await scrollTodayToTop(tester);

      app.clock.time = DateTime(2026, 11, 12, 6, 15);
      await backgroundAndResume(tester);

      expect(find.text('THURSDAY, NOVEMBER 12'), findsOneWidget);
      expect(find.text('START TODAY. GRACE FOR YESTERDAY.'), findsOneWidget);
      expect(find.text('0 DAYS'), findsOneWidget);
    });
  });

  testWidgets('where nothing is kept, Today says so', (tester) async {
    await pumpApp(tester, store: testStore(days: _ForgetfulDays()));

    expect(find.text(notSavedNotice), findsOneWidget);
  });

  testWidgets('on a phone, where the day is saved, it does not', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text(notSavedNotice), findsNothing);
  });

  testWidgets('a day that cannot be loaded says so and can be tried again', (
    tester,
  ) async {
    final days = _UnreadableDays();
    await pumpApp(tester, store: testStore(days: days));

    expect(find.text('Today could not be loaded.'), findsOneWidget);
    expect(find.byType(FsBoxRow), findsNothing);
    // The header still shows the date; only the day's data is missing.
    expect(find.text('TUESDAY, NOVEMBER 10'), findsOneWidget);

    days.unreadable = false;
    await tester.tap(find.text('TRY AGAIN'));
    await tester.pumpAndSettle();

    expect(find.text('Today could not be loaded.'), findsNothing);
    expect(find.byType(FsBoxRow), findsNWidgets(7));
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets('nothing overflows at $scale times the text size', (
      tester,
    ) async {
      await pumpApp(tester, textScale: scale);
      expect(tester.takeException(), isNull);
      for (final id in <String>['t_devo', ..._inactive]) {
        await showBox(tester, id);
        expect(tester.takeException(), isNull, reason: id);
      }
    });
  }

  testWidgets('nor on a small phone at 1.3 times the text size', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(320, 568), textScale: 1.3);
    expect(tester.takeException(), isNull);
    for (final id in <String>['t_devo', ..._inactive]) {
      await showBox(tester, id);
      expect(tester.takeException(), isNull, reason: id);
    }
  });
}

/// A store that keeps nothing, as the web preview's does.
class _ForgetfulDays extends TestDayRepository {
  @override
  bool get durable => false;
}

/// A store that cannot be read until the test says otherwise.
class _UnreadableDays extends TestDayRepository {
  bool unreadable = true;

  @override
  Stream<DayRecord> watchDay(String ownerId, LocalDate day) => unreadable
      ? Stream<DayRecord>.error(StateError('The test refused this read.'))
      : super.watchDay(ownerId, day);
}
