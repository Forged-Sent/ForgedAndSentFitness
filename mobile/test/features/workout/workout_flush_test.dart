import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/core/clock.dart';
import 'package:forged_and_sent/src/core/event_id.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/journal/data/memory_journal_repository.dart';
import 'package:forged_and_sent/src/features/settings/data/settings_repository.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';
import 'package:forged_and_sent/src/features/workout/data/memory_workout_repository.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_library.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_plan.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';
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

/// A store whose plan cannot be read.
class _NoPlan extends MemoryWorkoutRepository {
  _NoPlan(super.days);

  @override
  Future<WorkoutPlan> ensurePlan(
    String ownerId,
    WorkoutPlan Function() create,
  ) => Future<WorkoutPlan>.error(StateError('The plan cannot be read.'));
}

void main() {
  setUpAll(loadAppFonts);

  test('start answers "failed" when the plan cannot be read while the '
      'program is still loading, and leaves no error unheard', () async {
    final days = MemoryDayRepository();
    final loading = Completer<WorkoutLibrary>();
    final container = ProviderContainer(
      overrides: [
        localStoreProvider.overrideWithValue(
          LocalStore(
            ownerId: 'local-test',
            days: days,
            journal: MemoryJournalRepository(),
            settings: MemorySettingsRepository(),
            workouts: _NoPlan(days),
            close: () async {},
          ),
        ),
        clockProvider.overrideWithValue(TestClock(liftingEvening)),
        eventIdProvider.overrideWithValue(() => 'id'),
        workoutLibraryProvider.overrideWith((ref) => loading.future),
      ],
    );
    addTearDown(container.dispose);
    final provider = workoutViewModelProvider(_monday);
    container.listen(provider, (_, _) {});
    final model = container.read(provider.notifier);

    final starting = model.start();
    // The plan has failed by now; the program is still loading.
    await pumpEventQueue();
    loading.complete(await loadBundledWorkoutLibrary());

    expect(await starting, StartOutcome.failed);
    await pumpEventQueue();
  });

  group('every change is on its way to the store at once, and a pause '
      'waits for the last of them', () {
    late _SlowWorkouts workouts;
    late ProviderContainer container;
    late ProviderSubscription<AsyncValue<WorkoutView>> watching;
    late WorkoutViewModel model;
    late String setId;
    late String secondSetId;

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
              journal: MemoryJournalRepository(),
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
      watching = container.listen(provider, (_, _) {});
      await container.read(provider.future);
      model = container.read(provider.notifier);
      expect(await model.start(), StartOutcome.started);
      final session = (await workouts
          .watchSession('local-test', _monday)
          .first)!;
      setId = session.exercises.first.sets.first.id;
      secondSetId = session.exercises.first.sets[1].id;
      // The view model has the started session too, as the page would
      // before it offers Finish.
      for (var i = 0; i < 50; i++) {
        if (container.read(provider).value?.session != null) break;
        await pumpEventQueue();
      }
      expect(container.read(provider).value?.session?.id, session.id);
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

    test('leaving the page while changes are still on their way loses '
        'none of them', () async {
      // A slow disk: the first write is held, and four more queue up
      // behind it.
      workouts.gate = Completer<void>();
      final writes = <Future<bool>>[
        model.setReps(setId, 5),
        model.setWeight(setId, 135),
        model.setReps(secondSetId, 4),
        model.setWeight(secondSetId, 137.5),
        model.setTicked(setId, ticked: true),
      ];

      // He leaves the workout page: nothing watches the view model any
      // more, so it is disposed, with the writes still queued.
      watching.close();
      await container.pump();
      await pumpEventQueue();
      expect(container.read(workoutViewModelProvider(_monday).exists), isFalse);

      // The disk catches up.
      workouts.gate!.complete();
      final results = await Future.wait(writes);

      expect(results, everyElement(isTrue));
      final session = (await workouts
          .watchSession('local-test', _monday)
          .first)!;
      final sets = session.exercises.first.sets;
      expect(
        (sets[0].reps, sets[0].weightLb, sets[0].ticked),
        (5, 135.0, true),
      );
      expect((sets[1].reps, sets[1].weightLb), (4, 137.5));
    });

    test('finishing while leaving the page still finishes, at the time of '
        'the tap', () async {
      workouts.gate = Completer<void>();
      final typed = model.setReps(setId, 5);
      final clock = container.read(clockProvider) as TestClock;
      final finishing = model.finish();
      // The clock moves on while the finish waits its turn.
      clock.time = liftingEvening.add(const Duration(minutes: 30));

      watching.close();
      await container.pump();
      await pumpEventQueue();
      expect(container.read(workoutViewModelProvider(_monday).exists), isFalse);
      workouts.gate!.complete();

      expect(await typed, isTrue);
      expect(await finishing, isTrue);
      final session = (await workouts
          .watchSession('local-test', _monday)
          .first)!;
      expect(session.finished, isTrue);
      expect(session.finishedAtUtc, liftingEvening.toUtc());
      expect(session.exercises.first.sets.first.reps, 5);
    });

    // He leaves the workout page, so its view model is disposed, and opens
    // it again: a new view model for the same session.
    Future<WorkoutViewModel> leaveAndReopen() async {
      final provider = workoutViewModelProvider(_monday);
      watching.close();
      await container.pump();
      await pumpEventQueue();
      expect(container.read(provider.exists), isFalse);

      watching = container.listen(provider, (_, _) {});
      await container.read(provider.future);
      final reopened = container.read(provider.notifier);
      expect(identical(reopened, model), isFalse);
      expect(container.read(provider).value?.session, isNotNull);
      return reopened;
    }

    test('a change made after leaving and reopening the page is stored '
        'after the changes still waiting from before', () async {
      // A slow disk: the first write is held and the second waits behind
      // it.
      workouts.gate = Completer<void>();
      final before = <Future<bool>>[
        model.setReps(setId, 5),
        model.setReps(setId, 6),
      ];

      final reopened = await leaveAndReopen();
      final after = reopened.setReps(setId, 7);
      await pumpEventQueue();
      expect(workouts.written, isEmpty);

      workouts.gate!.complete();
      expect(await Future.wait(before), everyElement(isTrue));
      expect(await after, isTrue);

      expect(workouts.written, <Object?>[5, 6, 7]);
      expect((await stored()).reps, 7);
    });

    test('Finish on the reopened page waits for the changes still waiting '
        'from before, and what is checked first has them', () async {
      workouts.gate = Completer<void>();
      final typed = model.setReps(setId, 5);

      final reopened = await leaveAndReopen();
      WorkoutSession? checked;
      final checking = reopened.storedSession().then((s) => checked = s);
      final finishing = reopened.finish();
      await pumpEventQueue();
      // Neither has gone ahead of the change that is still waiting.
      expect(checked, isNull);
      expect(
        (await workouts.watchSession('local-test', _monday).first)!.finished,
        isFalse,
      );

      workouts.gate!.complete();
      expect(await typed, isTrue);
      await checking;
      expect(await finishing, isTrue);

      expect(checked!.exercises.first.sets.first.reps, 5);
      final session = (await workouts
          .watchSession('local-test', _monday)
          .first)!;
      expect(session.finished, isTrue);
      expect(session.exercises.first.sets.first.reps, 5);
    });

    test('a pause on the reopened page waits for the changes still waiting '
        'from before', () async {
      workouts.gate = Completer<void>();
      final typed = model.setReps(setId, 5);

      final reopened = await leaveAndReopen();
      var flushed = false;
      final flush = reopened.flush().then((_) => flushed = true);
      await pumpEventQueue();
      expect(flushed, isFalse);

      workouts.gate!.complete();
      await flush;
      expect(await typed, isTrue);
      expect((await stored()).reps, 5);
    });

    test('a session keeps its queue only while a change is waiting', () async {
      final writes = container.read(workoutWritesProvider);
      expect(writes.waiting, 0);

      workouts.gate = Completer<void>();
      final typed = model.setReps(setId, 5);
      final again = model.setReps(setId, 6);
      expect(writes.waiting, 1);

      workouts.gate!.complete();
      await typed;
      await again;
      await pumpEventQueue();
      expect(writes.waiting, 0);
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
