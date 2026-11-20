import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';

const String _words = 'sentinel-words-that-must-stay-private';

JournalEntry _entry({
  required LocalDate day,
  JournalSource source = JournalSource.pen,
  DateTime? createdAtUtc,
}) => JournalEntry(
  id: 'j1',
  ownerId: 'local-test',
  day: day,
  createdAtUtc: createdAtUtc ?? DateTime.utc(2026, 11, 10, 12, 30),
  utcOffset: const Duration(hours: -5),
  text: _words,
  source: source,
  prompt: '',
  revision: 1,
);

void main() {
  group('what may be saved', () {
    test('blank space around the text is dropped', () {
      expect(
        JournalText.clean('  I was short with my son.\n'),
        'I was short with my son.',
      );
    });

    test('nothing, or only blank space, is not an entry', () {
      expect(JournalText.clean(''), isNull);
      expect(JournalText.clean(' \n\t '), isNull);
    });

    test('4000 characters is the most, as in the prototype', () {
      expect(JournalText.clean('a' * 4000), hasLength(4000));
      expect(JournalText.clean('a' * 4001), isNull);
    });

    test('a save with no text cannot be built', () {
      expect(
        () => JournalChange.save(
          id: 'c1',
          ownerId: 'local-test',
          entryId: 'j1',
          text: '   ',
          source: JournalSource.pen,
          at: DateTime(2026, 11, 10, 7, 30),
        ),
        throwsArgumentError,
      );
    });
  });

  group('a change', () {
    test('is filed under the local date of the tap (decision Q9)', () {
      final late = JournalChange.save(
        id: 'c1',
        ownerId: 'local-test',
        entryId: 'j1',
        text: 'late',
        source: JournalSource.pen,
        at: DateTime(2026, 11, 10, 23, 59),
      );
      expect(late.day, const LocalDate(2026, 11, 10));
      expect(late.atUtc.isUtc, isTrue);
      expect(late.utcOffset, DateTime(2026, 11, 10, 23, 59).timeZoneOffset);
    });
  });

  group('printing never shows the words', () {
    test('an entry', () {
      final printed = _entry(day: const LocalDate(2026, 11, 10)).toString();
      expect(printed, isNot(contains(_words)));
      expect(printed, contains('${_words.length} characters'));
    });

    test('a change', () {
      final change = JournalChange.save(
        id: 'c1',
        ownerId: 'local-test',
        entryId: 'j1',
        text: _words,
        source: JournalSource.devotional,
        at: DateTime(2026, 11, 10, 7, 30),
        prompt: 'What possession has too much of your heart?',
      );
      expect(change.toString(), isNot(contains(_words)));
      expect(change.toString(), isNot(contains('possession')));
    });
  });

  group('the line above an entry (the prototype\'s jrWhen)', () {
    const today = LocalDate(2026, 11, 10);

    test('written under today\'s reading', () {
      expect(
        journalWhen(
          _entry(day: today, source: JournalSource.devotional),
          today,
        ),
        'Today · Devotional',
      );
    });

    test('written from the pen today shows the time on his clock', () {
      // 12:30 UTC at five hours behind UTC is 7:30 in the morning.
      expect(journalWhen(_entry(day: today), today), 'Today · 7:30 AM');
    });

    test('yesterday, and any earlier day', () {
      expect(journalWhen(_entry(day: today.previous), today), 'Yesterday');
      expect(
        journalWhen(_entry(day: const LocalDate(2026, 11, 3)), today),
        'Tue, Nov 3',
      );
      expect(
        journalWhen(
          _entry(
            day: const LocalDate(2026, 11, 3),
            source: JournalSource.devotional,
          ),
          today,
        ),
        'Tue, Nov 3 · Devotional',
      );
    });
  });
}
