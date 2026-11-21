import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_page.dart';
import 'package:forged_and_sent/src/features/settings/presentation/settings_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

/// Shared by the two halves of the journal's restart test (P06 acceptance 1
/// on a device: write an entry, kill the app, relaunch, the entry is
/// there). That an edit and a delete survive a restart is tested on a real
/// SQLite file, in `test/features/journal/drift_journal_repository_test.dart`,
/// and on a device by the three `journal_edit_restart_*` files.
///
/// It follows `restart_support.dart`: two files, run one after the other
/// with the app's process stopped in between, each starting the real app
/// with its real database file.
///
///     flutter test integration_test/journal_restart_1_write_test.dart -d <device> --no-uninstall
///     flutter test integration_test/journal_restart_2_verify_test.dart -d <device>
///
/// **Run it only on an emulator or simulator, or on a device whose app data
/// may be lost.** The second command ends by uninstalling the app, and with
/// it everything the app holds on that device: the whole journal and every
/// checked day.
///
/// The test's own steps work in the app's real journal and touch only
/// entries that hold its own sentence, [restartEntryWords]: the first half
/// deletes any left over from an earlier run and writes one. It neither
/// counts nor opens any other entry.

/// What the first half writes and the second half looks for. Made up for
/// this test; nobody's journal.
const String restartEntryWords =
    'Restart test entry. These words were written before the app was killed.';

final Finder journalSaveButton = find.byKey(
  const ValueKey<String>('fs-journal-save'),
);
final Finder journalMessage = find.byKey(
  const ValueKey<String>('fs-journal-message'),
);
final Finder journalOpenButton = find.byKey(
  const ValueKey<String>('fs-journal-open'),
);
final Finder entryDelete = find.byKey(
  const ValueKey<String>('fs-entry-delete'),
);

/// The field inside the box with [key], which is what text is typed into.
Finder fieldIn(String key) => find.descendant(
  of: find.byKey(ValueKey<String>(key)),
  matching: find.byType(EditableText),
);

/// Every row in the journal's list.
final Finder journalRows = find.byWidgetPredicate((Widget widget) {
  final key = widget.key;
  return key is ValueKey<String> && key.value.startsWith('fs-journal-entry-');
});

/// The rows that hold this test's own sentence. The only rows the test
/// counts, opens or deletes.
final Finder restartEntryRows = find.ancestor(
  of: find.textContaining(restartEntryWords),
  matching: journalRows,
);

/// Opens the Journal page from Today: the profile button, Settings, "Open
/// my journal".
Future<void> openJournalFromToday(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey<String>('fs-hero-profile')));
  await tester.pumpAndSettle();
  expect(find.byType(SettingsPage), findsOneWidget);
  final open = find.byKey(const ValueKey<String>('fs-settings-journal'));
  await tester.ensureVisible(open);
  await tester.pumpAndSettle();
  await tester.tap(open);
  await tester.pumpAndSettle();
  await waitForJournal(tester);
}

/// Waits for the Journal page to have its list, or its empty line.
Future<void> waitForJournal(WidgetTester tester) async {
  final settled = find.byKey(const ValueKey<String>('fs-journal-new'));
  for (var i = 0; i < 50 && settled.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
  expect(find.byType(JournalPage), findsOneWidget);
}

/// Android's back button, until Today is on screen again.
Future<void> backToToday(WidgetTester tester) async {
  for (var i = 0; i < 4 && find.byType(TodayPage).evaluate().isEmpty; i++) {
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }
  expect(find.byType(TodayPage), findsOneWidget);
}

/// The words in the field of the entry that is open.
String openEntryWords(WidgetTester tester) =>
    tester.widget<EditableText>(fieldIn('fs-entry-box')).controller.text;
