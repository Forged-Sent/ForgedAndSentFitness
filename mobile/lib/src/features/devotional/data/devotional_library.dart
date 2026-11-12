import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_date.dart';
import '../domain/devotional.dart';

/// The readings bundled with the app. Nothing is fetched at runtime.
///
/// Two files, both copies of the repository's `seed/` files, kept identical
/// by a test:
/// - `devotionals.json`: 366 readings with BSB verse text, and the month
///   themes;
/// - `esv_verses.json`: the ESV text of the same verses, keyed by reference.
class DevotionalLibrary {
  DevotionalLibrary._(this._byKey);

  static const String devotionalsAsset = 'assets/content/devotionals.json';
  static const String esvAsset = 'assets/content/esv_verses.json';

  /// Builds the library from the two files' text.
  factory DevotionalLibrary.fromJson({
    required String devotionals,
    required String esvVerses,
  }) {
    final file = json.decode(devotionals) as Map<String, dynamic>;
    final days = file['days'] as Map<String, dynamic>;
    final months = file['months'] as Map<String, dynamic>;
    final esv = (json.decode(esvVerses) as Map<String, dynamic>)
        .cast<String, String>();

    final byKey = <String, Devotional>{};
    for (final entry in days.entries) {
      final day = entry.value as Map<String, dynamic>;
      final month =
          months[int.parse(entry.key.substring(0, 2)).toString()]
              as Map<String, dynamic>? ??
          const <String, dynamic>{};
      final reference = day['ref'] as String;
      byKey[entry.key] = Devotional(
        monthDayKey: entry.key,
        monthName: month['name'] as String? ?? '',
        monthTheme: month['theme'] as String? ?? '',
        monthTag: month['tag'] as String? ?? '',
        series: day['series'] as String?,
        prayer: day['prayer'] as String,
        reference: reference,
        bsbText: day['text'] as String,
        esvText: esv[reference],
        reflect: day['reflect'] as String,
        act: day['act'] as String,
      );
    }
    return DevotionalLibrary._(byKey);
  }

  static Future<DevotionalLibrary> load(AssetBundle bundle) async {
    return DevotionalLibrary.fromJson(
      devotionals: await bundle.loadString(devotionalsAsset),
      esvVerses: await bundle.loadString(esvAsset),
    );
  }

  final Map<String, Devotional> _byKey;

  int get length => _byKey.length;

  Iterable<Devotional> get all => _byKey.values;

  /// The reading for [date], or null if the file has none for it.
  Devotional? forDate(LocalDate date) => _byKey[readingKeyFor(date)];
}

/// App-scoped. Tests may supply another bundle.
final assetBundleProvider = Provider<AssetBundle>((ref) => rootBundle);

final devotionalLibraryProvider = FutureProvider<DevotionalLibrary>(
  (ref) => DevotionalLibrary.load(ref.watch(assetBundleProvider)),
);
