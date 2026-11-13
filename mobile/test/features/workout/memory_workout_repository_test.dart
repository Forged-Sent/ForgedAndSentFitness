import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';
import 'package:forged_and_sent/src/features/workout/data/memory_workout_repository.dart';

import 'workout_repository_contract.dart';

void main() {
  group('MemoryWorkoutRepository', () {
    workoutRepositoryContract(() async {
      final days = MemoryDayRepository();
      return (workouts: MemoryWorkoutRepository(days), days: days);
    });

    test('says that it keeps nothing after the app closes', () {
      expect(MemoryWorkoutRepository(MemoryDayRepository()).durable, isFalse);
    });
  });
}
