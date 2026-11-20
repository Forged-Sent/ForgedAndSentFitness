import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_entry_page.dart';

import 'journal_restart_support.dart';

/// Shared by the three parts of the journal's edit and delete test on a
/// device: an entry is changed, the app is killed, and the change is there;
/// the entry is deleted, the app is killed, and it is still gone.
///
/// Three files, run one after the other, each a new process that starts
/// the real app with its real database file:
///
///     flutter test integration_test/journal_edit_restart_1_change_test.dart -d <device> --no-uninstall
///     flutter test integration_test/journal_edit_restart_2_delete_test.dart -d <device> --no-uninstall
///     flutter test integration_test/journal_edit_restart_3_gone_test.dart -d <device>
///
/// **Run it only on an emulator or simulator, or on a device whose app data
/// may be lost.** The last command ends by uninstalling the app, and with
/// it everything the app holds on that device.
///
/// The steps work in the app's real journal and touch only entries that
/// hold this test's own sentences. Any left over from an earlier run are
/// deleted first.

/// What part 1 first writes. Made up for this test; nobody's journal.
const String editEntryBefore =
    'Edit test entry, as first written. These words are replaced.';

/// What part 1 changes it to, and part 2 looks for.
const String editEntryAfter =
    'Edit test entry, after the change. These words were saved over the first.';

/// A second entry that part 1 writes and nothing changes or deletes. It
/// must be there in every part: without it, a journal that came back empty
/// would look the same as an entry that stayed deleted.
const String editEntryThatStays =
    'Edit test entry that stays. Nothing changes or deletes these words.';

final Finder newEntryButton = find.byKey(
  const ValueKey<String>('fs-journal-new'),
);
final Finder entrySaveButton = find.byKey(
  const ValueKey<String>('fs-entry-save'),
);

/// The journal rows that hold [words].
Finder rowsWith(String words) =>
    find.ancestor(of: find.textContaining(words), matching: journalRows);

/// Types [words] into the open entry's box and saves, then waits for the
/// Journal page.
Future<void> saveOpenEntryAs(WidgetTester tester, String words) async {
  expect(find.byType(JournalEntryPage), findsOneWidget);
  await tester.enterText(fieldIn('fs-entry-box'), words);
  await tester.pumpAndSettle();
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(entrySaveButton);
  await tester.pumpAndSettle();
  await tester.tap(entrySaveButton);
  // On a device the save is real work on another thread: the page closes a
  // moment after the tap.
  for (
    var i = 0;
    i < 100 && find.byType(JournalEntryPage).evaluate().isNotEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await waitForJournal(tester);
}

/// Deletes the open entry: the link asks for a second tap. Then waits for
/// the Journal page.
Future<void> deleteOpenEntry(WidgetTester tester) async {
  expect(find.byType(JournalEntryPage), findsOneWidget);
  for (var tap = 0; tap < 2; tap++) {
    await tester.ensureVisible(entryDelete);
    await tester.pumpAndSettle();
    await tester.tap(entryDelete);
    await tester.pumpAndSettle();
  }
  for (
    var i = 0;
    i < 100 && find.byType(JournalEntryPage).evaluate().isNotEmpty;
    i++
  ) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await waitForJournal(tester);
}

/// Deletes every entry that holds [words], one at a time.
Future<void> deleteLeftOver(WidgetTester tester, String words) async {
  for (var i = 0; i < 10 && rowsWith(words).evaluate().isNotEmpty; i++) {
    await tester.tap(rowsWith(words).first);
    await tester.pumpAndSettle();
    expect(openEntryWords(tester), words);
    await deleteOpenEntry(tester);
  }
  expect(rowsWith(words), findsNothing);
}
