import 'package:drift/drift.dart';

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

/// One member's local data. There is one database file per owner id, so one
/// member's rows cannot appear for another.
@DriftDatabase(tables: [CompletionEvents, DayStates, AppSettings])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
