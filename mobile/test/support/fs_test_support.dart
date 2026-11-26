import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:forged_and_sent/src/features/journal/data/memory_journal_repository.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/features/settings/data/settings_repository.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';
import 'package:forged_and_sent/src/features/today/data/today_content.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:forged_and_sent/src/features/workout/data/memory_workout_repository.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_library.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';

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

/// The app's bundled workout program, movement names and workout prayer,
/// read the same way.
WorkoutLibrary loadBundledWorkoutLibrary() => WorkoutLibrary.fromJson(
  workouts: _asset(WorkoutLibrary.workoutsAsset),
  movements: _asset(WorkoutLibrary.movementsAsset),
  prayer: _asset(WorkoutLibrary.prayerAsset),
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

/// The in-memory journal standing in for the phone's database in a widget
/// test: durable, as the Drift store is, and it can be told to fail.
class TestJournalRepository extends MemoryJournalRepository {
  /// When true, every save and delete throws, as a full or broken disk
  /// would. Nothing is stored.
  bool failWrites = false;

  /// How many changes the screens have tried to store.
  int attempts = 0;

  /// Every change the screens sent, in order, stored or not.
  final List<JournalChange> sent = <JournalChange>[];

  /// When true, a change is stored and then the call throws, as when the
  /// answer from the database is lost after the transaction committed.
  bool throwAfterStoring = false;

  /// When set, a change waits here before it is stored, so a test can look
  /// at the screen while a save is on its way.
  Completer<void>? gate;

  @override
  bool get durable => true;

  @override
  Future<JournalOutcome> apply(JournalChange change) async {
    attempts++;
    sent.add(change);
    if (gate != null) await gate!.future;
    if (failWrites) throw StateError('The test refused this save.');
    final outcome = await super.apply(change);
    if (throwAfterStoring) throw StateError('The answer was lost.');
    return outcome;
  }
}

/// The in-memory workout store of a widget test. Like [TestDayRepository]
/// it reports itself as durable, and it can be told to fail.
class TestWorkoutRepository extends MemoryWorkoutRepository {
  TestWorkoutRepository(super.days);

  /// When true, every change to a set or a rest timer, and every start,
  /// throws, as a full or broken disk would.
  bool failWrites = false;

  /// When true, a day's session cannot be read: the stream the screens
  /// listen to fails, and so does a single read, as they would on a broken
  /// database file.
  bool failSessionReads = false;

  Completer<void>? _held;

  /// From now on a change to a set waits, as it would behind a slow disk,
  /// until [release] is called.
  void hold() => _held = Completer<void>();

  /// Lets every waiting change through.
  void release() {
    _held?.complete();
    _held = null;
  }

  @override
  bool get durable => true;

  /// When true, the next change to reach the store throws, and the ones
  /// after it are stored again.
  bool failNextWrite = false;

  void _refuse() {
    if (failWrites || failNextWrite) {
      failNextWrite = false;
      throw StateError('The test refused this save.');
    }
  }

  @override
  Stream<WorkoutSession?> watchSession(String ownerId, LocalDate day) =>
      failSessionReads
      ? Stream<WorkoutSession?>.error(StateError('The test refused this read.'))
      : super.watchSession(ownerId, day);

  @override
  Future<WorkoutSession?> readSession(String ownerId, LocalDate day) async {
    if (failSessionReads) throw StateError('The test refused this read.');
    return super.readSession(ownerId, day);
  }

  @override
  Future<WorkoutSession> startSession(NewSession session) async {
    _refuse();
    return super.startSession(session);
  }

  @override
  Future<void> setReps(String setId, int? reps) async {
    await _held?.future;
    _refuse();
    return super.setReps(setId, reps);
  }

  /// Finishing waits behind a slow disk too. It is not refused by
  /// [failWrites]: a finish fails when the day's box cannot be checked,
  /// which the day store decides.
  @override
  Future<FinishOutcome> finishSession(String sessionId, DateTime now) async {
    await _held?.future;
    return super.finishSession(sessionId, now);
  }

  @override
  Future<void> setWeight(String setId, double? weightLb) async {
    await _held?.future;
    _refuse();
    return super.setWeight(setId, weightLb);
  }

  @override
  Future<void> setTicked(String setId, {required bool ticked}) async {
    await _held?.future;
    _refuse();
    return super.setTicked(setId, ticked: ticked);
  }

  @override
  Future<bool> addSet(String exerciseId, {required String setId}) async {
    await _held?.future;
    _refuse();
    return super.addSet(exerciseId, setId: setId);
  }

  @override
  Future<bool> removeSet(String setId) async {
    await _held?.future;
    _refuse();
    return super.removeSet(setId);
  }

  @override
  Future<void> setRest(
    String exerciseId, {
    required int baseSeconds,
    DateTime? endsAtUtc,
    int? pausedSeconds,
  }) async {
    _refuse();
    return super.setRest(
      exerciseId,
      baseSeconds: baseSeconds,
      endsAtUtc: endsAtUtc,
      pausedSeconds: pausedSeconds,
    );
  }
}

/// The box under the reading that journal text is typed into.
final Finder journalBox = find.descendant(
  of: find.byKey(const ValueKey<String>('fs-journal-box')),
  matching: find.byType(TextField),
);

/// "Save to my journal", under the reading.
final Finder journalSave = find.byKey(
  const ValueKey<String>('fs-journal-save'),
);

/// The line under that button: saved, failed or "write something first".
final Finder journalMessage = find.byKey(
  const ValueKey<String>('fs-journal-message'),
);

/// The box on the entry page.
final Finder entryBox = find.descendant(
  of: find.byKey(const ValueKey<String>('fs-entry-box')),
  matching: find.byType(TextField),
);

final Finder entrySave = find.byKey(const ValueKey<String>('fs-entry-save'));
final Finder entryDelete = find.byKey(
  const ValueKey<String>('fs-entry-delete'),
);
final Finder entryMessage = find.byKey(
  const ValueKey<String>('fs-entry-message'),
);

/// Types [text] into [field], scrolling it into view first.
Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
  await tester.ensureVisible(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

/// Taps [target], scrolling it into view first.
Future<void> tapVisible(WidgetTester tester, Finder target) async {
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
  await tester.tap(target);
  await tester.pumpAndSettle();
}

/// Opens the Journal page: Today, Settings, "Open my journal".
Future<void> openJournal(WidgetTester tester) async {
  await openSettings(tester);
  await tapVisible(
    tester,
    find.byKey(const ValueKey<String>('fs-settings-journal')),
  );
}

/// Writes [text] under today's reading and taps "Save to my journal".
/// Leaves the reading open.
Future<void> writeItDown(WidgetTester tester, String text) async {
  await openDevotional(tester);
  await typeInto(tester, journalBox, text);
  await tapVisible(tester, journalSave);
}

/// A store for a widget test. Its owner is `local-test`.
LocalStore testStore({
  TestDayRepository? days,
  TestJournalRepository? journal,
}) {
  final dayStore = days ?? TestDayRepository();
  return LocalStore(
    ownerId: 'local-test',
    days: dayStore,
    journal: journal ?? TestJournalRepository(),
    settings: MemorySettingsRepository(),
    workouts: TestWorkoutRepository(dayStore),
    close: () async {},
  );
}

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

  /// The journal entries the store holds, newest first, read the same way.
  Future<List<JournalEntry>> savedJournal(WidgetTester tester) async =>
      (await tester.runAsync(() => store.journal.watchEntries(ownerId).first))!;

  /// The days the store holds a done box for, read the same way.
  Future<Map<LocalDate, Set<String>>> savedDoneDays(
    WidgetTester tester,
  ) async =>
      (await tester.runAsync(() => store.days.watchDoneByDay(ownerId).first))!;

  /// The workout session the store holds for [day], read the same way.
  /// Null if none was started that day.
  Future<WorkoutSession?> savedSession(WidgetTester tester, LocalDate day) =>
      tester.runAsync<WorkoutSession?>(
        () => store.workouts.watchSession(ownerId, day).first,
      );

  /// Every completion event the store holds for one box of one day.
  Future<List<CompletionEvent>> savedEvents(
    WidgetTester tester,
    LocalDate day,
    String item,
  ) async =>
      (await tester.runAsync(() => store.days.eventsFor(ownerId, day, item)))!;
}

/// Stops the app and starts it again on the same store, as the phone does
/// after it killed the app: nothing the screens held in memory survives,
/// only what the store kept.
Future<AppHarness> relaunchApp(
  WidgetTester tester,
  AppHarness app, {
  ThemeMode themeMode = ThemeMode.dark,
}) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  return pumpApp(
    tester,
    store: app.store,
    clock: app.clock,
    themeMode: themeMode,
  );
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
        workoutLibraryProvider.overrideWith(
          (ref) async => loadBundledWorkoutLibrary(),
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

/// The first Monday of the default plan in most workout tests: a lifting
/// day, "Full Body A: Back Squat", at six in the evening.
final DateTime liftingEvening = DateTime(2026, 11, 9, 18);

/// The row on Train that opens today's workout.
final Finder trainTodayRow = find.byKey(
  const ValueKey<String>('fs-train-today'),
);

final Finder startWorkoutButton = find.byKey(
  const ValueKey<String>('fs-start-workout'),
);
final Finder finishWorkoutButton = find.byKey(
  const ValueKey<String>('fs-finish-workout'),
);
final Finder prayerAmenButton = find.byKey(
  const ValueKey<String>('fs-prayer-amen'),
);
final Finder prayerNotNowButton = find.byKey(
  const ValueKey<String>('fs-prayer-not-now'),
);
final Finder workoutClock = find.byKey(
  const ValueKey<String>('fs-workout-clock'),
);
final Finder lockedSummary = find.byKey(
  const ValueKey<String>('fs-workout-locked'),
);

/// The reps (or seconds) box of one set, by where its exercise and the set
/// stand on the page, both from 0.
Finder repsField(int exercise, int set) =>
    find.byKey(ValueKey<String>('fs-reps-$exercise-$set'));

/// The weight box of one set.
Finder weightField(int exercise, int set) =>
    find.byKey(ValueKey<String>('fs-weight-$exercise-$set'));

/// "Add set", under the rows of one exercise.
Finder addSetButton(int exercise) =>
    find.byKey(ValueKey<String>('fs-add-set-$exercise'));

/// "Remove", under a row he added while it is empty.
Finder removeSetButton(int exercise, int set) =>
    find.byKey(ValueKey<String>('fs-remove-set-$exercise-$set'));

/// Opens today's workout page: the Train tab, then today's row.
Future<void> openTodaysWorkout(WidgetTester tester) async {
  await openTab(tester, 'Train');
  await tester.ensureVisible(trainTodayRow);
  await tester.pumpAndSettle();
  await tester.tap(trainTodayRow);
  await tester.pumpAndSettle();
}

/// The workout page's own scroll view.
Finder get workoutScrollable => find
    .descendant(of: find.byType(WorkoutPage), matching: find.byType(Scrollable))
    .first;

/// Brings a widget of the workout page into view. The page builds only
/// what is near the screen, so this scrolls down until the widget exists.
Future<void> showOnWorkoutPage(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // It may be above what is on screen as well as below: start at the top.
    tester.state<ScrollableState>(workoutScrollable).position.jumpTo(0);
    await tester.pumpAndSettle();
  }
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 150, scrollable: workoutScrollable);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

/// Taps Start workout and answers the workout prayer with Amen.
Future<void> startWorkout(WidgetTester tester) async {
  await tester.ensureVisible(startWorkoutButton);
  await tester.pumpAndSettle();
  await tester.tap(startWorkoutButton);
  await tester.pumpAndSettle();
  // With large text the prayer is taller than the screen and Amen is
  // below the fold.
  await tester.ensureVisible(prayerAmenButton);
  await tester.pumpAndSettle();
  await tester.tap(prayerAmenButton);
  await tester.pumpAndSettle();
}

/// Types [text] into a number box of the workout page.
Future<void> typeNumber(WidgetTester tester, Finder field, String text) async {
  await showOnWorkoutPage(tester, field);
  await tester.enterText(field, text);
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

/// What draws the one text inside [widget]. A `Text` with a semantics
/// label is not drawn by its own render object but by the `RichText` it
/// builds, so this looks for that.
RenderParagraph paragraphOf(WidgetTester tester, Finder widget) =>
    tester.renderObject<RenderParagraph>(
      find.descendant(of: widget, matching: find.byType(RichText)),
    );

/// The words on each line of the text found by [text], from the top line
/// down, as it is drawn.
List<String> linesOf(WidgetTester tester, Finder text) {
  final paragraph = paragraphOf(tester, text);
  final plain = paragraph.text.toPlainText();
  final lines = <int, StringBuffer>{};
  for (var i = 0; i < plain.length; i++) {
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: i, extentOffset: i + 1),
    );
    if (boxes.isEmpty) continue;
    // Every letter of a line has the same top.
    lines
        .putIfAbsent((boxes.first.top * 10).round(), StringBuffer.new)
        .write(plain[i]);
  }
  return <String>[for (final line in lines.values) line.toString().trim()];
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
