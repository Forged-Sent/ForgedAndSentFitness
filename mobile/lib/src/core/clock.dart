import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_date.dart';

/// The one place the app reads the time. Everything that needs "now" or
/// "today" takes it from here, so a test can set the time and move it.
abstract interface class Clock {
  /// The current moment as a local-time `DateTime`: its fields are what the
  /// member's phone shows, and `timeZoneOffset` is his offset from UTC.
  DateTime now();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime now() => DateTime.now();
}

/// App-scoped. Tests override it with a clock they control.
final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// How often the app re-reads the clock while it is open. Midnight has its
/// own timer; this one catches a clock or a time zone that was changed.
const Duration clockCheckInterval = Duration(minutes: 1);

/// The member's current local day. It changes at local midnight while the
/// app is open, when the app comes back to the foreground, and when the
/// phone's clock is moved, so Today is never left showing yesterday.
final todayDateProvider = NotifierProvider<TodayDate, LocalDate>(TodayDate.new);

class TodayDate extends Notifier<LocalDate> {
  Timer? _midnight;
  Timer? _check;

  @override
  LocalDate build() {
    final clock = ref.watch(clockProvider);
    ref.onDispose(() {
      _midnight?.cancel();
      _check?.cancel();
    });
    _check?.cancel();
    _check = Timer.periodic(clockCheckInterval, (_) => refresh());
    final now = clock.now();
    _scheduleMidnight(now);
    return LocalDate.of(now);
  }

  /// Re-reads the clock. Called by the timers, when the app is resumed, and
  /// by every action that stamps a date, so what is on screen and what is
  /// saved agree.
  void refresh() {
    final now = ref.read(clockProvider).now();
    final today = LocalDate.of(now);
    if (today != state) {
      state = today;
    }
    _scheduleMidnight(now);
  }

  void _scheduleMidnight(DateTime now) {
    _midnight?.cancel();
    // `DateTime(y, m, d + 1)` is local midnight even across a daylight-saving
    // change. A little past it, so the clock has certainly rolled over.
    final next = DateTime(now.year, now.month, now.day + 1);
    final wait = next.difference(now) + const Duration(milliseconds: 250);
    _midnight = Timer(wait, refresh);
  }
}
