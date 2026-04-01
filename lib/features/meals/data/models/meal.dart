enum MealTimeOfDay { breakfast, lunch, dinner, snack }

class Meal {
  const Meal({
    this.id,
    required this.date,
    required this.timeOfDay,
    required this.description,
    required this.quantity,
    required this.notes,
  });

  final int? id;
  final DateTime date;
  final MealTimeOfDay timeOfDay;
  final String description;
  final String quantity;
  final String? notes;

  Meal copyWith({
    int? id,
    DateTime? date,
    MealTimeOfDay? timeOfDay,
    String? description,
    String? quantity,
    String? notes,
  }) {
    return Meal(
      id: id ?? this.id,
      date: date ?? this.date,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, Object?> toMap() {
    return <String, Object?>{
      'id': id,
      'date': DateTime(date.year, date.month, date.day).toIso8601String(),
      'time_of_day': timeOfDay.name,
      'description': description,
      'quantity': quantity,
      'notes': notes,
    };
  }

  factory Meal.fromMap(Map<String, Object?> map) {
    return Meal(
      id: map['id'] as int?,
      date: DateTime.parse(map['date'] as String),
      timeOfDay: MealTimeOfDay.values.firstWhere(
        (MealTimeOfDay value) => value.name == map['time_of_day'] as String,
      ),
      description: map['description'] as String,
      quantity: map['quantity'] as String? ?? '',
      notes: map['notes'] as String?,
    );
  }
}
