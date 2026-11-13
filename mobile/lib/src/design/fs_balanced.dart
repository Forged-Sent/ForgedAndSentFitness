import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Sets its text so that the lines are as even as they can be without
/// adding a line: what CSS `text-wrap: balance` does for the prototype's
/// reading headline and for the mission line on Today. Flutter fills each
/// line before starting the next, which leaves a last word or two on a
/// line of their own.
///
/// The child is a [Text]. It is given the narrowest width that still takes
/// the same number of lines as the full width would, and it stays at the
/// start of the line. A text that fits on one line is unchanged.
class FsBalanced extends SingleChildRenderObjectWidget {
  const FsBalanced({super.key, required Widget super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBalanced();
}

class _RenderBalanced extends RenderProxyBox {
  /// The constraints for the child: the same, but no wider than the
  /// narrowest width at which it is no taller than at the full width.
  BoxConstraints _balanced(BoxConstraints constraints) {
    final child = this.child;
    final full = constraints.maxWidth;
    if (child == null || !full.isFinite || full <= 0) return constraints;

    final height = child.getMinIntrinsicHeight(full);
    var tooNarrow = 0.0;
    var wideEnough = full;
    while (wideEnough - tooNarrow > 1) {
      final middle = (tooNarrow + wideEnough) / 2;
      if (child.getMinIntrinsicHeight(middle) > height) {
        tooNarrow = middle;
      } else {
        wideEnough = middle;
      }
    }
    return BoxConstraints(
      maxWidth: wideEnough,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );
  }

  /// This box is as wide as it is told to be; the text inside may be
  /// narrower.
  Size _sizeFor(BoxConstraints constraints, Size child) =>
      constraints.constrain(child);

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    final child = this.child;
    if (child == null) return constraints.smallest;
    return _sizeFor(constraints, child.getDryLayout(_balanced(constraints)));
  }

  @override
  double? computeDryBaseline(
    BoxConstraints constraints,
    TextBaseline baseline,
  ) => child?.getDryBaseline(_balanced(constraints), baseline);

  @override
  void performLayout() {
    final child = this.child;
    if (child == null) {
      size = constraints.smallest;
      return;
    }
    child.layout(_balanced(constraints), parentUsesSize: true);
    size = _sizeFor(constraints, child.size);
  }
}
