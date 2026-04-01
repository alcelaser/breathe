import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/physio/data/exercise_log_repository.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helpers/database_test_helper.dart';

void main() {
  late Database db;
  late ExerciseLogRepository repository;

  setUp(() async {
    db = await DatabaseTestHelper.openTestDatabase();
    repository = ExerciseLogRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('logExercise and getLogsForDate', () async {
    final DateTime date = DateTime(2026, 4, 1);
    await repository.logExercise(exerciseId: 'core_dead_bug', date: date);
    await repository.logExercise(exerciseId: 'hip_bridge', date: date);

    final logs = await repository.getLogsForDate(date);
    expect(logs.length, 2);
  });

  test('isLoggedToday returns false when date differs', () async {
    await repository.logExercise(
      exerciseId: 'core_dead_bug',
      date: DateTime.now().subtract(const Duration(days: 1)),
    );

    final isDone = await repository.isLoggedToday('core_dead_bug');
    expect(isDone, isFalse);
  });

  test('plan add/load/remove works', () async {
    await repository.addToPlan('hip_psoas_stretch');

    final planned = await repository.getPlannedExerciseIds();
    expect(planned.contains('hip_psoas_stretch'), isTrue);

    await repository.removeFromPlan('hip_psoas_stretch');
    final refreshed = await repository.getPlannedExerciseIds();
    expect(refreshed.contains('hip_psoas_stretch'), isFalse);
  });

  test('plan reps increment and history are tracked', () async {
    final DateTime day = DateTime(2026, 4, 1);
    await repository.incrementPlanReps(
      exerciseId: 'hip_psoas_stretch',
      reps: 5,
      date: day,
    );
    await repository.incrementPlanReps(
      exerciseId: 'hip_psoas_stretch',
      reps: 3,
      date: day,
    );

    final repsByExercise = await repository.getPlanRepsForDate(day);
    expect(repsByExercise['hip_psoas_stretch'], 8);

    final history =
        await repository.getPlanHistoryForExercise('hip_psoas_stretch');
    expect(history.length, 1);
    expect(history.first.repsDone, 8);
  });
}
