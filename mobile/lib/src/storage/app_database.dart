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

/// What each private journal entry currently says (build step S2).
///
/// Decision Q8: journal entries are kept on the device only. The text is
/// written through a codec, and [bodyFormat] records the form it was
/// stored in, so entries can be encrypted later without a new table. The
/// revision and the kept row of a deleted entry are there for a later
/// sync; neither is built.
@UseRowClass(JournalEntryRow)
class JournalEntries extends Table {
  /// Client-generated UUID, made once when the entry is first saved.
  TextColumn get id => text()();

  TextColumn get ownerId => text()();

  /// The local day the entry was first saved on, as `YYYY-MM-DD`.
  TextColumn get day => text()();

  /// When it was first saved: a UTC instant, and the phone's offset from
  /// UTC at that moment.
  IntColumn get createdAtUtcMs => integer()();
  IntColumn get utcOffsetMinutes => integer()();

  /// What he wrote, in the form named by [bodyFormat]. Empty once deleted.
  TextColumn get body => text()();
  TextColumn get bodyFormat => text()();

  /// Where it was written: `devotional` or `pen`.
  TextColumn get source => text()();

  /// The reflection question it answers, if any. Empty once deleted.
  TextColumn get prompt => text()();

  IntColumn get editedAtUtcMs => integer().nullable()();

  /// Set when he deletes the entry. The row stays, without its words, so
  /// a later sync can tell other devices it is gone.
  IntColumn get deletedAtUtcMs => integer().nullable()();

  /// How many times this entry has been written, counting from 1.
  IntColumn get revision => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// A row of [JournalEntries] as read from the database.
///
/// Written by hand, not generated, for one reason: a generated row prints
/// every column, and this one must never print [body] or [prompt].
class JournalEntryRow {
  const JournalEntryRow({
    required this.id,
    required this.ownerId,
    required this.day,
    required this.createdAtUtcMs,
    required this.utcOffsetMinutes,
    required this.body,
    required this.bodyFormat,
    required this.source,
    required this.prompt,
    required this.revision,
    this.editedAtUtcMs,
    this.deletedAtUtcMs,
  });

  final String id;
  final String ownerId;
  final String day;
  final int createdAtUtcMs;
  final int utcOffsetMinutes;
  final String body;
  final String bodyFormat;
  final String source;
  final String prompt;
  final int? editedAtUtcMs;
  final int? deletedAtUtcMs;
  final int revision;

  @override
  String toString() =>
      'JournalEntryRow($id, $day, $source, $bodyFormat, revision $revision, '
      '${body.length} stored characters'
      '${deletedAtUtcMs == null ? '' : ', deleted'})';
}

/// Every save and delete of a journal entry, in the order it happened
/// here. Rows are only ever added, and they never hold any text.
@DataClassName('JournalChangeRow')
class JournalChanges extends Table {
  /// Client-generated UUID.
  TextColumn get id => text()();

  TextColumn get ownerId => text()();
  TextColumn get entryId => text()();

  /// `save` or `delete`.
  TextColumn get kind => text()();

  /// The entry's revision once this change was applied.
  IntColumn get revision => integer()();

  /// This change's place in this database's order of journal changes.
  IntColumn get counter => integer().unique()();

  IntColumn get atUtcMs => integer()();
  IntColumn get utcOffsetMinutes => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The member's workout plan: which program he follows and how its days
/// fall on his week. One row per owner. Added in schema version 3.
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

/// One workout the member started. Added in schema version 3.
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
/// was started. Added in schema version 3.
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

/// One set of an exercise. Added in schema version 3.
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
/// 2. The journal tables (build step S2).
/// 3. Workout plans, sessions, exercises and sets (build step S3).
///
/// Each version's schema is frozen in `drift_schemas/`, and the tests in
/// `test/storage/` prove that a file of every earlier version opens in this
/// one with its rows intact.
@DriftDatabase(
  tables: [
    CompletionEvents,
    DayStates,
    AppSettings,
    JournalEntries,
    JournalChanges,
    WorkoutPlans,
    WorkoutSessions,
    WorkoutExercises,
    WorkoutSets,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 3;

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
    // A table that is already there is left alone: the new version number
    // is recorded after this step returns, so an update that was cut off
    // in between can leave the tables in place under the old number.
    // Creating them again would fail on every later launch.
    if (!await _tableExists(
      m.database,
      schema.journalEntries.actualTableName,
    )) {
      await m.createTable(schema.journalEntries);
    }
    if (!await _tableExists(
      m.database,
      schema.journalChanges.actualTableName,
    )) {
      await m.createTable(schema.journalChanges);
    }
  },
  from2To3: (Migrator m, Schema3 schema) async {
    await m.createTable(schema.workoutPlans);
    await m.createTable(schema.workoutSessions);
    await m.createTable(schema.workoutExercises);
    await m.createTable(schema.workoutSets);
    await m.createIndex(schema.workoutExercisesSession);
    await m.createIndex(schema.workoutExercisesMovement);
    await m.createIndex(schema.workoutSetsExercise);
  },
);

Future<bool> _tableExists(GeneratedDatabase database, String name) async {
  final found = await database
      .customSelect(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
        variables: <Variable<Object>>[Variable<String>(name)],
      )
      .get();
  return found.isNotEmpty;
}
