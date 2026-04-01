import 'package:flutter/material.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';

class ExerciseDetailSheet extends StatelessWidget {
  const ExerciseDetailSheet({
    super.key,
    required this.exercise,
    required this.isDone,
  });

  final Exercise exercise;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(exercise.name,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            if (exercise.id == 'hip_psoas_stretch' || exercise.id == 'lower_back_cobra_stretch') ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Image.asset(
                    'assets/poses/${exercise.id}.png',
                    height: 180,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Wrap(
              spacing: 8,
              children: exercise.bodyAreas
                  .map((String item) => Chip(label: Text(item)))
                  .toList(),
            ),
            Wrap(
              spacing: 8,
              children: exercise.goals
                  .map((String item) => Chip(label: Text(item)))
                  .toList(),
            ),
            const SizedBox(height: 8),
            Text(exercise.description),
            const SizedBox(height: 8),
            Text('Sets: ${exercise.sets?.toString() ?? '-'}'),
            Text('Reps: ${exercise.reps?.toString() ?? '-'}'),
            Text('Duration: ${exercise.durationSeconds?.toString() ?? '-'} s'),
            Text('Rest: ${exercise.restSeconds} s'),
            if (exercise.notes != null) Text('Notes: ${exercise.notes}'),
            const SizedBox(height: 12),
            const Text('Evidence',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Level: ${exercise.pedro.evidenceLevel}'),
            Text(
                'PEDro score: ${exercise.pedro.pedroScore?.toString() ?? 'N/A'}'),
            Text('Reference: ${exercise.pedro.reference}'),
            Text('DOI: ${exercise.pedro.doi ?? 'N/A'}'),
          ],
        ),
      ),
    );
  }
}
