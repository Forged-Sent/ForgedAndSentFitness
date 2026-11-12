import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/core/clock.dart';
import 'package:forged_and_sent/src/core/event_id.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/features/devotional/data/devotional_library.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/settings/data/settings_repository.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';
import 'package:forged_and_sent/src/features/today/data/today_content.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

/// The size the prototype reference screenshots were taken at.
const Size phone = Size(390, 844);

/// A Tuesday morning, the date on the review's reference screenshots.
final DateTime referenceTime = DateTime(2026, 11, 10, 7, 30);

/// A clock a test sets and moves.
class TestClock implements Clock {
  TestClock([DateTime? time]) : time = time ?? referenceTime;

  DateTime time;

  @override
  DateTime now() => time;
}

/// Loads the bundled typefaces, so text has its real width and shape.
/// Without this, tests draw every letter as a square.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

String _asset(String path) => File(path).readAsStringSync();

/// The app's bundled readings, read from the asset files themselves.
///
/// A widget test runs on a fake clock, where the asset bundle's way of
/// decoding a large file never finishes. Reading the files directly gives
/// the tests the real content; `bundled_content_test.dart` checks that the
/// bundle serves the same files.
DevotionalLibrary loadBundledLibrary() => DevotionalLibrary.fromJson(
  devotionals: _asset(DevotionalLibrary.devotionalsAsset),
  esvVerses: _asset(DevotionalLibrary.esvAsset),
);

/// The app's bundled boxes and mission lines, read the same way.
TodayContent loadBundledTodayContent() => TodayContent.fromJson(
  tasks: _asset(TodayContent.tasksAsset),
  missions: _asset(TodayContent.missionsAsset),
);

/// The in-memory store standing in for the phone's database in a widget
/// test: it reports itself as durable, as the Drift store does, so the
/// screens look as they do on a phone. It can also be told to fail.
class TestDayRepository extends MemoryDayRepository {
  /// When true, every save throws, as a full or broken disk would.
  bool failWrites = false;

  /// How many events the screens have tried to save.
  int saveAttempts = 0;

  @override
  bool get durable => true;

  @override
  Future<RecordOutcome> record(CompletionEvent event) {
    saveAttempts++;
    if (failWrites) throw StateError('The test refused this save.');
    return super.record(event);
  }
}

/// A store for a widget test. Its owner is `local-test`.
LocalStore testStore({TestDayRepository? days}) => LocalStore(
  ownerId: 'local-test',
  days: days ?? TestDayRepository(),
  settings: MemorySettingsRepository(),
  close: () async {},
);

/// What a test holds on to after starting the app.
class AppHarness {
  AppHarness({required this.store, required this.clock});

  final LocalStore store;
  final TestClock clock;

  String get ownerId => store.ownerId;

  /// What the store holds for [day], read outside the test's fake clock.
  ///
  /// A widget test runs on a fake clock. Taking the first value of a
  /// stream there never finishes, so the read is done in real time.
  Future<DayRecord> savedDay(WidgetTester tester, LocalDate day) async =>
      (await tester.runAsync(() => store.days.watchDay(ownerId, day).first))!;

  /// The days the store holds a done box for, read the same way.
  Future<Map<LocalDate, Set<String>>> savedDoneDays(
    WidgetTester tester,
  ) async =>
      (await tester.runAsync(() => store.days.watchDoneByDay(ownerId).first))!;
}

/// Starts the app on a screen of [size] and waits for it to settle.
///
/// The app gets a [testStore], a clock fixed at [referenceTime] and event
/// ids `e1`, `e2`, ... unless the test passes its own.
Future<AppHarness> pumpApp(
  WidgetTester tester, {
  Size size = phone,
  ThemeMode themeMode = ThemeMode.dark,
  double textScale = 1,
  String mode = 'preview',
  String? startupError,
  bool storageFailed = false,
  LocalStore? store,
  TestClock? clock,
  DevotionalLibrary? library,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  final harness = AppHarness(
    store: store ?? testStore(),
    clock: clock ?? TestClock(),
  );
  var issued = 0;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(harness.store),
        clockProvider.overrideWithValue(harness.clock),
        eventIdProvider.overrideWithValue(() => 'e${++issued}'),
        devotionalLibraryProvider.overrideWith(
          (ref) async => library ?? loadBundledLibrary(),
        ),
        todayContentProvider.overrideWith(
          (ref) async => loadBundledTodayContent(),
        ),
      ],
      child: ForgedSentApp(
        mode: mode,
        startupError: startupError,
        storageFailed: storageFailed,
        themeMode: themeMode,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return harness;
}

/// Decodes the hero photograph, which a test does not do on its own, so a
/// golden image shows it.
Future<void> loadHeroPhoto(WidgetTester tester) async {
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage(FsHeroHeader.photoAsset),
      tester.element(find.byType(MaterialApp)),
    );
  });
  await tester.pumpAndSettle();
}

/// The tab with [label] in the bottom bar.
Finder tab(String label) =>
    find.byKey(ValueKey<String>('fs-tab-${label.toLowerCase()}'));

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(tab(label));
  await tester.pumpAndSettle();
}

/// A round button in the hero header on screen.
Finder heroButton(FsHeroActionKind kind) =>
    find.byKey(ValueKey<String>('fs-hero-${kind.name}'));

/// The row of one of Today's boxes, by its id in the task list.
Finder box(String id) => find.byKey(ValueKey<String>('fs-box-$id'));

/// The Amen button at the foot of the reading, in any of its states.
final Finder amenButton = find.byKey(const ValueKey<String>('fs-amen'));

/// Opens Settings from Today's round profile button.
Future<void> openSettings(WidgetTester tester) async {
  await tester.tap(heroButton(FsHeroActionKind.profile));
  await tester.pumpAndSettle();
}

/// Opens the developer status page: Today, Settings, Build status.
Future<void> openStatusPage(WidgetTester tester) async {
  await openSettings(tester);
  await tester.ensureVisible(find.text('BUILD STATUS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('BUILD STATUS'));
  await tester.pumpAndSettle();
}

/// Today's own scroll view.
Finder get todayScrollable => find
    .descendant(of: find.byType(TodayPage), matching: find.byType(Scrollable))
    .first;

/// Brings one of Today's boxes into view. On a small screen or with large
/// text the card of boxes starts below what the list has built, so this
/// scrolls down until the box exists, then makes it fully visible.
Future<void> showBox(WidgetTester tester, String id) async {
  if (box(id).evaluate().isEmpty) {
    await tester.scrollUntilVisible(box(id), 120, scrollable: todayScrollable);
  }
  await tester.ensureVisible(box(id));
  await tester.pumpAndSettle();
}

/// Scrolls Today back to its header.
Future<void> scrollTodayToTop(WidgetTester tester) async {
  tester.state<ScrollableState>(todayScrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
}

/// Opens today's reading from the devotional box on Today.
Future<void> openDevotional(WidgetTester tester) async {
  await showBox(tester, 't_devo');
  await tester.tap(box('t_devo'));
  await tester.pumpAndSettle();
}

/// Reads the reading to its end and says Amen, which returns to Today.
Future<void> completeDevotional(WidgetTester tester) async {
  await openDevotional(tester);
  await scrollReaderToEnd(tester);
  await tester.tap(amenButton);
  await tester.pumpAndSettle();
}

/// The reading's scroll position.
ScrollPosition readerPosition(WidgetTester tester) => tester
    .state<ScrollableState>(
      find
          .descendant(
            of: find.byType(DevotionalPage),
            matching: find.byType(Scrollable),
          )
          .first,
    )
    .position;

/// Scrolls the reading to its end, as a member who has read it would.
Future<void> scrollReaderToEnd(WidgetTester tester) async {
  final position = readerPosition(tester);
  position.jumpTo(position.maxScrollExtent);
  await tester.pumpAndSettle();
}

/// Sends the app to the background and brings it back, as the phone does
/// when the member leaves and returns.
Future<void> backgroundAndResume(WidgetTester tester) async {
  for (final state in <AppLifecycleState>[
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ]) {
    tester.binding.handleAppLifecycleStateChanged(state);
  }
  await tester.pumpAndSettle();
}

/// Activates [widget] the way TalkBack and VoiceOver do: through its node in
/// the semantics tree, with no pointer on the screen. Fails if that node
/// offers no tap action. The test must have called `ensureSemantics` first.
Future<void> semanticsTap(WidgetTester tester, Finder widget) async {
  final node = tester.semantics.find(widget);
  tester.semantics.tap(
    find.semantics.byPredicate((SemanticsNode other) => other.id == node.id),
  );
  await tester.pumpAndSettle();
}

/// What Android's back button or gesture sends.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
