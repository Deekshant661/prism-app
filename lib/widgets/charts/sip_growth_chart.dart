import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/sip_result.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class SipGrowthChart extends StatelessWidget {
  final SipResult result;
  final double height;

  const SipGrowthChart({super.key, required this.result, this.height = 220});

  @override
  Widget build(BuildContext context) {
    if (result.yearlyGrowth.isEmpty) return const SizedBox.shrink();

    final investedSpots = result.yearlyGrowth
        .map((p) => FlSpot(p.year.toDouble(), p.invested))
        .toList();
    final corpusSpots = result.yearlyGrowth
        .map((p) => FlSpot(p.year.toDouble(), p.corpus))
        .toList();

    final maxVal = result.yearlyGrowth.last.corpus;

    return SizedBox(
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
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (result.years / 5).ceilToDouble().clamp(1, 10),
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      '${value.toInt()}Y',
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
                    formatINRShort(value),
                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: maxVal * 1.1,
          lineBarsData: [
            // Corpus (green)
            LineChartBarData(
              spots: corpusSpots,
              isCurved: true,
              color: AppColors.emerald,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.emerald.withOpacity(0.15), AppColors.emerald.withOpacity(0.0)],
                ),
              ),
            ),
            // Invested (blue)
            LineChartBarData(
              spots: investedSpots,
              isCurved: false,
              color: AppColors.primary,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.0)],
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.textPrimary,
              tooltipRoundedRadius: 8,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final label = spot.barIndex == 0 ? 'Corpus' : 'Invested';
                  return LineTooltipItem(
                    '$label\n${formatINRShort(spot.y)}',
                    const TextStyle(color: Colors.white, fontSize: 11),
                  );
                }).toList();
              },
            ),
          ),
        ),
        duration: const Duration(milliseconds: 400),
      ),
    );
  }
}
