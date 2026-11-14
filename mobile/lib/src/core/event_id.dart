import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Makes the id of one tap: a random version-4 UUID, minted once and kept
/// through every retry and replay of that tap.
///
/// The id is the completion event's only key (the maintainer's decision of
/// 2026-11-11, option A), so two taps must never share one. 122 random bits
/// from the platform's secure generator make that a non-event.
String newEventId([Random? random]) {
  final source = random ?? Random.secure();
  final bytes = List<int>.generate(16, (_) => source.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3f) | 0x80; // RFC 4122 variant
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// App-scoped. Tests override it to get ids they can name.
final eventIdProvider = Provider<String Function()>((ref) => newEventId);
