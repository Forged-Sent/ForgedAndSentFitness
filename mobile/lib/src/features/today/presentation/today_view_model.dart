import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/local_store.dart';
import '../../../core/clock.dart';
import '../../../core/event_id.dart';
import '../../../core/local_date.dart';
import '../../devotional/data/devotional_library.dart';
import '../../devotional/domain/devotional.dart';
import '../data/today_content.dart';
import '../domain/completion_event.dart';
import '../domain/day_box.dart';
import '../domain/streak.dart';

/// One of the day's boxes together with whether it is checked.
class BoxView {
  const BoxView({required this.box, required this.done});

  final DayBox box;
  final bool done;
}

/// Everything Today and the devotional reader show for one local day.
class TodayView {
  const TodayView({
    required this.date,
    required this.missionLine,
    required this.boxes,
    required this.record,
    required this.reading,
    required this.streakDays,
    required this.showPreviewPoints,
    required this.durable,
  });

  final LocalDate date;
  final String missionLine;
  final List<BoxView> boxes;

  /// The day's saved state. An undo needs it: it names the completion it
  /// undoes and the day that completion was recorded on.
  final DayRecord record;

  /// Today's reading, or null if the bundled file has none for this date.
  final Devotional? reading;

  /// Decision Q6: consecutive days with the devotional done.
  final int streakDays;

  /// Decision Q5: false unless the member turned the preview switch on.
  final bool showPreviewPoints;

  /// False where nothing is kept after the app closes (the web preview).
  final bool durable;

  int get total => boxes.length;
  int get doneCount => boxes.where((b) => b.done).length;

  bool get devotionalDone => record.isDone(DayItems.devotional);

  /// Done and total for one group of boxes.
  ({int done, int total}) countsFor(BoxCategory category) {
    final group = boxes.where((b) => b.box.category == category);
    return (done: group.where((b) => b.done).length, total: group.length);
  }
}

/// What a tap on Amen did.
enum AmenOutcome {
  /// The devotional is recorded as done for today.
  saved,

  /// The reading on screen was no longer today's: the clock had passed into
  /// another day. Nothing was saved, and the screen now shows today's
  /// reading, which has to be read to its end before Amen.
  newDay,

  /// The completion could not be saved.
  failed,
}

/// One owner's boxes for [day], straight from the store.
final dayRecordProvider = StreamProvider.family<DayRecord, LocalDate>((
  ref,
  day,
) {
  final store = ref.watch(localStoreProvider);
  return store.days.watchDay(store.ownerId, day);
});

final doneByDayProvider = StreamProvider<Map<LocalDate, Set<String>>>((ref) {
  final store = ref.watch(localStoreProvider);
  return store.days.watchDoneByDay(store.ownerId);
});

final showPreviewPointsProvider = StreamProvider<bool>(
  (ref) => ref.watch(localStoreProvider).settings.watchShowPreviewPoints(),
);

/// Presentation state for Today and the reader: loading, an error, or the
/// day's view.
///
/// Riverpod's automatic retry is off, so a failure shows at once and the
/// member retries with [TodayViewModel.retry].
final todayViewModelProvider = AsyncNotifierProvider<TodayViewModel, TodayView>(
  TodayViewModel.new,
  retry: (retryCount, error) => null,
);

class TodayViewModel extends AsyncNotifier<TodayView> {
  @override
  Future<TodayView> build() async {
    final date = ref.watch(todayDateProvider);
    final store = ref.watch(localStoreProvider);
    final content = await ref.watch(todayContentProvider.future);
    final library = await ref.watch(devotionalLibraryProvider.future);
    final record = await ref.watch(dayRecordProvider(date).future);
    final doneByDay = await ref.watch(doneByDayProvider.future);
    final showPoints = await ref.watch(showPreviewPointsProvider.future);

    return TodayView(
      date: date,
      missionLine: content.missionFor(date),
      boxes: <BoxView>[
        for (final box in content.boxes)
          BoxView(box: box, done: box.item != null && record.isDone(box.item!)),
      ],
      record: record,
      reading: library.forDate(date),
      streakDays: StreakRule.devotional.length(
        doneByDay: doneByDay,
        today: date,
      ),
      showPreviewPoints: showPoints,
      durable: store.days.durable,
    );
  }

  /// Loads again after an error.
  Future<void> retry() async {
    ref.invalidate(todayContentProvider);
    ref.invalidate(devotionalLibraryProvider);
    ref.invalidate(dayRecordProvider);
    ref.invalidate(doneByDayProvider);
    ref.invalidate(showPreviewPointsProvider);
    ref.invalidateSelf();
    await future.then<void>((_) {}, onError: (Object _) {});
  }

  /// Records "Amen" for the reading of [shownDay], the one on screen.
  ///
  /// A completion belongs to the local day of the tap (decision Q9). If
  /// that is no longer [shownDay], because midnight passed while the reading
  /// was open, the tap is refused and nothing is saved: he has not read
  /// today's reading, and yesterday's box is not checked late. The screen
  /// moves to today instead. Decided by the maintainer on 2026-11-12.
  Future<AmenOutcome> completeDevotional({required LocalDate shownDay}) async {
    final store = ref.read(localStoreProvider);
    final now = ref.read(clockProvider).now();
    if (LocalDate.of(now) != shownDay) {
      ref.read(todayDateProvider.notifier).refresh();
      return AmenOutcome.newDay;
    }
    final view = state.value;
    final current = view != null && view.date == shownDay
        ? view.record.items[DayItems.devotional]
        : null;
    final saved = await _record(
      CompletionEvent.complete(
        id: ref.read(eventIdProvider)(),
        ownerId: store.ownerId,
        item: DayItems.devotional,
        tappedAt: now,
        replacesEventId: current?.latestEventId,
      ),
    );
    return saved ? AmenOutcome.saved : AmenOutcome.failed;
  }

  /// Records an undo of the completion on screen. It clears the box on the
  /// day that completion was recorded, also when the clock has moved to
  /// another day since. Returns false if it could not be saved.
  Future<bool> undoDevotional() async {
    final view = state.value;
    final completion = view?.record.items[DayItems.devotional];
    if (view == null || completion == null || !completion.done) return true;
    final store = ref.read(localStoreProvider);
    return _record(
      CompletionEvent.undo(
        id: ref.read(eventIdProvider)(),
        ownerId: store.ownerId,
        item: DayItems.devotional,
        day: view.record.day,
        completion: completion,
        tappedAt: ref.read(clockProvider).now(),
      ),
    );
  }

  Future<bool> _record(CompletionEvent event) async {
    try {
      await ref.read(localStoreProvider).days.record(event);
    } catch (_) {
      return false;
    }
    if (!ref.mounted) return true;
    // The tap read the clock; make the day on screen agree with it.
    ref.read(todayDateProvider.notifier).refresh();
    return true;
  }
}

/// Turns the preview point values on or off (decision Q5).
Future<void> setShowPreviewPoints(WidgetRef ref, bool show) =>
    ref.read(localStoreProvider).settings.setShowPreviewPoints(show);
