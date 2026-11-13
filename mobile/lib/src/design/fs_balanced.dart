import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Sets its text so that the lines are as even as they can be without
/// adding a line: what CSS `text-wrap: balance` does for the prototype's
/// reading headline and for the mission line on Today. Flutter fills each
/// line before starting the next, which leaves a last word or two on a
/// line of their own.
///
/// The child is a [Text]. It is given the narrowest width that still takes
/// the same number of lines as the full width would. A text that fits on
/// one line is unchanged.
///
/// Two limits:
/// - **Left-to-right, start-aligned text only.** The child is placed at
///   the left edge of the space this widget is given. Right-to-left text,
///   and centered or end-aligned text, would be drawn against that left
///   edge instead of where they belong. The app has neither today.
/// - **Only a text that wraps can be balanced.** A child that is no taller
///   however narrow it gets is laid out as if this widget were not there:
///   a text that is cut off instead of wrapped (`maxLines`, `softWrap:
///   false`), or a child that is not a text.
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
    // No width made the child taller: it does not wrap, so there is nothing
    // to balance. The search has by now squeezed `wideEnough` to under a
    // point, which would collapse the child; it keeps the space it was
    // given instead.
    if (tooNarrow == 0) return constraints;
    return BoxConstraints(
      maxWidth: wideEnough,
      minHeight: constraints.minHeight,
      maxHeight: constraints.maxHeight,
    );
  }

  /// This box is as wide as it is told to be; the text inside may be
  /// narrower. A proxy box paints its child at its own top left corner,
  /// which is what puts the text at the left edge.
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
