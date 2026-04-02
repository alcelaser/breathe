import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
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

    test('upgrade adds quantity column to meals table', () async {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;

      final String dbPath = await getDatabasesPath();
      final String path = p.join(dbPath, 'recovery_app_upgrade_test.db');
      await deleteDatabase(path);

      final Database oldDb = await openDatabase(
        path,
        version: 3,
        onCreate: (Database db, int version) async {
          await db.execute('''
            CREATE TABLE meals (
              id           INTEGER PRIMARY KEY AUTOINCREMENT,
              date         TEXT    NOT NULL,
              time_of_day  TEXT    NOT NULL CHECK(time_of_day IN ('breakfast','lunch','dinner','snack')),
              description  TEXT    NOT NULL,
              notes        TEXT
            )
          ''');
        },
      );
      await oldDb.close();

      final Database upgradedDb = await openDatabase(
        path,
        version: DatabaseHelper.schemaVersion,
        onUpgrade: DatabaseHelper.onUpgrade,
      );

      final List<Map<String, Object?>> columns =
          await upgradedDb.rawQuery('PRAGMA table_info(meals)');
      final Set<String> columnNames = columns
          .map((Map<String, Object?> row) => row['name'] as String)
          .toSet();

      expect(columnNames.contains('quantity'), isTrue);

      await upgradedDb.close();
      await deleteDatabase(path);
    });
  });
}
