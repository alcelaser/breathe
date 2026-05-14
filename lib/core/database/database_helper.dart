import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'tables.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();
  static const int schemaVersion = 5;
  static const String databaseName = 'recovery_app.db';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final String dbPath = await getDatabasesPath();
    final String path = p.join(dbPath, databaseName);

    return openDatabase(
      path,
      version: schemaVersion,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  static Future<void> onCreate(Database db, int version) async {
    await db.execute(Tables.createBreathingSessions);
    await db.execute(Tables.createMeals);
    await db.execute(Tables.createWeightEntries);
    await db.execute(Tables.createExerciseLogs);
    await db.execute(Tables.createExercisePlan);
    await db.execute(Tables.createExercisePlanProgress);
    await db.execute(Tables.createRecipes);
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute(Tables.createExercisePlan);
    }
    if (oldVersion < 3) {
      await db.execute(Tables.createExercisePlanProgress);
    }
    if (oldVersion < 4) {
      final bool hasQuantityColumn =
          await _tableHasColumn(db, table: Tables.meals, column: 'quantity');
      if (!hasQuantityColumn) {
        await db.execute(
          "ALTER TABLE ${Tables.meals} ADD COLUMN quantity TEXT NOT NULL DEFAULT ''",
        );
      }
    }
    if (oldVersion < 5) {
      await db.execute(Tables.createRecipes);
    }
  }

  static Future<bool> _tableHasColumn(
    Database db, {
    required String table,
    required String column,
  }) async {
    final List<Map<String, Object?>> info =
        await db.rawQuery('PRAGMA table_info($table)');
    return info.any((Map<String, Object?> row) => row['name'] == column);
  }
}
