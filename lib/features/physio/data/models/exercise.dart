class ExercisePedro {
  const ExercisePedro({
    required this.evidenceLevel,
    required this.pedroScore,
    required this.reference,
    required this.doi,
  });

  final String evidenceLevel;
  final int? pedroScore;
  final String reference;
  final String? doi;

  factory ExercisePedro.fromMap(Map<String, Object?> map) {
    return ExercisePedro(
      evidenceLevel: map['evidenceLevel'] as String,
      pedroScore: map['pedroScore'] as int?,
      reference: map['reference'] as String,
      doi: map['doi'] as String?,
    );
  }
}

class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.bodyAreas,
    required this.goals,
    required this.description,
    required this.sets,
    required this.reps,
    required this.durationSeconds,
    required this.restSeconds,
    required this.notes,
    required this.pedro,
  });

  final String id;
  final String name;
  final List<String> bodyAreas;
  final List<String> goals;
  final String description;
  final int? sets;
  final int? reps;
  final int? durationSeconds;
  final int restSeconds;
  final String? notes;
  final ExercisePedro pedro;

  factory Exercise.fromMap(Map<String, Object?> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      bodyAreas: (map['bodyAreas'] as List<dynamic>).cast<String>(),
      goals: (map['goals'] as List<dynamic>).cast<String>(),
      description: map['description'] as String,
      sets: map['sets'] as int?,
      reps: map['reps'] as int?,
      durationSeconds: map['durationSeconds'] as int?,
      restSeconds: map['restSeconds'] as int,
      notes: map['notes'] as String?,
      pedro: ExercisePedro.fromMap(
          (map['pedro'] as Map<String, dynamic>).cast<String, Object?>()),
    );
  }
}
