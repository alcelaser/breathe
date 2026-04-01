import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/breathing/data/breathing_repository.dart';
import 'package:recovery_app/features/breathing/data/models/breathing_session.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helpers/database_test_helper.dart';

void main() {
  late Database db;
  late BreathingRepository repository;

  setUp(() async {
    db = await DatabaseTestHelper.openTestDatabase();
    repository = BreathingRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insertSession persists all values', () async {
    await repository.insertSession(
      BreathingSession(
        date: DateTime(2026, 4, 1),
        patternName: 'Box Breathing',
        inhaleSeconds: 4,
        holdSeconds: 4,
        exhaleSeconds: 4,
        cyclesCompleted: 5,
      ),
    );

    final sessions = await repository.getSessionsForDate(DateTime(2026, 4, 1));
    expect(sessions.length, 1);
    expect(sessions.first.patternName, 'Box Breathing');
    expect(sessions.first.cyclesCompleted, 5);
  });

  test('getAllSessions returns descending date order', () async {
    await repository.insertSession(
      BreathingSession(
        date: DateTime(2026, 3, 31),
        patternName: 'Relaxed',
        inhaleSeconds: 5,
        holdSeconds: 0,
        exhaleSeconds: 7,
        cyclesCompleted: 3,
      ),
    );
    await repository.insertSession(
      BreathingSession(
        date: DateTime(2026, 4, 1),
        patternName: '4-7-8',
        inhaleSeconds: 4,
        holdSeconds: 7,
        exhaleSeconds: 8,
        cyclesCompleted: 2,
      ),
    );

    final sessions = await repository.getAllSessions();
    expect(sessions.first.patternName, '4-7-8');
  });
}
