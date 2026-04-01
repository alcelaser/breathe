import 'package:flutter_test/flutter_test.dart';
import 'package:recovery_app/features/physio/data/exercise_repository.dart';

void main() {
  test('loadExercises parses JSON and includes pedro block', () async {
    final ExerciseRepository repository = ExerciseRepository(
      assetLoader: (_) async => '''
      [
        {
          "id": "x",
          "name": "Test",
          "bodyAreas": ["core"],
          "goals": ["stability"],
          "description": "desc",
          "sets": 1,
          "reps": 1,
          "durationSeconds": null,
          "restSeconds": 10,
          "notes": null,
          "pedro": {
            "evidenceLevel": "RCT",
            "pedroScore": 7,
            "reference": "Ref",
            "doi": null
          }
        }
      ]
      ''',
    );

    final items = await repository.loadExercises();
    expect(items.length, 1);
    expect(items.first.pedro.evidenceLevel, isNotEmpty);
  });

  test('filterByBodyArea applies OR logic', () async {
    final ExerciseRepository repository = ExerciseRepository(
      assetLoader: (_) async => '[]',
    );
    final all = await repository.loadExercises();
    final filtered = repository.filterByBodyArea(
      exercises: all,
      selectedBodyAreas: {'knee', 'hip'},
    );
    expect(filtered, isEmpty);
  });
}
