import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_number_field.dart';
import 'package:forged_and_sent/src/design/fs_theme.dart';

import '../support/fs_test_support.dart';

/// A number box on a page of its own, with what it last reported.
class _Host {
  final List<double?> reported = <double?>[];

  Future<void> pump(
    WidgetTester tester, {
    bool decimal = true,
    double max = 2000,
    double? value,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: FsTheme.dark,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 160,
            child: FsNumberField(
              value: value,
              onChanged: reported.add,
              semanticLabel: 'Set 1 weight in pounds',
              hint: 'lb',
              max: max,
              decimal: decimal,
            ),
          ),
        ),
      ),
    ),
  );
}

String _shown(WidgetTester tester) =>
    tester.widget<EditableText>(find.byType(EditableText)).controller.text;

void main() {
  setUpAll(loadAppFonts);

  testWidgets('reports the number typed, and null for an empty box', (
    tester,
  ) async {
    final host = _Host();
    await host.pump(tester);

    await tester.enterText(find.byType(FsNumberField), '135');
    await tester.enterText(find.byType(FsNumberField), '132.5');
    await tester.enterText(find.byType(FsNumberField), '');

    expect(host.reported, <double?>[135, 132.5, null]);
  });

  testWidgets('a keystroke the box does not take changes nothing: the text '
      'stays and no new number is reported', (tester) async {
    final host = _Host();
    await host.pump(tester);
    await tester.enterText(find.byType(FsNumberField), '137.5');
    expect(host.reported, <double?>[137.5]);

    // A second decimal digit, a fifth whole digit, a second point, a
    // letter: each is one keystroke too many.
    for (final tooMuch in <String>['137.55', '13755', '137.5.', '137.5a']) {
      await tester.enterText(find.byType(FsNumberField), tooMuch);
      await tester.pump();

      expect(_shown(tester), '137.5', reason: tooMuch);
      expect(host.reported, <double?>[137.5], reason: tooMuch);
    }

    // He can carry on typing from where he was.
    await tester.enterText(find.byType(FsNumberField), '137');
    expect(host.reported.last, 137);
  });

  testWidgets('a decimal comma is a decimal point', (tester) async {
    final host = _Host();
    await host.pump(tester);

    await tester.enterText(find.byType(FsNumberField), '132,5');

    expect(host.reported, <double?>[132.5]);
  });

  testWidgets('a number over the limit is reported as the limit, and shown '
      'as the limit once he leaves the box', (tester) async {
    final host = _Host();
    await host.pump(tester, max: 400);

    await tester.enterText(find.byType(FsNumberField), '999');
    expect(host.reported, <double?>[400]);
    expect(_shown(tester), '999');

    // The page stores 400 and gives it back; leaving the box shows it.
    await host.pump(tester, max: 400, value: 400);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    expect(_shown(tester), '400');
  });

  testWidgets('a whole-number box takes digits only, three at most', (
    tester,
  ) async {
    final host = _Host();
    await host.pump(tester, decimal: false, max: 999);

    await tester.enterText(find.byType(FsNumberField), '12');
    await tester.enterText(find.byType(FsNumberField), '125');
    expect(_shown(tester), '125');
    // A fourth digit is one keystroke too many: the text stays.
    await tester.enterText(find.byType(FsNumberField), '1254');
    expect(_shown(tester), '125');

    expect(host.reported, <double?>[12, 125]);
  });

  testWidgets('a whole-number box never makes a different number out of '
      'text that is not one: the text stays and nothing is reported', (
    tester,
  ) async {
    final host = _Host();
    await host.pump(tester, decimal: false, max: 999);

    // Pasted into an empty box. Dropping the point or the sign would
    // store 15 for "1.5" and 5 for "-5".
    for (final notWhole in <String>['1.5', '-5', '1,5', '5 reps']) {
      await tester.enterText(find.byType(FsNumberField), notWhole);
      await tester.pump();

      expect(_shown(tester), '', reason: notWhole);
      expect(host.reported, isEmpty, reason: notWhole);
    }

    // Typed over a number that is already there.
    await tester.enterText(find.byType(FsNumberField), '12');
    await tester.enterText(find.byType(FsNumberField), '12.5');
    expect(_shown(tester), '12');
    expect(host.reported, <double?>[12]);
  });

  testWidgets('a new value from outside is shown only while he is not '
      'typing in the box', (tester) async {
    final host = _Host();
    await host.pump(tester, value: 135);
    expect(_shown(tester), '135');

    // Typing: the box has the focus, and what is stored catches up
    // behind it without rewriting what he sees.
    await tester.tap(find.byType(FsNumberField));
    await tester.enterText(find.byType(FsNumberField), '140.');
    await host.pump(tester, value: 140);
    expect(_shown(tester), '140.');

    // Not typing: a value from the store replaces what the box shows.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await host.pump(tester, value: 145);
    expect(_shown(tester), '145');
  });

  test('numbers are written without a needless decimal', () {
    expect(FsNumberField.format(135), '135');
    expect(FsNumberField.format(132.5), '132.5');
    expect(FsNumberField.format(null), '');
  });
}
