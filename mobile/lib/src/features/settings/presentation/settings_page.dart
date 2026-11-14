import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/fs_button.dart';
import '../../../design/fs_card.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_hero_header.dart';
import '../../../design/fs_page_bar.dart';
import '../../../design/fs_section_head.dart';
import '../../../design/fs_tokens.dart';
import '../../../design/fs_typography.dart';
import '../../devotional/domain/devotional.dart';
import '../../today/presentation/today_view_model.dart';

/// Settings, as far as build step S1 needs them: the switch that shows
/// preview point values (decision Q5), the scripture credits, and the way
/// to the developer's build status page.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    super.key,
    required this.onBack,
    required this.onOpenStatus,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = FsColors.of(context);
    final showPoints = ref.watch(showPreviewPointsProvider).value ?? false;
    final note = FsText.bodySmall.copyWith(color: colors.textMuted);

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
          child: FsPageBar(onBack: onBack),
        ),
        const FsHeroHeader(kicker: 'This phone', title: 'Settings'),
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
              FsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const FsSectionHead(title: 'Points'),
                    const SizedBox(height: 4),
                    MergeSemantics(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Show point values',
                              style: FsText.body.copyWith(color: colors.text),
                            ),
                          ),
                          Switch(
                            key: const ValueKey<String>('fs-preview-points'),
                            value: showPoints,
                            activeThumbColor: colors.onAccent,
                            activeTrackColor: colors.accent,
                            onChanged: (bool value) =>
                                setShowPreviewPoints(ref, value),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Preview, not official. These are the prototype’s '
                      'values. The app does not score anything yet.',
                      style: note,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FsSpacing.block),
              FsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const FsSectionHead(title: 'Scripture'),
                    const SizedBox(height: 6),
                    Text(ScriptureNotices.bsb, style: note),
                    const SizedBox(height: 6),
                    Text(ScriptureNotices.esv, style: note),
                  ],
                ),
              ),
              const SizedBox(height: FsSpacing.block),
              FsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const FsSectionHead(title: 'This build'),
                    const SizedBox(height: 10),
                    FsButton.ghost(
                      label: 'Build status',
                      onPressed: onOpenStatus,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
