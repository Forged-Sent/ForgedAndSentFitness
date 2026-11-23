import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/journal/data/journal_repository.dart';
import '../features/journal/data/memory_journal_repository.dart';
import '../features/settings/data/settings_repository.dart';
import '../features/today/data/day_repository.dart';
import '../features/today/data/memory_day_repository.dart';
import '../features/workout/data/memory_workout_repository.dart';
import '../features/workout/data/workout_repository.dart';

/// Everything the app keeps on the device for one member: who he is here,
/// and the repositories that hold his data.
class LocalStore {
  const LocalStore({
    required this.ownerId,
    required this.days,
    required this.journal,
    required this.settings,
    required this.workouts,
    required this.close,
  });

  /// A store that keeps nothing after the app closes. The web preview and
  /// widget tests use it; the screen says that nothing is saved.
  factory LocalStore.inMemory({String ownerId = 'preview'}) {
    final days = MemoryDayRepository();
    return LocalStore(
      ownerId: ownerId,
      days: days,
      journal: MemoryJournalRepository(),
      settings: MemorySettingsRepository(),
      workouts: MemoryWorkoutRepository(days),
      close: () async {},
    );
  }

  /// Decision Q10: before sign-in this is the id of the local profile.
  final String ownerId;

  final DayRepository days;

  /// His private journal (decision Q8: on this device only).
  final JournalRepository journal;
  final SettingsRepository settings;

  /// The member's workout plan and sessions. Finishing a session checks
  /// the Workout box in [days].
  final WorkoutRepository workouts;

  /// Closes the database file. The app never needs to; tests do, to prove
  /// that what was recorded is still there when the file is opened again.
  final Future<void> Function() close;
}

/// App-scoped. `main` opens the store before the first frame and supplies it
/// here; tests supply their own. There is no default, so a build that forgot
/// to open the store fails loudly instead of quietly saving nothing.
final localStoreProvider = Provider<LocalStore>(
  (ref) => throw StateError('localStoreProvider was not given a store.'),
);
