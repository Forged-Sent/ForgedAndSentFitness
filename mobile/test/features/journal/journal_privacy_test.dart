import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_page.dart';

import '../../support/fs_test_support.dart';

/// Words no reading and no screen contains, so finding them anywhere
/// outside the journal means journal text got there.
const String _marker = 'zqx-private-sentinel-7731';
const String _markerEdit = 'zqx-edited-sentinel-9914';

/// Whether [message] holds the bytes of [needle] anywhere in it.
bool _carries(ByteData? message, List<int> needle) {
  if (message == null) return false;
  final bytes = message.buffer.asUint8List(
    message.offsetInBytes,
    message.lengthInBytes,
  );
  outer:
  for (var i = 0; i + needle.length <= bytes.length; i++) {
    for (var j = 0; j < needle.length; j++) {
      if (bytes[i + j] != needle[j]) continue outer;
    }
    return true;
  }
  return false;
}

/// Runs [body] with everything it prints, by `print` or by `debugPrint`,
/// collected in [printed] instead of shown.
///
/// The framework checks that `debugPrint` is back in place before a test
/// ends, so it is restored here and not in a tear-down.
Future<void> _capturingPrints(
  List<String> printed,
  Future<void> Function() body,
) async {
  final oldPrint = debugPrint;
  debugPrint = (String? message, {int? wrapWidth}) =>
      printed.add(message ?? '');
  try {
    await runZoned(
      body,
      zoneSpecification: ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) =>
            printed.add(line),
      ),
    );
  } finally {
    debugPrint = oldPrint;
  }
}

/// Prompt P06, acceptance 4: a test proves no journal field is passed to
/// any Firebase call. And the constraint beside it: journal text never
/// appears in a scoring input, a shared document, a log line or an
/// analytics event.
///
/// Three kinds of proof. What the source may import; what leaves the app
/// while a man writes, edits and deletes; and what is printed while he
/// does.
void main() {
  setUpAll(loadAppFonts);

  List<File> dartFilesUnder(String folder) => Directory(folder)
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  group('by its source', () {
    final firebaseImport = RegExp(
      r'''^\s*(import|export)\s+['"]package:'''
      r'''(firebase_|cloud_firestore|cloud_functions)''',
      multiLine: true,
    );

    test('the check knows every Firebase package by its import', () {
      for (final line in <String>[
        "import 'package:firebase_core/firebase_core.dart';",
        "import 'package:firebase_auth/firebase_auth.dart';",
        "import 'package:cloud_firestore/cloud_firestore.dart';",
        "import 'package:cloud_functions/cloud_functions.dart';",
        "export 'package:cloud_functions/cloud_functions.dart';",
        '  import "package:cloud_functions/cloud_functions.dart" as fn;',
      ]) {
        expect(
          firebaseImport.hasMatch('// first line\n$line\n'),
          isTrue,
          reason: line,
        );
      }
      for (final line in <String>[
        "import 'package:drift/drift.dart';",
        "import 'package:flutter_riverpod/flutter_riverpod.dart';",
        "// import 'package:cloud_functions/cloud_functions.dart';",
      ]) {
        expect(
          firebaseImport.hasMatch('// first line\n$line\n'),
          isFalse,
          reason: line,
        );
      }
    });

    test(
      'nothing in the journal feature, or the database, imports Firebase',
      () {
        final sources = <File>[
          ...dartFilesUnder('lib/src/features/journal'),
          ...dartFilesUnder('lib/src/storage'),
        ];
        expect(sources.length, greaterThanOrEqualTo(9));
        expect(<String>[
          for (final file in sources)
            if (firebaseImport.hasMatch(file.readAsStringSync())) file.path,
        ], isEmpty);
      },
    );

    test('the only code that may call Firebase cannot reach the journal: it '
        'imports nothing from the app', () {
      final appImport = RegExp(
        r'''^\s*(import|export)\s+['"](\.\./|package:forged_and_sent/)''',
        multiLine: true,
      );
      final firebase = dartFilesUnder('lib/src/firebase');
      expect(firebase, isNotEmpty);
      for (final file in firebase) {
        final source = file.readAsStringSync();
        expect(
          appImport.hasMatch(source),
          isFalse,
          reason: '${file.path} imports app code',
        );
        expect(
          source.toLowerCase(),
          isNot(contains('journal')),
          reason: '${file.path} mentions the journal',
        );
      }
    });

    test(
      'every file that imports Firebase is in the Firebase folder, or is main',
      () {
        final importers = <String>[
          for (final file in dartFilesUnder('lib'))
            if (firebaseImport.hasMatch(file.readAsStringSync()))
              file.path.replaceAll(r'\', '/'),
        ];
        for (final path in importers) {
          expect(
            path.startsWith('lib/src/firebase/') || path == 'lib/main.dart',
            isTrue,
            reason: '$path imports Firebase',
          );
        }
      },
    );

    test('the entry point, the one app file that imports Firebase, does not '
        'touch the journal and hands Firebase nothing from the store', () {
      final source = File('lib/main.dart').readAsStringSync();
      expect(source.toLowerCase(), isNot(contains('journal')));
      // Every call it makes on the Firebase connector, with its
      // arguments. None may name the store, the owner or a repository.
      final calls = RegExp(
        r'ForgedFirebaseRuntime\b[^;]*;',
      ).allMatches(source).map((match) => match.group(0)!).toList();
      expect(calls, isNotEmpty);
      for (final call in calls) {
        expect(
          RegExp(r'\b(store|localStore|ownerId|journal|days)\b').hasMatch(call),
          isFalse,
          reason: 'main.dart passes app data to Firebase: $call',
        );
      }
    });

    test('no app code prints or logs at all', () {
      final logging = RegExp(
        r'\b(print|debugPrint|debugPrintStack|log)\s*\(|dart:developer',
      );
      expect(<String>[
        for (final file in dartFilesUnder('lib'))
          if (logging.hasMatch(file.readAsStringSync())) file.path,
      ], isEmpty);
    });

    test('the journal feature prints and logs nothing', () {
      final logging = RegExp(
        r'\b(print|debugPrint|debugPrintStack|log)\s*\(|dart:developer',
      );
      expect(<String>[
        for (final file in dartFilesUnder('lib/src/features/journal'))
          if (logging.hasMatch(file.readAsStringSync())) file.path,
      ], isEmpty);
    });

    test(
      'nothing that scores or counts a day reads the journal: Today\'s rules '
      'and stores do not import it',
      () {
        for (final folder in <String>[
          'lib/src/features/today/domain',
          'lib/src/features/today/data',
        ]) {
          for (final file in dartFilesUnder(folder)) {
            expect(
              file.readAsStringSync().toLowerCase(),
              isNot(contains('journal')),
              reason: '${file.path} mentions the journal',
            );
          }
        }
      },
    );
  });

  group('while he writes, edits and deletes', () {
    testWidgets(
      'no message goes to a Firebase plugin, and his words go to no plugin '
      'but the keyboard',
      (tester) async {
        final channels = <String>[];
        final carriers = <String>{};
        final printed = <String>[];
        final secrets = <List<int>>[
          utf8.encode(_marker),
          utf8.encode(_markerEdit),
        ];

        // Every message the app sends to the platform passes through here.
        tester.binding.defaultBinaryMessenger.allMessagesHandler =
            (String channel, MessageHandler? handler, ByteData? message) {
              channels.add(channel);
              if (secrets.any((secret) => _carries(message, secret))) {
                carriers.add(channel);
              }
              return handler?.call(message) ?? Future<ByteData?>.value();
            };
        addTearDown(
          () => tester.binding.defaultBinaryMessenger.allMessagesHandler = null,
        );
        late AppHarness app;
        await _capturingPrints(printed, () async {
          app = await pumpApp(tester);

          // Write under the reading, and save.
          await writeItDown(tester, 'First: $_marker');
          expect(
            (await app.savedJournal(tester)).single.text,
            contains(_marker),
          );

          // Open it from the Journal page, change it, save.
          await tapVisible(
            tester,
            find.byKey(const ValueKey<String>('fs-journal-open')),
          );
          expect(find.byType(JournalPage), findsOneWidget);
          final id = (await app.savedJournal(tester)).single.id;
          await tester.tap(
            find.byKey(ValueKey<String>('fs-journal-entry-$id')),
          );
          await tester.pumpAndSettle();
          await typeInto(tester, entryBox, 'Changed: $_markerEdit');
          await tapVisible(tester, entrySave);
          expect(
            (await app.savedJournal(tester)).single.text,
            contains(_markerEdit),
          );

          // A second entry from the pen, then delete the first.
          await systemBack(tester);
          await scrollTodayToTop(tester);
          await tester.tap(heroButton(FsHeroActionKind.journal));
          await tester.pumpAndSettle();
          await typeInto(tester, entryBox, 'Pen: $_marker');
          await tapVisible(tester, entrySave);
          await tester.tap(
            find.byKey(ValueKey<String>('fs-journal-entry-$id')),
          );
          await tester.pumpAndSettle();
          await tapVisible(tester, entryDelete);
          await tapVisible(tester, entryDelete);
          expect(await app.savedJournal(tester), hasLength(1));
        });

        // The app did talk to the platform, so the recorder was listening.
        expect(channels, isNotEmpty);
        expect(
          channels.where(
            (channel) =>
                channel.toLowerCase().contains('firebase') ||
                channel.toLowerCase().contains('firestore'),
          ),
          isEmpty,
        );
        // Typing necessarily tells the keyboard what is in the box. That it
        // was seen there shows the recorder can see his words at all.
        expect(carriers, contains('flutter/textinput'));
        expect(carriers.difference(<String>{'flutter/textinput'}), isEmpty);
        expect(
          printed.where(
            (line) => line.contains(_marker) || line.contains(_markerEdit),
          ),
          isEmpty,
        );
      },
    );

    testWidgets('a failed save prints nothing about his words either', (
      tester,
    ) async {
      final printed = <String>[];
      final journal = TestJournalRepository()..failWrites = true;
      await _capturingPrints(printed, () async {
        await pumpApp(tester, store: testStore(journal: journal));
        await writeItDown(tester, 'Failing: $_marker');
      });

      expect(journal.attempts, 1);
      expect(tester.takeException(), isNull);
      expect(printed.where((line) => line.contains(_marker)), isEmpty);
    });
  });

  testWidgets('the print capture would notice his words, printed either way', (
    tester,
  ) async {
    // Guards the two log checks above against a capture that sees nothing:
    // a widget that prints when tapped, as a careless dependency might.
    final printed = <String>[];
    await _capturingPrints(printed, () async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              // ignore: avoid_print
              print('print: $_marker');
              await Future<void>.value();
              debugPrint('debugPrint: $_markerEdit');
            },
            child: const SizedBox.expand(),
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();
    });

    expect(printed, contains('print: $_marker'));
    expect(printed, contains('debugPrint: $_markerEdit'));
  });

  test('the recorder would notice his words in a message', () {
    // Guards the byte search above against a mistake that makes it blind:
    // this is what a Firestore write of an entry would look like.
    final write = const StandardMethodCodec().encodeMethodCall(
      const MethodCall('DocumentReference#set', <String, Object?>{
        'data': <String, Object?>{'text': 'x $_marker y'},
      }),
    );
    final harmless = const StandardMethodCodec().encodeMethodCall(
      const MethodCall('DocumentReference#set', <String, Object?>{
        'data': <String, Object?>{'done': true},
      }),
    );
    expect(_carries(write, utf8.encode(_marker)), isTrue);
    expect(_carries(harmless, utf8.encode(_marker)), isFalse);
    expect(_carries(null, utf8.encode(_marker)), isFalse);
  });
}
