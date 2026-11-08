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
      const String.fromEnvironment('FS_ENV', defaultValue: 'preview') ==
      'emulator';

  static String get emulatorHost {
    const override = String.fromEnvironment('FNS_EMULATOR_HOST');
    if (override.isNotEmpty) return override;
    if (kIsWeb) return '127.0.0.1';
    if (defaultTargetPlatform == TargetPlatform.android) return '10.0.2.2';
    return '127.0.0.1';
  }

  static Future<void> connectEmulators() async {
    const configuredProject = String.fromEnvironment(
      'FNS_FIREBASE_PROJECT',
      defaultValue: projectId,
    );
    if (!configuredProject.startsWith('demo-') ||
        configuredProject != projectId) {
      throw StateError(
        'Emulator mode requires demo-forgedandsent, not a live Firebase project.',
      );
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
    final auth = FirebaseAuth.instanceFor(app: app);
    final firestore = FirebaseFirestore.instanceFor(app: app);
    final storage = FirebaseStorage.instanceFor(app: app);
    await auth.useAuthEmulator(emulatorHost, 9099);
    firestore.useFirestoreEmulator(emulatorHost, 8080);
    await storage.useStorageEmulator(emulatorHost, 9199);

    // Real round-trips against all three emulators, not only configuration.
    final credential = await auth.signInAnonymously().timeout(
      const Duration(seconds: 15),
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Anonymous emulator sign-in returned no user.');
    }
    await firestore
        .collection('developer_smoke')
        .doc(user.uid)
        .get(const GetOptions(source: Source.server))
        .timeout(const Duration(seconds: 15));
    try {
      await storage
          .ref('developer_smoke/${user.uid}/__healthcheck_missing__.txt')
          .getMetadata()
          .timeout(const Duration(seconds: 15));
    } on FirebaseException catch (error) {
      if (error.code != 'object-not-found') rethrow;
    }
  }
}
