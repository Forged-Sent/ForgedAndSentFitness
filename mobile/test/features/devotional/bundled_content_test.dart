import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/devotional/data/devotional_library.dart';
import 'package:forged_and_sent/src/features/devotional/domain/devotional.dart';
import 'package:forged_and_sent/src/features/devotional/domain/scripture_reference.dart';
import 'package:forged_and_sent/src/features/today/data/today_content.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/domain/day_box.dart';

import '../../support/fs_test_support.dart';

/// Decision Q7: at most this many distinct ESV verses may be bundled until
/// there is a licence.
const int esvVerseLimit = 499;

/// Verses in each book of the Bible, by the traditional (KJV) verse
/// numbering. The ESV leaves a handful of verses to its footnotes, so its
/// own counts are a few lower in some books; that is far inside the margin
/// of a "no more than half of a book" check. The 66 numbers add up to
/// 31,102, which a test below confirms.
const Map<String, int> versesInBook = <String, int>{
  'Genesis': 1533,
  'Exodus': 1213,
  'Leviticus': 859,
  'Numbers': 1288,
  'Deuteronomy': 959,
  'Joshua': 658,
  'Judges': 618,
  'Ruth': 85,
  '1 Samuel': 810,
  '2 Samuel': 695,
  '1 Kings': 816,
  '2 Kings': 719,
  '1 Chronicles': 942,
  '2 Chronicles': 822,
  'Ezra': 280,
  'Nehemiah': 406,
  'Esther': 167,
  'Job': 1070,
  'Psalm': 2461,
  'Proverbs': 915,
  'Ecclesiastes': 222,
  'Song of Songs': 117,
  'Isaiah': 1292,
  'Jeremiah': 1364,
  'Lamentations': 154,
  'Ezekiel': 1273,
  'Daniel': 357,
  'Hosea': 197,
  'Joel': 73,
  'Amos': 146,
  'Obadiah': 21,
  'Jonah': 48,
  'Micah': 105,
  'Nahum': 47,
  'Habakkuk': 56,
  'Zephaniah': 53,
  'Haggai': 38,
  'Zechariah': 211,
  'Malachi': 55,
  'Matthew': 1071,
  'Mark': 678,
  'Luke': 1151,
  'John': 879,
  'Acts': 1007,
  'Romans': 433,
  '1 Corinthians': 437,
  '2 Corinthians': 257,
  'Galatians': 149,
  'Ephesians': 155,
  'Philippians': 104,
  'Colossians': 95,
  '1 Thessalonians': 89,
  '2 Thessalonians': 47,
  '1 Timothy': 113,
  '2 Timothy': 83,
  'Titus': 46,
  'Philemon': 25,
  'Hebrews': 303,
  'James': 108,
  '1 Peter': 105,
  '2 Peter': 61,
  '1 John': 105,
  '2 John': 13,
  '3 John': 14,
  'Jude': 25,
  'Revelation': 404,
};

/// Parsed JSON of a file, relative to `mobile/`, where the tests run.
Object? _json(String path) => json.decode(File(path).readAsStringSync());

void main() {
  final library = loadBundledLibrary();
  final esv = (_json(DevotionalLibrary.esvAsset)! as Map<String, dynamic>)
      .cast<String, String>();
  final devotionals =
      _json(DevotionalLibrary.devotionalsAsset)! as Map<String, dynamic>;

  group('the bundled files are the repository\'s own', () {
    for (final (asset, source) in <(String, String)>[
      (DevotionalLibrary.devotionalsAsset, '../seed/devotionals.json'),
      (DevotionalLibrary.esvAsset, '../seed/esv-verses.json'),
      (TodayContent.tasksAsset, '../seed/tasks.json'),
    ]) {
      test('$asset says what $source says', () {
        expect(_json(asset), _json(source));
      });
    }

    test('the mission lines are the ones inside the prototype', () {
      final html = File('../index.html').readAsStringSync();
      final match = RegExp(
        r'var MISSIONS\s*=\s*(\[.*?\]);',
        dotAll: true,
      ).firstMatch(html);
      expect(match, isNotNull, reason: 'MISSIONS not found in index.html');

      final bundled =
          (_json(TodayContent.missionsAsset)! as Map<String, dynamic>)['lines'];
      expect(bundled, json.decode(match!.group(1)!));
      expect(bundled, hasLength(14));
    });

    // WHEN TO RETIRE THIS TEST. It proves that step S1b copied v254's
    // readings into `seed/devotionals.json` faithfully, and it holds only
    // while the prototype and the seed are meant to say the same. Remove it
    // in the first pull request that does either of these:
    // - edits a reading in `seed/devotionals.json` (from then on the seed
    //   is the source, and the prototype's copy is expected to differ);
    // - finishes the prototype reconciliation (prompt P02, the "Reconcile
    //   the prototype baseline" row on the work board), which decides what
    //   `index.html` is.
    // Until then, a failure here means one of the two was changed without
    // the other: tell the maintainer rather than editing either to match.
    test('the readings\' words are the ones inside the prototype', () {
      // The prototype keeps its readings on one line: `var DEVOS = {...};`.
      // `index.html` on `main` and `versions/app-v254.html` hold the same
      // ones (see assets/SOURCES.md).
      final line = File('../index.html').readAsLinesSync().firstWhere(
        (line) => line.trimLeft().startsWith('var DEVOS = '),
        orElse: () => '',
      );
      expect(line, isNotEmpty, reason: 'DEVOS not found in index.html');
      final prototype =
          json.decode(
                line.substring(line.indexOf('{'), line.lastIndexOf('}') + 1),
              )
              as Map<String, dynamic>;
      final theirs = prototype['days'] as Map<String, dynamic>;
      final ours = devotionals['days'] as Map<String, dynamic>;

      expect(ours.keys.toList()..sort(), theirs.keys.toList()..sort());
      expect(devotionals['months'], prototype['months']);
      // Every field but the verse text. The prototype quotes the ESV; the
      // app's file keeps the BSB (decision Q7) and the ESV lives in its own
      // file, under the limits tested below.
      final same = <String, int>{};
      for (final key in ours.keys) {
        final mine = Map<String, dynamic>.of(ours[key] as Map<String, dynamic>)
          ..remove('text');
        final its = Map<String, dynamic>.of(theirs[key] as Map<String, dynamic>)
          ..remove('text');
        expect(mine, its, reason: key);
        for (final field in mine.keys) {
          same.update(field, (n) => n + 1, ifAbsent: () => 1);
        }
      }
      // ignore: avoid_print
      print('Readings equal to the prototype\'s, dates per field: $same.');
    });

    test('the app bundle serves all four files', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      for (final asset in <String>[
        DevotionalLibrary.devotionalsAsset,
        DevotionalLibrary.esvAsset,
        TodayContent.tasksAsset,
        TodayContent.missionsAsset,
      ]) {
        final bytes = await rootBundle.load(asset);
        expect(
          utf8.decode(bytes.buffer.asUint8List()),
          File(asset).readAsStringSync(),
          reason: asset,
        );
      }
    });
  });

  group('the readings', () {
    test('there is one for every date of a leap year', () {
      expect(library.length, 366);
      var date = const LocalDate(2028, 1, 1);
      while (date.year == 2028) {
        expect(library.forDate(date), isNotNull, reason: date.iso);
        date = date.addDays(1);
      }
    });

    test('every reading has its text in the BSB (decision Q7)', () {
      for (final reading in library.all) {
        expect(reading.bsbText.trim(), isNotEmpty, reason: reading.monthDayKey);
        expect(reading.prayer.trim(), isNotEmpty, reason: reading.monthDayKey);
        expect(reading.reflect.trim(), isNotEmpty, reason: reading.monthDayKey);
        expect(reading.act.trim(), isNotEmpty, reason: reading.monthDayKey);
        expect(
          reading.reference.trim(),
          isNotEmpty,
          reason: reading.monthDayKey,
        );
        expect(reading.monthName, isNotEmpty, reason: reading.monthDayKey);
      }
    });

    test('every date has every part, and no part the app does not know', () {
      const always = <String>{
        'headline',
        'prayer',
        'ref',
        'text',
        'jesus',
        'reflect',
        'act',
      };
      const sometimes = <String>{'series', 'sent', 'spirit'};
      final days = devotionals['days'] as Map<String, dynamic>;

      expect(days, hasLength(366));
      for (final entry in days.entries) {
        final day = entry.value as Map<String, dynamic>;
        final fields = day.keys.toSet();
        expect(fields.containsAll(always), isTrue, reason: entry.key);
        expect(
          fields.difference(always).difference(sometimes),
          isEmpty,
          reason: entry.key,
        );
        for (final field in <String>[...always, 'series']) {
          if (!day.containsKey(field)) continue;
          expect(day[field], isA<String>(), reason: '${entry.key} $field');
          expect(
            (day[field] as String).trim(),
            isNotEmpty,
            reason: '${entry.key} $field',
          );
        }
        // A tag is present and true, or absent.
        for (final tag in <String>['sent', 'spirit']) {
          if (day.containsKey(tag)) {
            expect(day[tag], isTrue, reason: '${entry.key} $tag');
          }
        }
      }
    });

    test('every reading has a headline and an "In Jesus" paragraph', () {
      for (final reading in library.all) {
        expect(reading.headline, isNotNull, reason: reading.monthDayKey);
        expect(
          reading.headline!.trim(),
          isNotEmpty,
          reason: reading.monthDayKey,
        );
        expect(reading.inJesus, isNotNull, reason: reading.monthDayKey);
        expect(
          reading.inJesus!.trim(),
          isNotEmpty,
          reason: reading.monthDayKey,
        );
      }
    });

    test('a reading carries at most one tag', () {
      final sent = library.all.where((r) => r.tags.contains(ReadingTag.sent));
      final spiritLed = library.all.where(
        (r) => r.tags.contains(ReadingTag.spiritLed),
      );
      // ignore: avoid_print
      print(
        'Tags: ${sent.length} Sent, ${spiritLed.length} Spirit-led, '
        '${library.all.where((r) => r.tags.isEmpty).length} with none; '
        '${library.all.where((r) => r.series != null).length} in a series.',
      );
      expect(sent, hasLength(48));
      expect(spiritLed, hasLength(55));
      expect(library.all.where((r) => r.tags.length > 1), isEmpty);
    });

    test('a reading\'s tags cannot be changed by the code that reads them', () {
      final tagged = library.all.firstWhere((r) => r.tags.isNotEmpty);
      final plain = library.all.firstWhere((r) => r.tags.isEmpty);

      expect(() => tagged.tags.add(ReadingTag.sent), throwsUnsupportedError);
      expect(tagged.tags.clear, throwsUnsupportedError);
      expect(() => plain.tags.add(ReadingTag.sent), throwsUnsupportedError);
      expect(plain.tags, isEmpty);
    });

    test('a reading is chosen by month and day, the same every year', () {
      final a = library.forDate(const LocalDate(2026, 11, 12))!;
      final b = library.forDate(const LocalDate(2031, 11, 12))!;

      expect(a.monthDayKey, '11-12');
      expect(a.reference, 'James 1:17');
      expect(a.headline, 'Every gift came from above');
      expect(a.monthName, 'November');
      expect(identical(a, b), isTrue);
      expect(readingKeyFor(const LocalDate(2026, 3, 7)), '03-07');
    });

    test('after the last entry the year starts again', () {
      final last = library.forDate(const LocalDate(2026, 12, 31))!;
      final first = library.forDate(const LocalDate(2027, 1, 1))!;

      expect(last.monthDayKey, '12-31');
      expect(first.monthDayKey, '01-01');
      expect(
        identical(first, library.forDate(const LocalDate(2026, 1, 1))),
        isTrue,
      );
    });

    test('February 29 has its own reading, used only in a leap year', () {
      expect(
        library.forDate(const LocalDate(2028, 2, 29))!.monthDayKey,
        '02-29',
      );
      // 2027 has no February 29: the 28th is followed by March 1.
      expect(
        library.forDate(const LocalDate(2027, 2, 28).addDays(1))!.monthDayKey,
        '03-01',
      );
    });
  });

  group('the bundled ESV text (decision Q7)', () {
    final verses = <VerseId>{
      for (final reference in esv.keys) ...expandReference(reference),
    };

    test('is no more than $esvVerseLimit distinct verses', () {
      // Printed on every run, so the count is in the test log.
      // ignore: avoid_print
      print(
        'ESV verses bundled: ${verses.length} of $esvVerseLimit allowed '
        '(${esv.length} references).',
      );
      expect(
        verses.length,
        lessThanOrEqualTo(esvVerseLimit),
        reason:
            'The ESV limit is reached: ${verses.length} distinct verses are '
            'bundled and $esvVerseLimit are allowed until there is a '
            'licence. Tell the maintainer. A verse added now must be BSB '
            'only; its ESV tab then says '
            '"${ScriptureNotices.esvLimitReached}".',
      );
    });

    test('is no more than half of any one book', () {
      final perBook = <String, int>{};
      for (final verse in verses) {
        perBook.update(verse.book, (n) => n + 1, ifAbsent: () => 1);
      }
      var largest = ('', 0.0);
      for (final entry in perBook.entries) {
        final total = versesInBook[entry.key];
        expect(total, isNotNull, reason: 'Unknown book "${entry.key}"');
        final share = entry.value / total!;
        if (share > largest.$2) largest = (entry.key, share);
        expect(
          share,
          lessThanOrEqualTo(0.5),
          reason: '${entry.value} of $total verses of ${entry.key}',
        );
      }
      // ignore: avoid_print
      print(
        'Largest share of one book: ${largest.$1}, '
        '${(largest.$2 * 100).toStringAsFixed(1)}%.',
      );
    });

    test('is under a quarter of all the bundled text', () {
      var other = 0;
      void count(Object? value) {
        if (value is String) {
          other += value.length;
        } else if (value is Map) {
          value.values.forEach(count);
        } else if (value is List) {
          value.forEach(count);
        }
      }

      count(devotionals);
      count(_json(TodayContent.missionsAsset));
      for (final box in loadBundledTodayContent().boxes) {
        other += box.title.length;
      }
      final esvCharacters = esv.values.fold<int>(0, (n, v) => n + v.length);
      final share = esvCharacters / (esvCharacters + other);
      // ignore: avoid_print
      print(
        'ESV share of all bundled text: '
        '${(share * 100).toStringAsFixed(1)}% '
        '($esvCharacters of ${esvCharacters + other} characters).',
      );
      expect(share, lessThan(0.25));
    });

    test('every reading\'s verse has ESV text today', () {
      final missing = <String>[
        for (final reading in library.all)
          if (reading.esvText == null) reading.reference,
      ];

      expect(missing, isEmpty);
    });

    test('the book table used above is complete', () {
      expect(versesInBook, hasLength(66));
      expect(versesInBook.values.reduce((a, b) => a + b), 31102);
    });
  });

  group('a verse with no ESV text bundled', () {
    final without = DevotionalLibrary.fromJson(
      devotionals: File(DevotionalLibrary.devotionalsAsset).readAsStringSync(),
      esvVerses: json.encode(Map<String, String>.of(esv)..remove('James 1:17')),
    );

    test('has BSB text and no ESV text', () {
      final reading = without.forDate(const LocalDate(2026, 11, 12))!;

      expect(reading.reference, 'James 1:17');
      expect(reading.textIn(Translation.bsb), isNotEmpty);
      expect(reading.textIn(Translation.esv), isNull);
    });

    test('leaves every other verse as it was', () {
      expect(
        without.all.where((reading) => reading.esvText == null),
        hasLength(1),
      );
    });
  });

  group('scripture references', () {
    test('expand to single verses', () {
      expect(expandReference('James 1:17'), <VerseId>[
        (book: 'James', chapter: 1, verse: 17),
      ]);
      expect(expandReference('Matthew 11:28–30'), hasLength(3));
      expect(expandReference('Philippians 2:3-4'), hasLength(2));
      expect(expandReference('Proverbs 3:5, 7'), <VerseId>[
        (book: 'Proverbs', chapter: 3, verse: 5),
        (book: 'Proverbs', chapter: 3, verse: 7),
      ]);
      expect(
        expandReference('1 Corinthians 16:13').single.book,
        '1 Corinthians',
      );
      expect(
        expandReference('Song of Songs 8:6–7').first.book,
        'Song of Songs',
      );
    });

    test('refuse a form they do not know rather than miscount it', () {
      for (final bad in <String>[
        'James',
        'James 1',
        'James 1:17b',
        'Romans 8:38-9:1',
        'Psalm 23:6-1',
      ]) {
        expect(() => expandReference(bad), throwsFormatException, reason: bad);
      }
    });

    test('every bundled reference is one they understand', () {
      for (final reference in <String>{
        ...esv.keys,
        ...library.all.map((reading) => reading.reference),
      }) {
        expect(expandReference(reference), isNotEmpty, reason: reference);
      }
    });
  });

  group('Today\'s boxes and mission lines', () {
    final content = loadBundledTodayContent();

    test('are the seven daily boxes, in the task list\'s order', () {
      expect(content.boxes.map((box) => box.id), <String>[
        't_devo',
        't_motto',
        't_comms',
        't_workout',
        't_water',
        't_cal',
        't_steps',
      ]);
      expect(content.boxes.map((box) => box.title), <String>[
        'Daily Devotional',
        'My Mission',
        'Rally Call',
        'Workout',
        'Hydrate',
        'Calories',
        'Steps',
      ]);
    });

    test('only the devotional can be checked in this build step', () {
      final active = content.boxes.where((box) => box.active).toList();

      expect(active.map((box) => box.id), <String>['t_devo']);
      expect(active.single.item, DayItems.devotional);
    });

    test('count in the ring\'s three groups as the prototype counts them', () {
      int inGroup(BoxCategory category) =>
          content.boxes.where((box) => box.category == category).length;

      expect(inGroup(BoxCategory.spirit), 2);
      expect(inGroup(BoxCategory.body), 4);
      expect(inGroup(BoxCategory.brotherhood), 1);
      expect(content.boxes.map((box) => box.command).toSet(), <String>{
        'Stand firm',
        'In love',
        'Be strong',
      });
    });

    test('carry the prototype\'s point values, for the preview switch', () {
      expect(
        {for (final box in content.boxes) box.id: box.previewPoints},
        <String, int>{
          't_devo': 2,
          't_motto': 1,
          't_comms': 1,
          't_workout': 3,
          't_water': 1,
          't_cal': 1,
          't_steps': 1,
        },
      );
    });

    test('the mission line is the day of the year modulo the 14 lines', () {
      final lines = content.missionLines;
      expect(lines, hasLength(14));

      // November 12, 2026 is day 316; 316 mod 14 is 8.
      expect(content.missionFor(const LocalDate(2026, 11, 12)), lines[8]);
      expect(
        content.missionFor(const LocalDate(2026, 11, 12)),
        'Confess it, drop it, move forward. Grace covers the man who gets '
        'back up.',
      );
      // January 1 is day 1: the second line, every year.
      expect(content.missionFor(const LocalDate(2026, 1, 1)), lines[1]);
      expect(content.missionFor(const LocalDate(2027, 1, 1)), lines[1]);
    });

    test('after the last line the list starts again', () {
      final lines = content.missionLines;

      // Day 13 shows the last line, day 14 the first, day 15 the second.
      expect(content.missionFor(const LocalDate(2026, 1, 13)), lines[13]);
      expect(content.missionFor(const LocalDate(2026, 1, 14)), lines[0]);
      expect(content.missionFor(const LocalDate(2026, 1, 15)), lines[1]);
      // The count restarts on January 1: December 31, 2026 is day 365, and
      // 365 mod 14 is 1, so that day and the next show the same line.
      expect(content.missionFor(const LocalDate(2026, 12, 31)), lines[1]);
      expect(missionLineFor(const LocalDate(2026, 12, 31), const []), '');
    });
  });
}
