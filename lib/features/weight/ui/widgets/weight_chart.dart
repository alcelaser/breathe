import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:recovery_app/features/weight/data/models/weight_entry.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({
    super.key,
    required this.entries,
  });

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No weight entries yet')),
      );
    }

    final List<WeightEntry> chartEntries =
        entries.length > 12 ? entries.sublist(entries.length - 12) : entries;
    final List<double> values =
        chartEntries.map((WeightEntry item) => item.weightKg).toList();
    final double minY =
        values.reduce((double a, double b) => a < b ? a : b) - 2;
    final double maxY =
        values.reduce((double a, double b) => a > b ? a : b) + 2;

    return SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              isCurved: true,
              spots: chartEntries
                  .asMap()
                  .entries
                  .map((MapEntry<int, WeightEntry> entry) {
                return FlSpot(entry.key.toDouble(), entry.value.weightKg);
              }).toList(),
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
