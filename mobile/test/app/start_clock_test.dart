import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/main.dart';

import '../support/fs_test_support.dart';

/// The restart test on the emulator has to run on a lifting day whatever
/// day it really is, so the app can be started on a clock the test
/// supplies. These tests are the guarantee that a release build cannot.
void main() {
  group('the clock the app starts with', () {
    final clock = TestClock();

    test('a release build refuses a clock that is not the phone\'s', () {
      expect(() => clockForStart(clock, releaseMode: true), throwsStateError);
    });

    test('a release build with no clock requested starts on the phone\'s', () {
      expect(clockForStart(null, releaseMode: true), isNull);
    });

    test('a debug or profile build takes the clock a test gives it', () {
      expect(clockForStart(clock, releaseMode: false), same(clock));
      expect(clockForStart(null, releaseMode: false), isNull);
    });
  });

  group('nothing but the restart test can ask for another clock', () {
    final main = File('lib/main.dart').readAsStringSync();

    List<File> dartFilesUnder(String folder) => Directory(folder)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .toList();

    test('the app\'s own entry point passes none', () {
      expect(main, contains('Future<void> main() => startApp();'));
    });

    test('startApp checks the clock against kReleaseMode before anything '
        'else', () {
      expect(
        main,
        contains(
          'final clock = clockForStart(testClock, releaseMode: kReleaseMode);',
        ),
      );
      // The requested clock is used nowhere but in that check.
      expect('testClock'.allMatches(main).length, 3);
    });

    test('the clock is overridden in one place only, in main.dart', () {
      final overrides = RegExp(r'clockProvider\s*\.\s*override');
      expect(overrides.allMatches(main), hasLength(1));
      final elsewhere = <String>[
        for (final file in dartFilesUnder('lib/src'))
          if (overrides.hasMatch(file.readAsStringSync())) file.path,
      ];
      expect(elsewhere, isEmpty);
    });

    test('nothing in the app calls startApp with a clock', () {
      final callsWithClock = RegExp(r'startApp\s*\(\s*testClock');
      final callers = <String>[
        for (final file in dartFilesUnder('lib'))
          if (callsWithClock.hasMatch(file.readAsStringSync())) file.path,
      ];
      expect(callers, isEmpty);
    });

    test('no build flag, setting or stored value chooses the clock', () {
      // The only build-time value main.dart reads is FS_ENV, the mode.
      final fromEnvironment = RegExp(r'fromEnvironment\(\s*[^)]*\)');
      expect(fromEnvironment.allMatches(main).map((m) => m.group(0)), <String>[
        "fromEnvironment('FS_ENV', defaultValue: 'preview')",
      ]);
      final clockFile = File('lib/src/core/clock.dart').readAsStringSync();
      expect(clockFile, isNot(contains('fromEnvironment')));
      expect(clockFile, contains('DateTime now() => DateTime.now();'));
    });
  });
}
