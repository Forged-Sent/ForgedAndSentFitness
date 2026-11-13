import '../../../core/local_date.dart';
import 'prescription.dart';

/// One set of an exercise in a session.
class SessionSet {
  const SessionSet({
    required this.id,
    required this.position,
    required this.target,
    this.reps,
    this.weightLb,
    this.ticked = false,
  });

  /// Client-generated, and the set's only key.
  final String id;

  final int position;

  /// What the plan asked for in this set, for example `5` or `25 sec`.
  final String target;

  /// Reps done, or seconds for a timed set. Null until entered.
  final int? reps;

  /// Pounds on the bar, or pounds added to a bodyweight lift. Never the
  /// member's body weight. Null until entered.
  final double? weightLb;

  /// For an exercise that is only marked done.
  final bool ticked;
}

/// Where an exercise's rest timer stands at one moment.
class RestState {
  const RestState({
    required this.left,
    required this.running,
    required this.over,
    required this.paused,
  });

  /// The seconds left on the timer.
  final int left;

  final bool running;

  /// True once a started timer has reached zero.
  final bool over;

  final bool paused;
}

/// One exercise of a session: a copy of what the plan prescribed when the
/// session was started, and the sets logged for it.
class SessionExercise {
  const SessionExercise({
    required this.id,
    required this.position,
    required this.movementId,
    required this.name,
    required this.prescription,
    required this.measure,
    required this.weightMode,
    required this.restBaseSeconds,
    required this.sets,
    this.restEndsAtUtc,
    this.restPausedSeconds,
  });

  /// Client-generated.
  final String id;

  /// Where the exercise stands on the page. Display order only.
  final int position;

  /// The movement's key in the workout library. "Last time" is found by
  /// this, never by [position] (review finding U3).
  final String movementId;

  /// The name shown for the member's equipment.
  final String name;

  final String prescription;
  final SetMeasure measure;
  final WeightMode weightMode;

  /// The rest timer's full length in seconds.
  final int restBaseSeconds;

  /// The instant the running rest timer reaches zero. Null when it is not
  /// running.
  final DateTime? restEndsAtUtc;

  /// The seconds left on a paused rest timer. Null when it is not paused.
  final int? restPausedSeconds;

  final List<SessionSet> sets;

  /// The first exercise of a superset has no rest timer.
  bool get hasRestTimer => !isSupersetFirst(prescription);

  /// Whether [set] counts as logged: a tick, or reps (or seconds) together
  /// with a weight where the lift needs one. The prototype's `paintDone`.
  bool isLogged(SessionSet set) {
    if (measure == SetMeasure.tick) return set.ticked;
    return (set.reps ?? 0) > 0 &&
        (measure == SetMeasure.seconds ||
            weightMode != WeightMode.required ||
            set.weightLb != null);
  }

  /// The rest timer at [nowUtc], worked out from the stored timestamps, so
  /// it is right after the app was closed and opened again.
  RestState restAt(DateTime nowUtc) {
    final endsAt = restEndsAtUtc;
    if (endsAt != null) {
      final left = (endsAt.difference(nowUtc).inMilliseconds / 1000).ceil();
      return left > 0
          ? RestState(left: left, running: true, over: false, paused: false)
          : const RestState(left: 0, running: false, over: true, paused: false);
    }
    final paused = restPausedSeconds;
    if (paused != null) {
      return RestState(left: paused, running: false, over: false, paused: true);
    }
    return RestState(
      left: restBaseSeconds,
      running: false,
      over: false,
      paused: false,
    );
  }
}

/// One workout the member started.
class WorkoutSession {
  WorkoutSession({
    required this.id,
    required this.ownerId,
    required this.day,
    required this.program,
    required this.planDay,
    required this.planWeek,
    required this.title,
    required this.sessionType,
    required this.minutes,
    required this.startedAtUtc,
    required this.startUtcOffset,
    required this.finishEventId,
    required this.exercises,
    this.finishedAtUtc,
    this.finishUtcOffset,
  }) : assert(startedAtUtc.isUtc, 'startedAtUtc must be a UTC DateTime'),
       assert(
         finishedAtUtc == null || finishedAtUtc.isUtc,
         'finishedAtUtc must be a UTC DateTime',
       );

  /// Client-generated.
  final String id;

  final String ownerId;

  /// The local day the session was started on. It keeps this day when it
  /// is finished after midnight (review finding U2).
  final LocalDate day;

  final String program;

  /// The plan's day and week numbers when the session was started. Shown
  /// above the title; nothing is looked up by them.
  final int planDay;
  final int planWeek;

  final String title;
  final String sessionType;
  final int minutes;

  /// When Amen was tapped, and the phone's offset from UTC at that moment.
  final DateTime startedAtUtc;
  final Duration startUtcOffset;

  /// When the session was finished. Null while it is in progress.
  final DateTime? finishedAtUtc;
  final Duration? finishUtcOffset;

  /// The id of the completion event that finishing records. Made when the
  /// session was started, so finishing twice records one completion.
  final String finishEventId;

  final List<SessionExercise> exercises;

  bool get finished => finishedAtUtc != null;

  /// The time on the phone's clock when the session started.
  DateTime get startedAtWallClock => startedAtUtc.add(startUtcOffset);

  /// The time on the phone's clock when the session was finished.
  DateTime? get finishedAtWallClock => finishedAtUtc == null
      ? null
      : finishedAtUtc!.add(finishUtcOffset ?? Duration.zero);

  /// How long the workout has run at [now], or ran in all once finished.
  /// Worked out from the stored instants, never from a counter in memory.
  Duration elapsedAt(DateTime now) {
    final end = finishedAtUtc ?? now.toUtc();
    final elapsed = end.difference(startedAtUtc);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  /// The sets that count as logged, and the pounds moved in them.
  ///
  /// Volume is weight times reps over every set with a weight. The
  /// prototype adds the member's body weight for bodyweight lifts; the app
  /// stores no body weight, so those sets add only the load he entered.
  SessionTotals get totals {
    var sets = 0;
    var volume = 0.0;
    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (!exercise.isLogged(set)) continue;
        sets++;
        final weight = set.weightLb ?? 0;
        if (exercise.measure == SetMeasure.reps && weight > 0) {
          volume += weight * (set.reps ?? 0);
        }
      }
    }
    return SessionTotals(loggedSets: sets, volumeLb: volume.round());
  }
}

class SessionTotals {
  const SessionTotals({required this.loggedSets, required this.volumeLb});

  final int loggedSets;
  final int volumeLb;
}

/// A session about to be started: everything [WorkoutSession] holds except
/// what is entered later.
class NewSession {
  const NewSession({
    required this.id,
    required this.ownerId,
    required this.program,
    required this.planDay,
    required this.planWeek,
    required this.title,
    required this.sessionType,
    required this.minutes,
    required this.startedAt,
    required this.finishEventId,
    required this.exercises,
  });

  final String id;
  final String ownerId;
  final String program;
  final int planDay;
  final int planWeek;
  final String title;
  final String sessionType;
  final int minutes;

  /// The phone's local time when Amen was tapped. The session's day is the
  /// local date of this moment (decision Q9).
  final DateTime startedAt;

  final String finishEventId;
  final List<SessionExercise> exercises;

  LocalDate get day => LocalDate.of(startedAt);
}

/// What was logged for one movement the last time it was done.
class LastTime {
  const LastTime({required this.day, required this.sets});

  final LocalDate day;

  /// The sets with reps entered, in order.
  final List<LastSet> sets;
}

class LastSet {
  const LastSet({required this.reps, this.weightLb});

  final int reps;
  final double? weightLb;
}

/// One set the finish check points at.
class SetIssue {
  const SetIssue({required this.setId, required this.text});

  final String setId;

  /// For example `Barbell Back Squat, Set 2: add the weight`.
  final String text;
}

/// What stands between a session and finishing it. The prototype's
/// `workoutFixes`.
class FinishCheck {
  const FinishCheck({required this.fixes, required this.blanks});

  /// Sets entered halfway: reps without the weight, or the weight without
  /// reps. These must be fixed before finishing.
  final List<SetIssue> fixes;

  /// Sets with nothing entered. He may finish without them.
  final List<SetIssue> blanks;

  bool get clear => fixes.isEmpty && blanks.isEmpty;
}

FinishCheck checkBeforeFinish(WorkoutSession session) {
  final fixes = <SetIssue>[];
  final blanks = <SetIssue>[];
  for (final exercise in session.exercises) {
    if (exercise.measure == SetMeasure.tick) continue;
    final timed = exercise.measure == SetMeasure.seconds;
    final noWeightNeeded = timed || exercise.weightMode != WeightMode.required;
    for (var i = 0; i < exercise.sets.length; i++) {
      final set = exercise.sets[i];
      final hasReps = (set.reps ?? 0) > 0;
      final hasWeight = set.weightLb != null;
      if (hasReps && (noWeightNeeded || hasWeight)) continue;
      final label = '${exercise.name}, Set ${i + 1}';
      if (!hasReps && (noWeightNeeded || !hasWeight)) {
        blanks.add(SetIssue(setId: set.id, text: '$label: nothing entered'));
      } else {
        fixes.add(
          SetIssue(
            setId: set.id,
            text: hasReps
                ? '$label: add the weight'
                : '$label: add the ${timed ? 'seconds' : 'reps'}',
          ),
        );
      }
    }
  }
  return FinishCheck(fixes: fixes, blanks: blanks);
}

/// What finishing a session did.
enum FinishOutcome {
  /// The session is now finished and the day's Workout box is checked.
  finished,

  /// The session was already finished. Nothing changed.
  alreadyFinished,
}
