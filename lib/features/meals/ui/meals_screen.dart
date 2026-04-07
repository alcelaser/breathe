import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';
import 'package:recovery_app/features/meals/ui/widgets/add_meal_sheet.dart';
import 'package:recovery_app/features/meals/ui/widgets/meal_card.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref, DateTime date,
      {Meal? meal}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AddMealSheet(
          initialDate: date,
          initialMeal: meal,
          onSave: (Meal newMeal) {
            if (meal == null) {
              return ref.read(mealNotifierProvider.notifier).addMeal(newMeal);
            } else {
              return ref.read(mealNotifierProvider.notifier).editMeal(newMeal);
            }
          },
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 48, 16, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        onPressed: () {
                          ref.read(mealNotifierProvider.notifier).loadForDate(
                                selectedDate.subtract(const Duration(days: 1)),
                              );
                        },
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'MEALS - ${DateFormat.MMMEd().format(selectedDate).toUpperCase()}',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  letterSpacing: 2.0,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
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

                      return LayoutBuilder(
                        builder:
                            (BuildContext context, BoxConstraints constraints) {
                          final double cardWidth = (constraints.maxWidth - 64)
                              .clamp(260.0, 420.0)
                              .toDouble();

                          return PageView.builder(
                            pageSnapping: true,
                            itemCount: meals.length,
                            itemBuilder: (BuildContext context, int index) {
                              final Meal meal = meals[index];
                              return Padding(
                                padding: EdgeInsets.fromLTRB(
                                  index == 0 ? 24 : 12,
                                  16,
                                  index == meals.length - 1 ? 24 : 12,
                                  16,
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: cardWidth,
                                    child: MealCard(
                                      meal: meal,
                                      enableSwipeToDelete: false,
                                      onEdit: () => _openAddSheet(
                                        context,
                                        ref,
                                        selectedDate,
                                        meal: meal,
                                      ),
                                      onRemove: () async {
                                        final int? id = meal.id;
                                        if (id == null) {
                                          return;
                                        }
                                        await ref
                                            .read(mealNotifierProvider.notifier)
                                            .deleteMeal(id);
                                        if (!context.mounted) {
                                          return;
                                        }
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Meal deleted. Undo?'),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (Object _, StackTrace __) {
                      return const Center(child: Text('Unable to load meals.'));
                    },
                  ),
                ),
              ],
            ),
          ),
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
