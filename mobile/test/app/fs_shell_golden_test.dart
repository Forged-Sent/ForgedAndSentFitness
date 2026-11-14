import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fs_test_support.dart';

/// Golden images of the shell at 390x844, the size of the prototype
/// reference screenshots. Walk stands for the tabs that are still
/// placeholders; Today has its own images in
/// `test/features/today/today_golden_test.dart`.
///
/// A Flutter render cannot match a browser render pixel for pixel. The
/// maintainer approves each image by eye beside the prototype; after that
/// the image is the baseline and any change to it fails here.
///
/// Compared on Windows only. Text is drawn slightly differently on each
/// operating system, so an image made on one fails on another. On other
/// systems these tests are skipped; no CI lane checks the images yet.
///
/// To redraw them: `flutter test --update-goldens test/app/fs_shell_golden_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  final skip = !Platform.isWindows;

  for (final (name, themeMode) in <(String, ThemeMode)>[
    ('dark', ThemeMode.dark),
    ('light', ThemeMode.light),
  ]) {
    testWidgets('Walk, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode);
      await openTab(tester, 'Walk');
      await loadHeroPhoto(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/shell_walk_$name.png'),
      );
    }, skip: skip);
  }
}
