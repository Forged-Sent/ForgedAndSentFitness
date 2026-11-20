import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../core/event_id.dart';
import '../../../design/fs_button.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_label_caps.dart';
import '../../../design/fs_page_bar.dart';
import '../../../design/fs_ruled.dart';
import '../../../design/fs_section_head.dart';
import '../../../design/fs_text_area.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../domain/journal_entry.dart';
import 'journal_view_model.dart';

/// What the entry page says, in each case.
abstract final class JournalEntryText {
  static const String private =
      'Private. Write about anything: a lift, your work, your family, your '
      'faith. Only you can read your journal. It is never scored.';
  static const String hint = 'Write it down.';
  static const String empty = 'Write something first.';
  static const String failed =
      'That did not save. Your entry is still here. Try again.';
  static const String deleteFailed =
      'That did not delete. Your entry is still here. Try again.';
  static const String delete = 'Delete this entry';
  static const String deleteSure = 'Tap again to delete this entry';
  static const String gone = 'This entry is no longer in your journal.';

  /// A save was refused because the entry was changed or deleted
  /// somewhere else after this page was filled from it.
  static const String separate = journalSeparateNotice;
}

/// One entry, open to be written or changed.
///
/// With an [entryId] it edits that entry and can delete it. Without one it
/// writes a new entry. The prototype's `openJournal` dialog, as a page: a
/// page keeps the box above the keyboard and gives Android's back button
/// one clear meaning. Leaving without saving keeps nothing, as closing the
/// prototype's dialog does.
class JournalEntryPage extends ConsumerStatefulWidget {
  const JournalEntryPage({super.key, this.entryId, required this.onDone});

  /// The entry to edit, or null to write a new one.
  final String? entryId;

  /// Returns to the Journal page.
  final VoidCallback onDone;

  @override
  ConsumerState<JournalEntryPage> createState() => _JournalEntryPageState();
}

class _JournalEntryPageState extends ConsumerState<JournalEntryPage> {
  final TextEditingController _text = TextEditingController();

  /// The entry's text has been put in the box. Done once, so what he types
  /// is not replaced when the list is read again.
  bool _filled = false;

  /// The revision of the entry the box was filled from. A save names it,
  /// so words he was never shown here are not replaced.
  int? _filledRevision;

  /// The words the box was filled with: what is in the box and is not
  /// these is his, typed here and not yet saved.
  String? _filledText;

  /// The id of every change this page has sent for its entry, stored or
  /// not: a save of its own that was stored without an answer is not
  /// "somewhere else".
  final Set<String> _sent = <String>{};

  /// True once a save was refused because the entry was changed or deleted
  /// somewhere else, or once the entry was deleted somewhere else while he
  /// had words here that were not saved. His words stay in the box and are
  /// no longer that entry's: the page goes on as a new entry.
  bool _separate = false;

  /// For a new entry: its id and time, made at the first save attempt and
  /// kept through every retry, so a retry can never make a second entry.
  String? _newId;
  DateTime? _newAt;

  /// The last save sent and not known to have been stored: its change id
  /// and its text. Trying the same text again sends the same change.
  ({String changeId, String text})? _attempt;

  bool _busy = false;
  String? _message;
  bool _deleteArmed = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save(JournalEntry? editing) async {
    if (_busy) return;
    final text = JournalText.clean(_text.text);
    if (text == null) {
      setState(() => _message = JournalEntryText.empty);
      return;
    }
    final String entryId;
    final DateTime at;
    if (editing != null) {
      entryId = editing.id;
      at = ref.read(clockProvider).now();
    } else {
      entryId = _newId ??= ref.read(eventIdProvider)();
      at = _newAt ??= ref.read(clockProvider).now();
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final attempt = _attempt != null && _attempt!.text == text
        ? _attempt!
        : (changeId: ref.read(eventIdProvider)(), text: text);
    _attempt = attempt;
    // Recorded before the answer comes: a save can be stored and its
    // answer lost.
    _sent.add(attempt.changeId);
    final result = await ref
        .read(journalActionsProvider)
        .save(
          changeId: attempt.changeId,
          entryId: entryId,
          text: text,
          at: at,
          baseRevision: editing == null ? null : _filledRevision,
          knownChanges: Set<String>.of(_sent),
        );
    if (!mounted) return;
    switch (result) {
      case EntrySave.saved:
        widget.onDone();
      case EntrySave.failed:
        setState(() {
          _busy = false;
          _message = JournalEntryText.failed;
        });
      case EntrySave.separate:
        // Nothing was written over the entry as it now stands.
        setState(() {
          _busy = false;
          _goOnAsNewEntry();
        });
    }
  }

  /// His words stay in the box and stop being the entry's: the next save
  /// gets a new id and is its own entry, and the page says why.
  void _goOnAsNewEntry() {
    _separate = true;
    _newId = null;
    _newAt = null;
    _attempt = null;
    _sent.clear();
    _deleteArmed = false;
    _message = JournalEntryText.separate;
  }

  /// True when the box holds words of his that were typed here over an
  /// entry and are not saved.
  bool get _hasUnsavedWords {
    final typed = _text.text.trim();
    return _filled && typed.isNotEmpty && typed != _filledText;
  }

  Future<void> _delete(JournalEntry entry) async {
    if (_busy) return;
    if (!_deleteArmed) {
      setState(() => _deleteArmed = true);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final deleted = await ref.read(journalActionsProvider).delete(entry.id);
    if (!mounted) return;
    if (deleted) {
      widget.onDone();
      return;
    }
    setState(() {
      _busy = false;
      _deleteArmed = false;
      _message = JournalEntryText.deleteFailed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final durable = ref.watch(journalDurableProvider);
    final today = ref.watch(todayDateProvider);
    final entries = ref.watch(journalEntriesProvider);

    JournalEntry? editing;
    if (widget.entryId != null && !_separate) {
      final list = entries.value;
      if (list == null) {
        return _plain(
          entries.hasError
              ? 'Your journal could not be read.'
              : 'Loading your entry…',
        );
      }
      for (final entry in list) {
        if (entry.id == widget.entryId) editing = entry;
      }
      if (editing == null) {
        // His own save or delete is on its way; its answer decides.
        if (_busy) return _plain('');
        // Gone, and not from this page: deleted somewhere else, or never
        // here. With nothing of his in the box there is nothing to keep.
        if (!_hasUnsavedWords) return _plain(JournalEntryText.gone);
        // Deleted somewhere else while he was changing it here. The box
        // and what he typed stay; the page goes on as a new entry.
        _goOnAsNewEntry();
      } else if (!_filled) {
        _filled = true;
        _filledRevision = editing.revision;
        _filledText = editing.text;
        _text.text = editing.text;
      }
    }
    final isNew = widget.entryId == null || _separate;

    final when = editing == null
        ? '${shortDate(today)} · ${clockTime(ref.read(clockProvider).now())}'
        : '${shortDate(editing.day)} · ${clockTime(editing.createdAtLocal)}';
    final note = FsText.bodySmall.copyWith(color: colors.textMuted);

    // Not a lazy list: the page is short, and every control on it should
    // exist for a screen reader whether or not it is on screen.
    final page = SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        FsSpacing.page,
        20,
        FsSpacing.page,
        FsSpacing.pageBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FsPageBar(onBack: _leave, trailing: 'Write it down'),
          const SizedBox(height: FsSpacing.block),
          FsLabelCaps(when, style: FsText.kicker, color: colors.highlight),
          const SizedBox(height: 4),
          FsSectionHead(title: isNew ? 'Journal' : 'Edit your entry'),
          const SizedBox(height: 10),
          Text(JournalEntryText.private, style: note),
          if (editing != null && editing.prompt.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            FsRuled(
              color: colors.accent,
              child: Text(
                editing.prompt,
                style: FsText.scriptureSmall.copyWith(color: colors.text),
              ),
            ),
          ],
          const SizedBox(height: 12),
          FsTextArea(
            key: const ValueKey<String>('fs-entry-box'),
            controller: _text,
            semanticLabel: 'Your journal entry',
            hint: JournalEntryText.hint,
            maxLength: JournalText.maxLength,
            minLines: 7,
            enabled: !_busy,
          ),
          if (!durable) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              journalNotSavedNotice,
              style: FsText.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          Semantics(
            liveRegion: true,
            child: _message == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _message!,
                      key: const ValueKey<String>('fs-entry-message'),
                      style: FsText.bodySmall.copyWith(
                        color: colors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
          FsButton(
            key: const ValueKey<String>('fs-entry-save'),
            label: _busy
                ? 'Saving…'
                : isNew
                ? 'Save'
                : 'Save changes',
            onPressed: _busy ? null : () => _save(editing),
          ),
          const SizedBox(height: 10),
          FsButton.ghost(
            key: const ValueKey<String>('fs-entry-close'),
            label: 'Close',
            onPressed: _busy ? null : widget.onDone,
          ),
          if (editing != null) ...<Widget>[
            const SizedBox(height: FsSpacing.block),
            Align(
              alignment: Alignment.centerLeft,
              child: FsButton.mini(
                key: const ValueKey<String>('fs-entry-delete'),
                label: _deleteArmed
                    ? JournalEntryText.deleteSure
                    : JournalEntryText.delete,
                onPressed: _busy ? null : () => _delete(editing!),
              ),
            ),
          ],
        ],
      ),
    );
    // While a save or a delete is on its way he stays on the page: if it
    // fails, his words and the line that says so must still be here.
    return PopScope(canPop: !_busy, child: page);
  }

  /// The page bar's Back. It waits, as Close does, while a change is on
  /// its way.
  void _leave() {
    if (!_busy) widget.onDone();
  }

  Widget _plain(String message) {
    final colors = FsColors.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        FsSpacing.page,
        20,
        FsSpacing.page,
        FsSpacing.pageBottom,
      ),
      children: <Widget>[
        FsPageBar(onBack: widget.onDone, trailing: 'Write it down'),
        const SizedBox(height: FsSpacing.block),
        Text(
          message,
          key: const ValueKey<String>('fs-entry-state'),
          style: FsText.body.copyWith(color: colors.text),
        ),
      ],
    );
  }
}
