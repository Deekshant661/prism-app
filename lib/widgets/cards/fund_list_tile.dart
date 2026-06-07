import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../common/category_badge.dart';
import '../common/return_badge.dart';

class FundListTile extends StatelessWidget {
  final int? rank;
  final String fundName;
  final String? amc;
  final String category;
  final double? oneYearReturn;
  final double? compositeScore;
  final VoidCallback? onTap;

  const FundListTile({
    super.key,
    this.rank,
    required this.fundName,
    this.amc,
    required this.category,
    this.oneYearReturn,
    this.compositeScore,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            // Rank circle
            if (rank != null)
              Container(
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '#$rank',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            // Fund info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fundName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (amc != null) ...[
                        Flexible(
                          child: Text(
                            amc!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      CategoryBadge(category: category),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Right side: return + score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReturnBadge(value: oneYearReturn, fontSize: 12),
                if (compositeScore != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${formatScore(compositeScore)}/100',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
