import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recovery_app/features/meals/data/meal_repository.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';

class MockMealRepository extends Mock implements MealRepository {}

class FakeMeal extends Fake implements Meal {}

void main() {
  late MockMealRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeMeal());
  });

  setUp(() {
    mockRepository = MockMealRepository();
    container = ProviderContainer(
      overrides: [
        mealRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loads meals on init', () async {
    when(() => mockRepository.getMealsForDate(any()))
        .thenAnswer((_) async => <Meal>[]);

    final value = await container.read(mealNotifierProvider.future);
    expect(value, isEmpty);
  });

  test('addMeal inserts and refreshes list', () async {
    final DateTime date = DateTime(2026, 4, 1);
    final Meal meal = Meal(
      id: 1,
      date: date,
      timeOfDay: MealTimeOfDay.breakfast,
      description: 'Oats',
      notes: null,
    );

    when(() => mockRepository.getMealsForDate(any()))
        .thenAnswer((_) async => <Meal>[]);
    when(() => mockRepository.insertMeal(any())).thenAnswer((_) async => 1);
    when(() => mockRepository.getMealsForDate(any()))
        .thenAnswer((_) async => <Meal>[meal]);

    await container.read(mealNotifierProvider.future);
    await container
        .read(mealNotifierProvider.notifier)
        .addMeal(meal.copyWith(id: null));

    expect(container.read(mealNotifierProvider).value!.length, 1);
    verify(() => mockRepository.insertMeal(any())).called(1);
  });
}
