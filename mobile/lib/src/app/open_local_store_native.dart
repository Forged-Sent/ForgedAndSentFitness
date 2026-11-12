import 'dart:io';

import '../features/settings/data/settings_repository.dart';
import '../features/today/data/drift_day_repository.dart';
import '../storage/native_storage.dart';
import 'local_store.dart';

/// Opens the store in the app's own folder.
Future<LocalStore> openLocalStore() async {
  await useAppTemporaryDirectoryForSqlite();
  return openLocalStoreIn(await appDataDirectory());
}

/// Opens the store kept in [folder]: finds or creates the local profile,
/// then opens that profile's database file and reads from it once. Tests
/// call this with a temporary folder.
///
/// Throws if the profile file is damaged, or if the database file is
/// corrupt or cannot be opened. Nothing is left open in that case.
Future<LocalStore> openLocalStoreIn(
  Directory folder, {
  bool background = true,
}) async {
  final ownerId = await loadOrCreateLocalProfileId(folder);
  final database = await openCheckedAppDatabase(
    databaseFileFor(folder, ownerId),
    background: background,
  );
  return LocalStore(
    ownerId: ownerId,
    days: DriftDayRepository(database),
    settings: DriftSettingsRepository(database),
    close: database.close,
  );
}
