import 'package:flutter/material.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    this.onDismissed,
  });

  final Meal meal;
  final VoidCallback? onDismissed;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey<int?>(meal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed?.call(),
      background: Container(
        color: Colors.red.shade300,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          title: Text(
            meal.description,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: meal.notes == null ? null : Text(meal.notes!),
        ),
      ),
    );
  }
}
