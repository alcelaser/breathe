import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';
import 'package:recovery_app/features/weight/providers/weight_providers.dart';
import 'package:recovery_app/features/weight/ui/widgets/add_weight_sheet.dart';
import 'package:recovery_app/features/weight/ui/widgets/bmr_calculator_sheet.dart';
import 'package:recovery_app/features/weight/ui/widgets/weight_chart.dart';

class WeightScreen extends ConsumerWidget {
  const WeightScreen({super.key});

  Future<void> _openAddWeight(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return AddWeightSheet(
          onSave: (WeightEntry entry) =>
              ref.read(weightNotifierProvider.notifier).addEntry(entry),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<WeightEntry>> state =
        ref.watch(weightNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: state.when(
          data: (List<WeightEntry> entries) {
            final List<WeightEntry> sorted = <WeightEntry>[
              ...entries
            ]..sort((WeightEntry a, WeightEntry b) => b.date.compareTo(a.date));

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                  children: <Widget>[
                    Text(
                      'WEIGHT',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                letterSpacing: 4.0,
                                fontWeight: FontWeight.w400,
                              ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.calculate),
                        label: const Text('BMR Calculator'),
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => const BmrCalculatorSheet(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                    WeightChart(entries: entries),
                    const SizedBox(height: 24),
                    ...sorted.map((WeightEntry entry) {
                      final double? delta = ref
                          .read(weightNotifierProvider.notifier)
                          .deltaForEntry(entry);
                      final String deltaText = delta == null
                          ? '—'
                          : '${delta >= 0 ? '↑' : '↓'} ${delta.abs().toStringAsFixed(1)}';
                      return Dismissible(
                        key: ValueKey<int?>(entry.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) async {
                          final int? id = entry.id;
                          if (id != null) {
                            await ref
                                .read(weightNotifierProvider.notifier)
                                .deleteEntry(id);
                          }
                        },
                        background: Container(
                          color: Colors.red.shade300,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.weightKg.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat.yMMMd().format(entry.date),
                                    style: const TextStyle(
                                        color: Color(0xFF9E9E9E)),
                                  ),
                                ],
                              ),
                              Text(
                                deltaText,
                                style: const TextStyle(
                                    color: Color(0xFFBDBDBD), fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object _, StackTrace __) {
            return const Center(child: Text('Unable to load weight entries.'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        backgroundColor: const Color(0xFFEEEEEE),
        foregroundColor: const Color(0xFF424242),
        onPressed: () => _openAddWeight(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
