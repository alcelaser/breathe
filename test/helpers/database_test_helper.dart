import 'package:recovery_app/core/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseTestHelper {
  static Future<Database> openTestDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final Database db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: DatabaseHelper.onCreate,
    );
    return db;
  }

  static Future<void> clearAllTables(Database db) async {
    await db.delete('meals');
    await db.delete('weight_entries');
    await db.delete('breathing_sessions');
    await db.delete('exercise_logs');
    await db.delete('exercise_plan');
    await db.delete('exercise_plan_progress');
  }
}
