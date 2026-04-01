import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/meals/data/meal_repository.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:sqflite/sqflite.dart';

import '../../../helpers/database_test_helper.dart';

void main() {
  late Database db;
  late MealRepository repository;

  setUp(() async {
    db = await DatabaseTestHelper.openTestDatabase();
    repository = MealRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  test('insert and fetch meals for date', () async {
    final DateTime date = DateTime(2026, 4, 1);
    await repository.insertMeal(
      Meal(
        date: date,
        timeOfDay: MealTimeOfDay.breakfast,
        description: 'Oats',
        quantity: '1 cup',
        notes: null,
      ),
    );

    final items = await repository.getMealsForDate(date);
    expect(items.length, 1);
    expect(items.first.description, 'Oats');
  });

  test('date range returns inclusive results', () async {
    await repository.insertMeal(
      Meal(
        date: DateTime(2026, 4, 1),
        timeOfDay: MealTimeOfDay.lunch,
        description: 'Rice',
        quantity: '2 cups',
        notes: null,
      ),
    );
    await repository.insertMeal(
      Meal(
        date: DateTime(2026, 4, 2),
        timeOfDay: MealTimeOfDay.dinner,
        description: 'Fish',
        quantity: '150g',
        notes: 'Light',
      ),
    );

    final results = await repository.getMealsForDateRange(
      start: DateTime(2026, 4, 1),
      end: DateTime(2026, 4, 2),
    );

    expect(results.length, 2);
  });

  test('delete removes one meal', () async {
    final int id = await repository.insertMeal(
      Meal(
        date: DateTime(2026, 4, 1),
        timeOfDay: MealTimeOfDay.snack,
        description: 'Fruit',
        quantity: '1 handful',
        notes: null,
      ),
    );

    await repository.deleteMeal(id);
    final results = await repository.getMealsForDate(DateTime(2026, 4, 1));
    expect(results, isEmpty);
  });
}
