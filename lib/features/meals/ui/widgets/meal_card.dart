import 'package:flutter/material.dart';
import 'package:recovery_app/features/meals/data/models/meal.dart';

class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    this.onRemove,
    this.onEdit,
    this.enableSwipeToDelete = true,
  });

  final Meal meal;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final bool enableSwipeToDelete;

  @override
  Widget build(BuildContext context) {
    final String detailText = meal.quantity.trim().isEmpty
        ? meal.timeOfDay.name.toUpperCase()
        : '${meal.timeOfDay.name.toUpperCase()} • ${meal.quantity}';

    final Widget card = Card(
      child: ListTile(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              meal.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              detailText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
        subtitle: meal.notes == null
            ? null
            : Text(
                meal.notes!,
                textAlign: TextAlign.center,
              ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit meal',
                icon: const Icon(Icons.edit, size: 20),
                onPressed: onEdit,
              ),
              IconButton(
                tooltip: 'Remove meal',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );

    if (!enableSwipeToDelete || onRemove == null) {
      return card;
    }

    return Dismissible(
      key: ValueKey<int?>(meal.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove?.call(),
      background: Container(
        color: Colors.red.shade300,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: card,
    );
  }
}
