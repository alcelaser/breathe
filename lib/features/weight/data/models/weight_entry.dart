class WeightEntry {
  const WeightEntry({
    this.id,
    required this.date,
    required this.weightKg,
  });

  final int? id;
  final DateTime date;
  final double weightKg;

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'weight_kg': weightKg,
    };
  }

  factory WeightEntry.fromMap(Map<String, Object?> map) {
    return WeightEntry(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      weightKg: (map['weight_kg'] as num).toDouble(),
    );
  }
}
