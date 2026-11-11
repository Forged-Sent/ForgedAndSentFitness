import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/firebase/forged_firebase_runtime.dart';

import 'support/fs_test_support.dart';

const String _preview =
    'Preview mode. No Firebase cloud connection configured.';
const String _outage =
    'Local emulator not available. No cloud fallback was attempted.';
const String _verified =
    'Verified local Auth, Firestore and Storage emulators (demo-forgedandsent).';

/// The app now opens on the tab shell. What the old home screen promised
/// still holds: it never claims a cloud connection, an emulator outage is
/// explained on screen without being asked for, and a verified emulator is
/// named as local.
void main() {
  setUpAll(loadAppFonts);

  testWidgets('preview makes no cloud Firebase connection claim', (
    tester,
  ) async {
    await pumpApp(tester);
    // It opens on Today inside the shell, not on the status page.
    expect(find.text('FORGED & SENT'), findsOneWidget);
    expect(find.text('TODAY’S MISSION'), findsOneWidget);
    expect(find.byType(FoundationHomeScreen), findsNothing);
    // Nothing on the opening screen speaks of a connection at all.
    expect(find.textContaining('Firebase'), findsNothing);
    expect(find.textContaining('emulator'), findsNothing);

    await openStatusPage(tester);
    expect(find.text('Build status'), findsOneWidget);
    expect(find.text('Faith. Training. Brotherhood.'), findsOneWidget);
    expect(find.text(_preview), findsOneWidget);
    expect(find.text(_verified), findsNothing);
    expect(find.text(_outage), findsNothing);
  });

  testWidgets('emulator outage fails closed with a visible explanation', (
    tester,
  ) async {
    await pumpApp(tester, mode: 'emulator', startupError: 'offline');
    // The explanation is the first thing on screen. Nobody has to find it.
    expect(find.byType(FoundationHomeScreen), findsOneWidget);
    expect(find.text(_outage), findsOneWidget);
    expect(
      find.text('Start the Firebase emulators and relaunch the app.'),
      findsOneWidget,
    );
    expect(find.text(_verified), findsNothing);
    expect(find.text(_preview), findsNothing);
    // The raw error text is not shown to the user.
    expect(find.textContaining('offline'), findsNothing);

    // Leaving the explanation does not turn it into a success message.
    await systemBack(tester);
    expect(find.text('TODAY’S MISSION'), findsOneWidget);
    await openStatusPage(tester);
    expect(find.text(_outage), findsOneWidget);
    expect(find.text(_verified), findsNothing);
  });

  testWidgets('verified emulator status is explicit', (tester) async {
    await pumpApp(tester, mode: 'emulator');
    // A working emulator does not interrupt: the app opens on Today.
    expect(find.text('TODAY’S MISSION'), findsOneWidget);
    expect(find.byType(FoundationHomeScreen), findsNothing);

    await openStatusPage(tester);
    expect(find.text(_verified), findsOneWidget);
    expect(find.text(_outage), findsNothing);
    expect(find.text(_preview), findsNothing);
    expect(
      find.text('Start the Firebase emulators and relaunch the app.'),
      findsNothing,
    );
  });

  test('development project ID is demo-only', () {
    expect(ForgedFirebaseRuntime.projectId, startsWith('demo-'));
  });
}
