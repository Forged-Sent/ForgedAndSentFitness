import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/features/devotional/domain/devotional.dart';
import 'package:forged_and_sent/src/features/settings/data/settings_repository.dart';
import 'package:forged_and_sent/src/features/settings/presentation/settings_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

final Finder _switch = find.byKey(const ValueKey<String>('fs-preview-points'));

/// The line that says a change to the switch was not saved.
final Finder _notSaved = find.byKey(
  const ValueKey<String>('fs-preview-points-not-saved'),
);

bool _switchOn(WidgetTester tester) => tester.widget<Switch>(_switch).value;

/// A settings store that can refuse to save, as a full or broken disk
/// would, and can hold a save until the test lets it go.
class _TestSettings extends MemorySettingsRepository {
  _TestSettings({super.showPreviewPoints});

  /// When true, every save throws.
  bool failWrites = false;

  /// How many saves the screen has asked for.
  int saveAttempts = 0;

  Completer<void>? _held;

  /// From now on a save waits until [release].
  void hold() => _held = Completer<void>();

  void release() {
    _held?.complete();
    _held = null;
  }

  @override
  Future<void> setShowPreviewPoints(bool show) async {
    saveAttempts++;
    await _held?.future;
    if (failWrites) throw StateError('The test refused this save.');
    return super.setShowPreviewPoints(show);
  }
}

/// A store for a widget test whose settings are [settings].
LocalStore _storeWith(_TestSettings settings) => LocalStore(
  ownerId: 'local-test',
  days: TestDayRepository(),
  journal: TestJournalRepository(),
  settings: settings,
  close: () async {},
);

/// What the store holds for the switch, read outside the test's fake clock.
Future<bool> _stored(WidgetTester tester, _TestSettings settings) async =>
    (await tester.runAsync(() => settings.watchShowPreviewPoints().first))!;

Future<void> _backToToday(WidgetTester tester) async {
  await systemBack(tester);
  expect(find.byType(TodayPage), findsOneWidget);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the profile button in Today\'s header opens Settings', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSettings(tester);

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Points'), findsOneWidget);
    expect(find.text('Scripture'), findsOneWidget);
    expect(find.text('This build'), findsOneWidget);
    // Both credit lines, word for word.
    expect(find.text(ScriptureNotices.bsb), findsOneWidget);
    expect(find.text(ScriptureNotices.esv), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('‹ BACK'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
  });

  group('the preview points switch (decision Q5)', () {
    testWidgets('is off by default, and Today shows no point values', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.textContaining('PTS'), findsNothing);

      await openSettings(tester);
      expect(_switchOn(tester), isFalse);
      // What the values are is said beside the switch.
      expect(find.textContaining('Preview, not official.'), findsOneWidget);
    });

    testWidgets('turned on, Today shows the prototype\'s values, labelled', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSettings(tester);

      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(_switchOn(tester), isTrue);

      await _backToToday(tester);
      await showBox(tester, 't_devo');
      expect(find.text('POINTS: PREVIEW, NOT OFFICIAL'), findsOneWidget);
      expect(tester.widget<FsBoxRow>(box('t_devo')).points, '+2 pts');
      expect(tester.widget<FsBoxRow>(box('t_workout')).points, '+3 pts');
      expect(tester.widget<FsBoxRow>(box('t_steps')).points, '+1 pt');
      // Values per box only. Nothing adds them up.
      expect(find.textContaining('WEEK'), findsNothing);
      expect(find.textContaining('TOTAL'), findsNothing);

      // And off again hides them.
      await scrollTodayToTop(tester);
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      await _backToToday(tester);
      expect(find.text('POINTS: PREVIEW, NOT OFFICIAL'), findsNothing);
      expect(tester.widget<FsBoxRow>(box('t_devo')).points, isNull);
    });

    testWidgets('is kept in the member\'s store', (tester) async {
      final app = await pumpApp(tester);
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();

      final stored = await tester.runAsync(
        () => app.store.settings.watchShowPreviewPoints().first,
      );
      expect(stored, isTrue);
    });

    testWidgets('a screen reader hears the switch with its name', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);
      await semanticsTap(tester, heroButton(FsHeroActionKind.profile));
      expect(find.byType(SettingsPage), findsOneWidget);

      expect(
        tester.getSemantics(_switch),
        isSemantics(
          label: 'Show point values',
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('a change to the switch that cannot be saved (board row: a setting '
      'that cannot be saved says so)', () {
    testWidgets('says so, and the switch keeps showing what is saved', (
      tester,
    ) async {
      final settings = _TestSettings()..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);
      expect(_notSaved, findsNothing);

      await tester.tap(_switch);
      await tester.pumpAndSettle();

      // He is told, in words, and nothing was thrown past the page.
      expect(tester.takeException(), isNull);
      expect(settings.saveAttempts, 1);
      expect(
        tester.widget<Text>(_notSaved).data,
        'That did not save. Try again.',
      );
      // The switch is where the store has it: still off.
      expect(_switchOn(tester), isFalse);
      expect(await _stored(tester, settings), isFalse);

      // Today agrees with the store: no point values.
      await _backToToday(tester);
      await showBox(tester, 't_devo');
      expect(find.text('POINTS: PREVIEW, NOT OFFICIAL'), findsNothing);
      expect(tester.widget<FsBoxRow>(box('t_devo')).points, isNull);
    });

    testWidgets('trying again saves it, and the line goes away', (
      tester,
    ) async {
      final settings = _TestSettings()..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(_notSaved, findsOneWidget);

      settings.failWrites = false;
      await tester.tap(_switch);
      await tester.pumpAndSettle();

      expect(_notSaved, findsNothing);
      expect(_switchOn(tester), isTrue);
      expect(await _stored(tester, settings), isTrue);
      expect(settings.saveAttempts, 2);
    });

    testWidgets('turning it off fails the same way: it stays on', (
      tester,
    ) async {
      final settings = _TestSettings(showPreviewPoints: true)
        ..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);
      expect(_switchOn(tester), isTrue);

      await tester.tap(_switch);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(_notSaved, findsOneWidget);
      expect(_switchOn(tester), isTrue);
      expect(await _stored(tester, settings), isTrue);
      // Today still shows the values, as the store says.
      await _backToToday(tester);
      await showBox(tester, 't_devo');
      expect(find.text('POINTS: PREVIEW, NOT OFFICIAL'), findsOneWidget);
    });

    testWidgets('the line is not left over when he comes back to Settings', (
      tester,
    ) async {
      final settings = _TestSettings()..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(_notSaved, findsOneWidget);

      await _backToToday(tester);
      await openSettings(tester);

      expect(_notSaved, findsNothing);
      expect(_switchOn(tester), isFalse);
    });

    testWidgets('a second tap while the first is being saved sends nothing '
        'more', (tester) async {
      final settings = _TestSettings()..hold();
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);

      await tester.tap(_switch);
      await tester.pump();
      await tester.tap(_switch);
      await tester.pump();
      expect(settings.saveAttempts, 1);
      // Nothing is claimed while the save is on its way, and the switch
      // says that it cannot be changed just now.
      expect(_switchOn(tester), isFalse);
      expect(_notSaved, findsNothing);
      expect(tester.widget<Switch>(_switch).onChanged, isNull);

      settings.release();
      await tester.pumpAndSettle();
      expect(_switchOn(tester), isTrue);
      expect(tester.widget<Switch>(_switch).onChanged, isNotNull);
      expect(await _stored(tester, settings), isTrue);
      expect(settings.saveAttempts, 1);
    });

    testWidgets('the line stays while he tries again, until the store has '
        'the change', (tester) async {
      final settings = _TestSettings()..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(_notSaved, findsOneWidget);

      // The second try is slow. Nothing has been saved yet, so the line
      // that says so is still there.
      settings
        ..failWrites = false
        ..hold();
      await tester.tap(_switch);
      await tester.pump();
      expect(settings.saveAttempts, 2);
      expect(_notSaved, findsOneWidget);
      expect(_switchOn(tester), isFalse);

      settings.release();
      await tester.pumpAndSettle();
      expect(_notSaved, findsNothing);
      expect(_switchOn(tester), isTrue);
      expect(await _stored(tester, settings), isTrue);
    });

    testWidgets('a second failure leaves the line where it was', (
      tester,
    ) async {
      final settings = _TestSettings()..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      await tester.tap(_switch);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(settings.saveAttempts, 2);
      expect(_notSaved, findsOneWidget);
      expect(_switchOn(tester), isFalse);
      expect(tester.widget<Switch>(_switch).onChanged, isNotNull);
    });

    testWidgets('a screen reader is told when the change is not saved', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final settings = _TestSettings()..failWrites = true;
      await pumpApp(tester, store: _storeWith(settings));
      await openSettings(tester);

      await semanticsTap(tester, _switch);

      expect(
        tester.getSemantics(_notSaved),
        isSemantics(label: 'That did not save. Try again.', isLiveRegion: true),
      );
      // The switch is still announced with its name, and still off.
      expect(
        tester.getSemantics(_switch),
        isSemantics(
          label: 'Show point values',
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });

    for (final (size, scale) in <(Size, double)>[
      (phone, 2.0),
      (const Size(320, 568), 1.3),
    ]) {
      testWidgets('nothing overflows with the line showing, at $scale times '
          'the text size on a ${size.width.toInt()}-wide screen', (
        tester,
      ) async {
        final settings = _TestSettings()..failWrites = true;
        await pumpApp(
          tester,
          size: size,
          textScale: scale,
          store: _storeWith(settings),
        );
        await openSettings(tester);
        await tester.ensureVisible(_switch);
        await tester.pumpAndSettle();
        await tester.tap(_switch);
        await tester.pumpAndSettle();

        expect(_notSaved, findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('BUILD STATUS'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets('Build status is reached from Settings', (tester) async {
    await pumpApp(tester);
    await openStatusPage(tester);

    expect(find.byType(FoundationHomeScreen), findsOneWidget);
    expect(
      find.text('Preview mode. No Firebase cloud connection configured.'),
      findsOneWidget,
    );
  });

  testWidgets('storage that could not be opened is explained first', (
    tester,
  ) async {
    await pumpApp(tester, storageFailed: true);

    // The explanation is the first thing on screen.
    expect(find.byType(FoundationHomeScreen), findsOneWidget);
    expect(
      find.text(
        'Local storage could not be opened. Nothing is saved on this device.',
      ),
      findsOneWidget,
    );
    expect(find.text('Close the app and open it again.'), findsOneWidget);
    // It is not mistaken for an emulator problem.
    expect(find.textContaining('emulator'), findsNothing);
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets('nothing overflows at $scale times the text size', (
      tester,
    ) async {
      await pumpApp(tester, textScale: scale);
      await openSettings(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('BUILD STATUS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
