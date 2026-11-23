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

  /// True while nothing is entered in the set.
  bool get isBlank => reps == null && weightLb == null && !ticked;
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

  /// How many of [sets] the plan asked for: the first this many. See
  /// [plannedSetCount].
  int get plannedSets => plannedSetCount(prescription);

  /// Whether he can add one more set: an exercise whose sets are counted,
  /// with fewer than [maxSets] rows. An exercise that is only marked done
  /// has no sets to add to.
  bool get canAddSet =>
      measure != SetMeasure.tick && sets.isNotEmpty && sets.length < maxSets;

  /// True for a row he added during the workout, after the plan's own.
  bool isAdded(SessionSet set) =>
      measure != SetMeasure.tick && set.position >= plannedSets;

  /// Whether [set] can be removed: only a row he added, and only while
  /// nothing is entered in it. A row from the plan is never removed;
  /// leaving it empty already means it is not counted.
  bool canRemove(SessionSet set) => isAdded(set) && set.isBlank;

  /// Whether [set] counts as logged: a tick, or reps (or seconds) together
  /// with a weight where the lift needs one. The prototype's `paintDone`.
  bool isLogged(SessionSet set) {
    if (measure == SetMeasure.tick) return set.ticked;
    return (set.reps ?? 0) > 0 &&
        (measure == SetMeasure.seconds ||
            weightMode != WeightMode.required ||
            set.weightLb != null);
  }

  /// What [set] is missing, if something is entered in it and it still
  /// does not count: its reps (or seconds) where only a weight was typed,
  /// or its weight where the lift needs one. Null for a set that counts,
  /// for one left empty, and for a tick row.
  SetGap? gapOf(SessionSet set) {
    if (measure == SetMeasure.tick || isLogged(set)) return null;
    if ((set.reps ?? 0) > 0) return SetGap.weight;
    return set.weightLb == null ? null : SetGap.reps;
  }

  /// The rest timer at [nowUtc], worked out from the stored timestamps, so
  /// it is right after the app was closed and opened again.
  RestState restAt(DateTime nowUtc) => restStateAt(
    nowUtc,
    baseSeconds: restBaseSeconds,
    endsAtUtc: restEndsAtUtc,
    pausedSeconds: restPausedSeconds,
  );
}

/// What a set entered halfway is missing. See [SessionExercise.gapOf].
enum SetGap {
  /// A weight was typed and no reps, or no seconds for a timed set.
  reps,

  /// Reps were typed and no weight, on a lift that needs one.
  weight,
}

/// Where a rest timer stands at [nowUtc], given what is stored for it: its
/// full length, and either the instant it reaches zero (running), the
/// seconds left (paused), or neither (waiting at its full length).
RestState restStateAt(
  DateTime nowUtc, {
  required int baseSeconds,
  required DateTime? endsAtUtc,
  required int? pausedSeconds,
}) {
  if (endsAtUtc != null) {
    final left = (endsAtUtc.difference(nowUtc).inMilliseconds / 1000).ceil();
    return left > 0
        ? RestState(left: left, running: true, over: false, paused: false)
        : const RestState(left: 0, running: false, over: true, paused: false);
  }
  if (pausedSeconds != null) {
    return RestState(
      left: pausedSeconds,
      running: false,
      over: false,
      paused: true,
    );
  }
  return RestState(
    left: baseSeconds,
    running: false,
    over: false,
    paused: false,
  );
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

  /// The sets with reps entered, in the order they were done. A set left
  /// empty that day is not here, and the sets after it keep their own
  /// [LastSet.position].
  final List<LastSet> sets;

  /// What was logged that day in the set at [position], or null if that
  /// set had no reps. No day of the bundled program lists a movement
  /// twice; if a day ever does, the first one answers.
  LastSet? at(int position) {
    for (final set in sets) {
      if (set.position == position) return set;
    }
    return null;
  }
}

class LastSet {
  const LastSet({required this.position, required this.reps, this.weightLb});

  /// The set's place in its exercise that day, from 0: the same number as
  /// [SessionSet.position].
  final int position;

  final int reps;
  final double? weightLb;
}

/// One set the finish check points at.
class SetIssue {
  const SetIssue({required this.setId, required this.text, this.blank = false});

  final String setId;

  /// For example `Barbell Back Squat, Set 2: add the weight`.
  final String text;

  /// True if nothing at all is entered in the set.
  final bool blank;
}

/// What stands between a session and finishing it. The prototype's
/// `workoutFixes`, with the maintainer's rule of 2026-11-13 for a weight
/// with no reps.
class FinishCheck {
  const FinishCheck({required this.fixes, required this.uncounted});

  /// Sets with reps and no weight, on a lift that needs one. These must be
  /// fixed before finishing.
  final List<SetIssue> fixes;

  /// Sets that will not be counted, in the order they stand on the page:
  /// nothing is entered, or a weight and no reps (or seconds). He may
  /// finish without them, and the summary then says which had a weight.
  final List<SetIssue> uncounted;

  /// True if every set in [uncounted] has nothing entered at all.
  bool get onlyBlanks => uncounted.every((SetIssue issue) => issue.blank);

  bool get clear => fixes.isEmpty && uncounted.isEmpty;
}

FinishCheck checkBeforeFinish(WorkoutSession session) {
  final fixes = <SetIssue>[];
  final uncounted = <SetIssue>[];
  for (final exercise in session.exercises) {
    if (exercise.measure == SetMeasure.tick) continue;
    final unit = exercise.measure == SetMeasure.seconds ? 'seconds' : 'reps';
    for (var i = 0; i < exercise.sets.length; i++) {
      final set = exercise.sets[i];
      if (exercise.isLogged(set)) continue;
      final label = '${exercise.name}, Set ${i + 1}';
      switch (exercise.gapOf(set)) {
        case SetGap.weight:
          fixes.add(SetIssue(setId: set.id, text: '$label: add the weight'));
        case SetGap.reps:
          // The maintainer's rule: a weight with no reps does not hold
          // Finish up, on any lift. The prototype holds it up on a loaded
          // lift ("add the reps") and calls it blank on the others.
          uncounted.add(
            SetIssue(setId: set.id, text: '$label: a weight but no $unit'),
          );
        case null:
          uncounted.add(
            SetIssue(
              setId: set.id,
              text: '$label: nothing entered',
              blank: true,
            ),
          );
      }
    }
  }
  return FinishCheck(fixes: fixes, uncounted: uncounted);
}

/// What finishing a session did.
enum FinishOutcome {
  /// The session is now finished and the day's Workout box is checked.
  finished,

  /// The session was already finished. Nothing changed.
  alreadyFinished,
}
