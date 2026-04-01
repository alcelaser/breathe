import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('DatabaseHelper', () {
    test('creates all required tables', () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final Database db = await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: DatabaseHelper.onCreate,
      );

      final List<Map<String, Object?>> tables = await db.rawQuery('''
        SELECT name FROM sqlite_master
        WHERE type = 'table'
      ''');

      final Set<String> tableNames = tables
          .map((Map<String, Object?> row) => row['name'] as String)
          .toSet();

      expect(tableNames.contains('breathing_sessions'), isTrue);
      expect(tableNames.contains('meals'), isTrue);
      expect(tableNames.contains('weight_entries'), isTrue);
      expect(tableNames.contains('exercise_logs'), isTrue);
      expect(tableNames.contains('exercise_plan'), isTrue);
      expect(tableNames.contains('exercise_plan_progress'), isTrue);

      await db.close();
    });
  });
}
