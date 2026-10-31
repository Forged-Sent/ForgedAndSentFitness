import 'package:flutter/material.dart';

class ForgedSentApp extends StatelessWidget {
  const ForgedSentApp({super.key, this.mode = 'preview', this.startupError});

  final String mode;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forged & Sent',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B7C43),
          brightness: Brightness.dark,
        ),
      ),
      home: FoundationHomeScreen(mode: mode, startupError: startupError),
    );
  }
}

class FoundationHomeScreen extends StatelessWidget {
  const FoundationHomeScreen({super.key, this.mode = 'preview', this.startupError});

  final String mode;
  final String? startupError;

  @override
  Widget build(BuildContext context) {
    final status = startupError != null
        ? 'Local emulator not available. No cloud fallback was attempted.'
        : mode == 'emulator'
            ? 'Connected to local Firebase emulators (demo-forgedandsent).'
            : 'Preview mode. No Firebase cloud connection configured.';

    return Scaffold(
      appBar: AppBar(title: const Text('Forged & Sent')),
      body: SafeArea(
        child: Center(
          child: Padding(
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
                Text(status, textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12)),
                if (startupError != null) ...[
                  const SizedBox(height: 12),
                  const Text('Start the Firebase emulators and relaunch the app.',
                    textAlign: TextAlign.center),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
