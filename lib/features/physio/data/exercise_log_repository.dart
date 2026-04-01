import 'package:recovery_app/core/database/data_access_exception.dart';
import 'package:recovery_app/core/database/database_helper.dart';
import 'package:recovery_app/core/database/tables.dart';
import 'package:recovery_app/features/physio/data/models/exercise_log.dart';
import 'package:recovery_app/features/physio/data/models/plan_progress_entry.dart';
import 'package:sqflite/sqflite.dart';

class ExerciseLogRepository {
  ExerciseLogRepository({
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

  Future<int> logExercise({
    required String exerciseId,
    required DateTime date,
  }) async {
    try {
      final Database database = await _database();
      final ExerciseLog log = ExerciseLog(
        date: date,
        exerciseId: exerciseId,
      );
      return database.insert(Tables.exerciseLogs, log.toMap()..remove('id'));
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to log exercise: $error');
    }
  }

  Future<List<ExerciseLog>> getLogsForDate(DateTime date) async {
    try {
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.exerciseLogs,
        where: 'date = ?',
        whereArgs: <Object>[normalized.toIso8601String()],
        orderBy: 'id DESC',
      );
      return rows.map(ExerciseLog.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load exercise logs: $error');
    }
  }

  Future<bool> isLoggedToday(String exerciseId) async {
    try {
      final DateTime now = DateTime.now();
      final DateTime today = DateTime(now.year, now.month, now.day);
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.exerciseLogs,
        where: 'exercise_id = ? AND date = ?',
        whereArgs: <Object>[exerciseId, today.toIso8601String()],
        limit: 1,
      );
      return rows.isNotEmpty;
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to check exercise log state: $error');
    }
  }

  Future<void> deleteLog(int id) async {
    try {
      final Database database = await _database();
      await database.delete(Tables.exerciseLogs,
          where: 'id = ?', whereArgs: <Object>[id]);
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to delete exercise log: $error');
    }
  }

  Future<Set<String>> getPlannedExerciseIds() async {
    try {
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.exercisePlan,
        orderBy: 'id ASC',
      );
      return rows
          .map((Map<String, Object?> row) => row['exercise_id'] as String)
          .toSet();
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load planned exercises: $error');
    }
  }

  Future<void> addToPlan(String exerciseId) async {
    try {
      final Database database = await _database();
      await database.insert(
        Tables.exercisePlan,
        <String, Object?>{
          'exercise_id': exerciseId,
          'added_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to add exercise to plan: $error');
    }
  }

  Future<void> removeFromPlan(String exerciseId) async {
    try {
      final Database database = await _database();
      await database.delete(
        Tables.exercisePlan,
        where: 'exercise_id = ?',
        whereArgs: <Object>[exerciseId],
      );
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to remove exercise from plan: $error');
    }
  }

  Future<void> incrementPlanReps({
    required String exerciseId,
    required int reps,
    DateTime? date,
  }) async {
    try {
      final DateTime chosenDate = date ?? DateTime.now();
      final DateTime normalized =
          DateTime(chosenDate.year, chosenDate.month, chosenDate.day);
      final String isoDate = normalized.toIso8601String();
      final Database database = await _database();

      final List<Map<String, Object?>> existing = await database.query(
        Tables.exercisePlanProgress,
        where: 'exercise_id = ? AND date = ?',
        whereArgs: <Object>[exerciseId, isoDate],
        limit: 1,
      );

      if (existing.isEmpty) {
        if (reps <= 0) {
          return;
        }
        await database.insert(
          Tables.exercisePlanProgress,
          <String, Object?>{
            'date': isoDate,
            'exercise_id': exerciseId,
            'reps_done': reps,
          },
        );
        return;
      }

      final Map<String, Object?> row = existing.first;
      final int current = row['reps_done'] as int;
      final int next = current + reps;
      if (next <= 0) {
        await database.delete(
          Tables.exercisePlanProgress,
          where: 'exercise_id = ? AND date = ?',
          whereArgs: <Object>[exerciseId, isoDate],
        );
        return;
      }
      await database.update(
        Tables.exercisePlanProgress,
        <String, Object?>{'reps_done': next},
        where: 'exercise_id = ? AND date = ?',
        whereArgs: <Object>[exerciseId, isoDate],
      );
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to update planned reps: $error');
    }
  }

  Future<Map<String, int>> getPlanRepsForDate(DateTime date) async {
    try {
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.exercisePlanProgress,
        where: 'date = ?',
        whereArgs: <Object>[normalized.toIso8601String()],
      );

      final Map<String, int> result = <String, int>{};
      for (final Map<String, Object?> row in rows) {
        result[row['exercise_id'] as String] = row['reps_done'] as int;
      }
      return result;
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load reps for date: $error');
    }
  }

  Future<List<PlanProgressEntry>> getPlanHistoryForExercise(
      String exerciseId) async {
    try {
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.exercisePlanProgress,
        where: 'exercise_id = ?',
        whereArgs: <Object>[exerciseId],
        orderBy: 'date DESC',
      );
      return rows.map(PlanProgressEntry.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to load plan history: $error');
    }
  }
}
