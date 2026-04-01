import 'package:recovery_app/core/database/data_access_exception.dart';
import 'package:recovery_app/core/database/database_helper.dart';
import 'package:recovery_app/core/database/tables.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:sqflite/sqflite.dart';

class MealRepository {
  MealRepository({
    DatabaseHelper? helper,
    Database? db,
  })  : _helper = helper ?? DatabaseHelper.instance,
        _db = db;

  final DatabaseHelper _helper;
  final Database? _db;

  Future<Database> _database() async {
    if (_db != null) {
      return _db;
    }
    return _helper.database;
  }

  Future<List<Meal>> getMealsForDate(DateTime date) async {
    try {
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.meals,
        where: 'date = ?',
        whereArgs: <Object>[normalized.toIso8601String()],
        orderBy: 'id ASC',
      );
      return rows.map(Meal.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load meals for date: $error');
    }
  }

  Future<List<Meal>> getMealsForDateRange({
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final DateTime startNormalized =
          DateTime(start.year, start.month, start.day);
      final DateTime endNormalized = DateTime(end.year, end.month, end.day);
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.meals,
        where: 'date >= ? AND date <= ?',
        whereArgs: <Object>[
          startNormalized.toIso8601String(),
          endNormalized.toIso8601String(),
        ],
        orderBy: 'date ASC, id ASC',
      );
      return rows.map(Meal.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load meals for range: $error');
    }
  }

  Future<int> insertMeal(Meal meal) async {
    try {
      final Database database = await _database();
      return database.insert(Tables.meals, meal.toMap()..remove('id'));
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to insert meal: $error');
    }
  }

  Future<void> deleteMeal(int id) async {
    try {
      final Database database = await _database();
      await database
          .delete(Tables.meals, where: 'id = ?', whereArgs: <Object>[id]);
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to delete meal: $error');
    }
  }
}
