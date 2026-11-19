import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/journal/data/journal_repository.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';

const String owner = 'local-test';
const LocalDate nov12 = LocalDate(2026, 11, 12);

/// A save of [text] as the entry [entryId], tapped at [at].
JournalChange saveOf(
  String changeId,
  String entryId,
  String text, {
  DateTime? at,
  String ownerId = owner,
  JournalSource source = JournalSource.devotional,
  String prompt = 'What possession has too much of your heart?',
}) => JournalChange.save(
  id: changeId,
  ownerId: ownerId,
  entryId: entryId,
  text: text,
  source: source,
  at: at ?? DateTime(2026, 11, 12, 6, 30),
  prompt: prompt,
);

JournalChange deleteOf(
  String changeId,
  String entryId, {
  DateTime? at,
  String ownerId = owner,
}) => JournalChange.delete(
  id: changeId,
  ownerId: ownerId,
  entryId: entryId,
  at: at ?? DateTime(2026, 11, 12, 9),
);

/// The rules every journal store follows. Run against the Drift store and
/// the in-memory one.
void journalRepositoryContract(Future<JournalRepository> Function() open) {
  late JournalRepository journal;

  setUp(() async => journal = await open());

  Future<List<JournalEntry>> entries([String ownerId = owner]) =>
      journal.watchEntries(ownerId).first;

  test('a new store has no entries', () async {
    expect(await entries(), isEmpty);
    expect(await journal.entry(owner, 'j1'), isNull);
  });

  test('a save makes one entry, as it was written', () async {
    final at = DateTime(2026, 11, 12, 6, 30);
    expect(
      await journal.apply(saveOf('c1', 'j1', '  My truck.  ', at: at)),
      JournalOutcome.applied,
    );

    final entry = (await entries()).single;
    expect(entry.id, 'j1');
    expect(entry.ownerId, owner);
    expect(entry.text, 'My truck.');
    expect(entry.day, nov12);
    expect(entry.createdAtUtc, at.toUtc());
    expect(entry.utcOffset, at.timeZoneOffset);
    expect(entry.source, JournalSource.devotional);
    expect(entry.prompt, 'What possession has too much of your heart?');
    expect(entry.editedAtUtc, isNull);
    expect(entry.revision, 1);
    expect((await journal.entry(owner, 'j1'))!.text, 'My truck.');
  });

  test('saving the same entry id again changes that entry; it never makes a '
      'second (P06: a retry can never create a second entry)', () async {
    final first = DateTime(2026, 11, 12, 6, 30);
    final later = DateTime(2026, 11, 13, 21, 5);
    await journal.apply(saveOf('c1', 'j1', 'My truck.', at: first));
    expect(
      await journal.apply(
        saveOf(
          'c2',
          'j1',
          'My truck, and my time.',
          at: later,
          source: JournalSource.pen,
          prompt: '',
        ),
      ),
      JournalOutcome.applied,
    );

    final entry = (await entries()).single;
    expect(entry.text, 'My truck, and my time.');
    expect(entry.revision, 2);
    expect(entry.editedAtUtc, later.toUtc());
    // What it was when first saved does not move.
    expect(entry.day, nov12);
    expect(entry.createdAtUtc, first.toUtc());
    expect(entry.source, JournalSource.devotional);
    expect(entry.prompt, 'What possession has too much of your heart?');
  });

  test('the same change sent twice is applied once', () async {
    final change = saveOf('c1', 'j1', 'My truck.');
    expect(await journal.apply(change), JournalOutcome.applied);
    expect(await journal.apply(change), JournalOutcome.duplicate);

    expect((await entries()).single.revision, 1);
    expect(await journal.changesFor(owner, 'j1'), hasLength(1));
  });

  test('a delete takes the entry out of the journal', () async {
    await journal.apply(saveOf('c1', 'j1', 'My truck.'));
    expect(await journal.apply(deleteOf('c2', 'j1')), JournalOutcome.applied);

    expect(await entries(), isEmpty);
    expect(await journal.entry(owner, 'j1'), isNull);
    final changes = await journal.changesFor(owner, 'j1');
    expect(changes.map((c) => c.kind), <JournalChangeKind>[
      JournalChangeKind.save,
      JournalChangeKind.delete,
    ]);
    expect(changes.map((c) => c.revision), <int>[1, 2]);
    expect(changes.last.counter, greaterThan(changes.first.counter));
  });

  test('a deleted entry cannot be written again or deleted twice', () async {
    await journal.apply(saveOf('c1', 'j1', 'My truck.'));
    await journal.apply(deleteOf('c2', 'j1'));

    expect(
      await journal.apply(saveOf('c3', 'j1', 'Back again.')),
      JournalOutcome.entryGone,
    );
    expect(await journal.apply(deleteOf('c4', 'j1')), JournalOutcome.entryGone);
    expect(await entries(), isEmpty);
    expect(await journal.changesFor(owner, 'j1'), hasLength(2));
  });

  test('deleting an entry that never existed changes nothing', () async {
    expect(
      await journal.apply(deleteOf('c1', 'nope')),
      JournalOutcome.entryGone,
    );
    expect(await journal.changesFor(owner, 'nope'), isEmpty);
  });

  test('entries are listed newest first', () async {
    await journal.apply(
      saveOf('c1', 'j1', 'first', at: DateTime(2026, 11, 10, 6)),
    );
    await journal.apply(
      saveOf('c2', 'j2', 'third', at: DateTime(2026, 11, 12, 6)),
    );
    await journal.apply(
      saveOf('c3', 'j3', 'second', at: DateTime(2026, 11, 11, 6)),
    );
    // Editing the oldest does not move it up.
    await journal.apply(
      saveOf('c4', 'j1', 'first, edited', at: DateTime(2026, 11, 13, 6)),
    );

    expect((await entries()).map((e) => e.text), <String>[
      'third',
      'second',
      'first, edited',
    ]);
  });

  test('one owner cannot read or change another owner\'s entry', () async {
    await journal.apply(saveOf('c1', 'j1', 'mine'));

    expect(await entries('someone-else'), isEmpty);
    expect(await journal.entry('someone-else', 'j1'), isNull);
    // Nor what was done to it, and when.
    expect(await journal.changesFor('someone-else', 'j1'), isEmpty);
    expect(await journal.changesFor(owner, 'j1'), hasLength(1));
    expect(
      await journal.apply(
        saveOf('c2', 'j1', 'overwritten', ownerId: 'someone-else'),
      ),
      JournalOutcome.entryGone,
    );
    expect(
      await journal.apply(deleteOf('c3', 'j1', ownerId: 'someone-else')),
      JournalOutcome.entryGone,
    );
    expect((await entries()).single.text, 'mine');
  });

  test('the list is sent again after every change', () async {
    final seen = <List<String>>[];
    final listening = journal
        .watchEntries(owner)
        .listen((list) => seen.add(list.map((e) => e.text).toList()));
    addTearDown(listening.cancel);
    await pumpEventQueue();

    await journal.apply(saveOf('c1', 'j1', 'one'));
    await pumpEventQueue();
    await journal.apply(saveOf('c2', 'j1', 'one, edited'));
    await pumpEventQueue();
    await journal.apply(deleteOf('c3', 'j1'));
    await pumpEventQueue();

    expect(seen.first, isEmpty);
    expect(seen, anyElement(equals(<String>['one'])));
    expect(seen, anyElement(equals(<String>['one, edited'])));
    expect(seen.last, isEmpty);
  });
}
