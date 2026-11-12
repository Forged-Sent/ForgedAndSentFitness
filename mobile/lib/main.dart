import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/forged_sent_app.dart';
import 'src/app/local_store.dart';
import 'src/app/open_local_store.dart';
import 'src/firebase/forged_firebase_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mode = String.fromEnvironment('FS_ENV', defaultValue: 'preview');

  // The member's local storage is opened before the first frame, so a box
  // he checked yesterday is checked when Today first appears. If it cannot
  // be opened the app still starts, saves nothing, and says so.
  LocalStore store;
  var storageFailed = false;
  try {
    store = await openLocalStore();
  } catch (_) {
    store = LocalStore.inMemory();
    storageFailed = true;
  }

  void start(String mode, {String? startupError}) {
    runApp(
      ProviderScope(
        overrides: [localStoreProvider.overrideWithValue(store)],
        child: ForgedSentApp(
          mode: mode,
          startupError: startupError,
          storageFailed: storageFailed,
        ),
      ),
    );
  }

  if (mode == 'preview') {
    start('preview');
    return;
  }
  if (mode != 'emulator') {
    // In this development foundation, cloud DEV/PROD modes are deliberately
    // unavailable. Never silently fall back from emulator to cloud.
    start(
      'unsupported',
      startupError: 'Cloud Firebase modes are disabled in this build.',
    );
    return;
  }

  try {
    await ForgedFirebaseRuntime.connectEmulators();
    start('emulator');
  } catch (error) {
    start('emulator', startupError: 'Emulator startup check failed.');
  }
}
