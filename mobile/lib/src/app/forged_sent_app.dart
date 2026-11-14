import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/clock.dart';
import '../design/fs_theme.dart';
import 'fs_router.dart';

/// The app. It must sit under a `ProviderScope` that supplies
/// `localStoreProvider`; `main` and the tests each do that.
class ForgedSentApp extends ConsumerStatefulWidget {
  const ForgedSentApp({
    super.key,
    this.mode = 'preview',
    this.startupError,
    this.storageFailed = false,
    this.themeMode = ThemeMode.system,
  });

  final String mode;
  final String? startupError;

  /// True when the member's local storage could not be opened. The app
  /// then runs without saving, says so, and opens on the status page.
  final bool storageFailed;

  /// Follows the phone's dark or light setting unless a test fixes it.
  final ThemeMode themeMode;

  @override
  ConsumerState<ForgedSentApp> createState() => _ForgedSentAppState();
}

class _ForgedSentAppState extends ConsumerState<ForgedSentApp> {
  late final GoRouter _router = buildFsRouter(
    mode: widget.mode,
    startupError: widget.startupError,
    storageFailed: widget.storageFailed,
  );

  /// Coming back to the app after midnight: Today must not still show
  /// yesterday. Timers do not run while the app is in the background.
  late final AppLifecycleListener _lifecycle = AppLifecycleListener(
    onResume: () => ref.read(todayDateProvider.notifier).refresh(),
  );

  @override
  void initState() {
    super.initState();
    _lifecycle;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
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
    this.storageFailed = false,
  });

  final String mode;
  final String? startupError;
  final bool storageFailed;

  @override
  Widget build(BuildContext context) {
    final status = storageFailed
        ? 'Local storage could not be opened. Nothing is saved on this device.'
        : startupError != null
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
                if (storageFailed) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Close the app and open it again.',
                    textAlign: TextAlign.center,
                  ),
                ] else if (startupError != null) ...[
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
