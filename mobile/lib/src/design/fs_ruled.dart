import 'package:flutter/widgets.dart';

/// Content set behind a vertical rule on its left. The prototype uses it
/// twice in a reading: the verse (`.d-read`, a brass rule) and the
/// "In Jesus" paragraph (`#d-jesus`, an accent rule).
class FsRuled extends StatelessWidget {
  const FsRuled({super.key, required this.color, required this.child});

  /// The rule's color.
  final Color color;

  final Widget child;

  /// The rule's width. The prototype asks for 4 CSS pixels and the browser
  /// draws 3.6 at the reference size.
  static const double ruleWidth = 3.6;

  /// Space between the rule and the content.
  static const double inset = 14;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: color, width: ruleWidth),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: inset),
        child: child,
      ),
    );
  }
}
