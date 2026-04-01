class PlanProgressEntry {
  const PlanProgressEntry({
    this.id,
    required this.date,
    required this.exerciseId,
    required this.repsDone,
  });

  final int? id;
  final DateTime date;
  final String exerciseId;
  final int repsDone;

  Map<String, Object?> toMap() {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    return <String, Object?>{
      'id': id,
      'date': normalized.toIso8601String(),
      'exercise_id': exerciseId,
      'reps_done': repsDone,
    };
  }

  factory PlanProgressEntry.fromMap(Map<String, Object?> map) {
    return PlanProgressEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      exerciseId: map['exercise_id'] as String,
      repsDone: map['reps_done'] as int,
    );
  }
}
