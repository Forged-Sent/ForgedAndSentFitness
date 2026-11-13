import 'package:drift/drift.dart';

import 'app_database.steps.dart';

part 'app_database.g.dart';

/// Every tap that checks or clears a box, in the order it happened here.
/// Rows are only ever added.
///
/// The event id is the only key (the maintainer's decision of 2026-11-11,
/// option A): storing the same event twice leaves one row. What a box
/// currently shows is not here; it is the matching row of [DayStates].
@DataClassName('CompletionEventRow')
class CompletionEvents extends Table {
  /// Client-generated UUID.
  TextColumn get id => text()();

  TextColumn get ownerId => text()();

  /// The local day the event belongs to, as `YYYY-MM-DD`.
  TextColumn get day => text()();

  TextColumn get item => text()();

  /// The state the tap asked for.
  BoolColumn get done => boolean()();

  /// This event's place in this database's order of events. The highest
  /// counter for a box is its latest event; the phone's clock is never
  /// used for that.
  IntColumn get counter => integer().unique()();

  /// When the tap happened: a UTC instant, and the phone's offset from UTC
  /// at that moment. For the record and for display only.
  IntColumn get tappedAtUtcMs => integer()();
  IntColumn get utcOffsetMinutes => integer()();

  /// The event that set the box when the tap was made, if any.
  TextColumn get replacesEventId => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// What each box of each day currently shows, derived from the events and
/// written in the same transaction as the event that changed it.
@DataClassName('DayStateRow')
class DayStates extends Table {
  TextColumn get ownerId => text()();
  TextColumn get day => text()();
  TextColumn get item => text()();
  BoolColumn get done => boolean()();
  TextColumn get latestEventId => text()();
  IntColumn get latestCounter => integer()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId, day, item};
}

/// Small device-only settings, such as the switch that shows preview point
/// values.
@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

/// The member's workout plan: which program he follows and how its days
/// fall on his week. One row per owner. Added in schema version 2.
///
/// Weekdays are numbered as `LocalDate.weekday` numbers them: Monday is 1
/// and Sunday is 7.
@DataClassName('WorkoutPlanRow')
class WorkoutPlans extends Table {
  TextColumn get ownerId => text()();

  TextColumn get program => text()();

  /// The equipment setup the movement names are shown for.
  TextColumn get equipment => text()();

  /// The weekly rest day.
  IntColumn get restWeekday => integer()();

  /// The three lifting weekdays, in order from the day after the rest day,
  /// as `1,3,5`.
  TextColumn get liftWeekdays => text()();

  /// Whether the optional fourth training day is on.
  BoolColumn get fourthDay => boolean()();

  /// The first day of the plan's first week, as `YYYY-MM-DD`: always the
  /// day after a rest day.
  TextColumn get startDay => text()();

  @override
  Set<Column<Object>> get primaryKey => {ownerId};
}

/// One workout the member started. Added in schema version 2.
///
/// A session belongs to the local day it was started on and keeps that day
/// for good, so it can be finished after midnight. It carries its own copy
/// of what the plan said that day; nothing here points back into the plan,
/// so changing the plan later cannot change a session.
@DataClassName('WorkoutSessionRow')
class WorkoutSessions extends Table {
  /// Client-generated UUID.
  TextColumn get id => text()();

  TextColumn get ownerId => text()();

  /// The local day the session was started on, as `YYYY-MM-DD`.
  TextColumn get day => text()();

  TextColumn get program => text()();

  /// The plan's day and week numbers when the session was started. For the
  /// line above the title only; nothing is looked up by them.
  IntColumn get planDay => integer()();
  IntColumn get planWeek => integer()();

  TextColumn get title => text()();
  TextColumn get sessionType => text()();
  IntColumn get minutes => integer()();

  /// When Amen was tapped: a UTC instant, and the phone's offset from UTC
  /// at that moment. The workout clock is worked out from this.
  IntColumn get startedAtUtcMs => integer()();
  IntColumn get startUtcOffsetMinutes => integer()();

  /// When the session was finished. Null while it is in progress.
  IntColumn get finishedAtUtcMs => integer().nullable()();
  IntColumn get finishUtcOffsetMinutes => integer().nullable()();

  /// The id of the completion event that finishing this session records,
  /// made when the session was started. Finishing twice therefore records
  /// one completion.
  TextColumn get finishEventId => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// One session per owner per day.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {ownerId, day},
  ];
}

/// One exercise of a session, as the plan prescribed it when the session
/// was started. Added in schema version 2.
@DataClassName('WorkoutExerciseRow')
@TableIndex(name: 'workout_exercises_session', columns: {#sessionId})
@TableIndex(name: 'workout_exercises_movement', columns: {#movementId})
class WorkoutExercises extends Table {
  /// Client-generated UUID.
  TextColumn get id => text()();

  TextColumn get sessionId => text().references(WorkoutSessions, #id)();

  /// Where the exercise stands on the page. For display order only: "last
  /// time" is found by [movementId], never by this.
  IntColumn get position => integer()();

  /// The movement's key in the workout library.
  TextColumn get movementId => text()();

  /// The name shown for the member's equipment.
  TextColumn get name => text()();

  /// The prescription text, for example `3 x 5 (RPE 7, rest 2 min)`.
  TextColumn get prescription => text()();

  /// What a set of this exercise records: `reps`, `seconds`, or `tick` for
  /// an exercise that is only marked done.
  TextColumn get measure => text()();

  /// Whether a set needs a weight: `required`, `optional` (a bodyweight
  /// lift that can be loaded) or `none`.
  TextColumn get weightMode => text()();

  /// The rest timer's full length in seconds.
  IntColumn get restBaseSeconds => integer()();

  /// The UTC instant the running rest timer reaches zero. Null when it is
  /// not running.
  IntColumn get restEndsAtUtcMs => integer().nullable()();

  /// The seconds left on a paused rest timer. Null when it is not paused.
  IntColumn get restPausedSeconds => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One set of an exercise. Added in schema version 2.
@DataClassName('WorkoutSetRow')
@TableIndex(name: 'workout_sets_exercise', columns: {#exerciseId})
class WorkoutSets extends Table {
  /// Client-generated UUID.
  TextColumn get id => text()();

  TextColumn get exerciseId => text().references(WorkoutExercises, #id)();

  IntColumn get position => integer()();

  /// What the plan asked for in this set, for example `5` or `25 sec`.
  TextColumn get target => text()();

  /// Reps done, or seconds for a timed set. Null until entered.
  IntColumn get reps => integer().nullable()();

  /// The weight on the bar in pounds, or the weight added to a bodyweight
  /// lift. Never the member's body weight. Null until entered.
  RealColumn get weightLb => real().nullable()();

  /// For an exercise that is only marked done.
  BoolColumn get ticked => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One member's local data. There is one database file per owner id, so one
/// member's rows cannot appear for another.
///
/// Schema versions:
/// 1. The day's boxes and settings (build step S1).
/// 2. Workout plans, sessions, exercises and sets (build step S3).
///
/// Each version's schema is frozen in `drift_schemas/`, and
/// `test/storage/migration_test.dart` proves that a file of every earlier
/// version opens in this one with its rows intact.
@DriftDatabase(
  tables: [
    CompletionEvents,
    DayStates,
    AppSettings,
    WorkoutPlans,
    WorkoutSessions,
    WorkoutExercises,
    WorkoutSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) => m.runMigrationSteps(
      from: from,
      to: to,
      // A step is applied completely or not at all, so a phone that loses
      // power halfway through is not left with half the new tables.
      steps: (int version, GeneratedDatabase database) =>
          database.transaction(() => _upgradeSteps(version, database)),
    ),
    beforeOpen: (OpeningDetails details) async {
      // SQLite checks references between tables only when asked to.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

/// What each schema version adds to the one before it. Written against the
/// frozen schema of the version it produces, not against the tables above,
/// so a later change to a table cannot change an old step.
final _upgradeSteps = migrationSteps(
  from1To2: (Migrator m, Schema2 schema) async {
    await m.createTable(schema.workoutPlans);
    await m.createTable(schema.workoutSessions);
    await m.createTable(schema.workoutExercises);
    await m.createTable(schema.workoutSets);
    await m.createIndex(schema.workoutExercisesSession);
    await m.createIndex(schema.workoutExercisesMovement);
    await m.createIndex(schema.workoutSetsExercise);
  },
);
