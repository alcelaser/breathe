import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:recovery_app/features/breathing/providers/breathing_providers.dart';
import 'package:recovery_app/features/meals/providers/meal_providers.dart';
import 'package:recovery_app/features/physio/providers/physio_providers.dart';
import 'package:recovery_app/features/weight/providers/weight_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Widget _summaryItem({
    required BuildContext context,
    required String title,
    required String summary,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              title.toUpperCase(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFBDBDBD),
                    letterSpacing: 3.0,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              summary,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 22,
                    color: const Color(0xFF424242),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breathing = ref.watch(breathingTodayProvider);
    final mealsCount = ref.watch(mealsCountTodayProvider);
    final latestWeight = ref.watch(latestWeightSummaryProvider);
    final physioProgress = ref.watch(physioTodayProgressProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              children: <Widget>[
                _summaryItem(
                  context: context,
                  title: 'Breathing',
                  summary: breathing.when(
                    data: (items) => items.isEmpty
                        ? 'No session yet'
                        : 'Last session today: ${items.first.patternName}',
                    loading: () => 'Loading...',
                    error: (_, __) => 'Unavailable',
                  ),
                  onTap: () => context.go('/breathing'),
                ),
                const Divider(color: Color(0xFFEEEEEE), height: 1),
                _summaryItem(
                  context: context,
                  title: 'Meals',
                  summary: mealsCount.when(
                    data: (value) => '$value meals logged today',
                    loading: () => 'Loading...',
                    error: (_, __) => 'Unavailable',
                  ),
                  onTap: () => context.go('/meals'),
                ),
                const Divider(color: Color(0xFFEEEEEE), height: 1),
                _summaryItem(
                  context: context,
                  title: 'Weight',
                  summary: latestWeight.when(
                    data: (result) {
                      final latest = result.latest;
                      if (latest == null) {
                        return 'No entries yet';
                      }
                      final String date =
                          DateFormat.yMMMd().format(latest.date);
                      final String delta = result.delta == null
                          ? ''
                          : ' (Δ ${result.delta!.toStringAsFixed(1)} kg)';
                      return '${latest.weightKg.toStringAsFixed(1)} kg on $date$delta';
                    },
                    loading: () => 'Loading...',
                    error: (_, __) => 'Unavailable',
                  ),
                  onTap: () => context.go('/weight'),
                ),
                const Divider(color: Color(0xFFEEEEEE), height: 1),
                _summaryItem(
                  context: context,
                  title: 'Physio',
                  summary: physioProgress.when(
                    data: (value) {
                      if (value.exercisesDone == 0 && value.totalReps == 0) {
                        return 'No progress logged today';
                      }
                      return '${value.exercisesDone} done • ${value.totalReps} reps today';
                    },
                    loading: () => 'Loading...',
                    error: (_, __) => 'Unavailable',
                  ),
                  onTap: () => context.go('/physio'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
