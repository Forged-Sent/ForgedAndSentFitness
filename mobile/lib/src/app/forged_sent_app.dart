import 'package:flutter/material.dart';

class ForgedSentApp extends StatelessWidget {
  const ForgedSentApp({super.key});

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
      home: const FoundationHomeScreen(),
    );
  }
}

class FoundationHomeScreen extends StatelessWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forged & Sent')),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fitness_center, size: 64),
                SizedBox(height: 24),
                Text(
                  'Faith. Training. Brotherhood.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text(
                  'Flutter foundation is ready for the first devotional workout.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'No account or Firebase connection configured yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
