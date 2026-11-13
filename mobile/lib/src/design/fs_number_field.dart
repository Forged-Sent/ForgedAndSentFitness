import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fs_colors.dart';
import 'fs_tokens.dart';
import 'fs_typography_workout.dart';

/// A box for typing one number: the prototype's `numField`.
///
/// [onChanged] is called on every keystroke with the number typed, or null
/// when the box is empty. The box keeps what is being typed while it has
/// the focus; a new [value] from outside is shown only when it does not.
class FsNumberField extends StatefulWidget {
  const FsNumberField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    required this.hint,
    required this.max,
    this.decimal = false,
    this.invalid = false,
  });

  final double? value;
  final ValueChanged<double?> onChanged;

  /// What a screen reader says for the box, for example "Set 1 reps".
  final String semanticLabel;

  /// The grey word in an empty box, for example "reps" or "lb".
  final String hint;

  /// The largest number the box accepts. A larger one is stored as this.
  final double max;

  /// Whether one decimal place may be typed. Otherwise whole numbers only.
  final bool decimal;

  /// Draws the box outlined in the danger color: this number is missing.
  final bool invalid;

  /// "135" for 135, "132.5" for 132.5.
  static String format(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.round().toString()
        : value.toStringAsFixed(1);
  }

  @override
  State<FsNumberField> createState() => _FsNumberFieldState();
}

class _FsNumberFieldState extends State<FsNumberField> {
  late final TextEditingController _controller = TextEditingController(
    text: FsNumberField.format(widget.value),
  );
  late final FocusNode _focus = FocusNode()..addListener(_onFocus);

  static final RegExp _oneDecimal = RegExp(r'^\d{0,4}([.,]\d?)?$');

  @override
  void didUpdateWidget(FsNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focus.hasFocus && _parse(_controller.text) != widget.value) {
      _controller.text = FsNumberField.format(widget.value);
    }
  }

  @override
  void dispose() {
    _focus
      ..removeListener(_onFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Leaving the box shows the number as it was stored: "135." becomes
  /// "135", and a number over the limit becomes the limit.
  void _onFocus() {
    if (!_focus.hasFocus) {
      _controller.text = FsNumberField.format(widget.value);
    }
  }

  double? _parse(String text) {
    final number = double.tryParse(text.trim().replaceAll(',', '.'));
    if (number == null || number < 0) return null;
    final rounded = (number * 10).round() / 10;
    return rounded > widget.max ? widget.max : rounded;
  }

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(FsRadius.base),
      borderSide: BorderSide(color: color, width: width),
    );
    final resting = widget.invalid
        ? border(colors.danger, 2)
        : border(colors.hairline, 1);

    return Semantics(
      label: widget.semanticLabel,
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        onChanged: (String text) => widget.onChanged(_parse(text)),
        textAlign: TextAlign.center,
        keyboardType: TextInputType.numberWithOptions(decimal: widget.decimal),
        textInputAction: TextInputAction.next,
        inputFormatters: <TextInputFormatter>[
          if (widget.decimal)
            FilteringTextInputFormatter.allow(_oneDecimal)
          else ...<TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(3),
          ],
        ],
        style: FsWorkoutText.fieldValue.copyWith(color: colors.text),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: FsWorkoutText.fieldValue.copyWith(
            color: colors.textMuted,
            fontWeight: FontWeight.w400,
          ),
          isDense: true,
          filled: true,
          fillColor: colors.surfaceRaised,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 13,
          ),
          border: resting,
          enabledBorder: resting,
          focusedBorder: border(
            widget.invalid ? colors.danger : colors.accent,
            2,
          ),
        ),
      ),
    );
  }
}
