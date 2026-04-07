import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('shows meals in horizontal side-scrolling pages',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          mealNotifierProvider.overrideWith(() => _FakeMealNotifierWithData()),
        ],
        child: const MaterialApp(home: MealsScreen()),
      ),
    );

    await tester.pumpAndSettle();

    final PageView pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.scrollDirection, Axis.horizontal);
    expect(pageView.pageSnapping, isTrue);
    expect(find.text('Oatmeal'), findsOneWidget);
  });
}

class _FakeMealNotifier extends MealNotifier {
  @override
  Future<List<Meal>> build() async => <Meal>[];
}

class _FakeMealNotifierWithData extends MealNotifier {
  @override
  Future<List<Meal>> build() async => <Meal>[
        Meal(
          id: 1,
          date: DateTime(2026, 4, 7),
          timeOfDay: MealTimeOfDay.breakfast,
          description: 'Oatmeal',
          quantity: '1 bowl',
          notes: null,
        ),
      ];
}
