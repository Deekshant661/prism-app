import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/nav_point.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class NavChart extends StatelessWidget {
  final List<NavPoint> data;
  final double height;

  const NavChart({super.key, required this.data, this.height = 220});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final sortedData = [...data]..sort((a, b) => a.date.compareTo(b.date));
    final isPositive = sortedData.length > 1
        ? sortedData.last.navValue >= sortedData.first.navValue
        : true;
    final lineColor = isPositive ? AppColors.positive : AppColors.negative;

    final spots = sortedData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.navValue);
    }).toList();

    final minY = sortedData.map((e) => e.navValue).reduce((a, b) => a < b ? a : b);
    final maxY = sortedData.map((e) => e.navValue).reduce((a, b) => a > b ? a : b);
    final yPadding = (maxY - minY) * 0.1;

    return SizedBox(
      height: height,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (maxY - minY) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withOpacity(0.5),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (sortedData.length / 5).ceilToDouble(),
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= sortedData.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      formatNavDate(sortedData[idx].date),
                      style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 52,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${value.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: minY - yPadding,
          maxY: maxY + yPadding,
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.textPrimary,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final idx = spot.x.toInt();
                  final point = idx >= 0 && idx < sortedData.length
                      ? sortedData[idx]
                      : null;
                  return LineTooltipItem(
                    point != null
                        ? '${formatFullDate(point.date)}\n₹${point.navValue.toStringAsFixed(2)}'
                        : '',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.2,
              color: lineColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lineColor.withOpacity(0.15), lineColor.withOpacity(0.0)],
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
