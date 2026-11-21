import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/local_store.dart';
import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../core/local_date.dart';
import '../../today/domain/completion_event.dart';
import '../../today/presentation/today_view_model.dart' show doneByDayProvider;
import '../data/workout_library.dart';
import '../domain/workout_plan.dart';
import '../domain/workout_session.dart';
import 'workout_view_model.dart';

/// One line of Train: a day, what the plan holds for it, and whether its
/// workout is done.
class TrainDay {
  const TrainDay({
    required this.date,
    required this.planDay,
    required this.title,
    required this.detail,
    required this.done,
    required this.isToday,
  });

  final LocalDate date;
  final PlanDay planDay;

  /// The session's title, or what the day is instead: "Sabbath", "Rest
  /// day", "Plan starts Monday, November 16", "Plan complete".
  final String title;

  /// "Core · 45 min", "Rest, worship, family", or empty.
  final String detail;

  /// Whether the day's Workout box is checked.
  final bool done;

  final bool isToday;

  /// A day with a session opens the workout page.
  bool get opens => planDay.isTrain;

  /// Nothing to do on this day: drawn muted.
  bool get dim => !planDay.isTrain;
}

/// Everything Train shows.
class TrainView {
  const TrainView({
    required this.today,
    required this.status,
    required this.message,
    required this.week,
    required this.todaySession,
    required this.carriedOver,
    required this.durable,
  });

  /// Today's line: also the first card on the page.
  final TrainDay today;

  /// "Ready to train", "Workout complete", "Rest day", "Nothing finished
  /// yet today".
  final String status;

  /// What the first card says on a day with no session, for example
  /// "Your plan starts Monday, November 16." Null on a day with one.
  final String? message;

  /// Monday to Sunday of the week that holds today.
  final List<TrainDay> week;

  /// The session started today, or null.
  final WorkoutSession? todaySession;

  /// A session started on an earlier day and not finished: the workout
  /// begun before midnight, still open. Null if there is none.
  final WorkoutSession? carriedOver;

  /// False where nothing is kept after the app closes (the web preview).
  final bool durable;
}

/// "Plan starts Monday, November 16" and the like: the prototype's
/// `rowLabel`.
({String title, String detail}) planDayLabel(
  PlanDay planDay,
  WorkoutPlan plan,
) {
  switch (planDay.kind) {
    case PlanDayKind.before:
      return (title: 'Plan starts ${weekdayName(plan.start)}', detail: '');
    case PlanDayKind.over:
      return (title: 'Plan complete', detail: '');
    case PlanDayKind.rest:
      return (title: 'Sabbath', detail: 'Rest, worship, family');
    case PlanDayKind.off:
      return (title: 'Rest day', detail: 'Optional day is off');
    case PlanDayKind.train:
      final workout = planDay.workout!;
      return (
        title: workout.title,
        detail: workout.minutes > 0
            ? '${workout.sessionType} · ${workout.minutes} min'
            : workout.sessionType,
      );
  }
}

/// Presentation state for the Train tab: loading, an error, or the view.
final trainViewModelProvider = AsyncNotifierProvider<TrainViewModel, TrainView>(
  TrainViewModel.new,
  retry: (retryCount, error) => null,
);

class TrainViewModel extends AsyncNotifier<TrainView> {
  @override
  Future<TrainView> build() async {
    final date = ref.watch(todayDateProvider);
    final store = ref.watch(localStoreProvider);
    final library = await ref.watch(workoutLibraryProvider.future);
    final plan = await ref.watch(workoutPlanProvider.future);
    final doneByDay = await ref.watch(doneByDayProvider.future);
    final todaySession = await ref.watch(sessionForDayProvider(date).future);
    final carriedOver = await ref.watch(earlierOpenSessionProvider.future);

    TrainDay dayOf(LocalDate day) {
      final planDay = library.dayFor(plan, day);
      final label = planDayLabel(planDay, plan);
      return TrainDay(
        date: day,
        planDay: planDay,
        title: label.title,
        detail: label.detail,
        done: doneByDay[day]?.contains(DayItems.workout) ?? false,
        isToday: day == date,
      );
    }

    final today = dayOf(date);
    final monday = date.addDays(1 - date.weekday);

    final String status;
    if (today.done) {
      status = 'Workout complete';
    } else if (today.planDay.kind == PlanDayKind.rest ||
        today.planDay.kind == PlanDayKind.off) {
      status = 'Rest day';
    } else if (today.planDay.isTrain) {
      status = 'Ready to train';
    } else {
      status = 'Nothing finished yet today';
    }

    final String? message;
    switch (today.planDay.kind) {
      case PlanDayKind.train:
        message = null;
      case PlanDayKind.rest:
        // The prototype shows the rest day's own line from the program.
        final rest = today.planDay.workout!.exercises;
        message = rest.isEmpty
            ? 'Sabbath.'
            : 'Sabbath. ${rest.first.prescription}';
      case PlanDayKind.off:
        message = 'Rest day. The optional 4th training day is off.';
      case PlanDayKind.before:
        message = 'Your plan starts ${heroDateLine(plan.start)}.';
      case PlanDayKind.over:
        // The calendar has run past the plan. It says nothing about what
        // he logged: the words are the maintainer's (2026-11-20).
        message = 'You have reached the end of this plan.';
    }

    return TrainView(
      today: today,
      status: status,
      message: message,
      week: <TrainDay>[for (var i = 0; i < 7; i++) dayOf(monday.addDays(i))],
      todaySession: todaySession,
      carriedOver: carriedOver,
      durable: store.workouts.durable,
    );
  }

  /// Loads again after an error: everything [build] reads is read again,
  /// today's session among it. A provider that failed keeps its error
  /// until it is asked again.
  Future<void> retry() async {
    ref.invalidate(workoutLibraryProvider);
    ref.invalidate(workoutPlanProvider);
    ref.invalidate(doneByDayProvider);
    ref.invalidate(sessionForDayProvider(ref.read(todayDateProvider)));
    ref.invalidate(earlierOpenSessionProvider);
    ref.invalidateSelf();
    await future.then<void>((_) {}, onError: (Object _) {});
  }
}
