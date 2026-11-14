import 'package:flutter/widgets.dart';

import 'fs_button.dart';

/// One choice in an [FsSegmented].
class FsSegment<T> {
  const FsSegment({required this.value, required this.label, this.hint});

  final T value;

  /// The short text on the segment, for example `ESV`.
  final String label;

  /// What a screen reader says instead of [label], for example
  /// "English Standard Version".
  final String? hint;
}

/// A row of small buttons of which one is selected: the prototype's
/// segmented control, built from its mini buttons.
class FsSegmented<T> extends StatelessWidget {
  const FsSegmented({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<FsSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (var i = 0; i < segments.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(width: 6),
          FsButton.mini(
            label: segments[i].label,
            semanticLabel: segments[i].hint,
            selected: segments[i].value == selected,
            onPressed: () => onChanged(segments[i].value),
          ),
        ],
      ],
    );
  }
}
