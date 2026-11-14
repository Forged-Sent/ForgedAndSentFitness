import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../design/fs_box_row.dart';
import '../../../design/fs_button.dart';
import '../../../design/fs_card.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_hero_header.dart';
import '../../../design/fs_label_caps.dart';
import '../../../design/fs_progress_ring.dart';
import '../../../design/fs_section_head.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../domain/day_box.dart';
import 'today_view_model.dart';

/// What every screen says where nothing is kept after the app closes: the
/// web preview, or a phone whose storage could not be opened.
const String notSavedNotice = 'Nothing you check here is saved.';

/// What stands beside point values wherever they are shown (decision Q5).
const String previewPointsNotice = 'Points: preview, not official';

/// "+2 pts", "+1 pt".
String pointsLabel(int points) => '+$points ${points == 1 ? 'pt' : 'pts'}';

/// The streak line in Today's header. Decision Q6: the streak counts days
/// with the devotional done, so the prototype's "Full-day streak" wording
/// is not used.
String streakLine(int days) => days > 0
    ? 'Streak: $days ${days == 1 ? 'day' : 'days'}'
    : 'Start today. Grace for yesterday.';

/// Today: the date, the mission line, the progress ring and the day's
/// boxes. Only the devotional can be opened and checked in build step S1.
class TodayPage extends ConsumerWidget {
  const TodayPage({
    super.key,
    required this.onOpenDevotional,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenDevotional;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(todayDateProvider);
    final state = ref.watch(todayViewModelProvider);
    // While a new value is on its way (a box was just checked, or midnight
    // passed) the last one stays on screen instead of a loading card.
    final view = state.value;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        FsHeroHeader(
          large: true,
          kicker: heroDateLine(date),
          note: view == null ? null : streakLine(view.streakDays),
          title: 'Today’s Mission',
          subtitle: view?.missionLine,
          actions: <FsHeroAction>[
            const FsHeroAction(
              FsHeroActionKind.search,
              label: 'Search how the app works',
            ),
            const FsHeroAction(
              FsHeroActionKind.help,
              label: 'How this page works',
            ),
            const FsHeroAction(
              FsHeroActionKind.journal,
              label: 'New journal entry',
            ),
            const FsHeroAction(FsHeroActionKind.tags, label: 'Tags'),
            FsHeroAction(
              FsHeroActionKind.profile,
              label: 'Settings',
              onPressed: onOpenSettings,
            ),
          ],
        ),
        if (view != null) _ProgressPanel(view: view),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FsSpacing.page,
            FsSpacing.block,
            FsSpacing.page,
            FsSpacing.pageBottom,
          ),
          child: view != null
              ? _BoxesCard(view: view, onOpenDevotional: onOpenDevotional)
              : state.hasError
              ? _LoadFailedCard(
                  onRetry: () =>
                      ref.read(todayViewModelProvider.notifier).retry(),
                )
              : const _LoadingCard(),
        ),
      ],
    );
  }
}

/// The dark panel under the header: the ring, then one line per group of
/// boxes and the streak. The prototype's `.ready`, without its week-points
/// line: the app computes no totals (decision Q5).
class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({required this.view});

  final TodayView view;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      for (final category in BoxCategory.values)
        (
          category.label,
          '${view.countsFor(category).done} of '
              '${view.countsFor(category).total}',
        ),
      ('Streak', '${view.streakDays} ${view.streakDays == 1 ? 'day' : 'days'}'),
    ];

    return ColoredBox(
      color: FsColors.panel,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: FsSpacing.page,
          vertical: 12,
        ),
        child: Row(
          children: <Widget>[
            FsProgressRing(
              done: view.doneCount,
              total: view.total,
              caption: 'Boxes',
              semanticLabel:
                  '${view.doneCount} of ${view.total} boxes done today',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  for (var i = 0; i < rows.length; i++) ...<Widget>[
                    if (i > 0) const SizedBox(height: 5),
                    MergeSemantics(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: FsLabelCaps(
                              rows[i].$1,
                              style: FsText.stat,
                              color: FsColors.heroInk,
                            ),
                          ),
                          const SizedBox(width: 12),
                          FsLabelCaps(
                            rows[i].$2,
                            style: FsText.stat,
                            color: FsColors.ringValue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoxesCard extends StatelessWidget {
  const _BoxesCard({required this.view, required this.onOpenDevotional});

  final TodayView view;
  final VoidCallback onOpenDevotional;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final reading = view.reading;

    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FsSectionHead(
            title: 'Today’s boxes',
            trailing: FsTally(
              done: view.doneCount,
              total: view.total,
              semanticLabel: '${view.doneCount} of ${view.total} done',
            ),
          ),
          const SizedBox(height: FsSectionSpacing.headToMeter),
          FsMeter(fraction: view.total == 0 ? 0 : view.doneCount / view.total),
          const SizedBox(height: FsSectionSpacing.meterToContent),
          if (!view.durable) ...<Widget>[
            Text(
              notSavedNotice,
              style: FsText.bodySmall.copyWith(color: colors.danger),
            ),
            const SizedBox(height: FsSectionSpacing.rows),
          ],
          if (view.showPreviewPoints) ...<Widget>[
            FsLabelCaps(
              previewPointsNotice,
              style: FsText.kicker,
              color: colors.textMuted,
            ),
            const SizedBox(height: FsSectionSpacing.rows),
          ],
          for (var i = 0; i < view.boxes.length; i++) ...<Widget>[
            if (i > 0) const SizedBox(height: FsSectionSpacing.rows),
            _row(view.boxes[i], reading?.reference),
          ],
        ],
      ),
    );
  }

  Widget _row(BoxView boxView, String? reference) {
    final box = boxView.box;
    final points = view.showPreviewPoints
        ? pointsLabel(box.previewPoints)
        : null;
    if (!box.active) {
      return FsBoxRow(
        key: ValueKey<String>('fs-box-${box.id}'),
        command: box.command,
        title: box.title,
        subtitle: 'Not active yet',
        checked: false,
        points: points,
        onTap: null,
      );
    }
    return FsBoxRow(
      key: ValueKey<String>('fs-box-${box.id}'),
      command: box.command,
      title: box.title,
      subtitle: boxView.done
          ? 'Read today'
          : reference == null
          ? 'Tap to open today’s reading'
          : '$reference. Tap to open today’s reading',
      checked: boxView.done,
      points: points,
      showChevron: true,
      onTap: onOpenDevotional,
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return FsCard(
      child: Text(
        'Loading today…',
        style: FsText.body.copyWith(color: FsColors.of(context).textMuted),
      ),
    );
  }
}

class _LoadFailedCard extends StatelessWidget {
  const _LoadFailedCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Today could not be loaded.',
            style: FsText.body.copyWith(color: colors.text),
          ),
          const SizedBox(height: 14),
          FsButton.ghost(label: 'Try again', onPressed: onRetry),
        ],
      ),
    );
  }
}
