import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';

class ExerciseRepository {
  ExerciseRepository({Future<String> Function(String key)? assetLoader})
      : _assetLoader = assetLoader ?? rootBundle.loadString;

  final Future<String> Function(String key) _assetLoader;

  Future<List<Exercise>> loadExercises() async {
    final String jsonString = await _assetLoader('assets/exercises.json');
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
    return decoded
        .map((dynamic item) => Exercise.fromMap(
            (item as Map<String, dynamic>).cast<String, Object?>()))
        .toList();
  }

  List<Exercise> filterByBodyArea({
    required List<Exercise> exercises,
    required Set<String> selectedBodyAreas,
  }) {
    if (selectedBodyAreas.isEmpty) {
      return exercises;
    }
    return exercises
        .where((Exercise exercise) =>
            exercise.bodyAreas.any(selectedBodyAreas.contains))
        .toList();
  }

  List<Exercise> filterByGoal({
    required List<Exercise> exercises,
    required String goal,
  }) {
    return exercises
        .where((Exercise exercise) => exercise.goals.contains(goal))
        .toList();
  }
}
