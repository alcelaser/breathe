import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recovery_app/features/physio/data/models/exercise.dart';
import 'package:recovery_app/features/physio/providers/physio_providers.dart';
import 'package:recovery_app/features/physio/ui/widgets/exercise_card.dart';
import 'package:recovery_app/features/physio/ui/widgets/exercise_detail_sheet.dart';
import 'package:recovery_app/features/physio/ui/widgets/exercise_filter_chips.dart';

class PhysioScreen extends ConsumerWidget {
  const PhysioScreen({super.key});

  Future<void> _openDetails(
    BuildContext context,
    WidgetRef ref,
    Exercise exercise,
    bool isDone,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return ExerciseDetailSheet(
          exercise: exercise,
          isDone: isDone,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<PhysioState> state = ref.watch(physioNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (PhysioState data) {
            final List<Exercise> completedToday = data.allExercises
                .where(
                    (Exercise item) => data.loggedExerciseIds.contains(item.id))
                .toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: <Widget>[
                Text(
                  'PHYSIO',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        letterSpacing: 4.0,
                        fontWeight: FontWeight.w400,
                      ),
                ),
                const SizedBox(height: 32),
                ExerciseFilterChips(
                  selected: data.selectedBodyAreas,
                  onToggle: (String area) => ref
                      .read(physioNotifierProvider.notifier)
                      .toggleBodyArea(area),
                  onClear: () =>
                      ref.read(physioNotifierProvider.notifier).clearFilters(),
                ),
                const SizedBox(height: 16),
                if (completedToday.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text('TODAY\'S SESSION', style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 2.0, color: const Color(0xFFBDBDBD))),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: completedToday
                          .map((Exercise exercise) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(label: Text(exercise.name)),
                              ))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ...data.filteredExercises.map((Exercise exercise) {
                  final bool isDone =
                      data.loggedExerciseIds.contains(exercise.id);
                  final bool isPlanned =
                      data.plannedExerciseIds.contains(exercise.id);
                  return ExerciseCard(
                    exercise: exercise,
                    isPlanned: isPlanned,
                    onTogglePlan: () {
                      if (isPlanned) {
                        ref
                            .read(physioNotifierProvider.notifier)
                            .removeFromPlan(exercise.id);
                      } else {
                        ref
                            .read(physioNotifierProvider.notifier)
                            .addToPlan(exercise.id);
                      }
                    },
                    onTap: () => _openDetails(context, ref, exercise, isDone),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object _, StackTrace __) {
            return const Center(child: Text('Unable to load physio exercises.'));
          },
        ),
      ),
    );
  }
}
