import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/fs_button.dart';
import '../../../design/fs_card.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_ruled.dart';
import '../../../design/fs_text_area.dart';
import '../../../design/fs_typography.dart';
import '../domain/journal_entry.dart';
import 'journal_view_model.dart';

/// What the box says after a save, in each case.
abstract final class WriteItDownText {
  static const String hint = 'Answer it honestly. Only you can read this.';
  static const String save = 'Save to my journal';
  static const String saving = 'Saving…';
  static const String empty = 'Write something first.';
  static const String saved = 'Saved to your journal. Only you can read it.';

  /// After a save where nothing is kept once the app closes (the web
  /// preview): it must not say "Saved".
  static const String savedNotKept =
      'Added to your journal for now. It is not kept when the app closes.';
  static const String failed =
      'That did not save. Your entry is still here. Try again.';
  static const String retryNote =
      'Saving here updates the same journal entry. To write a separate '
      'entry, discard this draft first.';

  /// When the entry this draft was saved as has since been changed or
  /// deleted in his journal.
  static const String separate = journalSeparateNotice;
  static const String discard = 'Discard draft and start a different entry';
  static const String discardSure = 'Tap again to discard this draft';
  static const String note =
      'Today’s reflection question starts the entry. Private, and never '
      'scored.';
}

/// The "Write it down" box under the day's reading: the reflection
/// question, a place to answer it, and "Save to my journal".
///
/// The prototype's `#jr-devo`. Writing here is optional: Amen does not
/// look at this box.
class WriteItDown extends ConsumerStatefulWidget {
  const WriteItDown({
    super.key,
    required this.prompt,
    required this.onOpenJournal,
  });

  /// The reading's reflection question.
  final String prompt;

  /// Opens the Journal page.
  final VoidCallback onOpenJournal;

  @override
  ConsumerState<WriteItDown> createState() => _WriteItDownState();
}

class _WriteItDownState extends ConsumerState<WriteItDown>
    with WidgetsBindingObserver {
  late final TextEditingController _text;
  final FocusNode _focus = FocusNode();

  /// Where the box and the Save button are on the page.
  final GlobalKey _boxPlace = GlobalKey();
  final GlobalKey _savePlace = GlobalKey();

  /// True after the first tap on Discard; the second tap discards.
  bool _discardArmed = false;

  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: ref.read(devotionalDraftProvider).text);
    _focus.addListener(_keepSaveInView);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focus
      ..removeListener(_keepSaveInView)
      ..dispose();
    _text.dispose();
    super.dispose();
  }

  /// The keyboard came up, changed height or went away.
  @override
  void didChangeMetrics() => _keepSaveInView();

  /// While he is writing in the box, keeps "Save to my journal" on the
  /// page under it.
  ///
  /// A text field brings only the line being typed into view. With the
  /// keyboard open the page is short, and that leaves the button under
  /// the box out of sight below the page's foot, as if there were no way
  /// to save.
  ///
  /// It runs one frame after the page has its new size: the text field
  /// brings its own line into view in the first, and this must come
  /// after that, not be undone by it.
  void _keepSaveInView() {
    if (!_focus.hasFocus) return;
    final binding = WidgetsBinding.instance;
    binding.addPostFrameCallback((_) {
      binding.addPostFrameCallback((_) => _showSave());
      binding.scheduleFrame();
    });
    binding.scheduleFrame();
  }

  void _showSave() {
    if (!mounted || !_focus.hasFocus) return;
    final box = _boxPlace.currentContext?.findRenderObject();
    final save = _savePlace.currentContext?.findRenderObject();
    final page = Scrollable.maybeOf(context)?.position;
    if (box is! RenderBox || save is! RenderBox || page == null) return;

    // Only if the box and the button fit on the page together. When what
    // he has written is too long for that, the line he is typing wins:
    // bringing the button up would push it off the top.
    final top = box.localToGlobal(Offset.zero).dy;
    final bottom = save.localToGlobal(Offset(0, save.size.height)).dy;
    if (bottom - top + _saveMargin > page.viewportDimension) return;

    // The least scroll that puts the button, with a little air under it,
    // on the page: nothing moves if it is there already.
    save.showOnScreen(
      rect: Rect.fromLTWH(
        0,
        0,
        save.size.width,
        save.size.height + _saveMargin,
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
    );
  }

  /// The space kept between the Save button and the foot of the page.
  static const double _saveMargin = 8;

  void _onDraft(DevotionalDraft? previous, DevotionalDraft next) {
    // A save or a discard emptied the draft: empty the box with it.
    if (previous != null && previous.clears != next.clears) _text.clear();
    if (next.status != DraftStatus.failed && _discardArmed) {
      setState(() => _discardArmed = false);
    }
  }

  void _discard() {
    if (!_discardArmed) {
      setState(() => _discardArmed = true);
      return;
    }
    ref.read(devotionalDraftProvider.notifier).discard();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DevotionalDraft>(devotionalDraftProvider, _onDraft);
    final draft = ref.watch(devotionalDraftProvider);
    final durable = ref.watch(journalDurableProvider);
    final colors = FsColors.of(context);
    final saving = draft.status == DraftStatus.saving;
    final note = FsText.bodySmall.copyWith(color: colors.textMuted);

    final (String? message, Color messageColor) = switch (draft.status) {
      DraftStatus.empty => (WriteItDownText.empty, colors.danger),
      DraftStatus.failed => (
        draft.separate ? WriteItDownText.separate : WriteItDownText.failed,
        colors.danger,
      ),
      DraftStatus.saved => (
        durable ? WriteItDownText.saved : WriteItDownText.savedNotKept,
        colors.text,
      ),
      DraftStatus.idle || DraftStatus.saving => (null, colors.text),
    };

    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FsRuled(
            color: colors.accent,
            child: Text(
              // The question he began to answer, if he has begun.
              draft.prompt ?? widget.prompt,
              key: const ValueKey<String>('fs-journal-prompt'),
              style: FsText.scriptureSmall.copyWith(color: colors.text),
            ),
          ),
          const SizedBox(height: 10),
          KeyedSubtree(
            key: _boxPlace,
            child: FsTextArea(
              key: const ValueKey<String>('fs-journal-box'),
              controller: _text,
              focusNode: _focus,
              semanticLabel: 'Your journal entry',
              hint: WriteItDownText.hint,
              maxLength: JournalText.maxLength,
              enabled: !saving,
              onChanged: (String text) {
                ref
                    .read(devotionalDraftProvider.notifier)
                    .typed(text, prompt: widget.prompt);
                // The box grows as he writes, and the button moves down.
                _keepSaveInView();
              },
            ),
          ),
          const SizedBox(height: 10),
          KeyedSubtree(
            key: _savePlace,
            child: FsButton(
              key: const ValueKey<String>('fs-journal-save'),
              label: saving ? WriteItDownText.saving : WriteItDownText.save,
              onPressed: saving
                  ? null
                  : () => ref
                        .read(devotionalDraftProvider.notifier)
                        .save(prompt: widget.prompt),
            ),
          ),
          if (!durable) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              journalNotSavedNotice,
              style: FsText.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          // Always in the tree, so a screen reader announces each change.
          Semantics(
            liveRegion: true,
            child: message == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      message,
                      key: const ValueKey<String>('fs-journal-message'),
                      style: FsText.bodySmall.copyWith(
                        color: messageColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
          if (draft.status == DraftStatus.saved) ...<Widget>[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: FsButton.mini(
                key: const ValueKey<String>('fs-journal-open'),
                label: 'My journal',
                onPressed: widget.onOpenJournal,
              ),
            ),
          ],
          if (draft.status == DraftStatus.failed) ...<Widget>[
            // Not once the draft is separate from its entry: saving it
            // then writes another entry, which the message above says.
            if (!draft.separate) ...<Widget>[
              const SizedBox(height: 8),
              Text(WriteItDownText.retryNote, style: note),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: FsButton.mini(
                key: const ValueKey<String>('fs-journal-discard'),
                label: _discardArmed
                    ? WriteItDownText.discardSure
                    : WriteItDownText.discard,
                onPressed: _discard,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(WriteItDownText.note, style: note),
        ],
      ),
    );
  }
}
