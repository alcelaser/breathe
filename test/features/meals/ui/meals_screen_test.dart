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
          selectedMealsDateProvider.overrideWith(
            (Ref ref) => DateTime(2026, 4, 7),
          ),
        ],
        child: const MaterialApp(home: MealsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Meal 7'), findsOneWidget);

    await tester.fling(
      find.byType(ListView).first,
      const Offset(-400, 0),
      1800,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meal 8'), findsOneWidget);

    await tester.fling(
      find.byType(ListView).first,
      const Offset(400, 0),
      1800,
    );
    await tester.pumpAndSettle();

    expect(find.text('Meal 7'), findsOneWidget);
  });
}

class _FakeMealNotifier extends MealNotifier {
  @override
  Future<List<Meal>> build() async => <Meal>[];
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
