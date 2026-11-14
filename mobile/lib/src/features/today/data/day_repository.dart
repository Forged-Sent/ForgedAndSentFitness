import '../../../core/local_date.dart';
import '../domain/completion_event.dart';

/// The boundary between Today and wherever the day's boxes are kept.
///
/// Plain Dart. The app uses the Drift implementation on a phone and the
/// in-memory one in the web preview and in widget tests. Nothing here, and
/// nothing behind it, talks to Firebase.
abstract interface class DayRepository {
  /// Whether what is recorded survives closing the app. False only for the
  /// in-memory store, and the screen says so.
  bool get durable;

  /// One owner's boxes on one local day: the current state at once, then
  /// again after every change.
  Stream<DayRecord> watchDay(String ownerId, LocalDate day);

  /// For every day that has a done box, the items done on it. The streak is
  /// worked out from this.
  Stream<Map<LocalDate, Set<String>>> watchDoneByDay(String ownerId);

  /// Stores [event] and updates its day's state in one transaction.
  ///
  /// An event whose id is already stored changes nothing. An event whose
  /// target is the state the box already has is not stored.
  Future<RecordOutcome> record(CompletionEvent event);

  /// Every stored event for one box on one day, oldest first. For tests and
  /// for later sync; no screen reads it.
  Future<List<CompletionEvent>> eventsFor(
    String ownerId,
    LocalDate day,
    String item,
  );
}
