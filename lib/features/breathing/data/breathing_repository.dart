import 'package:recovery_app/core/database/data_access_exception.dart';
import 'package:recovery_app/core/database/database_helper.dart';
import 'package:recovery_app/core/database/tables.dart';
import 'package:recovery_app/features/breathing/data/models/breathing_session.dart';
import 'package:sqflite/sqflite.dart';

class BreathingRepository {
  BreathingRepository({
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

  Future<int> insertSession(BreathingSession session) async {
    try {
      final Database database = await _database();
      return database.insert(
        Tables.breathingSessions,
        session.toMap()..remove('id'),
      );
    } on DatabaseException catch (error) {
      throw DataAccessException('Failed to save breathing session: $error');
    }
  }

  Future<List<BreathingSession>> getSessionsForDate(DateTime date) async {
    try {
      final DateTime normalized = DateTime(date.year, date.month, date.day);
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.breathingSessions,
        where: 'date = ?',
        whereArgs: <Object>[normalized.toIso8601String()],
        orderBy: 'id DESC',
      );
      return rows.map(BreathingSession.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException(
          'Failed to fetch breathing sessions for date: $error');
    }
  }

  Future<List<BreathingSession>> getAllSessions() async {
    try {
      final Database database = await _database();
      final List<Map<String, Object?>> rows = await database.query(
        Tables.breathingSessions,
        orderBy: 'date DESC, id DESC',
      );
      return rows.map(BreathingSession.fromMap).toList();
    } on DatabaseException catch (error) {
      throw DataAccessException(
          'Failed to fetch all breathing sessions: $error');
    }
  }
}
