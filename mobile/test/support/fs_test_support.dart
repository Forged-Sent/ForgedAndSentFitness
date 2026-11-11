import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';

/// The size the prototype reference screenshots were taken at.
const Size phone = Size(390, 844);

/// A Tuesday, the date on the review's reference screenshots.
final DateTime referenceDate = DateTime(2026, 11, 10);

/// Loads the bundled typefaces, so text has its real width and shape.
/// Without this, tests draw every letter as a square.
Future<void> loadAppFonts() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final manifest =
      json.decode(await rootBundle.loadString('FontManifest.json'))
          as List<dynamic>;
  for (final entry in manifest.cast<Map<String, dynamic>>()) {
    final loader = FontLoader(entry['family'] as String);
    for (final font
        in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

/// Starts the app on a screen of [size] and waits for it to settle.
Future<void> pumpApp(
  WidgetTester tester, {
  Size size = phone,
  ThemeMode themeMode = ThemeMode.dark,
  double textScale = 1,
  String mode = 'preview',
  String? startupError,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ForgedSentApp(
      mode: mode,
      startupError: startupError,
      themeMode: themeMode,
      now: () => referenceDate,
    ),
  );
  await tester.pumpAndSettle();
}

/// Decodes the hero photograph, which a test does not do on its own, so a
/// golden image shows it.
Future<void> loadHeroPhoto(WidgetTester tester) async {
  await tester.runAsync(() async {
    await precacheImage(
      const AssetImage(FsHeroHeader.photoAsset),
      tester.element(find.byType(FsHeroHeader).first),
    );
  });
  await tester.pumpAndSettle();
}

/// The tab with [label] in the bottom bar.
Finder tab(String label) =>
    find.byKey(ValueKey<String>('fs-tab-${label.toLowerCase()}'));

Future<void> openTab(WidgetTester tester, String label) async {
  await tester.tap(tab(label));
  await tester.pumpAndSettle();
}

/// Opens the developer status page from Today.
Future<void> openStatusPage(WidgetTester tester) async {
  await tester.ensureVisible(find.text('BUILD STATUS'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('BUILD STATUS'));
  await tester.pumpAndSettle();
}

/// What Android's back button or gesture sends.
Future<void> systemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await tester.pumpAndSettle();
}
