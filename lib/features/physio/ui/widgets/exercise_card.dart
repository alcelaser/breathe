import 'package:flutter/material.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.isPlanned,
    required this.onTogglePlan,
    required this.onTap,
  });

  final Exercise exercise;
  final bool isPlanned;
  final VoidCallback onTogglePlan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String dosage = exercise.durationSeconds != null
        ? '${exercise.durationSeconds}s'
        : '${exercise.sets ?? '-'} x ${exercise.reps ?? '-'}';

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              exercise.name.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFBDBDBD),
                    letterSpacing: 2.0,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              dosage,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    color: const Color(0xFF424242),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              exercise.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: <Widget>[
                TextButton(
                  onPressed: onTogglePlan,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF9E9E9E),
                  ),
                  child: Text(isPlanned ? 'REMOVE PLAN' : 'ADD TO PLAN', style: const TextStyle(letterSpacing: 1.5)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(color: Color(0xFFEEEEEE), height: 1),
          ],
        ),
      ),
    );
  }
}
