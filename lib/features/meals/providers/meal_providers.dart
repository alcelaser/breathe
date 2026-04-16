import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/core/database/database_providers.dart';
import 'package:recovery_app/features/meals/data/meal_repository.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';

final mealRepositoryProvider = Provider<MealRepository>((Ref ref) {
  final helper = ref.watch(databaseHelperProvider);
  return MealRepository(helper: helper);
});

final selectedMealsDateProvider = StateProvider<DateTime>((Ref ref) {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final mealsForDateProvider =
    FutureProvider.family<List<Meal>, DateTime>((ref, date) async {
  final repository = ref.watch(mealRepositoryProvider);
  final normalized = DateTime(date.year, date.month, date.day);
  return repository.getMealsForDate(normalized);
});

final mealNotifierProvider =
    AsyncNotifierProvider<MealNotifier, void>(MealNotifier.new);

final mealsCountTodayProvider = FutureProvider<int>((Ref ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final meals = await repository.getMealsForDate(today);
  return meals.length;
});

class MealNotifier extends AsyncNotifier<void> {
  MealRepository get _repository => ref.read(mealRepositoryProvider);

  @override
  Future<void> build() async {
    // No initial state
  }

  Future<void> addMeal(Meal meal) async {
    await _repository.insertMeal(meal);
    ref.invalidate(mealsForDateProvider);
    ref.invalidate(mealsCountTodayProvider);
  }

  Future<void> deleteMeal(int id) async {
    await _repository.deleteMeal(id);
    ref.invalidate(mealsForDateProvider);
    ref.invalidate(mealsCountTodayProvider);
  }

  Future<void> editMeal(Meal meal) async {
    await _repository.updateMeal(meal);
    ref.invalidate(mealsForDateProvider);
    ref.invalidate(mealsCountTodayProvider);
  }
}
