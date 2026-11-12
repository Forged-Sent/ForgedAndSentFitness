import 'dart:io';

import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../core/event_id.dart';
import 'app_database.dart';

/// Phone storage: where the files live, who the local member is, and how his
/// database file is opened. Not compiled into the web preview.

/// The folder the app keeps its own files in. It is private to the app and
/// is not the member's Documents folder.
Future<Directory> appDataDirectory() => getApplicationSupportDirectory();

/// Tells SQLite where it may write temporary files. Android does not let an
/// app use the system's temporary folder, which is SQLite's default.
Future<void> useAppTemporaryDirectoryForSqlite() async {
  sqlite3.tempDirectory = (await getTemporaryDirectory()).path;
}

final RegExp _localProfileId = RegExp(
  r'^local-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
);

/// The id of the member on this phone before he has signed in.
///
/// Decision Q10: a man may use the app before signing in, with a local
/// profile that is adopted at his first sign-in. The id is made once, on
/// first launch, and kept in a small file beside the database. Adoption at
/// sign-in belongs to build step S4 and is not built.
///
/// Throws a [StateError] if the file exists but does not hold a valid id.
/// Making a new id then would silently hide everything he has recorded.
Future<String> loadOrCreateLocalProfileId(
  Directory folder, {
  String Function() newId = newEventId,
}) async {
  final file = File('${folder.path}${Platform.pathSeparator}local_profile_id');
  if (await file.exists()) {
    final stored = (await file.readAsString()).trim();
    if (!_localProfileId.hasMatch(stored)) {
      throw StateError('The local profile file does not hold a profile id.');
    }
    return stored;
  }
  final id = 'local-${newId()}';
  await folder.create(recursive: true);
  await file.writeAsString(id, flush: true);
  return id;
}

/// The database file of one owner. One file per owner id, so one member's
/// rows cannot appear for another.
File databaseFileFor(Directory folder, String ownerId) =>
    File('${folder.path}${Platform.pathSeparator}forged_$ownerId.sqlite');

/// Opens [file], creating it if it does not exist.
///
/// On a phone the database work runs on a background isolate, so a slow
/// write never stalls the screen. Tests pass `background: false` to keep
/// everything in one isolate.
AppDatabase openAppDatabase(File file, {bool background = true}) {
  return AppDatabase(
    background ? NativeDatabase.createInBackground(file) : NativeDatabase(file),
  );
}
