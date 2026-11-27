import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/app/open_local_store.dart';
import 'package:forged_and_sent/src/core/clock.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import 'journal_restart_support.dart';

/// Shared by the three parts of the upgrade test: a phone that ran the
/// build before workout logging (database schema version 2: the day's
/// boxes and the journal) gets the build with workout logging (version 3)
/// installed over it, without being uninstalled.
///
/// Part 1 is run from a checkout of the older build, parts 2 and 3 from
/// this one. Part 1 uses only what both builds have, so the same file runs
/// in either. Copy `upgrade_support.dart` and `upgrade_1_on_older_build_test.dart`
/// into the older checkout's `integration_test/` folder, then:
///
///     (older checkout) flutter test integration_test/upgrade_1_on_older_build_test.dart -d <device> --no-uninstall
///     (this checkout)  flutter test integration_test/upgrade_2_after_install_test.dart -d <device> --no-uninstall
///     (this checkout)  flutter test integration_test/upgrade_3_after_relaunch_test.dart -d <device>
///
/// Start with the app not installed. **Run it only on an emulator or
/// simulator, or on a device whose app data may be lost:** the last command
/// ends by uninstalling the app.
///
/// **The clock.** Part 2 starts a workout, and a workout can be started
/// only on a day that has one: Monday, Wednesday or Friday on the plan
/// every member gets. The test must pass whatever day it is run on, with
/// the device's own date left alone. So all three parts start the app
/// with its clock moved forward by whole days to the next lifting day, as
/// the workout restart test does; on a lifting day it is not moved at all.
/// Nothing else about the clock changes: it still runs.
///
/// Parts 2 and 3 start the app through its own door for that,
/// `startApp(testClock:)` (`startAppOnLiftingDay` in
/// `workout_restart_support.dart`). The older build has no such door, so
/// part 1 starts it the way that build's `main()` does, with the clock
/// put in beside the store: [startOlderAppOnLiftingDay], which uses only
/// what both builds have. The two clocks follow one rule, written twice;
/// part 2 checks that, started together, they give the same day. That
/// part 1 really ran on that day is shown by the devotional box: parts 2
/// and 3 find it checked only on the day the older build completed it.
///
/// All three parts run on the same real day, and not across midnight:
/// they would not agree on the day they moved to, and a box checked on
/// one day is, correctly, not checked on the next.

/// The phone's clock moved forward by whole days to the next lifting day:
/// Monday, Wednesday or Friday. The same rule as `NextLiftingDayClock` in
/// `workout_restart_support.dart`, written again here because this file
/// must also compile in the older build, which does not have that one.
class UpgradeLiftingDayClock implements Clock {
  UpgradeLiftingDayClock() : _days = _daysToLiftingDay();

  final int _days;

  static const Set<int> _liftingDays = <int>{
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  };

  static int _daysToLiftingDay() {
    final today = LocalDate.of(DateTime.now());
    for (var days = 0; days < 7; days++) {
      if (_liftingDays.contains(today.addDays(days).weekday)) return days;
    }
    throw StateError('No lifting day in the next week.');
  }

  @override
  DateTime now() {
    final real = DateTime.now();
    // Calendar days, not 24-hour steps: the hour on the clock stays the
    // same across a daylight-saving change.
    return DateTime(
      real.year,
      real.month,
      real.day + _days,
      real.hour,
      real.minute,
      real.second,
      real.millisecond,
    );
  }
}

/// Starts the older build on [UpgradeLiftingDayClock] and waits for
/// Today's boxes.
///
/// It does what that build's `main()` does when it starts in preview
/// mode: opens the member's store and runs the app over it. The one
/// difference is the clock, put in beside the store. The newer build is
/// started through `startApp(testClock:)` instead.
Future<Clock> startOlderAppOnLiftingDay(WidgetTester tester) async {
  final clock = UpgradeLiftingDayClock();
  final (:store, :storageFailed) = await openLocalStoreOrFallback();
  runApp(
    ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(store),
        clockProvider.overrideWithValue(clock),
      ],
      child: ForgedSentApp(storageFailed: storageFailed),
    ),
  );
  await tester.pumpAndSettle();
  for (var i = 0; i < 100 && find.byType(FsBoxRow).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(TodayPage), findsOneWidget);
  expect(find.byType(FsBoxRow), findsWidgets);
  return clock;
}

/// What part 1 writes and parts 2 and 3 look for. Made up for this test.
const String upgradeEntryUnderReading =
    'Upgrade test, first entry. Written under the reading on the older build.';
const String upgradeEntryFromJournal =
    'Upgrade test, second entry. Written from the journal on the older build.';

final Finder newEntryButton = find.byKey(
  const ValueKey<String>('fs-journal-new'),
);
final Finder entrySaveButton = find.byKey(
  const ValueKey<String>('fs-entry-save'),
);

/// The journal rows that hold [words].
Finder rowsWith(String words) =>
    find.ancestor(of: find.textContaining(words), matching: journalRows);

/// Both of this test's entries are in the list, once each.
void expectBothEntries() {
  expect(rowsWith(upgradeEntryUnderReading), findsOneWidget);
  expect(rowsWith(upgradeEntryFromJournal), findsOneWidget);
}
