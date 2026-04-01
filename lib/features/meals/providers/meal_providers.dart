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

final mealNotifierProvider =
    AsyncNotifierProvider<MealNotifier, List<Meal>>(MealNotifier.new);

final mealsCountTodayProvider = FutureProvider<int>((Ref ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final meals = await repository.getMealsForDate(today);
  return meals.length;
});

class MealNotifier extends AsyncNotifier<List<Meal>> {
  DateTime _currentDate = DateTime.now();

  MealRepository get _repository => ref.read(mealRepositoryProvider);

  @override
  Future<List<Meal>> build() async {
    _currentDate = ref.watch(selectedMealsDateProvider);
    return _repository.getMealsForDate(_currentDate);
  }

  Future<void> loadForDate(DateTime date) async {
    final normalized = DateTime(date.year, date.month, date.day);
    _currentDate = normalized;
    ref.read(selectedMealsDateProvider.notifier).state = normalized;
    state = const AsyncLoading<List<Meal>>();
    state =
        await AsyncValue.guard(() => _repository.getMealsForDate(normalized));
  }

  Future<void> addMeal(Meal meal) async {
    await _repository.insertMeal(meal);
    final List<Meal> refreshed =
        await _repository.getMealsForDate(_currentDate);
    state = AsyncData<List<Meal>>(refreshed);
  }

  Future<void> deleteMeal(int id) async {
    await _repository.deleteMeal(id);
    final List<Meal> current = state.valueOrNull ?? <Meal>[];
    state = AsyncData<List<Meal>>(
      current.where((Meal meal) => meal.id != id).toList(),
    );
  }

  Future<void> editMeal(Meal meal) async {
    await _repository.updateMeal(meal);
    final List<Meal> refreshed =
        await _repository.getMealsForDate(_currentDate);
    state = AsyncData<List<Meal>>(refreshed);
  }
}
