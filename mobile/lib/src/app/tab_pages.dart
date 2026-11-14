import 'package:flutter/material.dart';

import '../design/fs_card.dart';
import '../design/fs_colors.dart';
import '../design/fs_hero_header.dart';
import '../design/fs_label_caps.dart';
import '../design/fs_tokens.dart';
import '../design/fs_typography.dart';
import 'shell_destinations.dart';

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
  const _PlaceholderCard({required this.label, required this.message});

  final String label;
  final String message;

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
        ],
      ),
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
