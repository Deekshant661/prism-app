import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../models/sector_allocation.dart';
import '../../utils/constants.dart';

class SectorPieChart extends StatelessWidget {
  final List<SectorAllocation> sectors;

  const SectorPieChart({super.key, required this.sectors});

  @override
  Widget build(BuildContext context) {
    if (sectors.isEmpty) return const SizedBox.shrink();

    final sorted = [...sectors]..sort((a, b) => b.allocationPct.compareTo(a.allocationPct));
    final topSectors = sorted.take(8).toList();

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: topSectors.asMap().entries.map((e) {
                final color = chartColors[e.key % chartColors.length];
                return PieChartSectionData(
                  value: e.value.allocationPct,
                  color: color,
                  radius: 50,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...topSectors.asMap().entries.map((e) {
          final color = chartColors[e.key % chartColors.length];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 12, height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.value.sectorName,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  '${e.value.allocationPct.toStringAsFixed(1)}%',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
