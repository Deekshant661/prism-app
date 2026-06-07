import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final double? value;
  final bool isReturn;

  const MetricCard({
    super.key,
    required this.label,
    this.value,
    this.isReturn = true,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = isReturn ? formatReturn(value) : formatScore(value);
    final color = value == null
        ? AppColors.textMuted
        : isReturn
            ? (value! >= 0 ? AppColors.positive : AppColors.negative)
            : AppColors.textPrimary;

    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
