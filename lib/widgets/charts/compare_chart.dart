import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/nav_point.dart';
import '../../utils/constants.dart';

class CompareChart extends StatelessWidget {
  final Map<String, List<NavPoint>> fundData; // fundName → navData
  final double height;

  const CompareChart({super.key, required this.fundData, this.height = 250});

  @override
  Widget build(BuildContext context) {
    if (fundData.isEmpty) return const SizedBox.shrink();

    // Normalise all series to 100 at their start
    final lines = <LineChartBarData>[];
    final entries = fundData.entries.toList();
    double maxVal = 110;
    double minVal = 90;

    for (int i = 0; i < entries.length; i++) {
      final data = [...entries[i].value]..sort((a, b) => a.date.compareTo(b.date));
      if (data.isEmpty) continue;

      final baseNav = data.first.navValue;
      if (baseNav == 0) continue;

      final spots = data.asMap().entries.map((e) {
        final normalised = (e.value.navValue / baseNav) * 100;
        if (normalised > maxVal) maxVal = normalised;
        if (normalised < minVal) minVal = normalised;
        return FlSpot(e.key.toDouble(), normalised);
      }).toList();

      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.2,
        color: chartColors[i % chartColors.length],
        barWidth: 2,
        dotData: const FlDotData(show: false),
      ));
    }

    return Column(
      children: [
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.border.withOpacity(0.5),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: minVal - 5,
              maxY: maxVal + 5,
              lineBarsData: lines,
              lineTouchData: const LineTouchData(handleBuiltInTouches: true),
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: entries.asMap().entries.map((e) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(
                    color: chartColors[e.key % chartColors.length],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  e.value.key,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
