import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/clock.dart';
import 'package:forged_and_sent/src/core/event_id.dart';
import 'package:forged_and_sent/src/core/local_date.dart';

import '../support/fs_test_support.dart';

/// A container whose "today" follows [clock].
///
/// These are widget tests only for their fake clock: `tester.pump(duration)`
/// makes that much time pass for the timers. Each test disposes its
/// container itself; a timer left running after that fails the test.
ProviderContainer _container(TestClock clock) {
  final container = ProviderContainer(
    overrides: [clockProvider.overrideWithValue(clock)],
  );
  // Keep the provider alive, as a screen that shows the date does.
  container.listen(todayDateProvider, (_, _) {});
  return container;
}

void main() {
  group('today', () {
    testWidgets('is the clock\'s local date', (tester) async {
      final container = _container(TestClock(DateTime(2026, 11, 12, 9)));

      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 12));
      container.dispose();
    });

    testWidgets('changes at local midnight while the app is open', (
      tester,
    ) async {
      final clock = TestClock(DateTime(2026, 11, 12, 23, 59, 30));
      final container = _container(clock);
      final seen = <LocalDate>[];
      container.listen(todayDateProvider, (_, next) => seen.add(next));

      // Ten seconds before midnight: still the 12th.
      clock.time = DateTime(2026, 11, 12, 23, 59, 50);
      await tester.pump(const Duration(seconds: 20));
      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 12));

      // Just past it: the 13th, without anyone touching the screen. Eleven
      // seconds is less than the one-minute check, so this is the midnight
      // timer.
      clock.time = DateTime(2026, 11, 13, 0, 0, 1);
      await tester.pump(const Duration(seconds: 11));
      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 13));
      expect(seen, <LocalDate>[const LocalDate(2026, 11, 13)]);

      // And again the night after.
      clock.time = DateTime(2026, 11, 14, 0, 0, 1);
      await tester.pump(const Duration(days: 1));
      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 14));
      container.dispose();
    });

    testWidgets('follows a clock that was moved, within a minute', (
      tester,
    ) async {
      final clock = TestClock(DateTime(2026, 11, 12, 9));
      final container = _container(clock);

      // The member sets his phone back a day. No midnight passes.
      clock.time = DateTime(2026, 11, 11, 9);
      await tester.pump(clockCheckInterval);
      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 11));

      // And forward two.
      clock.time = DateTime(2026, 11, 13, 9);
      await tester.pump(clockCheckInterval);
      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 13));
      container.dispose();
    });

    testWidgets('refresh re-reads the clock at once', (tester) async {
      final clock = TestClock(DateTime(2026, 11, 12, 9));
      final container = _container(clock);

      clock.time = DateTime(2026, 11, 13, 9);
      container.read(todayDateProvider.notifier).refresh();

      expect(container.read(todayDateProvider), const LocalDate(2026, 11, 13));
      container.dispose();
    });
  });

  group('event ids', () {
    final form = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    test('are version-4 UUIDs', () {
      for (var i = 0; i < 50; i++) {
        expect(newEventId(), matches(form));
      }
    });

    test('do not repeat', () {
      final ids = <String>{for (var i = 0; i < 2000; i++) newEventId()};

      expect(ids, hasLength(2000));
    });
  });
}
