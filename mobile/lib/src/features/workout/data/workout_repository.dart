import '../../../core/local_date.dart';
import '../domain/workout_plan.dart';
import '../domain/workout_session.dart';

/// The boundary between the workout screens and wherever the member's plan
/// and sessions are kept.
///
/// Plain Dart. The app uses the Drift implementation on a phone and the
/// in-memory one in the web preview and in widget tests. Nothing here, and
/// nothing behind it, talks to Firebase.
abstract interface class WorkoutRepository {
  /// Whether what is recorded survives closing the app. False only for the
  /// in-memory store, and the screens say so.
  bool get durable;

  /// The owner's plan: the current value at once, then again after every
  /// change. Null until he has one.
  Stream<WorkoutPlan?> watchPlan(String ownerId);

  /// The owner's plan. If he has none yet, [create] makes one and it is
  /// stored; a plan that already exists is never replaced.
  Future<WorkoutPlan> ensurePlan(String ownerId, WorkoutPlan Function() create);

  /// Replaces the owner's plan. Sessions already started are not touched:
  /// each carries its own copy of what it was started with.
  Future<void> savePlan(String ownerId, WorkoutPlan plan);

  /// The session the owner started on [day], with its exercises and sets:
  /// the current value at once, then again after every change. Null if he
  /// started none that day.
  Stream<WorkoutSession?> watchSession(String ownerId, LocalDate day);

  /// The session the owner started on [day] as it is stored at this
  /// moment, or null: one read.
  ///
  /// For a check that has to see every change already stored. Whoever
  /// listens to [watchSession] hears of a change a moment after it is
  /// stored, so what he last heard can be a change behind.
  Future<WorkoutSession?> readSession(String ownerId, LocalDate day);

  /// The owner's most recently started session that is not finished, or
  /// null. This is how a workout begun before midnight is found again the
  /// next day.
  Stream<WorkoutSession?> watchOpenSession(String ownerId);

  /// Stores [session] with every exercise and set, in one transaction.
  ///
  /// One session per owner per day: if the owner already has a session on
  /// that day, nothing is stored and the existing session is returned, so a
  /// double tap on Amen starts one workout.
  Future<WorkoutSession> startSession(NewSession session);

  /// Sets what was entered for one set. Null clears a value.
  Future<void> setReps(String setId, int? reps);
  Future<void> setWeight(String setId, double? weightLb);
  Future<void> setTicked(String setId, {required bool ticked});

  /// Stores an exercise's rest timer: its full length, and either the
  /// instant it reaches zero (running), the seconds left (paused), or
  /// neither (waiting at its full length).
  Future<void> setRest(
    String exerciseId, {
    required int baseSeconds,
    DateTime? endsAtUtc,
    int? pausedSeconds,
  });

  /// Finishes the session at [now], the phone's local time, and checks the
  /// Workout box of the day the session was started on, in one
  /// transaction.
  ///
  /// Finishing a session that is already finished changes nothing: the
  /// finish time stays, and no second completion is recorded.
  Future<FinishOutcome> finishSession(String sessionId, DateTime now);

  /// For each of [movementIds], what the owner logged the last time he did
  /// that movement on a day before [before]. Matched by movement id, never
  /// by where the exercise stood in the plan. Each set keeps the position
  /// it was logged in, so a set left empty leaves a gap and does not move
  /// the later sets up. A movement with nothing logged has no entry.
  Future<Map<String, LastTime>> lastTimes(
    String ownerId, {
    required LocalDate before,
    required Iterable<String> movementIds,
  });
}
