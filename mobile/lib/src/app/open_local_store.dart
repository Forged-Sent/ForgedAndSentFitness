import 'local_store.dart';
import 'open_local_store_web.dart'
    if (dart.library.io) 'open_local_store_native.dart'
    as platform;

/// Opens the member's local store for this platform.
///
/// On a phone: his SQLite file, through Drift. In the web preview: memory
/// only (ADR-0005: web must not claim to save).
Future<LocalStore> openLocalStore() => platform.openLocalStore();

/// What start-up has to work with: a store, and whether it is the member's
/// real one.
typedef StartupStore = ({LocalStore store, bool storageFailed});

/// Opens the member's local store with [open]. If that fails, for example
/// because his database file is corrupt, the app still starts: with a
/// store that keeps nothing, and `storageFailed` set, so the app opens on
/// the status page and says that nothing is saved.
Future<StartupStore> openLocalStoreOrFallback([
  Future<LocalStore> Function() open = openLocalStore,
]) async {
  try {
    return (store: await open(), storageFailed: false);
  } catch (_) {
    return (store: LocalStore.inMemory(), storageFailed: true);
  }
}
