import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_scripture.dart';
import 'package:forged_and_sent/src/features/devotional/data/devotional_library.dart';
import 'package:forged_and_sent/src/features/devotional/domain/devotional.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

const LocalDate _nov10 = LocalDate(2026, 11, 10);
const LocalDate _nov11 = LocalDate(2026, 11, 11);
const String _devotional = DayItems.devotional;

FsButton _amen(WidgetTester tester) => tester.widget<FsButton>(amenButton);

/// The verse on screen.
String _verse(WidgetTester tester) =>
    tester.widget<FsScripture>(find.byType(FsScripture)).text;

Finder get _notice => find.byKey(const ValueKey<String>('fs-scripture-notice'));

Future<void> _choose(WidgetTester tester, String translation) async {
  await tester.ensureVisible(find.widgetWithText(FsButton, translation));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FsButton, translation));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  final library = loadBundledLibrary();
  final reading = library.forDate(_nov10)!;
  final nextReading = library.forDate(_nov11)!;

  testWidgets('the devotional box opens today\'s real reading', (tester) async {
    await pumpApp(tester);
    await openDevotional(tester);

    expect(find.byType(DevotionalPage), findsOneWidget);
    expect(find.text('November 10'), findsOneWidget);
    expect(find.text('TUESDAY'), findsOneWidget);
    expect(
      find.text('${reading.monthName} · ${reading.monthTheme}'.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text(reading.monthTag), findsOneWidget);
    for (final label in <String>[
      'OPEN IN PRAYER',
      'READING',
      'REFLECT',
      'ACT',
    ]) {
      expect(find.text('// $label'), findsOneWidget, reason: label);
    }
    expect(find.text(reading.prayer), findsOneWidget);
    expect(find.text(reading.reflect), findsOneWidget);
    expect(find.text(reading.act), findsOneWidget);
    // The verse is the bundled one, in the BSB, with its reference.
    expect(_verse(tester), reading.bsbText);
    expect(
      find.text('— ${reading.reference} (BSB)'.toUpperCase()),
      findsOneWidget,
    );
    // No demo copy is left over from the earlier Today demo.
    expect(find.textContaining('Synthetic'), findsNothing);
    expect(find.textContaining('demo'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  group('Amen (P05 acceptance 4)', () {
    testWidgets('is disabled until the end of the scroll', (tester) async {
      final app = await pumpApp(tester);
      final days = app.store.days as TestDayRepository;
      await openDevotional(tester);

      // The page is always taller than the screen: there is an end to reach.
      final position = readerPosition(tester);
      expect(position.pixels, 0);
      expect(position.maxScrollExtent, greaterThanOrEqualTo(220));
      expect(_amen(tester).onPressed, isNull);
      expect(_amen(tester).label, 'Scroll to the bottom to say Amen');
      expect(find.text('Read it all the way through.'), findsOneWidget);

      // Most of the way down is not the end.
      position.jumpTo(position.maxScrollExtent - 40);
      await tester.pumpAndSettle();
      expect(_amen(tester).onPressed, isNull);
      // Tapping the disabled button saves nothing and goes nowhere.
      await tester.tap(amenButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(days.saveAttempts, 0);
      expect(find.byType(DevotionalPage), findsOneWidget);

      // Within a finger's width of the end is.
      position.jumpTo(position.maxScrollExtent - 8);
      await tester.pumpAndSettle();
      expect(_amen(tester).onPressed, isNotNull);
      expect(_amen(tester).label, 'Amen');
      expect(find.text('You made it to the end.'), findsOneWidget);

      // Scrolling back up does not lock it again.
      position.jumpTo(0);
      await tester.pumpAndSettle();
      expect(_amen(tester).onPressed, isNotNull);
    });

    testWidgets(
      'a reading that would fit on the screen still has to be scrolled',
      (tester) async {
        // A screen far taller than any reading: nothing would need scrolling.
        // The page is then made 220 points taller than the screen, as the
        // prototype does, so Amen is never unlocked just by opening the page.
        await pumpApp(tester, size: const Size(390, 3000));
        await openDevotional(tester);

        final position = readerPosition(tester);
        expect(position.pixels, 0);
        expect(position.maxScrollExtent, moreOrLessEquals(220, epsilon: 1));
        expect(_amen(tester).onPressed, isNull);
        expect(_amen(tester).label, 'Scroll to the bottom to say Amen');
        expect(find.text('Read it all the way through.'), findsOneWidget);

        // Waiting does not unlock it either.
        await tester.pump(const Duration(seconds: 30));
        expect(_amen(tester).onPressed, isNull);

        await scrollReaderToEnd(tester);
        expect(_amen(tester).onPressed, isNotNull);
        expect(_amen(tester).label, 'Amen');
      },
    );

    testWidgets('checks the box, returns to Today, and Undo clears it', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      await completeDevotional(tester);

      expect(find.byType(DevotionalPage), findsNothing);
      expect(find.byType(TodayPage), findsOneWidget);
      expect((await app.savedDay(tester, _nov10)).isDone(_devotional), isTrue);

      // The reading now offers the way back.
      await openDevotional(tester);
      expect(_amen(tester).label, 'Amen. Undo');
      expect(_amen(tester).variant, FsButtonVariant.ghost);
      expect(_amen(tester).onPressed, isNotNull);
      expect(
        find.text('Your Daily Devotional box is checked.'),
        findsOneWidget,
      );

      await tester.ensureVisible(amenButton);
      await tester.pumpAndSettle();
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      // Undo stays on the reading, as in the prototype.
      expect(find.byType(DevotionalPage), findsOneWidget);
      expect((await app.savedDay(tester, _nov10)).isDone(_devotional), isFalse);
      expect(_amen(tester).label, isNot('Amen. Undo'));
      final events = await app.store.days.eventsFor(
        app.ownerId,
        _nov10,
        _devotional,
      );
      expect(events.map((e) => e.done), <bool>[true, false]);
      expect(events.last.replacesEventId, events.first.id);
    });

    testWidgets('tapped twice in a row still stores one completion', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      await openDevotional(tester);
      await scrollReaderToEnd(tester);

      await tester.tap(amenButton);
      await tester.tap(amenButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      final events = await app.store.days.eventsFor(
        app.ownerId,
        _nov10,
        _devotional,
      );
      expect(events, hasLength(1));
      expect(events.single.done, isTrue);
    });

    testWidgets('is reachable and usable with a screen reader', (tester) async {
      final handle = tester.ensureSemantics();
      final app = await pumpApp(tester);
      // The row on Today is opened through its semantics node, no pointer.
      await showBox(tester, 't_devo');
      await semanticsTap(tester, box('t_devo'));
      expect(find.byType(DevotionalPage), findsOneWidget);

      // Near the end, but not at it, the button is announced with what it
      // waits for, as disabled, and offers no tap.
      final position = readerPosition(tester);
      position.jumpTo(position.maxScrollExtent - 60);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(amenButton),
        isSemantics(
          label: 'Scroll to the bottom to say Amen',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          hasTapAction: false,
        ),
      );

      // A screen reader moves down the page with its scroll action, not a
      // drag. That reaches the end and unlocks Amen.
      position.jumpTo(0);
      await tester.pumpAndSettle();
      final scrollable = find.semantics.scrollable();
      for (var i = 0; i < 12 && _amen(tester).onPressed == null; i++) {
        tester.semantics.scrollUp(scrollable: scrollable);
        await tester.pumpAndSettle();
      }
      expect(
        tester.getSemantics(amenButton),
        isSemantics(
          label: 'Amen',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );

      // And Amen itself is pressed through the semantics tree.
      await semanticsTap(tester, amenButton);
      expect(find.byType(TodayPage), findsOneWidget);
      expect((await app.savedDay(tester, _nov10)).isDone(_devotional), isTrue);
      await showBox(tester, 't_devo');
      expect(
        tester.getSemantics(box('t_devo')),
        isSemantics(
          label: 'Daily Devotional. Read today',
          hasCheckedState: true,
          isChecked: true,
          isButton: true,
        ),
      );
      handle.dispose();
    });
  });

  group('undo after the clock has moved to another day (S1 board row)', () {
    for (final (label, moved) in <(String, DateTime)>[
      ('forward', DateTime(2026, 11, 11, 8)),
      ('back', DateTime(2026, 11, 9, 8)),
    ]) {
      testWidgets('$label: the box clears on the day it was checked', (
        tester,
      ) async {
        final app = await pumpApp(tester);
        await completeDevotional(tester);
        await openDevotional(tester);
        expect(_amen(tester).label, 'Amen. Undo');

        // The phone's clock is now on another day, and the app has not yet
        // noticed: the reading of the 10th is still on screen.
        app.clock.time = moved;
        final other = LocalDate.of(moved);
        await tester.ensureVisible(amenButton);
        await tester.pumpAndSettle();
        await tester.tap(amenButton);
        await tester.pumpAndSettle();

        // The 10th, where the completion was recorded, is cleared.
        expect(
          (await app.savedDay(tester, _nov10)).isDone(_devotional),
          isFalse,
        );
        final events = await app.store.days.eventsFor(
          app.ownerId,
          _nov10,
          _devotional,
        );
        expect(events.map((e) => e.done), <bool>[true, false]);
        // The undo was tapped on the other day and filed under the 10th.
        expect(events.last.day, _nov10);
        expect(LocalDate.of(events.last.tappedAt), other);
        // Nothing was filed under the day the clock moved to.
        expect((await app.savedDay(tester, other)).items, isEmpty);
        expect(
          await app.store.days.eventsFor(app.ownerId, other, _devotional),
          isEmpty,
        );
        expect(await app.savedDoneDays(tester), isEmpty);
      });
    }
  });

  testWidgets('past midnight the page shows the new day, locked again', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await openDevotional(tester);
    await scrollReaderToEnd(tester);
    expect(_amen(tester).onPressed, isNotNull);

    app.clock.time = DateTime(2026, 11, 11, 0, 0, 5);
    await tester.pump(const Duration(minutes: 1));
    await tester.pumpAndSettle();

    expect(find.text('November 11'), findsOneWidget);
    expect(find.text('November 10'), findsNothing);
    expect(_verse(tester), nextReading.bsbText);
    expect(readerPosition(tester).pixels, 0);
    // He has not read this one: Amen waits for the end again.
    expect(_amen(tester).onPressed, isNull);

    // Amen now belongs to the 11th, the day of the tap (decision Q9).
    await scrollReaderToEnd(tester);
    await tester.tap(amenButton);
    await tester.pumpAndSettle();
    expect((await app.savedDay(tester, _nov11)).isDone(_devotional), isTrue);
    expect((await app.savedDay(tester, _nov10)).items, isEmpty);
  });

  testWidgets('Amen tapped past midnight is filed under the day of the tap', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await openDevotional(tester);
    await scrollReaderToEnd(tester);

    // The clock passes midnight and he taps before the page has changed.
    app.clock.time = DateTime(2026, 11, 11, 0, 0, 2);
    await tester.tap(amenButton);
    await tester.pumpAndSettle();

    expect((await app.savedDay(tester, _nov11)).isDone(_devotional), isTrue);
    expect((await app.savedDay(tester, _nov10)).items, isEmpty);
    // Today, back on screen, is the 11th with its box checked.
    await scrollTodayToTop(tester);
    expect(find.text('WEDNESDAY, NOVEMBER 11'), findsOneWidget);
  });

  group('the verse (decision Q7)', () {
    testWidgets('opens in the BSB and switches to the ESV on its tab', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDevotional(tester);

      expect(_verse(tester), reading.bsbText);
      expect(tester.widget<Text>(_notice).data, ScriptureNotices.bsb);
      expect(
        tester.widget<FsButton>(find.widgetWithText(FsButton, 'BSB')).selected,
        isTrue,
      );

      await _choose(tester, 'ESV');
      expect(_verse(tester), reading.esvText);
      expect(
        find.text('— ${reading.reference} (ESV)'.toUpperCase()),
        findsOneWidget,
      );
      // The Crossway notice is shown where the ESV text is.
      expect(tester.widget<Text>(_notice).data, ScriptureNotices.esv);
      expect(find.textContaining('Crossway'), findsOneWidget);
      expect(
        tester.widget<FsButton>(find.widgetWithText(FsButton, 'ESV')).selected,
        isTrue,
      );

      await _choose(tester, 'BSB');
      expect(_verse(tester), reading.bsbText);
      expect(find.textContaining('Crossway'), findsNothing);
    });

    testWidgets('opens in the BSB again every time', (tester) async {
      await pumpApp(tester);
      await openDevotional(tester);
      await _choose(tester, 'ESV');
      await systemBack(tester);

      await openDevotional(tester);

      expect(_verse(tester), reading.bsbText);
    });

    testWidgets(
      'with no ESV text bundled, the ESV tab says the limit is reached',
      (tester) async {
        final esv =
            (json.decode(File(DevotionalLibrary.esvAsset).readAsStringSync())
                    as Map<String, dynamic>)
                .cast<String, String>()
              ..remove(reading.reference);
        await pumpApp(
          tester,
          library: DevotionalLibrary.fromJson(
            devotionals: File(
              DevotionalLibrary.devotionalsAsset,
            ).readAsStringSync(),
            esvVerses: json.encode(esv),
          ),
        );
        await openDevotional(tester);

        // The BSB is there as always.
        expect(_verse(tester), reading.bsbText);

        await _choose(tester, 'ESV');
        expect(
          find.text('ESV limit reached until we have a licence'),
          findsOneWidget,
        );
        expect(find.byType(FsScripture), findsNothing);
        // No ESV text is on screen, so neither is the ESV notice.
        expect(_notice, findsNothing);
        expect(find.textContaining('Crossway'), findsNothing);
        expect(find.text(reading.esvText!), findsNothing);

        // Amen does not depend on the translation.
        await scrollReaderToEnd(tester);
        expect(_amen(tester).onPressed, isNotNull);

        await _choose(tester, 'BSB');
        expect(_verse(tester), reading.bsbText);
        expect(
          find.text('ESV limit reached until we have a licence'),
          findsNothing,
        );
      },
    );
  });

  testWidgets('a save that fails says so, checks nothing, and can be retried', (
    tester,
  ) async {
    final days = TestDayRepository()..failWrites = true;
    final app = await pumpApp(tester, store: testStore(days: days));
    await openDevotional(tester);
    await scrollReaderToEnd(tester);

    await tester.tap(amenButton);
    await tester.pumpAndSettle();

    // He stays on the reading and is told. Nothing claims to be saved.
    expect(find.byType(DevotionalPage), findsOneWidget);
    expect(find.text('That did not save. Try again.'), findsOneWidget);
    expect(_amen(tester).label, 'Amen');
    expect((await app.savedDay(tester, _nov10)).items, isEmpty);

    days.failWrites = false;
    await tester.tap(amenButton);
    await tester.pumpAndSettle();

    expect(find.byType(TodayPage), findsOneWidget);
    expect((await app.savedDay(tester, _nov10)).isDone(_devotional), isTrue);
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets('nothing overflows at $scale times the text size', (
      tester,
    ) async {
      await pumpApp(tester, textScale: scale);
      await openDevotional(tester);
      expect(tester.takeException(), isNull);
      await _choose(tester, 'ESV');
      expect(tester.takeException(), isNull);
      await scrollReaderToEnd(tester);
      expect(tester.takeException(), isNull);
      expect(_amen(tester).onPressed, isNotNull);
    });
  }

  testWidgets('nor on a small phone at 1.3 times the text size', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(320, 568), textScale: 1.3);
    await openDevotional(tester);
    await _choose(tester, 'ESV');
    await scrollReaderToEnd(tester);
    expect(tester.takeException(), isNull);
  });
}
