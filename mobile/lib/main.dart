import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app/forged_sent_app.dart';
import 'src/app/local_store.dart';
import 'src/app/open_local_store.dart';
import 'src/core/clock.dart';
import 'src/firebase/forged_firebase_runtime.dart';

/// The app as the phone starts it: on the phone's own clock.
Future<void> main() => startApp();

/// The clock the app starts with: [requested], or null for the phone's own.
///
/// A clock can be requested only by Dart code that calls [startApp] with
/// one, and the only such code is the restart test under
/// `integration_test/`, which is not part of an app build. No setting,
/// build flag, link or stored value reaches this.
///
/// A release build refuses a requested clock outright: it throws, so the
/// app cannot start on anything but the phone's clock. [releaseMode] is
/// `kReleaseMode` in the app; it is a parameter so a test can prove the
/// refusal, which a test run can never be in release mode to see.
Clock? clockForStart(Clock? requested, {required bool releaseMode}) {
  if (requested != null && releaseMode) {
    throw StateError('A release build runs on the phone’s clock only.');
  }
  return requested;
}

/// Starts the app. [testClock] is for the restart test on the emulator,
/// which has to run on a lifting day whatever day it really is; see
/// [clockForStart] for why a release build can never be given one.
Future<void> startApp({Clock? testClock}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final clock = clockForStart(testClock, releaseMode: kReleaseMode);
  const mode = String.fromEnvironment('FS_ENV', defaultValue: 'preview');

  // The member's local storage is opened, and read from once, before the
  // first frame, so a box he checked yesterday is checked when Today first
  // appears. If it cannot be opened or read the app still starts, saves
  // nothing, and says so.
  final (:store, :storageFailed) = await openLocalStoreOrFallback();

  void start(String mode, {String? startupError}) {
    runApp(
      ProviderScope(
        overrides: [
          localStoreProvider.overrideWithValue(store),
          if (clock != null) clockProvider.overrideWithValue(clock),
        ],
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
