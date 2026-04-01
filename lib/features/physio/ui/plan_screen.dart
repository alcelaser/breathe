import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';
import 'package:recovery_app/features/physio/data/models/plan_progress_entry.dart';
import 'package:recovery_app/features/physio/providers/physio_providers.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PhysioState> state = ref.watch(physioNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (PhysioState data) {
            final List<Exercise> planned = data.allExercises
                .where((Exercise item) => data.plannedExerciseIds.contains(item.id))
                .toList();
            final DateTime selectedDate = data.selectedPlanDate;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      onPressed: () {
                        ref.read(physioNotifierProvider.notifier).loadPlanForDate(
                              selectedDate.subtract(const Duration(days: 1)),
                            );
                      },
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'PLAN - ${DateFormat.MMMEd().format(selectedDate).toUpperCase()}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            letterSpacing: 2.0,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                    IconButton(
                      onPressed: () {
                        ref.read(physioNotifierProvider.notifier).loadPlanForDate(
                              selectedDate.add(const Duration(days: 1)),
                            );
                      },
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (planned.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Text('No exercises in your plan yet.', style: TextStyle(color: Color(0xFF9E9E9E))),
                    ),
                  ),
                ...planned.map((Exercise exercise) {
                  final bool isDone = data.loggedExerciseIds.contains(exercise.id);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          exercise.name.toUpperCase(),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          exercise.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'TOTAL REPS TODAY: ',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: const Color(0xFFBDBDBD)),
                            ),
                            Text(
                              '${data.planRepsToday[exercise.id] ?? 0}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: <Widget>[
                            OutlinedButton(
                              onPressed: () => ref
                                  .read(physioNotifierProvider.notifier)
                                  .logPlanReps(
                                    exerciseId: exercise.id,
                                    reps: 1,
                                  ),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE0E0E0))),
                              child: const Text('+1 REP'),
                            ),
                            OutlinedButton(
                              onPressed: () => ref
                                  .read(physioNotifierProvider.notifier)
                                  .logPlanReps(
                                    exerciseId: exercise.id,
                                    reps: 5,
                                  ),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE0E0E0))),
                              child: const Text('+5 REPS'),
                            ),
                            if (!isDone)
                              FilledButton(
                                onPressed: () => ref
                                    .read(physioNotifierProvider.notifier)
                                    .markDone(exercise.id),
                                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFA3B19E)),
                                child: const Text('MARK DONE'),
                              ),
                            if (isDone)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                child: Text('DONE ✓', style: TextStyle(color: Color(0xFFA3B19E), letterSpacing: 2.0)),
                              ),
                            TextButton(
                              onPressed: () => ref
                                  .read(physioNotifierProvider.notifier)
                                  .removeFromPlan(exercise.id),
                              style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF9A9A)),
                              child: const Text('REMOVE'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if ((data.planHistoryByExercise[exercise.id] ?? []).isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Divider(color: Color(0xFFEEEEEE), height: 1),
                          const SizedBox(height: 12),
                          Text(
                            'HISTORY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 2.0, color: const Color(0xFFBDBDBD)),
                          ),
                          const SizedBox(height: 8),
                          ...((data.planHistoryByExercise[exercise.id] ?? <PlanProgressEntry>[])
                                  .take(3)
                                  .map(
                                    (PlanProgressEntry entry) => Text(
                                      '${DateFormat.yMMMd().format(entry.date)}: ${entry.repsDone} reps',
                                      style: const TextStyle(color: Color(0xFF9E9E9E)),
                                    ),
                                  )),
                        ]
                      ],
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object _, StackTrace __) {
            return const Center(child: Text('Unable to load plan.'));
          },
        ),
      ),
    );
  }
}
