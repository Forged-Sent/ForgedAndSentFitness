/// Turns an entry's text into what is written to the database, and back.
///
/// Decision Q8: entries are device-only and not encrypted for the pilot,
/// and the design must not need a rework to encrypt them later. This is
/// the one place the stored form of the text is decided. Each row records
/// the [format] it was written in, so a later codec that encrypts can
/// still read rows written by this one, and re-write them.
abstract interface class JournalBodyCodec {
  /// The name written beside every row this codec stores.
  String get format;

  String encode(String text);

  /// Reads a row written in [format]. Throws a [JournalFormatException] if
  /// this codec cannot read that format.
  String decode(String stored, String format);
}

/// The text as typed. The pilot's codec.
class PlainJournalBodyCodec implements JournalBodyCodec {
  const PlainJournalBodyCodec();

  static const String plainFormat = 'plain-v1';

  @override
  String get format => plainFormat;

  @override
  String encode(String text) => text;

  @override
  String decode(String stored, String format) {
    if (format != plainFormat) throw JournalFormatException(format);
    return stored;
  }
}

/// A row is stored in a form this build cannot read. The message names the
/// format and never the contents.
class JournalFormatException implements Exception {
  const JournalFormatException(this.format);

  final String format;

  @override
  String toString() =>
      'JournalFormatException: cannot read a journal entry stored as '
      '"$format".';
}
