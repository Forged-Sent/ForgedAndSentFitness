import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/data/memory_journal_repository.dart';

import 'journal_repository_contract.dart';

void main() {
  group('MemoryJournalRepository', () {
    journalRepositoryContract(() async => MemoryJournalRepository());

    test('says that it keeps nothing after the app closes', () {
      expect(MemoryJournalRepository().durable, isFalse);
    });
  });
}
