import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';

void main() {
  testWidgets('Flutter-generated host keeps the intended app entry point',
      (tester) async {
    await tester.pumpWidget(const ForgedSentApp());
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Faith. Training. Brotherhood.'), findsOneWidget);
  });
}
