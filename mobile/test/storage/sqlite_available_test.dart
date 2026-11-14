import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// ADR-0005 asks the first Drift pull request to prove that SQLite arrives
/// with the app's own package graph. The `sqlite3` package builds or fetches
/// it through a build hook; this fails on any machine where that did not
/// happen, instead of every database test failing with a loader error.
void main() {
  test('SQLite is supplied by the sqlite3 build hook', () {
    final database = sqlite3.openInMemory();
    addTearDown(database.close);

    final version =
        database.select('select sqlite_version() as v').single['v'] as String;

    // Printed so a test log shows which SQLite the hook supplied.
    // ignore: avoid_print
    print('SQLite $version');
    expect(int.parse(version.split('.').first), greaterThanOrEqualTo(3));
  });
}
