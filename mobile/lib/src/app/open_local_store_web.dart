import 'local_store.dart';

/// The web preview keeps nothing: there is no SQLite file in a browser
/// until the separate WASM setup in ADR-0005 is built and tested.
Future<LocalStore> openLocalStore() async => LocalStore.inMemory();
