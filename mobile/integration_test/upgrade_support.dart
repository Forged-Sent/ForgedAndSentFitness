import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
/// All three parts run on the same calendar day: a box checked before
/// midnight is, correctly, not checked the next day. Parts 2 and 3 start a
/// workout only on a day that has one to start.

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
