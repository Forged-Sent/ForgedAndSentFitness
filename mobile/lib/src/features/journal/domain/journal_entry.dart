import '../../../core/local_date.dart';

/// Where an entry was first written.
enum JournalSource {
  /// The "Write it down" box under the day's reading.
  devotional('devotional'),

  /// The pen: a new entry started from the Journal page or Today's header.
  pen('pen');

  const JournalSource(this.stored);

  /// The word kept in the database.
  final String stored;

  static JournalSource parse(String stored) => values.firstWhere(
    (source) => source.stored == stored,
    orElse: () => throw FormatException('Not a journal source', stored),
  );
}

/// The rules for what a man may save as an entry's text.
abstract final class JournalText {
  /// The prototype's limit on the box (`maxlength="4000"`).
  static const int maxLength = 4000;

  /// The text as it is saved: without the blank space around it. Null when
  /// there is nothing to save or it is too long.
  static String? clean(String typed) {
    final text = typed.trim();
    if (text.isEmpty || text.length > maxLength) return null;
    return text;
  }
}

/// One private journal entry as it stands now.
///
/// Decision Q8: journal entries are kept on the device only. An entry is
/// private to its owner: it is never part of a shared document, a score, a
/// log line or an analytics event. [toString] leaves the words out so that
/// printing an entry by accident cannot leak them.
class JournalEntry {
  JournalEntry({
    required this.id,
    required this.ownerId,
    required this.day,
    required this.createdAtUtc,
    required this.utcOffset,
    required this.text,
    required this.source,
    required this.prompt,
    required this.revision,
    this.editedAtUtc,
  }) : assert(createdAtUtc.isUtc, 'createdAtUtc must be a UTC DateTime');

  /// Client-generated once, when the entry is first saved, and its only
  /// key. Saving again with the same id changes this entry; it can never
  /// make a second one.
  final String id;

  final String ownerId;

  /// The local date the entry was first saved on (decision Q9's day
  /// boundary: the phone's date at that moment).
  final LocalDate day;

  /// When it was first saved, as an instant in UTC, and the phone's offset
  /// from UTC at that moment. Neither is folded into the other.
  final DateTime createdAtUtc;
  final Duration utcOffset;

  /// What he wrote.
  final String text;

  final JournalSource source;

  /// The reflection question the entry answers, for an entry written under
  /// a reading. Empty otherwise.
  final String prompt;

  /// When it was last changed, or null if it never was.
  final DateTime? editedAtUtc;

  /// How many times this entry has been written, counting from 1. A later
  /// sync would use it to tell a newer copy from an older one.
  final int revision;

  /// The time on his phone's clock when he first saved it.
  DateTime get createdAtLocal => createdAtUtc.add(utcOffset);

  @override
  String toString() =>
      'JournalEntry($id, $day, ${source.stored}, revision $revision, '
      '${text.length} characters)';
}

/// What a save or a delete asks the store to do.
enum JournalChangeKind {
  save('save'),
  delete('delete');

  const JournalChangeKind(this.stored);

  final String stored;
}

/// One save or one delete of one entry: the thing a man did, with the id it
/// was given on the phone.
///
/// The store writes the change and the entry it produces in one
/// transaction. The list of changes never holds any text; it is what a
/// later sync (decision Q8: not built) would work from.
class JournalChange {
  JournalChange._({
    required this.id,
    required this.ownerId,
    required this.entryId,
    required this.kind,
    required this.atUtc,
    required this.utcOffset,
    required this.day,
    required this.text,
    required this.source,
    required this.prompt,
  });

  /// Saves [text] as the entry [entryId]: a new entry if there is none with
  /// that id, otherwise a change to it.
  ///
  /// [at] is the phone's local time. For a new entry it must be the time of
  /// the first save attempt, kept through every retry, so a retry writes
  /// the same entry on the same day.
  ///
  /// Throws an [ArgumentError] if [text] is empty or too long. Screens
  /// check that first with [JournalText.clean].
  factory JournalChange.save({
    required String id,
    required String ownerId,
    required String entryId,
    required String text,
    required JournalSource source,
    required DateTime at,
    String prompt = '',
  }) {
    final clean = JournalText.clean(text);
    if (clean == null) {
      throw ArgumentError(
        'A journal entry needs some text, at most '
        '${JournalText.maxLength} characters.',
      );
    }
    return JournalChange._(
      id: id,
      ownerId: ownerId,
      entryId: entryId,
      kind: JournalChangeKind.save,
      atUtc: at.toUtc(),
      utcOffset: at.timeZoneOffset,
      day: LocalDate.of(at),
      text: clean,
      source: source,
      prompt: prompt,
    );
  }

  /// Deletes the entry [entryId].
  factory JournalChange.delete({
    required String id,
    required String ownerId,
    required String entryId,
    required DateTime at,
  }) => JournalChange._(
    id: id,
    ownerId: ownerId,
    entryId: entryId,
    kind: JournalChangeKind.delete,
    atUtc: at.toUtc(),
    utcOffset: at.timeZoneOffset,
    day: LocalDate.of(at),
    text: '',
    source: JournalSource.pen,
    prompt: '',
  );

  /// Client-generated, and the change's only key. Sending the same change
  /// twice applies it once.
  final String id;

  final String ownerId;
  final String entryId;
  final JournalChangeKind kind;

  /// When he tapped, as an instant in UTC, and the phone's offset then.
  final DateTime atUtc;
  final Duration utcOffset;

  /// The local date of the tap. A new entry is filed under it.
  final LocalDate day;

  /// For a save: the text, already cleaned. Empty for a delete.
  final String text;

  /// For a save that makes a new entry: where it was written and the
  /// question it answers. An existing entry keeps its own.
  final JournalSource source;
  final String prompt;

  @override
  String toString() =>
      'JournalChange($id, ${kind.stored}, entry $entryId, '
      '${text.length} characters)';
}

/// What the store did with a change.
enum JournalOutcome {
  /// The change was stored and the entry now reflects it.
  applied,

  /// A change with this id is already stored. Nothing was written.
  duplicate,

  /// The entry was deleted earlier (or, for a delete, never existed).
  /// Nothing was written.
  entryGone,
}
