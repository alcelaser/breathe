import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';
import 'package:recovery_app/features/physio/data/models/exercise_log.dart';
import 'package:recovery_app/features/physio/data/models/plan_progress_entry.dart';
import 'package:recovery_app/features/physio/providers/physio_providers.dart';
import 'package:recovery_app/features/physio/ui/plan_screen.dart';

void main() {
  testWidgets('renders dedicated plan screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          physioNotifierProvider.overrideWith(() => _FakePhysioNotifier()),
        ],
        child: const MaterialApp(home: PlanScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.textContaining('PLAN -'), findsOneWidget);
    expect(find.text('DEAD BUG'), findsOneWidget);
  });
}

class _FakePhysioNotifier extends PhysioNotifier {
  @override
  Future<PhysioState> build() async {
    const Exercise exercise = Exercise(
      id: 'e1',
      name: 'Dead Bug',
      bodyAreas: <String>['core'],
      goals: <String>['stability'],
      description: 'desc',
      sets: 2,
      reps: 8,
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

    return PhysioState(
      allExercises: <Exercise>[exercise],
      filteredExercises: <Exercise>[exercise],
      selectedBodyAreas: <String>{},
      todaysLogs: <ExerciseLog>[],
      loggedExerciseIds: <String>{},
      plannedExerciseIds: <String>{'e1'},
      planRepsToday: <String, int>{'e1': 6},
      planHistoryByExercise: <String, List<PlanProgressEntry>>{},
      selectedPlanDate: DateTime(2026, 4, 1),
    );
  }
}
