import 'package:flutter/material.dart';

import '../design/fs_button.dart';
import '../design/fs_card.dart';
import '../design/fs_colors.dart';
import '../design/fs_hero_header.dart';
import '../design/fs_label_caps.dart';
import '../design/fs_tokens.dart';
import '../design/fs_typography.dart';
import 'shell_destinations.dart';

const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Wednesday, November 11": the line above Today's title in the prototype.
String heroDateLine(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}';

/// A hero header over a scrolling column of blocks.
class _ShellPage extends StatelessWidget {
  const _ShellPage({required this.header, required this.blocks});

  final Widget header;
  final List<Widget> blocks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        header,
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
              for (var i = 0; i < blocks.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(height: FsSpacing.block),
                blocks[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  const _PlaceholderCard({
    required this.label,
    required this.message,
    this.action,
  });

  final String label;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return FsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          FsLabelCaps(label, color: colors.highlight),
          const SizedBox(height: 6),
          Text(message, style: FsText.body.copyWith(color: colors.text)),
          if (action != null) ...<Widget>[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

/// Today in step S0: the real header over a card that says what comes next.
/// Step S1 replaces the body with the ring and the day's boxes, and the
/// line under the title with the day's mission.
class TodayPlaceholderPage extends StatelessWidget {
  const TodayPlaceholderPage({
    super.key,
    required this.now,
    required this.onOpenStatus,
  });

  /// The clock, so a test can fix the date.
  final DateTime Function() now;

  /// Opens the developer status page.
  final VoidCallback onOpenStatus;

  @override
  Widget build(BuildContext context) {
    const destination = ShellDestinations.today;
    return _ShellPage(
      header: FsHeroHeader(
        large: true,
        kicker: heroDateLine(now()),
        title: destination.title,
        // The prototype's own tagline, from its opening screen. The day's
        // mission line is content, and arrives with step S1.
        subtitle: 'Faith. Fitness. Brotherhood.',
        actions: destination.actions,
      ),
      blocks: <Widget>[
        _PlaceholderCard(
          label: 'Coming next',
          message:
              'Today’s boxes and the daily devotional arrive in the next '
              'step. This build shows the look of the app: the header, the '
              'tabs, and the dark and light themes.',
          action: FsButton.ghost(
            label: 'Build status',
            onPressed: onOpenStatus,
          ),
        ),
      ],
    );
  }
}

/// A tab that is not built yet: its real header over one card.
class TabPlaceholderPage extends StatelessWidget {
  const TabPlaceholderPage({super.key, required this.destination});

  final ShellDestination destination;

  @override
  Widget build(BuildContext context) {
    return _ShellPage(
      header: FsHeroHeader(
        kicker: destination.kicker,
        title: destination.title,
        actions: destination.actions,
      ),
      blocks: <Widget>[
        _PlaceholderCard(
          label: 'Not built yet',
          message: '${destination.label} arrives in a later step.',
        ),
      ],
    );
  }
}
