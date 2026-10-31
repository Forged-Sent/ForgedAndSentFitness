import 'package:flutter/material.dart';

import 'src/app/forged_sent_app.dart';
import 'src/firebase/forged_firebase_runtime.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const mode = String.fromEnvironment('FNS_ENV', defaultValue: 'preview');
  if (mode == 'preview') {
    runApp(const ForgedSentApp());
    return;
  }
  if (mode != 'emulator') {
    // In this development foundation, cloud DEV/PROD modes are deliberately
    // unavailable. Never silently fall back from emulator to cloud.
    runApp(const ForgedSentApp(
      mode: 'unsupported',
      startupError: 'Cloud Firebase modes are disabled in this build.',
    ));
    return;
  }

  try {
    await ForgedFirebaseRuntime.connectEmulators();
    runApp(const ForgedSentApp(mode: 'emulator'));
  } catch (error) {
    runApp(const ForgedSentApp(
      mode: 'emulator',
      startupError: 'Emulator startup check failed.',
    ));
  }
}
