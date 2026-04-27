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

    // Using all entries instead of clipping to the last 12
    final List<WeightEntry> chartEntries = orderedEntries;

    final DateTime firstDate = chartEntries.first.date;
    final List<FlSpot> spots = chartEntries.map((WeightEntry entry) {
      final double daysSinceFirst =
          entry.date.difference(firstDate).inMinutes / Duration.minutesPerDay;
      return FlSpot(daysSinceFirst, entry.weightKg);
    }).toList();

    final double minX = spots.first.x;
    final double maxX = spots.last.x == minX ? minX + 1 : spots.last.x;
    final List<double> values =
        chartEntries.map((WeightEntry item) => item.weightKg).toList();
    final double minY =
        values.reduce((double a, double b) => a < b ? a : b) - 2;
    final double maxY =
        values.reduce((double a, double b) => a > b ? a : b) + 2;

    List<FlSpot> trendSpots = [];
    if (spots.length > 1) {
      final int n = spots.length;
      double sumX = 0;
      double sumY = 0;
      double sumXY = 0;
      double sumX2 = 0;

      for (final spot in spots) {
        sumX += spot.x;
        sumY += spot.y;
        sumXY += spot.x * spot.y;
        sumX2 += spot.x * spot.x;
      }

      final double denominator = (n * sumX2) - (sumX * sumX);
      if (denominator != 0) {
        final double m = ((n * sumXY) - (sumX * sumY)) / denominator;
        final double b = (sumY - (m * sumX)) / n;

        trendSpots = [
          FlSpot(minX, (m * minX) + b),
          FlSpot(maxX, (m * maxX) + b),
        ];
      }
    }

    return SizedBox(
      height: 280,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: LineChart(
          LineChartData(
            minX: minX,
            maxX: maxX,
            minY: minY,
            maxY: maxY,
            lineBarsData: <LineChartBarData>[
              LineChartBarData(
                isCurved: true,
                curveSmoothness: 0.35,
                preventCurveOverShooting: true,
                spots: spots,
              ),
              if (trendSpots.isNotEmpty)
                LineChartBarData(
                  isCurved: false,
                  spots: trendSpots,
                  color: Colors.grey.withOpacity(0.5),
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
            ],
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                axisNameSize: 24,
                axisNameWidget: const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _calculateBottomInterval(maxX - minX),
                  getTitlesWidget: (double value, TitleMeta meta) {
                    final DateTime date = firstDate.add(
                      Duration(days: value.toInt()),
                    );
                    return Transform.translate(
                      offset: const Offset(0, 10),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    );
                  },
                  reservedSize: 32,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameSize: 24,
                axisNameWidget: const Text(
                  'Weight (kg)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: _calculateLeftInterval(maxY - minY),
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Text(
                      value.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.right,
                    );
                  },
                  reservedSize: 40,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: const Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
                left: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            gridData: const FlGridData(show: false),
          ),
        ),
      ),
    );
  }

  double _calculateBottomInterval(double range) {
    if (range <= 7) return 1;
    if (range <= 14) return 2;
    if (range <= 30) return 5;
    return 10;
  }

  double _calculateLeftInterval(double range) {
    if (range <= 5) return 1;
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    return 10;
  }
}
