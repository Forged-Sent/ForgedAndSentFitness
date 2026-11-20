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

/// What Settings says when a change to a setting could not be saved. The
/// reading says the same when Amen could not be saved.
const String settingNotSavedNotice = 'That did not save. Try again.';

/// Settings, as far as build step S1 needs them: the switch that shows
/// preview point values (decision Q5), the scripture credits, and the way
/// to the developer's build status page.
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    super.key,
    required this.onBack,
    required this.onOpenStatus,
    required this.onOpenJournal,
  });

  final VoidCallback onBack;
  final VoidCallback onOpenStatus;

  /// Opens his private journal.
  final VoidCallback onOpenJournal;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  /// True while a change to the switch is on its way to the store.
  bool _saving = false;

  /// True once a change to the switch could not be saved, until one is. It
  /// stays true while he tries again: the line goes only when the store has
  /// the change.
  bool _saveFailed = false;

  /// Asks the store to turn the preview point values on or off.
  ///
  /// The switch itself is never moved here. It shows what the store holds,
  /// so it moves when the store has the change, and stays where it is when
  /// the store refuses it; the page then says so.
  Future<void> _setShowPoints(bool show) async {
    if (_saving) return;
    setState(() => _saving = true);
    var saved = true;
    try {
      await setShowPreviewPoints(ref, show);
    } catch (_) {
      saved = false;
    }
    if (!mounted) return;
    setState(() {
      _saving = false;
      _saveFailed = !saved;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: FsPageBar(onBack: widget.onBack),
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
                            // Not offered while a change is on its way:
                            // a second tap would be ignored, so the switch
                            // says that it is not available.
                            onChanged: _saving ? null : _setShowPoints,
                          ),
                        ],
                      ),
                    ),
                    if (_saveFailed) ...<Widget>[
                      Semantics(
                        // A node of its own, so a screen reader announces
                        // this line when it appears and nothing else.
                        container: true,
                        liveRegion: true,
                        child: Text(
                          settingNotSavedNotice,
                          key: const ValueKey<String>(
                            'fs-preview-points-not-saved',
                          ),
                          style: FsText.bodySmall.copyWith(
                            color: colors.danger,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const FsSectionHead(title: 'My journal'),
                    const SizedBox(height: 6),
                    Text(
                      'Private. It is not sent to any server, and it is never scored.',
                      style: note,
                    ),
                    const SizedBox(height: 10),
                    FsButton.ghost(
                      key: const ValueKey<String>('fs-settings-journal'),
                      label: 'Open my journal',
                      onPressed: widget.onOpenJournal,
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
                      onPressed: widget.onOpenStatus,
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
