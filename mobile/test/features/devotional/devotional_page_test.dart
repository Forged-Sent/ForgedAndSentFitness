import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_colors.dart';
import 'package:forged_and_sent/src/design/fs_scripture.dart';
import 'package:forged_and_sent/src/design/fs_tag.dart';
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

Finder get _inJesus => find.byKey(const ValueKey<String>('fs-in-jesus'));

Finder get _sentTag => find.byKey(const ValueKey<String>('fs-tag-sent'));

Finder get _spiritTag => find.byKey(const ValueKey<String>('fs-tag-spirit'));

/// A clock at half past seven in the morning of [day].
TestClock _at(LocalDate day) =>
    TestClock(DateTime(day.year, day.month, day.day, 7, 30));

/// The date [reading] is shown on, in a leap year so that February 29 has
/// one too.
LocalDate _dateOf(Devotional reading) => LocalDate(
  2028,
  int.parse(reading.monthDayKey.substring(0, 2)),
  int.parse(reading.monthDayKey.substring(3)),
);

/// How much there is to read in [reading].
int _length(Devotional reading) =>
    (reading.headline ?? '').length +
    reading.prayer.length +
    reading.bsbText.length +
    (reading.inJesus ?? '').length +
    reading.reflect.length +
    reading.act.length;

/// What a screen reader says, in the order it says it.
List<String> _spoken(WidgetTester tester) => tester.semantics
    .simulatedAccessibilityTraversal()
    .map((node) => node.label)
    .where((label) => label.isNotEmpty)
    .toList();

/// Fails unless [labels] are all in [spoken], in this order.
void _expectInOrder(List<String> spoken, List<String> labels) {
  var from = 0;
  for (final label in labels) {
    final at = spoken.indexOf(label, from);
    expect(
      at,
      isNot(-1),
      reason:
          '"$label" is not read after ${labels.take(labels.indexOf(label))}'
          ' in $spoken',
    );
    from = at + 1;
  }
}

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
      'IN JESUS',
      'REFLECT',
      'ACT',
    ]) {
      expect(find.text('// $label'), findsOneWidget, reason: label);
    }
    // v254's headline and "In Jesus" paragraph, word for word.
    expect(find.text(reading.headline!.toUpperCase()), findsOneWidget);
    expect(tester.widget<Text>(_inJesus).data, reading.inJesus);
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
        expect(events.last.tapLocalDate, other);
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
    // And the page says why it changed under him.
    expect(find.text(newDayNotice), findsOneWidget);

    // Amen now belongs to the 11th, the day of the tap (decision Q9).
    await scrollReaderToEnd(tester);
    await tester.tap(amenButton);
    await tester.pumpAndSettle();
    expect((await app.savedDay(tester, _nov11)).isDone(_devotional), isTrue);
    expect((await app.savedDay(tester, _nov10)).items, isEmpty);
  });

  testWidgets(
    'reaching the end of one reading as the day changes does not unlock the next',
    (tester) async {
      final app = await pumpApp(tester);
      await openDevotional(tester);
      expect(_amen(tester).onPressed, isNull);

      // He reaches the end of the 10th's reading. The page notes it, to
      // unlock Amen once the frame is drawn. No frame is drawn yet.
      final position = readerPosition(tester);
      position.jumpTo(position.maxScrollExtent);

      // In that gap midnight passes and the page moves to the 11th.
      app.clock.time = DateTime(2026, 11, 11, 0, 0, 5);
      await tester.pump(const Duration(minutes: 1));
      await tester.pumpAndSettle();

      // The 11th's reading is on screen from the top, and the end he
      // reached belonged to the 10th: Amen stays locked.
      expect(find.text('November 11'), findsOneWidget);
      expect(_verse(tester), nextReading.bsbText);
      expect(readerPosition(tester).pixels, 0);
      expect(_amen(tester).onPressed, isNull);
      expect(_amen(tester).label, 'Scroll to the bottom to say Amen');
      expect(find.text(newDayNotice), findsOneWidget);

      // Reading the 11th to its end unlocks it as usual.
      await scrollReaderToEnd(tester);
      expect(_amen(tester).onPressed, isNotNull);
      await tester.tap(amenButton);
      await tester.pumpAndSettle();
      expect((await app.savedDay(tester, _nov11)).isDone(_devotional), isTrue);
      expect((await app.savedDay(tester, _nov10)).items, isEmpty);
    },
  );

  group('Amen tapped just after midnight, before the page has changed', () {
    // Decided by the maintainer on 2026-11-12: the tap is refused, nothing
    // is saved, the new day's reading is shown locked, and one line says
    // it is a new day.
    testWidgets('is refused: nothing is saved for either day', (tester) async {
      final app = await pumpApp(tester);
      final days = app.store.days as TestDayRepository;
      await openDevotional(tester);
      await scrollReaderToEnd(tester);
      expect(_amen(tester).onPressed, isNotNull);
      expect(find.text(newDayNotice), findsNothing);

      // The clock passes midnight. No timer has run and the app was not
      // resumed, so the reading of the 10th is still on screen, unlocked.
      app.clock.time = DateTime(2026, 11, 11, 0, 0, 2);
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      // No box is checked and no event exists, for the old day or the new.
      expect(days.saveAttempts, 0);
      expect((await app.savedDay(tester, _nov10)).items, isEmpty);
      expect((await app.savedDay(tester, _nov11)).items, isEmpty);
      expect(
        await app.store.days.eventsFor(app.ownerId, _nov11, _devotional),
        isEmpty,
      );
      expect(await app.savedDoneDays(tester), isEmpty);

      // He stays on the reading, which is now the 11th's, at the top, with
      // Amen locked again and a line that says why.
      expect(find.byType(DevotionalPage), findsOneWidget);
      expect(find.text('November 11'), findsOneWidget);
      expect(find.text('November 10'), findsNothing);
      expect(_verse(tester), nextReading.bsbText);
      expect(readerPosition(tester).pixels, 0);
      expect(_amen(tester).onPressed, isNull);
      expect(_amen(tester).label, 'Scroll to the bottom to say Amen');
      expect(find.text(newDayNotice), findsOneWidget);
      expect(newDayNotice, contains('new day'));
      // It is not reported as a failed save.
      expect(find.text('That did not save. Try again.'), findsNothing);
    });

    testWidgets('then reading the new day to its end and Amen saves it', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      await openDevotional(tester);
      await scrollReaderToEnd(tester);
      app.clock.time = DateTime(2026, 11, 11, 0, 0, 2);
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      await scrollReaderToEnd(tester);
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      expect(find.byType(TodayPage), findsOneWidget);
      expect((await app.savedDay(tester, _nov11)).isDone(_devotional), isTrue);
      expect((await app.savedDay(tester, _nov10)).items, isEmpty);
      await scrollTodayToTop(tester);
      expect(find.text('WEDNESDAY, NOVEMBER 11'), findsOneWidget);
    });

    testWidgets('a screen reader is told about the new day', (tester) async {
      final handle = tester.ensureSemantics();
      final app = await pumpApp(tester);
      await openDevotional(tester);
      await scrollReaderToEnd(tester);
      app.clock.time = DateTime(2026, 11, 11, 0, 0, 2);
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.byKey(const ValueKey<String>('fs-new-day'))),
        isSemantics(label: newDayNotice, isLiveRegion: true),
      );
      handle.dispose();
    });
  });

  group('the headline, the tags and "In Jesus" (S1b)', () {
    // A Saturday in the February series, tagged Sent; a Saturday whose
    // headline takes two lines, tagged Spirit-led; and a day with no tag.
    const sentDay = LocalDate(2026, 2, 7);
    const spiritDay = LocalDate(2026, 1, 3);
    const plainDay = LocalDate(2026, 11, 12);
    final sent = library.forDate(sentDay)!;
    final spirit = library.forDate(spiritDay)!;
    final plain = library.forDate(plainDay)!;

    test('the three dates are what these tests take them to be', () {
      expect(sent.series, isNotNull);
      expect(sent.tags, <ReadingTag>[ReadingTag.sent]);
      expect(spirit.series, isNull);
      expect(spirit.tags, <ReadingTag>[ReadingTag.spiritLed]);
      expect(plain.tags, isEmpty);
    });

    testWidgets('the headline is under the date, the tag under the headline', (
      tester,
    ) async {
      await pumpApp(tester, clock: _at(sentDay));
      await openDevotional(tester);

      final lines = <Rect>[
        tester.getRect(find.text('February 7')),
        tester.getRect(find.text(sent.series!.toUpperCase())),
        tester.getRect(find.text(sent.headline!.toUpperCase())),
        tester.getRect(_sentTag),
        tester.getRect(find.text(sent.monthTag)),
        tester.getRect(find.text('// OPEN IN PRAYER')),
      ];
      for (var i = 1; i < lines.length; i++) {
        expect(
          lines[i].top,
          greaterThanOrEqualTo(lines[i - 1].bottom),
          reason: 'line $i starts above the end of line ${i - 1}',
        );
      }
      // The spacing the prototype has between them: 8 under the date, 14
      // under a series line, 12 above the tags, 10 above the month line.
      expect(lines[1].top - lines[0].bottom, moreOrLessEquals(8, epsilon: 0.5));
      expect(
        lines[2].top - lines[1].bottom,
        moreOrLessEquals(14, epsilon: 0.5),
      );
      expect(
        lines[3].top - lines[2].bottom,
        moreOrLessEquals(12, epsilon: 0.5),
      );
      expect(
        lines[4].top - lines[3].bottom,
        moreOrLessEquals(10, epsilon: 0.5),
      );
    });

    testWidgets('"In Jesus" sits between the Reading and Reflect', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDevotional(tester);

      final tops = <double>[
        for (final label in <String>[
          'OPEN IN PRAYER',
          'READING',
          'IN JESUS',
          'REFLECT',
          'ACT',
        ])
          tester.getRect(find.text('// $label')).top,
      ];
      expect(tops, orderedEquals(<double>[...tops]..sort()));

      final label = tester.getRect(find.text('// IN JESUS'));
      final text = tester.getRect(_inJesus);
      // Under everything that belongs to the verse, the notice included.
      expect(label.top, greaterThan(tester.getRect(_notice).bottom));
      expect(text.top, greaterThanOrEqualTo(label.bottom));
      expect(
        tester.getRect(find.text('// REFLECT')).top,
        greaterThan(text.bottom),
      );
      expect(tester.widget<Text>(_inJesus).data, reading.inJesus);
    });

    testWidgets('a screen reader reads them in that order, as written', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, clock: _at(sentDay));
      await openDevotional(tester);

      // The top of the page: date, series, headline, tag, month line.
      _expectInOrder(_spoken(tester), <String>[
        'February 7',
        sent.series!,
        sent.headline!,
        'Sent: take it to someone',
        sent.monthTag,
        'Open in prayer',
        sent.prayer,
      ]);
      // The headline is read as a sentence, not as the capitals drawn.
      expect(find.bySemanticsLabel(sent.headline!), findsOneWidget);
      expect(find.bySemanticsLabel(sent.headline!.toUpperCase()), findsNothing);

      // Further down: the verse, then "In Jesus", then Reflect.
      await tester.ensureVisible(_inJesus);
      await tester.pumpAndSettle();
      _expectInOrder(_spoken(tester), <String>[
        '— ${sent.reference} (BSB)',
        ScriptureNotices.bsb,
        'In Jesus',
        sent.inJesus!,
        'Reflect',
        sent.reflect,
      ]);
      expect(
        tester.getSemantics(find.text('// IN JESUS')),
        isSemantics(label: 'In Jesus', isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('a Sent reading shows the Sent tag and no other', (
      tester,
    ) async {
      await pumpApp(tester, clock: _at(sentDay));
      await openDevotional(tester);

      expect(find.byType(FsTag), findsOneWidget);
      expect(find.text('SENT: TAKE IT TO SOMEONE'), findsOneWidget);
      expect(tester.widget<FsTag>(_sentTag).tone, FsTagTone.accent);
      expect(_spiritTag, findsNothing);
    });

    for (final (name, themeMode, color) in <(String, ThemeMode, Color)>[
      ('dark', ThemeMode.dark, FsColors.dark.accent),
      ('light', ThemeMode.light, FsColors.ringValue),
    ]) {
      testWidgets('the Sent tag is bright orange on the dark header, $name', (
        tester,
      ) async {
        await pumpApp(tester, themeMode: themeMode, clock: _at(sentDay));
        await openDevotional(tester);

        final words = tester.widget<Text>(
          find.text('SENT: TAKE IT TO SOMEONE'),
        );
        expect(words.style?.color, color);
        // Never the light theme's dark orange, which is hard to read there.
        expect(words.style?.color, isNot(FsColors.light.accent));
      });
    }

    testWidgets('a Spirit-led reading shows the Spirit-led tag and no other', (
      tester,
    ) async {
      await pumpApp(tester, clock: _at(spiritDay));
      await openDevotional(tester);

      expect(find.byType(FsTag), findsOneWidget);
      expect(find.text('SPIRIT-LED'), findsOneWidget);
      expect(tester.widget<FsTag>(_spiritTag).tone, FsTagTone.gold);
      expect(_sentTag, findsNothing);
      expect(find.text(spirit.headline!.toUpperCase()), findsOneWidget);
    });

    testWidgets('a reading with no tag shows none', (tester) async {
      await pumpApp(tester, clock: _at(plainDay));
      await openDevotional(tester);

      expect(find.byType(FsTag), findsNothing);
      expect(find.text(plain.headline!.toUpperCase()), findsOneWidget);
      // The line about the month follows the headline directly, 10 below.
      expect(
        tester.getRect(find.text(plain.monthTag)).top -
            tester.getRect(find.text(plain.headline!.toUpperCase())).bottom,
        moreOrLessEquals(10, epsilon: 0.5),
      );
    });

    testWidgets('a tag is words to read: tapping it does nothing', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final app = await pumpApp(tester, clock: _at(sentDay));
      final days = app.store.days as TestDayRepository;
      await openDevotional(tester);

      expect(
        tester.getSemantics(find.text('SENT: TAKE IT TO SOMEONE')),
        isSemantics(
          label: 'Sent: take it to someone',
          isButton: false,
          hasTapAction: false,
        ),
      );
      await tester.tap(_sentTag);
      await tester.pumpAndSettle();

      expect(find.byType(DevotionalPage), findsOneWidget);
      expect(days.saveAttempts, 0);
      expect((await app.savedDay(tester, sentDay)).items, isEmpty);
      handle.dispose();
    });

    testWidgets(
      'a reading with no headline, tag or "In Jesus" text shows none of them',
      (tester) async {
        final file =
            json.decode(
                  File(DevotionalLibrary.devotionalsAsset).readAsStringSync(),
                )
                as Map<String, dynamic>;
        ((file['days'] as Map<String, dynamic>)[sentDay.monthDayKey]
              as Map<String, dynamic>)
          ..remove('headline')
          ..remove('jesus')
          ..remove('sent');
        await pumpApp(
          tester,
          clock: _at(sentDay),
          library: DevotionalLibrary.fromJson(
            devotionals: json.encode(file),
            esvVerses: File(DevotionalLibrary.esvAsset).readAsStringSync(),
          ),
        );
        await openDevotional(tester);

        expect(find.text(sent.headline!.toUpperCase()), findsNothing);
        expect(find.byType(FsTag), findsNothing);
        expect(find.text('// IN JESUS'), findsNothing);
        expect(_inJesus, findsNothing);
        // The rest of the reading is there, and Amen works as it did.
        expect(find.text('February 7'), findsOneWidget);
        expect(find.text('// REFLECT'), findsOneWidget);
        expect(_verse(tester), sent.bsbText);
        await scrollReaderToEnd(tester);
        expect(_amen(tester).onPressed, isNotNull);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('Amen still waits for the end of the longest reading', (
      tester,
    ) async {
      final longest = library.all.reduce(
        (a, b) => _length(a) >= _length(b) ? a : b,
      );
      final day = _dateOf(longest);
      final app = await pumpApp(tester, clock: _at(day));
      final days = app.store.days as TestDayRepository;
      await openDevotional(tester);

      final position = readerPosition(tester);
      expect(position.pixels, 0);
      // Longer than the screen by more than the 220 points every reading
      // is given: there is real text to scroll through.
      expect(position.maxScrollExtent, greaterThan(220));
      expect(_amen(tester).onPressed, isNull);

      // Past "In Jesus" and most of the way down is not the end.
      position.jumpTo(position.maxScrollExtent - 40);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(_inJesus).bottom,
        lessThan(tester.getRect(find.byType(DevotionalPage)).bottom),
      );
      expect(_amen(tester).onPressed, isNull);
      expect(_amen(tester).label, 'Scroll to the bottom to say Amen');
      await tester.tap(amenButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(days.saveAttempts, 0);

      // The end is.
      position.jumpTo(position.maxScrollExtent - 8);
      await tester.pumpAndSettle();
      expect(_amen(tester).label, 'Amen');
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      expect(find.byType(TodayPage), findsOneWidget);
      expect((await app.savedDay(tester, day)).isDone(_devotional), isTrue);
    });
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

  group('the headline and the tags at larger text sizes', () {
    Devotional longest(Iterable<Devotional> readings) => readings.reduce(
      (a, b) => a.headline!.length >= b.headline!.length ? a : b,
    );
    // The longest headline of all, and the longest that carries each tag.
    final cases = <(String, Devotional)>[
      ('the longest headline', longest(library.all)),
      (
        'a Sent tag',
        longest(library.all.where((r) => r.tags.contains(ReadingTag.sent))),
      ),
      (
        'a Spirit-led tag',
        longest(
          library.all.where((r) => r.tags.contains(ReadingTag.spiritLed)),
        ),
      ),
    ];

    for (final (size, scale) in <(Size, double)>[
      (phone, 1.3),
      (phone, 2.0),
      (const Size(320, 568), 1.3),
    ]) {
      for (final (name, shown) in cases) {
        testWidgets('$name fits at $scale times the text size on a '
            '${size.width.toInt()} by ${size.height.toInt()} screen', (
          tester,
        ) async {
          await pumpApp(
            tester,
            size: size,
            textScale: scale,
            clock: _at(_dateOf(shown)),
          );
          await openDevotional(tester);
          expect(tester.takeException(), isNull);

          // The headline and every tag stay inside the page margins, and
          // no line of their words is cut off.
          final page = tester.getRect(find.byType(DevotionalPage));
          final parts = <Finder>[
            find.text(shown.headline!.toUpperCase()),
            for (final tag in shown.tags) find.text(tag.label.toUpperCase()),
            find.byType(FsTag),
          ];
          for (final part in parts) {
            expect(part, findsOneWidget);
            final rect = tester.getRect(part);
            expect(rect.left, greaterThanOrEqualTo(page.left + 16));
            expect(rect.right, lessThanOrEqualTo(page.right - 16));
            final drawn = paragraphOf(tester, part);
            expect(drawn.didExceedMaxLines, isFalse);
            expect(drawn.size.width, greaterThan(0));
            // Its lines put back together are the words, all of them.
            expect(linesOf(tester, part).join(' '), drawn.text.toPlainText());
          }
          expect(find.byType(FsTag), findsNWidgets(shown.tags.length));

          await scrollReaderToEnd(tester);
          expect(tester.takeException(), isNull);
          expect(_amen(tester).onPressed, isNotNull);
        });
      }
    }
  });
}
