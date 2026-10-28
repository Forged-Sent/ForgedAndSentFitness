import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';

void main() {
  testWidgets('foundation app renders its identity and honest status', (tester) async {
    await tester.pumpWidget(const ForgedSentApp());
    expect(find.text('Forged & Sent'), findsOneWidget);
    expect(find.text('Faith. Training. Brotherhood.'), findsOneWidget);
    expect(find.text('No account or Firebase connection configured yet.'),
        findsOneWidget);
  });
}
