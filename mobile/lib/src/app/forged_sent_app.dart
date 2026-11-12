import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../design/fs_theme.dart';
import 'fs_router.dart';

class ForgedSentApp extends StatefulWidget {
  const ForgedSentApp({
    super.key,
    this.mode = 'preview',
    this.startupError,
    this.themeMode = ThemeMode.system,
    this.now,
  });

  final String mode;
  final String? startupError;

  /// Follows the phone's dark or light setting unless a test fixes it.
  final ThemeMode themeMode;

  /// The clock. Tests pass a fixed one; the app uses the device's.
  final DateTime Function()? now;

  @override
  State<ForgedSentApp> createState() => _ForgedSentAppState();
}

class _ForgedSentAppState extends State<ForgedSentApp> {
  late final GoRouter _router = buildFsRouter(
    mode: widget.mode,
    startupError: widget.startupError,
    now: widget.now ?? DateTime.now,
  );

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Forged & Sent',
      // The corner ribbon would sit on top of the brand bar.
      debugShowCheckedModeBanner: false,
      theme: FsTheme.light,
      darkTheme: FsTheme.dark,
      themeMode: widget.themeMode,
      routerConfig: _router,
    );
  }
}

/// The developer status page: which mode this build runs in, and whether the
/// local emulator check passed. Reached from Today, and shown first when the
/// start-up check fails.
class FoundationHomeScreen extends StatelessWidget {
  const FoundationHomeScreen({
    super.key,
    this.mode = 'preview',
    this.startupError,
  });

  final String mode;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    final status = startupError != null
        ? 'Local emulator not available. No cloud fallback was attempted.'
        : mode == 'emulator'
        ? 'Verified local Auth, Firestore and Storage emulators (demo-forgedandsent).'
        : 'Preview mode. No Firebase cloud connection configured.';

    return Scaffold(
      appBar: AppBar(title: const Text('Build status')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.fitness_center, size: 64),
                const SizedBox(height: 24),
                const Text(
                  'Faith. Training. Brotherhood.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Flutter foundation is ready for the first devotional workout.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                if (startupError != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Start the Firebase emulators and relaunch the app.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
