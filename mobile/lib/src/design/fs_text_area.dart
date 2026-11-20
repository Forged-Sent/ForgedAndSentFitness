import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'fs_colors.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

/// A box to write several lines in: the prototype's `textarea.field`.
///
/// It grows from [minLines] to [maxLines] and then scrolls. It stops
/// taking letters at [maxLength] and shows no counter, as the prototype's
/// boxes do.
///
/// [maxLength] is counted as the prototype's `maxlength` counts it, and as
/// Dart's `String.length` does: in UTF-16 code units, so an emoji is two
/// or more. Whoever saves the text can check its `length` against the
/// same number and never disagree with the box.
class FsTextArea extends StatelessWidget {
  const FsTextArea({
    super.key,
    required this.controller,
    required this.semanticLabel,
    this.hint,
    this.onChanged,
    this.enabled = true,
    this.minLines = 5,
    this.maxLines = 12,
    this.maxLength,
    this.focusNode,
  });

  final TextEditingController controller;

  /// What a screen reader calls the box.
  final String semanticLabel;

  /// Shown, muted, while the box is empty.
  final String? hint;

  final ValueChanged<String>? onChanged;
  final bool enabled;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(FsRadius.base),
      borderSide: BorderSide(color: color, width: width),
    );

    return Semantics(
      label: semanticLabel,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        onChanged: onChanged,
        minLines: minLines,
        maxLines: maxLines,
        inputFormatters: <TextInputFormatter>[
          if (maxLength != null) FsCodeUnitLimit(maxLength!),
        ],
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        // What is written here is private. Ask the keyboard not to learn
        // from it. Android keyboards honor this; iOS has no such setting.
        enableIMEPersonalizedLearning: false,
        style: FsText.body.copyWith(color: colors.text),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: FsText.body.copyWith(color: colors.textMuted),
          hintMaxLines: 3,
          filled: true,
          fillColor: colors.background,
          contentPadding: const EdgeInsets.all(FsSpacing.card),
          border: border(colors.hairline, 1),
          enabledBorder: border(colors.hairline, 1),
          disabledBorder: border(colors.hairline, 1),
          focusedBorder: border(colors.accent, 1.5),
        ),
      ),
    );
  }
}

/// Keeps a text box within [max] UTF-16 code units, the measure of
/// `String.length`.
///
/// Typing or pasting at the end: what does not fit is dropped from the end,
/// a whole character at a time, so an emoji is never cut in half. Typing or
/// pasting anywhere else when it does not fit: the edit is refused, because
/// cutting from the end would drop words that were already there.
class FsCodeUnitLimit extends TextInputFormatter {
  const FsCodeUnitLimit(this.max);

  final int max;

  /// [text], cut to at most [max] code units at a character boundary.
  static String fit(String text, int max) {
    if (text.length <= max) return text;
    final kept = StringBuffer();
    var length = 0;
    for (final character in text.characters) {
      if (length + character.length > max) break;
      kept.write(character);
      length += character.length;
    }
    return kept.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= max) return newValue;
    final String text;
    if (oldValue.text.length > max) {
      // The box was already over, which only code can do. Cut it to size.
      text = fit(newValue.text, max);
    } else if (newValue.text.startsWith(oldValue.text)) {
      // Added at the end. Fit the added part on its own, so that an accent
      // typed after the last letter cannot take that letter with it.
      final added = newValue.text.substring(oldValue.text.length);
      text = oldValue.text + fit(added, max - oldValue.text.length);
    } else {
      return oldValue;
    }
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
