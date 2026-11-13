import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/shell_destinations.dart';
import '../../../core/date_text.dart';
import '../../../core/local_date.dart';
import '../../../core/time_text.dart';
import '../../../design/fs_button.dart';
import '../../../design/fs_card.dart';
import '../../../design/fs_chevron_row.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_hero_header.dart';
import '../../../design/fs_label_caps.dart';
import '../../../design/fs_section_head.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../../../design/fs_typography_workout.dart';
import '../../today/presentation/today_page.dart' show notSavedNotice;
import 'train_view_model.dart';

/// Train: today's session and this week, Monday to Sunday.
///
/// The prototype's `drawTrain`, `drawDayWorkout` and `drawWeek`. Its
/// challenge buttons, calendar strip, charts and plan form belong to later
/// build steps and are not here.
class TrainPage extends ConsumerWidget {
  const TrainPage({super.key, required this.onOpenWorkout});

  /// Opens the workout page of one day.
  final ValueChanged<LocalDate> onOpenWorkout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(trainViewModelProvider);
    // While a new value is on its way the last one stays on screen.
    final view = state.value;
    final destination = ShellDestinations.train;

    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        FsHeroHeader(
          kicker: destination.kicker,
          title: destination.title,
          actions: destination.actions,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FsSpacing.page,
            FsSpacing.block,
            FsSpacing.page,
            FsSpacing.pageBottom,
          ),
          child: view == null
              ? state.hasError
                    ? _LoadFailedCard(
                        onRetry: () =>
                            ref.read(trainViewModelProvider.notifier).retry(),
                      )
                    : const _LoadingCard()
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    if (view.carriedOver != null) ...<Widget>[
                      _CarriedOverCard(
                        view: view,
                        onOpen: () => onOpenWorkout(view.carriedOver!.day),
                      ),
                      const SizedBox(height: FsSpacing.block),
                    ],
                    _TodayCard(
                      view: view,
                      onOpen: () => onOpenWorkout(view.today.date),
                    ),
                    const SizedBox(height: FsSpacing.block),
                    _WeekCard(view: view, onOpenWorkout: onOpenWorkout),
                  ],
                ),
        ),
      ],
    );
  }
}

/// A workout begun on an earlier day and still open, with the way back
/// into it. This is what lets a session started before midnight be
/// finished after it (review finding U2).
class _CarriedOverCard extends StatelessWidget {
  const _CarriedOverCard({required this.view, required this.onOpen});

  final TrainView view;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final session = view.carriedOver!;
    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          FsLabelCaps('Workout in progress', color: colors.highlight),
          const SizedBox(height: 4),
          Text(
            'You started this on ${heroDateLine(session.day)} and have not '
            'finished it.',
            style: FsText.body.copyWith(color: colors.text),
          ),
          const SizedBox(height: 12),
          FsChevronRow(
            key: const ValueKey<String>('fs-train-carried-over'),
            title: session.title,
            subtitle:
                'Started ${clockTime(session.startedAtWallClock)} · '
                'Tap to continue',
            mark: FsRowMark.chevron,
            onTap: onOpen,
          ),
        ],
      ),
    );
  }
}

/// Today: the date, where the day stands, and the session to open. The
/// prototype's `.day-panel`.
class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.view, required this.onOpen});

  final TrainView view;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final today = view.today;
    final session = view.todaySession;

    final String detail;
    if (session != null && session.finished) {
      detail = '${today.detail} · Finished · Tap to view';
    } else if (session != null) {
      detail = '${today.detail} · In progress · Tap to continue';
    } else {
      detail = '${today.detail} · Tap to open';
    }

    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(
              heroDateLine(today.date),
              style: FsText.sectionTitle.copyWith(color: colors.text),
            ),
          ),
          const SizedBox(height: 2),
          FsLabelCaps(
            view.status,
            key: const ValueKey<String>('fs-train-status'),
            style: FsWorkoutText.status,
            color: today.done ? colors.accent : colors.text,
          ),
          if (!view.durable) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              notSavedNotice,
              style: FsText.bodySmall.copyWith(color: colors.danger),
            ),
          ],
          const SizedBox(height: 12),
          if (today.opens)
            FsChevronRow(
              key: const ValueKey<String>('fs-train-today'),
              title: today.title,
              subtitle: detail,
              mark: today.done ? FsRowMark.check : FsRowMark.chevron,
              onTap: onOpen,
            )
          else
            Text(
              view.message ?? '',
              key: const ValueKey<String>('fs-train-message'),
              style: FsText.bodySmall.copyWith(color: colors.textMuted),
            ),
        ],
      ),
    );
  }
}

/// "Your week": one row per day, Monday to Sunday. The prototype's
/// `drawWeek`.
class _WeekCard extends StatelessWidget {
  const _WeekCard({required this.view, required this.onOpenWorkout});

  final TrainView view;
  final ValueChanged<LocalDate> onOpenWorkout;

  @override
  Widget build(BuildContext context) {
    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const FsSectionHead(title: 'Your week'),
          const SizedBox(height: FsSectionSpacing.headToMeter),
          for (final day in view.week)
            FsChevronRow(
              key: ValueKey<String>('fs-week-${day.date.iso}'),
              emphasis: day.isToday
                  ? FsRowEmphasis.current
                  : FsRowEmphasis.plain,
              leading: _Weekday(date: day.date),
              title: day.title,
              subtitle: <String>[
                if (day.isToday) 'Today',
                if (day.detail.isNotEmpty) day.detail,
              ].join(' · '),
              dim: day.dim,
              mark: day.done
                  ? FsRowMark.check
                  : day.opens
                  ? FsRowMark.chevron
                  : FsRowMark.none,
              semanticLabel: <String>[
                '${heroDateLine(day.date)}: ${day.title}',
                if (day.detail.isNotEmpty) day.detail,
                if (day.done) 'Workout complete',
              ].join('. '),
              onTap: day.opens ? () => onOpenWorkout(day.date) : null,
            ),
        ],
      ),
    );
  }
}

/// "THU" over "12" at the left of a week row.
class _Weekday extends StatelessWidget {
  const _Weekday({required this.date});

  final LocalDate date;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return SizedBox(
      width: 52,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            shortWeekdayName(date).toUpperCase(),
            style: FsWorkoutText.weekday.copyWith(color: colors.textMuted),
          ),
          Text(
            '${date.day}',
            style: FsWorkoutText.weekdayNumber.copyWith(color: colors.text),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return FsCard(
      child: Text(
        'Loading your plan…',
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
            'Your plan could not be loaded.',
            style: FsText.body.copyWith(color: colors.text),
          ),
          const SizedBox(height: 14),
          FsButton.ghost(label: 'Try again', onPressed: onRetry),
        ],
      ),
    );
  }
}
