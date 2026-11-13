import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_label_caps.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';
import 'fs_typography_workout.dart';

/// What a dialog's border says about it.
enum FsDialogTone {
  /// A notice or a choice (the prototype's `.nw-box`).
  notice,

  /// Something that has to be put right first.
  warning,
}

/// A box over a dimmed page: the prototype's `.cdlg-box`.
///
/// It scrolls when its content is taller than the screen, as it is with
/// large text. Show it with [showFsDialog].
class FsDialog extends StatelessWidget {
  const FsDialog({
    super.key,
    required this.title,
    required this.children,
    required this.actions,
    this.kicker,
    this.tone = FsDialogTone.notice,
    this.actionsInRow = false,
  });

  /// The dimmed page behind a dialog: `rgba(0,0,0,.55)`.
  static const Color scrim = Color(0x8C000000);

  /// The small caps line above the title.
  final String? kicker;

  final String title;

  /// What stands between the title and the buttons.
  final List<Widget> children;

  /// The buttons, most important first.
  final List<Widget> actions;

  final FsDialogTone tone;

  /// Two buttons side by side instead of one under the other.
  final bool actionsInRow;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final border = tone == FsDialogTone.warning
        ? colors.danger
        : colors.highlight;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          // The prototype sets a dialog 56 points down the screen.
          padding: const EdgeInsets.fromLTRB(
            FsSpacing.page,
            56,
            FsSpacing.page,
            FsSpacing.page,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: title,
              child: Material(
                color: colors.background,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(FsRadius.cardLarge),
                  side: BorderSide(color: border, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      if (kicker != null) ...<Widget>[
                        FsLabelCaps(
                          kicker!,
                          style: FsText.kicker,
                          color: colors.highlight,
                        ),
                        const SizedBox(height: 10),
                      ],
                      Semantics(
                        header: true,
                        child: Text(
                          title.toUpperCase(),
                          semanticsLabel: title,
                          style: FsWorkoutText.dialogTitle.copyWith(
                            color: colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...children,
                      const SizedBox(height: 16),
                      if (actionsInRow)
                        Row(
                          children: <Widget>[
                            for (
                              var i = 0;
                              i < actions.length;
                              i++
                            ) ...<Widget>[
                              if (i > 0) const SizedBox(width: 10),
                              Expanded(child: actions[i]),
                            ],
                          ],
                        )
                      else
                        for (var i = 0; i < actions.length; i++) ...<Widget>[
                          if (i > 0) const SizedBox(height: 10),
                          actions[i],
                        ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows a dialog over the whole app, tab bar included.
///
/// A tap outside the box does nothing. Android's back button closes the
/// dialog and returns null, so every dialog must treat null as its "no"
/// answer.
Future<T?> showFsDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: FsDialog.scrim,
    builder: builder,
  );
}
