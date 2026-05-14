import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:recovery_app/features/meals/ui/widgets/add_meal_sheet.dart';

void main() {
  testWidgets('allows saving a meal without quantity', (WidgetTester tester) async {
    Meal? savedMeal;
    final DateTime date = DateTime(2026, 4, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AddMealSheet(
            initialDate: date,
            onSave: (Meal meal) async {
              savedMeal = meal;
            },
          ),
        ),
      ),
    );

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'Soup',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();

    expect(savedMeal, isNotNull);
    expect(savedMeal!.description, 'Soup');
    expect(savedMeal!.quantity, '');
  });
}
