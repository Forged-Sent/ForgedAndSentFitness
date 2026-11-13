import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/workout/data/memory_workout_repository.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';

import 'workout_repository_contract.dart';

/// A day store that can be made to wait, or to fail once, as a slow or
/// full disk would.
class _SlowDays extends MemoryDayRepository {
  Completer<void>? gate;
  bool failNext = false;
  int recordCalls = 0;

  @override
  Future<RecordOutcome> record(CompletionEvent event) async {
    recordCalls++;
    await gate?.future;
    if (failNext) {
      failNext = false;
      throw StateError('The test refused this save.');
    }
    return super.record(event);
  }
}

void main() {
  group('MemoryWorkoutRepository', () {
    workoutRepositoryContract(() async {
      final days = MemoryDayRepository();
      return (workouts: MemoryWorkoutRepository(days), days: days);
    });

    test(
      'an edit and a second finish asked for while a finish is waiting '
      'take their turn after it, as they would behind a transaction',
      () async {
        final days = _SlowDays();
        final workouts = MemoryWorkoutRepository(days);
        await workouts.startSession(
          newSession('s1', DateTime(2026, 11, 12, 18, 10)),
        );
        await workouts.setReps('s1-squat-s0', 5);
        await workouts.setWeight('s1-squat-s0', 135);

        // The first finish stops halfway: the day's store is slow.
        days.gate = Completer<void>();
        final first = workouts.finishSession(
          's1',
          DateTime(2026, 11, 12, 18, 52),
        );
        await pumpEventQueue();
        // While it waits, he types into a set and taps Finish again.
        final edit = workouts.setReps('s1-squat-s0', 99);
        final second = workouts.finishSession(
          's1',
          DateTime(2026, 11, 12, 19, 30),
        );
        await pumpEventQueue();

        // Nothing has happened yet: both wait for the first finish.
        var stored = (await workouts.watchSession(ownerA, nov12).first)!;
        expect(stored.finished, isFalse);
        expect(stored.exercises.first.sets[0].reps, 5);

        days.gate!.complete();
        expect(await first, FinishOutcome.finished);
        await edit;
        expect(await second, FinishOutcome.alreadyFinished);

        stored = (await workouts.watchSession(ownerA, nov12).first)!;
        // The first finish stands, the edit met a locked session, and the
        // second finish changed nothing.
        expect(stored.finishedAtUtc, DateTime(2026, 11, 12, 18, 52).toUtc());
        expect(stored.exercises.first.sets[0].reps, 5);
        expect(stored.exercises.first.sets[0].weightLb, 135);
        expect(
          await days.eventsFor(ownerA, nov12, DayItems.workout),
          hasLength(1),
        );
        expect(days.recordCalls, 1);
      },
    );

    test('a finish that fails leaves the queue working', () async {
      final days = _SlowDays()..failNext = true;
      final workouts = MemoryWorkoutRepository(days);
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );

      await expectLater(
        workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52)),
        throwsStateError,
      );
      // The session is still open, and the next changes go through.
      await workouts.setReps('s1-squat-s0', 5);
      expect(
        await workouts.finishSession('s1', DateTime(2026, 11, 12, 19)),
        FinishOutcome.finished,
      );
      final stored = (await workouts.watchSession(ownerA, nov12).first)!;
      expect(stored.exercises.first.sets[0].reps, 5);
      expect(stored.finishedAtUtc, DateTime(2026, 11, 12, 19).toUtc());
    });

    test('says that it keeps nothing after the app closes', () {
      expect(MemoryWorkoutRepository(MemoryDayRepository()).durable, isFalse);
    });
  });
}
