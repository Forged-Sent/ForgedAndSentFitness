import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Carried over from the Today demo branch and widened. There it covered
/// the Today feature; here it covers everything a feature is built from.
///
/// AGENTS.md: UI depends on application and domain code, not on Firebase
/// SDK types. Build step S1 writes nothing to Firebase at all, so nothing
/// outside `lib/src/firebase/` and `main.dart` may import its SDK.
void main() {
  final firebaseImport = RegExp(
    r'''^\s*(import|export)\s+['"]package:(firebase_|cloud_firestore)''',
    multiLine: true,
  );

  for (final folder in <String>[
    'lib/src/features',
    'lib/src/core',
    'lib/src/storage',
    'lib/src/design',
    'lib/src/app',
  ]) {
    test('$folder imports no Firebase SDK', () {
      final sources = Directory(folder)
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .toList();
      expect(sources, isNotEmpty, reason: 'No Dart files under $folder');

      final offenders = <String>[
        for (final file in sources)
          if (firebaseImport.hasMatch(file.readAsStringSync())) file.path,
      ];
      expect(offenders, isEmpty);
    });
  }

  test('the check itself would catch an import', () {
    expect(
      firebaseImport.hasMatch(
        "import 'package:cloud_firestore/cloud_firestore.dart';",
      ),
      isTrue,
    );
    expect(
      firebaseImport.hasMatch(
        "import 'package:firebase_auth/firebase_auth.dart';",
      ),
      isTrue,
    );
    expect(
      firebaseImport.hasMatch("import 'package:drift/drift.dart';"),
      isFalse,
    );
  });
}
