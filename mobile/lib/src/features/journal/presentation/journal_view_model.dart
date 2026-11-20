import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/local_store.dart';
import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../core/event_id.dart';
import '../../../core/local_date.dart';
import '../domain/journal_entry.dart';

/// What every journal screen says where nothing is kept after the app
/// closes (the web preview).
const String journalNotSavedNotice = 'Nothing you write here is saved.';

/// What the box under the reading and the entry page say when the entry
/// his words belonged to was changed or deleted in his journal in the
/// meantime. His words stay in the box, and the next save writes them as
/// an entry of their own.
const String journalSeparateNotice =
    'Not saved yet. This entry was changed or deleted in your journal. '
    'Save again to keep these words as a new entry.';

/// His entries, newest first, straight from the store.
///
/// Riverpod's automatic retry is off, so a failure shows at once.
final journalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  final store = ref.watch(localStoreProvider);
  return store.journal.watchEntries(store.ownerId);
}, retry: (retryCount, error) => null);

/// Whether what he writes survives closing the app.
final journalDurableProvider = Provider<bool>(
  (ref) => ref.watch(localStoreProvider).journal.durable,
);

/// The line above an entry: "Today · Devotional", "Today · 7:30 AM",
/// "Yesterday", "Tue, Nov 10". The prototype's `jrWhen`.
String journalWhen(JournalEntry entry, LocalDate today) {
  final day = entry.day == today
      ? 'Today'
      : entry.day == today.previous
      ? 'Yesterday'
      : shortDate(entry.day);
  if (entry.source == JournalSource.devotional) return '$day · Devotional';
  return entry.day == today ? '$day · ${clockTime(entry.createdAtLocal)}' : day;
}

/// Where the box under the reading stands.
enum DraftStatus {
  /// Nothing to say: he is writing, or has not started.
  idle,

  /// He tapped Save with nothing written.
  empty,

  /// The save is on its way to the database.
  saving,

  /// The transaction committed. Only now does the screen say "Saved".
  saved,

  /// The save did not commit. His text is still in the box.
  failed,
}

/// What he has written under today's reading and not yet saved.
///
/// It lives as long as the app is open, so leaving the reading and coming
/// back does not lose it. It is never written anywhere until he taps Save.
class DevotionalDraft {
  const DevotionalDraft({
    this.text = '',
    this.status = DraftStatus.idle,
    this.prompt,
    this.entryId,
    this.firstSaveAt,
    this.attempt,
    this.sent = const <String>{},
    this.clears = 0,
  });

  final String text;
  final DraftStatus status;

  /// The reflection question he was looking at when he began to write.
  /// The entry answers this one, also if midnight passes and the page
  /// moves on to the next day's reading before he saves. Null until he
  /// has typed something.
  final String? prompt;

  /// The id his entry will have. Made at the first save attempt and kept
  /// through every retry, so a retry can never make a second entry. The
  /// prototype's `jrDraftId`.
  final String? entryId;

  /// The moment of that first attempt. The entry is filed under its date.
  final DateTime? firstSaveAt;

  /// The last save that was sent and not known to have been stored: its
  /// change id and the exact text it carried. Trying the same text again
  /// sends the same change, so if the first one was stored after all the
  /// retry changes nothing.
  final ({String changeId, String text})? attempt;

  /// The id of every change this draft has sent for its entry, stored or
  /// not. A later save names them, so the store can tell an entry that is
  /// as this draft left it from one he has since changed in his journal.
  final Set<String> sent;

  /// Goes up each time the box is emptied by a save or a discard, so the
  /// screen knows to clear what is typed.
  final int clears;

  /// True when the entry this draft was saved as has since been changed or
  /// deleted in his journal. The draft no longer belongs to that entry: his
  /// words are still in the box, and saving them writes a separate entry.
  bool get separate => status == DraftStatus.failed && entryId == null;

  DevotionalDraft _with({
    String? text,
    DraftStatus? status,
    String? prompt,
    String? entryId,
    DateTime? firstSaveAt,
    ({String changeId, String text})? attempt,
  }) => DevotionalDraft(
    text: text ?? this.text,
    status: status ?? this.status,
    prompt: prompt ?? this.prompt,
    entryId: entryId ?? this.entryId,
    firstSaveAt: firstSaveAt ?? this.firstSaveAt,
    attempt: attempt ?? this.attempt,
    sent: sent,
    clears: clears,
  );
}

final devotionalDraftProvider =
    NotifierProvider<DevotionalDraftNotifier, DevotionalDraft>(
      DevotionalDraftNotifier.new,
    );

class DevotionalDraftNotifier extends Notifier<DevotionalDraft> {
  @override
  DevotionalDraft build() {
    // A different member's store starts with an empty box.
    ref.watch(localStoreProvider);
    return const DevotionalDraft();
  }

  /// He typed, with [prompt] on screen. A message about the last save no
  /// longer applies, except that a failed save keeps offering the retry.
  void typed(String text, {required String prompt}) {
    final draft = state;
    if (draft.status == DraftStatus.saving) return;
    // He has started once a save was tried, or while there are words in
    // the box. Emptying the box before any save is starting over.
    final started =
        draft.entryId != null ||
        (draft.text.trim().isNotEmpty && text.trim().isNotEmpty);
    state = DevotionalDraft(
      text: text,
      status: draft.status == DraftStatus.failed
          ? DraftStatus.failed
          : DraftStatus.idle,
      // The question is fixed when he starts, and let go if he empties
      // the box before ever trying to save.
      prompt: started
          ? draft.prompt
          : text.trim().isEmpty
          ? null
          : prompt,
      entryId: draft.entryId,
      firstSaveAt: draft.firstSaveAt,
      attempt: draft.attempt,
      sent: draft.sent,
      clears: draft.clears,
    );
  }

  /// Saves what is in the box as one journal entry. It answers the
  /// question he began with; [prompt], the one on screen now, is used only
  /// if the draft has none.
  Future<void> save({required String prompt}) async {
    final draft = state;
    if (draft.status == DraftStatus.saving) return;
    final text = JournalText.clean(draft.text);
    if (text == null) {
      state = draft._with(status: DraftStatus.empty);
      return;
    }

    final store = ref.read(localStoreProvider);
    final entryId = draft.entryId ?? ref.read(eventIdProvider)();
    final at = draft.firstSaveAt ?? ref.read(clockProvider).now();
    final answered = draft.prompt ?? prompt;
    final attempt = draft.attempt != null && draft.attempt!.text == text
        ? draft.attempt!
        : (changeId: ref.read(eventIdProvider)(), text: text);
    // Recorded before the answer comes: a save can be stored and its
    // answer lost.
    final sent = <String>{...draft.sent, attempt.changeId};
    state = DevotionalDraft(
      text: draft.text,
      status: DraftStatus.saving,
      prompt: answered,
      entryId: entryId,
      firstSaveAt: at,
      attempt: attempt,
      sent: sent,
      clears: draft.clears,
    );

    JournalOutcome? outcome;
    try {
      outcome = await store.journal.apply(
        JournalChange.save(
          id: attempt.changeId,
          ownerId: store.ownerId,
          entryId: entryId,
          text: text,
          source: JournalSource.devotional,
          at: at,
          prompt: answered,
          // If he has changed this entry in his journal since an earlier
          // attempt of this draft was stored, his newer words stand.
          knownChanges: draft.sent,
        ),
      );
    } catch (_) {
      // Nothing about the failure is logged: the message could carry text.
      outcome = null;
    }
    if (!ref.mounted) return;

    if (outcome == JournalOutcome.applied ||
        outcome == JournalOutcome.duplicate) {
      state = DevotionalDraft(
        status: DraftStatus.saved,
        clears: draft.clears + 1,
      );
      return;
    }
    // The save did not commit, or its entry was deleted or changed in his
    // journal in the meantime. A deleted entry cannot be written again,
    // and one he has changed must not be replaced by this older draft, so
    // in both cases the next try gets a new id and is a separate entry.
    // Otherwise the ids are kept and the retry sends the same change.
    final gone =
        outcome == JournalOutcome.entryGone ||
        outcome == JournalOutcome.changedElsewhere;
    state = DevotionalDraft(
      text: draft.text,
      status: DraftStatus.failed,
      prompt: answered,
      entryId: gone ? null : entryId,
      firstSaveAt: gone ? null : at,
      attempt: gone ? null : attempt,
      sent: gone ? const <String>{} : sent,
      clears: draft.clears,
    );
  }

  /// Throws the draft away, so the next save starts a different entry.
  void discard() {
    if (state.status == DraftStatus.saving) return;
    state = DevotionalDraft(clears: state.clears + 1);
  }
}

/// What became of a save from the entry page.
enum EntrySave {
  /// The transaction committed: his words are the entry.
  saved,

  /// Nothing was stored. The same save can be tried again.
  failed,

  /// Nothing was stored, because the entry was changed or deleted
  /// somewhere else since this page was filled from it. His words are not
  /// that entry's any more.
  separate,
}

/// Saves and deletes from the entry page.
class JournalActions {
  JournalActions(this._ref);

  final Ref _ref;

  /// Saves [text] as the entry [entryId]. For a new entry, [at] is the
  /// time of its first save attempt.
  ///
  /// [changeId] names this save. A retry of the same text passes the same
  /// one, so a save that was stored without its answer coming back is not
  /// stored a second time.
  ///
  /// The page says what it knows of the entry, so that it never replaces
  /// words it has not shown him: [baseRevision], the revision its box was
  /// filled from (null for a new entry), and [knownChanges], every change
  /// the page itself has sent for this entry.
  Future<EntrySave> save({
    required String changeId,
    required String entryId,
    required String text,
    required DateTime at,
    required int? baseRevision,
    required Set<String> knownChanges,
  }) async {
    final store = _ref.read(localStoreProvider);
    try {
      final outcome = await store.journal.apply(
        JournalChange.save(
          id: changeId,
          ownerId: store.ownerId,
          entryId: entryId,
          text: text,
          source: JournalSource.pen,
          at: at,
          baseRevision: baseRevision,
          knownChanges: knownChanges,
        ),
      );
      return switch (outcome) {
        JournalOutcome.applied || JournalOutcome.duplicate => EntrySave.saved,
        JournalOutcome.entryGone ||
        JournalOutcome.changedElsewhere => EntrySave.separate,
      };
    } catch (_) {
      return EntrySave.failed;
    }
  }

  /// Deletes the entry. True only when the transaction committed.
  Future<bool> delete(String entryId) async {
    final store = _ref.read(localStoreProvider);
    try {
      await store.journal.apply(
        JournalChange.delete(
          id: _ref.read(eventIdProvider)(),
          ownerId: store.ownerId,
          entryId: entryId,
          at: _ref.read(clockProvider).now(),
        ),
      );
      // Already gone is as good as deleted.
      return true;
    } catch (_) {
      return false;
    }
  }
}

final journalActionsProvider = Provider<JournalActions>(JournalActions.new);
