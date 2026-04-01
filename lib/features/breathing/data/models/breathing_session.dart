class BreathingSession {
  const BreathingSession({
    this.id,
    required this.date,
    required this.patternName,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    required this.cyclesCompleted,
  });

  final int? id;
  final DateTime date;
  final String patternName;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int cyclesCompleted;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'pattern_name': patternName,
      'inhale_seconds': inhaleSeconds,
      'hold_seconds': holdSeconds,
      'exhale_seconds': exhaleSeconds,
      'cycles_completed': cyclesCompleted,
    };
  }

  factory BreathingSession.fromMap(Map<String, Object?> map) {
    return BreathingSession(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      patternName: map['pattern_name'] as String,
      inhaleSeconds: map['inhale_seconds'] as int,
      holdSeconds: map['hold_seconds'] as int,
      exhaleSeconds: map['exhale_seconds'] as int,
      cyclesCompleted: map['cycles_completed'] as int,
    );
  }
}
