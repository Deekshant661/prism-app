import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final int fundCount;
  final double? avgScore;
  final double? bestReturn;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.fundCount,
    this.avgScore,
    this.bestReturn,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);
    final icon = categoryIcon(category);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 20),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              categoryLabel(category),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$fundCount funds',
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (avgScore != null)
                  Text(
                    'Avg ${formatScore(avgScore)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                if (bestReturn != null)
                  Text(
                    'Best ${formatReturn(bestReturn)}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: bestReturn! >= 0 ? AppColors.positive : AppColors.negative,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
