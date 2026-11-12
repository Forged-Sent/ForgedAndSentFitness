import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/today/data/memory_day_repository.dart';

import 'day_repository_contract.dart';

void main() {
  group('MemoryDayRepository', () {
    dayRepositoryContract(() async => MemoryDayRepository());

    test('says that it does not keep anything', () {
      expect(MemoryDayRepository().durable, isFalse);
    });
  });
}
