import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/design/fs_shell.dart';

void main() {
  testWidgets('Flutter-generated host keeps the intended app entry point', (
    tester,
  ) async {
    // Exactly as main.dart starts it in preview mode: no arguments.
    await tester.pumpWidget(const ForgedSentApp());
    await tester.pumpAndSettle();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Forged & Sent');
    // Both themes are supplied, and the phone's setting chooses.
    expect(app.theme?.brightness, Brightness.light);
    expect(app.darkTheme?.brightness, Brightness.dark);
    expect(app.themeMode, ThemeMode.system);

    // One screen frame, the shell, holding Today's header.
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(FsShell), findsOneWidget);
    expect(find.byType(FsHeroHeader), findsOneWidget);
    expect(find.text('TODAY’S MISSION'), findsOneWidget);
    // The developer status screen is no longer the home.
    expect(find.byType(FoundationHomeScreen), findsNothing);
    expect(find.text('Faith. Training. Brotherhood.'), findsNothing);
  });
}
