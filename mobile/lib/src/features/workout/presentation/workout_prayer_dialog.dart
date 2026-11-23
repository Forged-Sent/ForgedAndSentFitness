import 'package:flutter/material.dart';

import '../../../design/fs_button.dart';
import '../../../design/fs_colors.dart';
import '../../../design/fs_dialog.dart';
import '../../../design/fs_typography_workout.dart';

/// Shows the workout prayer and returns true if he tapped Amen.
///
/// Decision Q11: the prayer stays in front of starting a workout, with a
/// visible "Not now" that returns without starting. Android's back button
/// does what "Not now" does; a tap outside the box does nothing.
Future<bool> showWorkoutPrayer(BuildContext context, List<String> lines) async {
  final amen = await showFsDialog<bool>(
    context,
    builder: (BuildContext context) => WorkoutPrayerDialog(lines: lines),
  );
  return amen ?? false;
}

/// The prototype's `openWorkoutPrayer`, with the "Not now" button decision
/// Q11 adds.
///
/// The prayer's words are the prototype's `WORKOUT_PRAYER`, bundled as
/// `workout_prayer.json` and passed in here. They are never written in
/// code.
class WorkoutPrayerDialog extends StatelessWidget {
  const WorkoutPrayerDialog({super.key, required this.lines});

  /// One paragraph per entry. The last is "Amen."
  final List<String> lines;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return FsDialog(
      kicker: 'Before you train',
      title: 'Workout prayer',
      actions: <Widget>[
        FsButton(
          key: const ValueKey<String>('fs-prayer-amen'),
          label: 'Amen',
          onPressed: () => Navigator.of(context).pop(true),
        ),
        FsButton.ghost(
          key: const ValueKey<String>('fs-prayer-not-now'),
          label: 'Not now',
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ],
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(left: BorderSide(color: colors.accent, width: 3)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 0, 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                for (var i = 0; i < lines.length; i++)
                  if (i < lines.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        lines[i],
                        style: FsWorkoutText.prayer.copyWith(
                          color: colors.text,
                        ),
                      ),
                    )
                  else
                    Text(
                      lines[i].toUpperCase(),
                      semanticsLabel: lines[i],
                      style: FsWorkoutText.prayerAmen.copyWith(
                        color: colors.text,
                      ),
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
