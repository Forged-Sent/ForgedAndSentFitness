import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/core/clock.dart';
import 'package:forged_and_sent/src/core/event_id.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/settings/data/settings_repository.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';
import 'package:forged_and_sent/src/features/workout/data/memory_workout_repository.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_library.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_view_model.dart';

import '../../support/fs_test_support.dart';

const LocalDate _monday = LocalDate(2026, 11, 9);

/// A store whose writes of a set wait until the test lets them through,
/// as a slow disk would.
class _SlowWorkouts extends MemoryWorkoutRepository {
  _SlowWorkouts(super.days);

  Completer<void>? gate;

  /// The values written, in the order they reached the store.
  final List<Object?> written = <Object?>[];

  @override
  Future<void> setReps(String setId, int? reps) async {
    await gate?.future;
    written.add(reps);
    return super.setReps(setId, reps);
  }

  @override
  Future<void> setWeight(String setId, double? weightLb) async {
    await gate?.future;
    written.add(weightLb);
    return super.setWeight(setId, weightLb);
  }
}

void main() {
  setUpAll(loadAppFonts);

  group('every change is on its way to the store at once, and a pause '
      'waits for the last of them', () {
    late _SlowWorkouts workouts;
    late ProviderContainer container;
    late WorkoutViewModel model;
    late String setId;

    setUp(() async {
      final days = MemoryDayRepository();
      workouts = _SlowWorkouts(days);
      var issued = 0;
      container = ProviderContainer(
        overrides: [
          localStoreProvider.overrideWithValue(
            LocalStore(
              ownerId: 'local-test',
              days: days,
              settings: MemorySettingsRepository(),
              workouts: workouts,
              close: () async {},
            ),
          ),
          clockProvider.overrideWithValue(TestClock(liftingEvening)),
          eventIdProvider.overrideWithValue(() => 'id${++issued}'),
          workoutLibraryProvider.overrideWith(
            (ref) async => loadBundledWorkoutLibrary(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final provider = workoutViewModelProvider(_monday);
      // Keeps the view model alive for the test.
      container.listen(provider, (_, _) {});
      await container.read(provider.future);
      model = container.read(provider.notifier);
      expect(await model.start(), StartOutcome.started);
      final session = (await workouts
          .watchSession('local-test', _monday)
          .first)!;
      setId = session.exercises.first.sets.first.id;
    });

    Future<({int? reps, double? weight})> stored() async {
      final session = (await workouts
          .watchSession('local-test', _monday)
          .first)!;
      final set = session.exercises.first.sets.first;
      return (reps: set.reps, weight: set.weightLb);
    }

    test(
      'flush does not return while a change is still being written',
      () async {
        workouts.gate = Completer<void>();
        final reps = model.setReps(setId, 5);
        final weight = model.setWeight(setId, 135);
        var flushed = false;
        final flush = model.flush().then((_) => flushed = true);

        await pumpEventQueue();
        expect(flushed, isFalse);
        expect((await stored()).reps, isNull);

        workouts.gate!.complete();
        await flush;

        expect(flushed, isTrue);
        expect(await reps, isTrue);
        expect(await weight, isTrue);
        expect(await stored(), (reps: 5, weight: 135.0));
      },
    );

    test('changes reach the store in the order they were made', () async {
      workouts.gate = Completer<void>();
      for (final reps in <int>[1, 12, 125, 12, 1]) {
        unawaited(model.setReps(setId, reps));
      }
      unawaited(model.setReps(setId, null));
      unawaited(model.setReps(setId, 8));

      workouts.gate!.complete();
      await model.flush();

      expect(workouts.written, <Object?>[1, 12, 125, 12, 1, null, 8]);
      expect((await stored()).reps, 8);
    });

    test('with nothing on its way, flush returns at once', () async {
      await model.setReps(setId, 5);

      await model.flush().timeout(const Duration(seconds: 1));

      expect((await stored()).reps, 5);
    });
  });

  testWidgets('when the app is paused the workout page asks for a flush', (
    tester,
  ) async {
    await pumpApp(tester, clock: TestClock(liftingEvening));
    await openTodaysWorkout(tester);
    await startWorkout(tester);
    await typeNumber(tester, repsField(0, 0), '5');
    final model = ProviderScope.containerOf(
      tester.element(find.byType(WorkoutPage)),
    ).read(workoutViewModelProvider(_monday).notifier);
    expect(model.flushes, 0);

    // What Android sends when he presses Home or the screen locks.
    for (final state in <AppLifecycleState>[
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pump();

    expect(model.flushes, greaterThanOrEqualTo(1));

    for (final state in <AppLifecycleState>[
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tester.pumpAndSettle();
  });
}
