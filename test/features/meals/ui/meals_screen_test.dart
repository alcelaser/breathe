import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/meals/data/meal_repository.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';
import 'package:recovery_app/features/meals/ui/meals_screen.dart';

void main() {
  testWidgets('shows flat list and fab', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealRepositoryProvider.overrideWithValue(_EmptyFakeMealRepository()),
          mealNotifierProvider.overrideWith(() => _FakeMealNotifier()),
        ],
        child: const MaterialApp(home: MealsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('MEALS -'), findsOneWidget);
    expect(find.text('Nothing logged yet'), findsOneWidget);
  });

  testWidgets('swipes between full day screens', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealRepositoryProvider.overrideWithValue(_FakeMealRepository()),
        ],
        child: const MaterialApp(home: MealsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final DateTime now = DateTime.now();
    final int today = now.day;
    final int tomorrow = now.add(const Duration(days: 1)).day;

    expect(find.text('Meal $today'), findsOneWidget);

    await tester.fling(
      find.byType(PageView).first,
      const Offset(-400, 0),
      1800,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meal $tomorrow'), findsOneWidget);

    await tester.fling(
      find.byType(PageView).first,
      const Offset(400, 0),
      1800,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meal $today'), findsOneWidget);
  });
}

class _FakeMealNotifier extends MealNotifier {
  @override
  Future<void> build() async {}
}

class _EmptyFakeMealRepository extends MealRepository {
  @override
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    return <Meal>[];
  }
}

class _FakeMealRepository extends MealRepository {
  @override
  Future<List<Meal>> getMealsForDate(DateTime date) async {
    return <Meal>[
      Meal(
        id: date.day,
        date: date,
        timeOfDay: MealTimeOfDay.breakfast,
        description: 'Meal ${date.day}',
        quantity: '1 bowl',
        notes: null,
      ),
    ];
  }

  @override
  Future<void> deleteMeal(int id) async {}

  @override
  Future<int> insertMeal(Meal meal) async => 1;

  @override
  Future<void> updateMeal(Meal meal) async {}
}
