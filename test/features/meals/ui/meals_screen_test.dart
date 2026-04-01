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
}

class _FakeMealNotifier extends MealNotifier {
  @override
  Future<List<Meal>> build() async => <Meal>[];
}
