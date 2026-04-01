import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';
import 'package:recovery_app/features/weight/data/weight_repository.dart';
import 'package:recovery_app/features/weight/providers/weight_providers.dart';

class MockWeightRepository extends Mock implements WeightRepository {}

class FakeWeightEntry extends Fake implements WeightEntry {}

void main() {
  late MockWeightRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeWeightEntry());
  });

  setUp(() {
    mockRepository = MockWeightRepository();
    container = ProviderContainer(
      overrides: [
        weightRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loads entries on init', () async {
    when(() => mockRepository.getAllWeightEntries())
        .thenAnswer((_) async => <WeightEntry>[]);

    final value = await container.read(weightNotifierProvider.future);
    expect(value, isEmpty);
  });

  test('addEntry triggers repository and refresh', () async {
    final WeightEntry entry =
        WeightEntry(date: DateTime(2026, 4, 1), weightKg: 70);

    when(() => mockRepository.getAllWeightEntries())
        .thenAnswer((_) async => <WeightEntry>[]);
    when(() => mockRepository.insertOrUpdateWeight(any()))
        .thenAnswer((_) async => 1);
    when(() => mockRepository.getAllWeightEntries())
        .thenAnswer((_) async => <WeightEntry>[entry]);

    await container.read(weightNotifierProvider.future);
    await container.read(weightNotifierProvider.notifier).addEntry(entry);

    expect(container.read(weightNotifierProvider).value!.first.weightKg, 70);
  });
}
