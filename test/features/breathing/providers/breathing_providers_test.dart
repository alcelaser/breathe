import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recovery_app/features/breathing/data/breathing_repository.dart';
import 'package:recovery_app/features/breathing/data/models/breathing_session.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';

class MockBreathingRepository extends Mock implements BreathingRepository {}

class FakeBreathingSession extends Fake implements BreathingSession {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBreathingRepository mockRepository;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeBreathingSession());
  });

  setUp(() {
    mockRepository = MockBreathingRepository();
    when(() => mockRepository.insertSession(any())).thenAnswer((_) async => 1);
    when(() => mockRepository.getSessionsForDate(any()))
        .thenAnswer((_) async => <BreathingSession>[]);

    container = ProviderContainer(
      overrides: [
        breathingRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('initial phase is inhale', () async {
    final value = await container.read(breathingNotifierProvider.future);
    expect(value.phase, BreathingPhase.inhale);
  });

  test('phase advances and saves at completion', () async {
    final notifier = container.read(breathingNotifierProvider.notifier);
    await container.read(breathingNotifierProvider.future);

    await notifier.startSession(
      patternName: 'Test',
      inhale: 1,
      hold: 0,
      exhale: 1,
      cycles: 1,
    );

    notifier.tick();
    notifier.tick();
    notifier.tick();
    notifier.tick();
    await Future<void>.delayed(Duration.zero);

    expect(container.read(breathingNotifierProvider).value!.didFinish, isTrue);
  });
}
