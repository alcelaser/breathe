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

    final List<WeightEntry> orderedEntries = <WeightEntry>[...entries]
      ..sort((WeightEntry a, WeightEntry b) => a.date.compareTo(b.date));
    final List<WeightEntry> chartEntries =
        orderedEntries.length > 12
            ? orderedEntries.sublist(orderedEntries.length - 12)
            : orderedEntries;
    final DateTime firstDate = chartEntries.first.date;
    final List<FlSpot> spots = chartEntries.map((WeightEntry entry) {
      final double daysSinceFirst =
          entry.date.difference(firstDate).inMinutes / Duration.minutesPerDay;
      return FlSpot(daysSinceFirst, entry.weightKg);
    }).toList();

    final double minX = spots.first.x;
    final double maxX =
        spots.last.x == minX ? minX + 1 : spots.last.x;
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
          minX: minX,
          maxX: maxX,
          minY: minY,
          maxY: maxY,
          lineBarsData: <LineChartBarData>[
            LineChartBarData(
              isCurved: true,
              spots: spots,
            ),
          ],
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }
}
