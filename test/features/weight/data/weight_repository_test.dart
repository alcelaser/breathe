import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';
import 'package:recovery_app/features/weight/data/weight_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helpers/database_test_helper.dart';

void main() {
  late Database db;
  late WeightRepository repository;

  setUp(() async {
    db = await DatabaseTestHelper.openTestDatabase();
    repository = WeightRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insertOrUpdateWeight upserts by date', () async {
    await repository.insertOrUpdateWeight(
      WeightEntry(date: DateTime(2026, 4, 1), weightKg: 70),
    );
    await repository.insertOrUpdateWeight(
      WeightEntry(date: DateTime(2026, 4, 1), weightKg: 71),
    );

    final entries = await repository.getAllWeightEntries();
    expect(entries.length, 1);
    expect(entries.first.weightKg, 71);
  });

  test('latest and delta are computed', () async {
    await repository.insertOrUpdateWeight(
      WeightEntry(date: DateTime(2026, 4, 1), weightKg: 70),
    );
    await repository.insertOrUpdateWeight(
      WeightEntry(date: DateTime(2026, 4, 2), weightKg: 68.5),
    );

    final latest = await repository.getLatestWeightEntry();
    final delta =
        await repository.getDeltaFromPrevious(date: DateTime(2026, 4, 2));

    expect(latest, isNotNull);
    expect(latest!.weightKg, 68.5);
    expect(delta, -1.5);
  });

  test('deleteWeightEntry removes only target row', () async {
    final int id1 = await repository.insertOrUpdateWeight(
      WeightEntry(date: DateTime(2026, 4, 1), weightKg: 70),
    );
    await repository.insertOrUpdateWeight(
      WeightEntry(date: DateTime(2026, 4, 2), weightKg: 71),
    );

    await repository.deleteWeightEntry(id1);
    final entries = await repository.getAllWeightEntries();

    expect(entries.length, 1);
    expect(entries.first.weightKg, 71);
  });
}
