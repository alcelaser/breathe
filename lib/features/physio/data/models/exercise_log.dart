class ExerciseLog {
  const ExerciseLog({
    this.id,
    required this.date,
    required this.exerciseId,
    this.completed = true,
  });

  final int? id;
  final DateTime date;
  final String exerciseId;
  final bool completed;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'exercise_id': exerciseId,
      'completed': completed ? 1 : 0,
    };
  }

  factory ExerciseLog.fromMap(Map<String, Object?> map) {
    return ExerciseLog(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      exerciseId: map['exercise_id'] as String,
      completed: (map['completed'] as int) == 1,
    );
  }
}
