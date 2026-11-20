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

/// One member's local data. There is one database file per owner id, so one
/// member's rows cannot appear for another.
@DriftDatabase(
  tables: [
    CompletionEvents,
    DayStates,
    AppSettings,
    JournalEntries,
    JournalChanges,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Version 1: completions, day states and settings (build step S1).
  /// Version 2: the journal tables (build step S2).
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        // Both tables or neither. And a table that is already there is
        // left alone: SQLite records the new version after this returns,
        // so an update that was cut off between the two can leave the
        // tables in place under the old version number. Creating them
        // again would fail on every later launch.
        await transaction(() async {
          if (!await _tableExists(journalEntries.actualTableName)) {
            await m.createTable(journalEntries);
          }
          if (!await _tableExists(journalChanges.actualTableName)) {
            await m.createTable(journalChanges);
          }
        });
      }
    },
  );

  Future<bool> _tableExists(String name) async {
    final found = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: <Variable<Object>>[Variable<String>(name)],
    ).get();
    return found.isNotEmpty;
  }
}
