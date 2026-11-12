import '../../../core/local_date.dart';

/// The box ids the app knows. Only the devotional can be completed in build
/// step S1.
abstract final class DayItems {
  static const String devotional = 'devotional';
}

/// One tap that checks or clears a box. Events are only ever added: an undo
/// is a second event, never an edit of the first.
///
/// Design: `docs/reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md`,
/// journey J1, option A.
class CompletionEvent {
  /// An event exactly as it is stored. [tappedAtUtc] must be a UTC
  /// `DateTime`.
  CompletionEvent({
    required this.id,
    required this.ownerId,
    required this.day,
    required this.item,
    required this.done,
    required this.tappedAtUtc,
    required this.utcOffset,
    this.replacesEventId,
  }) : assert(tappedAtUtc.isUtc, 'tappedAtUtc must be a UTC DateTime');

  /// A completion tapped at [tappedAt], the phone's local time. Its day is
  /// the local date at the moment of the tap (decision Q9), read from
  /// [tappedAt] here and nowhere else.
  CompletionEvent.complete({
    required this.id,
    required this.ownerId,
    required this.item,
    required DateTime tappedAt,
    this.replacesEventId,
  }) : day = LocalDate.of(tappedAt),
       done = true,
       tappedAtUtc = tappedAt.toUtc(),
       utcOffset = tappedAt.timeZoneOffset;

  /// An undo of the completion that set [completion]. It is filed under the
  /// day that completion was recorded on, whatever the clock says now, so a
  /// phone whose clock moved to another day still clears the right box.
  CompletionEvent.undo({
    required this.id,
    required this.ownerId,
    required this.item,
    required this.day,
    required ItemState completion,
    required DateTime tappedAt,
  }) : done = false,
       tappedAtUtc = tappedAt.toUtc(),
       utcOffset = tappedAt.timeZoneOffset,
       replacesEventId = completion.latestEventId;

  /// Client-generated, and the event's only key. Sending the same event
  /// twice stores it once.
  final String id;

  final String ownerId;

  /// The day whose box this event sets.
  final LocalDate day;

  final String item;

  /// The state the tap asked for. An event states its target; it does not
  /// toggle.
  final bool done;

  /// When the tap happened, as an instant in UTC. Kept for the record and
  /// for display; it is never used to decide which of two events is the
  /// later one.
  final DateTime tappedAtUtc;

  /// The phone's offset from UTC at that moment. Stored beside the instant,
  /// so the time on the phone's clock can be shown again later, on any
  /// device, without changing the instant.
  final Duration utcOffset;

  /// The local calendar day the phone showed when the tap was made: the
  /// instant moved by the offset. Not always [day]: an undo is filed under
  /// the day of the completion it undoes.
  LocalDate get tapLocalDate => LocalDate.of(tappedAtUtc.add(utcOffset));

  /// The event that set this box when the tap was made, if any. Unused on
  /// one device; from build step S4 the server orders events from two
  /// devices by it.
  final String? replacesEventId;
}

/// Where one box of one day stands.
class ItemState {
  const ItemState({
    required this.done,
    required this.latestEventId,
    required this.latestCounter,
  });

  final bool done;

  /// The event that put the box in this state.
  final String latestEventId;

  /// That event's place in this database's order of events.
  final int latestCounter;

  @override
  bool operator ==(Object other) =>
      other is ItemState &&
      other.done == done &&
      other.latestEventId == latestEventId &&
      other.latestCounter == latestCounter;

  @override
  int get hashCode => Object.hash(done, latestEventId, latestCounter);
}

/// One owner's boxes on one local day. A box with no entry has never been
/// touched.
class DayRecord {
  const DayRecord({
    required this.ownerId,
    required this.day,
    this.items = const <String, ItemState>{},
  });

  final String ownerId;
  final LocalDate day;
  final Map<String, ItemState> items;

  bool isDone(String item) => items[item]?.done ?? false;

  @override
  bool operator ==(Object other) =>
      other is DayRecord &&
      other.ownerId == ownerId &&
      other.day == day &&
      _sameItems(other.items, items);

  @override
  int get hashCode => Object.hash(
    ownerId,
    day,
    Object.hashAllUnordered(
      items.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );
}

bool _sameItems(Map<String, ItemState> a, Map<String, ItemState> b) {
  if (a.length != b.length) return false;
  for (final entry in a.entries) {
    if (b[entry.key] != entry.value) return false;
  }
  return true;
}

/// What storing an event did.
enum RecordOutcome {
  /// The event was stored and the box now has the state it asked for.
  applied,

  /// An event with this id is already stored. Nothing changed.
  duplicate,

  /// The box already had the state the event asked for, so nothing was
  /// stored. This is what makes a double tap on Amen harmless.
  alreadyInState,
}

/// Decides what to do with [event], given whether its id is already stored
/// and the box's [current] state. Both stores use this, so the rule exists
/// once.
RecordOutcome decideOutcome({
  required CompletionEvent event,
  required bool idAlreadyStored,
  required ItemState? current,
}) {
  if (idAlreadyStored) return RecordOutcome.duplicate;
  if ((current?.done ?? false) == event.done) {
    return RecordOutcome.alreadyInState;
  }
  return RecordOutcome.applied;
}
