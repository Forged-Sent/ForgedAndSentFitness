import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Explicitly local-only developer configuration. It never reads real
/// google-services.json, GoogleService-Info.plist, or cloud Firebase options.
class ForgedFirebaseRuntime {
  static const projectId = 'demo-forgedandsent';

  static bool get emulatorRequested =>
      const String.fromEnvironment('FNS_ENV', defaultValue: 'preview') ==
      'emulator';

  static String get emulatorHost {
    const override = String.fromEnvironment('FNS_EMULATOR_HOST');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return '127.0.0.1';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return '127.0.0.1';
  }

  static Future<void> connectEmulators() async {
    const configuredProject =
        String.fromEnvironment('FNS_FIREBASE_PROJECT', defaultValue: projectId);
    if (!configuredProject.startsWith('demo-') || configuredProject != projectId) {
      throw StateError('Emulator mode requires demo-forgedandsent, not a live Firebase project.');
    }

    final app = await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'demo-api-key',
        appId: '1:1234567890:web:forgedandsentdemo',
        messagingSenderId: '1234567890',
        projectId: projectId,
        storageBucket: 'demo-forgedandsent.appspot.com',
      ),
    );
    await FirebaseAuth.instanceFor(app: app).useAuthEmulator(emulatorHost, 9099);
    FirebaseFirestore.instanceFor(app: app).useFirestoreEmulator(emulatorHost, 8080);
    await FirebaseStorage.instanceFor(app: app).useStorageEmulator(emulatorHost, 9199);

    // Actually contact the Auth emulator rather than claiming that a configured
    // SDK is connected. Failure is surfaced to the UI; never retries in cloud.
    await FirebaseAuth.instanceFor(app: app).signInAnonymously();
  }
}
