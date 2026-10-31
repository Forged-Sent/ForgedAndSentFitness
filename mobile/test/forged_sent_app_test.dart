import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/firebase/forged_firebase_runtime.dart';

void main() {
  testWidgets('preview makes no cloud Firebase connection claim', (tester) async {
    await tester.pumpWidget(const ForgedSentApp());
    expect(find.text('Forged & Sent'), findsOneWidget);
    expect(find.text('Faith. Training. Brotherhood.'), findsOneWidget);
    expect(find.text('Preview mode. No Firebase cloud connection configured.'), findsOneWidget);
  });
  testWidgets('emulator outage fails closed with a visible explanation', (tester) async {
    await tester.pumpWidget(const ForgedSentApp(mode: 'emulator', startupError: 'offline'));
    expect(find.text('Local emulator not available. No cloud fallback was attempted.'), findsOneWidget);
  });
  test('development project ID is demo-only', () {
    expect(ForgedFirebaseRuntime.projectId, startsWith('demo-'));
  });
}
