/// One verse of the Bible: a book, a chapter and a verse number.
typedef VerseId = ({String book, int chapter, int verse});

final RegExp _reference = RegExp(r'^(.+?)\s+(\d+):(.+)$');
final RegExp _number = RegExp(r'^\d+$');

/// The single verses a reference such as `Matthew 11:28–30` or
/// `Proverbs 3:5, 7` stands for.
///
/// Decision Q7 limits the bundled ESV text to 499 distinct verses, so
/// verses have to be counted, not references. A reference this function
/// does not understand throws a [FormatException]: a new form must be
/// taught here before it can be bundled, instead of being counted as one
/// verse by mistake.
List<VerseId> expandReference(String reference) {
  final match = _reference.firstMatch(reference.trim());
  if (match == null) {
    throw FormatException('Not a "Book chapter:verse" reference', reference);
  }
  final book = match.group(1)!;
  final chapter = int.parse(match.group(2)!);

  final verses = <VerseId>[];
  for (final part in match.group(3)!.split(RegExp(r'\s*[,;]\s*'))) {
    // A range may be written with a hyphen or an en dash.
    final ends = part.split(RegExp('[-–]'));
    if (ends.length > 2 || ends.any((end) => !_number.hasMatch(end.trim()))) {
      throw FormatException('Verse numbers not understood', reference);
    }
    final first = int.parse(ends.first.trim());
    final last = int.parse(ends.last.trim());
    if (last < first) {
      throw FormatException('A range that runs backwards', reference);
    }
    for (var verse = first; verse <= last; verse++) {
      verses.add((book: book, chapter: chapter, verse: verse));
    }
  }
  return verses;
}
