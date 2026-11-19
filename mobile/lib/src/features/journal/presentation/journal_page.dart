import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../design/fs_button.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_hero_header.dart';
import '../../../design/fs_label_caps.dart';
import '../../../design/fs_page_bar.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../domain/journal_entry.dart';
import 'journal_view_model.dart';

/// How much of an entry the list shows before "…". The prototype's 220.
const int journalPreviewLength = 220;

/// What the Journal page says when there is nothing in it.
const String journalEmptyText =
    'Nothing written yet. Write under today’s reading, or tap New entry '
    'and write about your workout, your day, your family or your faith.';

/// "My journal": his entries, newest first. Tapping one opens it.
///
/// The prototype's `drawJournalPage`, without its prayer tabs, tags and
/// search, which prompt P06 leaves for later.
class JournalPage extends ConsumerWidget {
  const JournalPage({
    super.key,
    required this.onBack,
    required this.onNewEntry,
    required this.onOpenEntry,
  });

  final VoidCallback onBack;
  final VoidCallback onNewEntry;
  final ValueChanged<String> onOpenEntry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = FsColors.of(context);
    final entries = ref.watch(journalEntriesProvider);
    final durable = ref.watch(journalDurableProvider);
    final today = ref.watch(todayDateProvider);
    final list = entries.value;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FsSpacing.page,
            20,
            FsSpacing.page,
            2,
          ),
          child: FsPageBar(onBack: onBack, trailing: 'Write it down'),
        ),
        const FsHeroHeader(kicker: 'Only you can read it', title: 'My journal'),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FsSpacing.page,
            FsSpacing.block,
            FsSpacing.page,
            FsSpacing.pageBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                child: FsButton.ghost(
                  key: const ValueKey<String>('fs-journal-new'),
                  label: 'New entry',
                  semanticLabel: 'New journal entry',
                  onPressed: onNewEntry,
                ),
              ),
              if (!durable) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  journalNotSavedNotice,
                  style: FsText.bodySmall.copyWith(color: colors.danger),
                ),
              ],
              const SizedBox(height: 10),
              if (list == null)
                Text(
                  entries.hasError
                      ? 'Your journal could not be read.'
                      : 'Loading your journal…',
                  key: const ValueKey<String>('fs-journal-state'),
                  style: FsText.body.copyWith(color: colors.text),
                )
              else if (list.isEmpty)
                Text(
                  journalEmptyText,
                  key: const ValueKey<String>('fs-journal-empty'),
                  style: FsText.body.copyWith(color: colors.textMuted),
                )
              else
                for (final entry in list)
                  _EntryRow(
                    entry: entry,
                    when: journalWhen(entry, today),
                    onOpen: () => onOpenEntry(entry.id),
                  ),
              if (list == null && entries.hasError) ...<Widget>[
                const SizedBox(height: 14),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FsButton.ghost(
                    label: 'Try again',
                    onPressed: () => ref.invalidate(journalEntriesProvider),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One entry in the list: when it was written, then how it starts.
class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.when,
    required this.onOpen,
  });

  final JournalEntry entry;
  final String when;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final preview = entry.text.length > journalPreviewLength
        ? '${entry.text.substring(0, journalPreviewLength)}…'
        : entry.text;

    return Semantics(
      button: true,
      label: 'Open entry from $when. $preview',
      excludeSemantics: true,
      onTap: onOpen,
      child: InkWell(
        key: ValueKey<String>('fs-journal-entry-${entry.id}'),
        onTap: onOpen,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.hairline)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                FsLabelCaps(
                  when,
                  style: FsText.kicker,
                  color: colors.highlight,
                ),
                const SizedBox(height: 4),
                Text(preview, style: FsText.body.copyWith(color: colors.text)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
