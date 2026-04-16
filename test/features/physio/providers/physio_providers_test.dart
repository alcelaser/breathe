import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recovery_app/features/physio/data/exercise_log_repository.dart';
import 'package:recovery_app/features/physio/data/exercise_repository.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';
import 'package:recovery_app/features/physio/data/models/exercise_log.dart';
import 'package:recovery_app/features/physio/data/models/plan_progress_entry.dart';
import 'package:recovery_app/features/physio/providers/physio_providers.dart';

class MockExerciseRepository extends Mock implements ExerciseRepository {}

class MockExerciseLogRepository extends Mock implements ExerciseLogRepository {}

void main() {
  late MockExerciseRepository exerciseRepository;
  late MockExerciseLogRepository logRepository;
  late ProviderContainer container;

  const Exercise sample = Exercise(
    id: 'e1',
    name: 'Test',
    bodyAreas: <String>['core'],
    goals: <String>['stability'],
    description: 'desc',
    sets: 2,
    reps: 10,
    durationSeconds: null,
    restSeconds: 30,
    notes: null,
    pedro: ExercisePedro(
      evidenceLevel: 'RCT',
      pedroScore: 7,
      reference: 'Ref',
      doi: null,
    ),
  );

  setUp(() {
    exerciseRepository = MockExerciseRepository();
    logRepository = MockExerciseLogRepository();

    when(() => exerciseRepository.loadExercises())
        .thenAnswer((_) async => <Exercise>[sample]);
    when(() => exerciseRepository.filterByBodyArea(
            exercises: any(named: 'exercises'),
            selectedBodyAreas: any(named: 'selectedBodyAreas')))
        .thenReturn(<Exercise>[sample]);
    when(() => logRepository.getLogsForDate(any()))
        .thenAnswer((_) async => <ExerciseLog>[]);
    when(() => logRepository.getPlannedExerciseIds())
        .thenAnswer((_) async => <String>{});
    when(() => logRepository.getPlanRepsForDate(any()))
        .thenAnswer((_) async => <String, int>{});
    when(() => logRepository.getPlanHistoryForExercise(any()))
        .thenAnswer((_) async => <PlanProgressEntry>[]);
    when(() => logRepository.logExercise(
        exerciseId: any(named: 'exerciseId'),
        date: any(named: 'date'))).thenAnswer((_) async => 1);
    when(() => logRepository.addToPlan(any())).thenAnswer((_) async {});
    when(() => logRepository.removeFromPlan(any())).thenAnswer((_) async {});
    when(() => logRepository.incrementPlanReps(
          exerciseId: any(named: 'exerciseId'),
          reps: any(named: 'reps'),
          date: any(named: 'date'),
        )).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        exerciseRepositoryProvider.overrideWithValue(exerciseRepository),
        exerciseLogRepositoryProvider.overrideWithValue(logRepository),
      ],
    );
  });

  tearDown(() => container.dispose());

  test('loads exercises on init', () async {
    final state = await container.read(physioNotifierProvider.future);
    expect(state.allExercises.length, 1);
  });

  test('markDone logs and updates state', () async {
    await container.read(physioNotifierProvider.future);
    when(() => logRepository.getLogsForDate(any())).thenAnswer(
      (_) async => <ExerciseLog>[
        ExerciseLog(date: DateTime(2026, 4, 1), exerciseId: 'e1')
      ],
    );

    await container.read(physioNotifierProvider.notifier).markDone('e1');

    expect(
        container
            .read(physioNotifierProvider)
            .value!
            .loggedExerciseIds
            .contains('e1'),
        isTrue);
  });

  test('addToPlan updates planned ids', () async {
    await container.read(physioNotifierProvider.future);
    when(() => logRepository.getPlannedExerciseIds())
        .thenAnswer((_) async => <String>{'e1'});

    await container.read(physioNotifierProvider.notifier).addToPlan('e1');

    expect(
      container.read(physioNotifierProvider).value!.plannedExerciseIds,
      contains('e1'),
    );
  });

  test('today progress includes reps even when exercise is not marked done',
      () async {
    when(() => logRepository.getPlannedExerciseIds())
        .thenAnswer((_) async => <String>{'e1'});
    when(() => logRepository.getPlanRepsForDate(any()))
        .thenAnswer((_) async => <String, int>{'e1': 12});

    await container.read(physioNotifierProvider.future);
    final progress = await container.read(physioTodayProgressProvider.future);

    expect(progress.exercisesDone, 0);
    expect(progress.totalReps, 12);
  });
}
