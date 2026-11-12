import 'local_store.dart';
import 'open_local_store_web.dart'
    if (dart.library.io) 'open_local_store_native.dart'
    as platform;

/// Opens the member's local store for this platform.
///
/// On a phone: his SQLite file, through Drift. In the web preview: memory
/// only (ADR-0005: web must not claim to save).
Future<LocalStore> openLocalStore() => platform.openLocalStore();
