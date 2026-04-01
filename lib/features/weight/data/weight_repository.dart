import 'package:recovery_app/core/database/data_access_exception.dart';
import 'package:recovery_app/core/database/database_helper.dart';
import 'package:recovery_app/core/database/tables.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';
import 'package:sqflite/sqflite.dart';

class WeightRepository {
  WeightRepository({
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

  Future<int> insertOrUpdateWeight(WeightEntry entry) async {
    try {
      final Database database = await _database();
      return database.insert(
        Tables.weightEntries,
        entry.toMap()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to insert or update weight: $error');
    }
  }

  Future<List<WeightEntry>> getAllWeightEntries() async {
    try {
      final Database database = await _database();
      final List<Map<String, Object?>> rows =
          await database.query(Tables.weightEntries, orderBy: 'date ASC');
      return rows.map(WeightEntry.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load weight entries: $error');
    }
  }

  Future<void> deleteWeightEntry(int id) async {
    try {
      final Database database = await _database();
      await database.delete(
        Tables.weightEntries,
        where: 'id = ?',
        whereArgs: <Object>[id],
      );
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to delete weight entry: $error');
    }
  }

  Future<WeightEntry?> getLatestWeightEntry() async {
    try {
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database
          .query(Tables.weightEntries, orderBy: 'date DESC', limit: 1);
      if (rows.isEmpty) {
        return null;
      }
      return WeightEntry.fromMap(rows.first);
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to fetch latest weight entry: $error');
    }
  }

  Future<double?> getDeltaFromPrevious({required DateTime date}) async {
    try {
      final Database database = await _database();
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final List<Map<String, Object?>> currentRows = await database.query(
        Tables.weightEntries,
        where: 'date = ?',
        whereArgs: <Object>[normalized.toIso8601String()],
        limit: 1,
      );
      if (currentRows.isEmpty) {
        return null;
      }

      final List<Map<String, Object?>> previousRows = await database.query(
        Tables.weightEntries,
        where: 'date < ?',
        whereArgs: <Object>[normalized.toIso8601String()],
        orderBy: 'date DESC',
        limit: 1,
      );
      if (previousRows.isEmpty) {
        return null;
      }

      final double current = (currentRows.first['weight_kg'] as num).toDouble();
      final double previous =
          (previousRows.first['weight_kg'] as num).toDouble();
      return current - previous;
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to calculate weight delta: $error');
    }
  }
}
