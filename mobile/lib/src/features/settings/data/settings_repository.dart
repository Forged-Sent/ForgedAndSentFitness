import 'dart:async';

import '../../../storage/app_database.dart';

/// Device-only settings. Build step S1 has one.
abstract interface class SettingsRepository {
  /// Decision Q5: point values are hidden until the server scores them.
  /// This switch, off by default, shows the prototype's values, labelled
  /// "preview, not official".
  Stream<bool> watchShowPreviewPoints();

  Future<void> setShowPreviewPoints(bool show);
}

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);

  static const String _showPreviewPoints = 'show_preview_points';

  final AppDatabase _db;

  @override
  Stream<bool> watchShowPreviewPoints() {
    final query = _db.select(_db.appSettings)
      ..where((t) => t.key.equals(_showPreviewPoints));
    return query.watchSingleOrNull().map((row) => row?.value == 'true');
  }

  @override
  Future<void> setShowPreviewPoints(bool show) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: _showPreviewPoints,
          value: show ? 'true' : 'false',
        ),
      );
}

/// Settings held in memory only: the web preview and widget tests.
class MemorySettingsRepository implements SettingsRepository {
  MemorySettingsRepository({bool showPreviewPoints = false})
    : _show = showPreviewPoints;

  final StreamController<void> _changes = StreamController<void>.broadcast();
  bool _show;

  @override
  Stream<bool> watchShowPreviewPoints() {
    return Stream<bool>.multi((controller) {
      controller.add(_show);
      final changes = _changes.stream.listen((_) => controller.add(_show));
      controller.onCancel = changes.cancel;
    });
  }

  @override
  Future<void> setShowPreviewPoints(bool show) async {
    _show = show;
    _changes.add(null);
  }
}
