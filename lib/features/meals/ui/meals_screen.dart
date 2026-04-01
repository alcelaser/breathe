import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';
import 'package:recovery_app/features/meals/ui/widgets/add_meal_sheet.dart';
import 'package:recovery_app/features/meals/ui/widgets/meal_card.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<void> _openAddSheet(
      BuildContext context, WidgetRef ref, DateTime date) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddMealSheet(
          initialDate: date,
          onSave: (Meal meal) =>
              ref.read(mealNotifierProvider.notifier).addMeal(meal),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime selectedDate = ref.watch(selectedMealsDateProvider);
    final AsyncValue<List<Meal>> mealsState = ref.watch(mealNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      ref.read(mealNotifierProvider.notifier).loadForDate(
                            selectedDate.subtract(const Duration(days: 1)),
                          );
                    },
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'MEALS - ${DateFormat.MMMEd().format(selectedDate).toUpperCase()}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w400,
                        ),
                  ),
                  IconButton(
                    onPressed: () {
                      ref.read(mealNotifierProvider.notifier).loadForDate(
                            selectedDate.add(const Duration(days: 1)),
                          );
                    },
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
            Expanded(
              child: mealsState.when(
                data: (List<Meal> meals) {
                  if (meals.isEmpty) {
                    return const Center(child: Text('Nothing logged yet'));
                  }

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    children: meals.map((Meal meal) {
                      return MealCard(
                        meal: meal,
                        onDismissed: () async {
                          final int? id = meal.id;
                          if (id == null) {
                            return;
                          }
                          await ref.read(mealNotifierProvider.notifier).deleteMeal(id);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Meal deleted. Undo?')),
                          );
                        },
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (Object _, StackTrace __) {
                  return const Center(child: Text('Unable to load meals.'));
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        foregroundColor: const Color(0xFF424242),
        onPressed: () => _openAddSheet(context, ref, selectedDate),
        child: const Icon(Icons.add),
      ),
    );
  }
}
