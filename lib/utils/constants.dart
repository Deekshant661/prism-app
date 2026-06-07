import 'package:flutter/material.dart';

/// App-wide color constants
class AppColors {
  static const primary = Color(0xFF1E40AF);       // Deep blue
  static const primaryLight = Color(0xFF3B82F6);
  static const accent = Color(0xFF7C3AED);         // Purple
  static const emerald = Color(0xFF059669);         // Emerald green
  static const positive = Color(0xFF16A34A);
  static const negative = Color(0xFFDC2626);
  static const surface = Color(0xFFF8FAFC);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFF94A3B8);
  static const border = Color(0xFFE2E8F0);
  static const shimmerBase = Color(0xFFE2E8F0);
  static const shimmerHighlight = Color(0xFFF1F5F9);
}

/// Category colors
Color categoryColor(String category) {
  switch (category) {
    case 'LARGE_CAP': return const Color(0xFF2563EB);
    case 'MID_CAP': return const Color(0xFF7C3AED);
    case 'SMALL_CAP': return const Color(0xFFEA580C);
    case 'FLEXI_CAP': return const Color(0xFF0D9488);
    case 'ELSS': return const Color(0xFF16A34A);
    case 'INDEX': return const Color(0xFF6B7280);
    case 'DEBT': return const Color(0xFFCA8A04);
    case 'BALANCED_ADVANTAGE': return const Color(0xFF059669);
    default: return const Color(0xFF6B7280);
  }
}

/// Category icon
IconData categoryIcon(String category) {
  switch (category) {
    case 'LARGE_CAP': return Icons.castle_outlined;
    case 'MID_CAP': return Icons.trending_up;
    case 'SMALL_CAP': return Icons.rocket_launch_outlined;
    case 'FLEXI_CAP': return Icons.dashboard_outlined;
    case 'ELSS': return Icons.savings_outlined;
    case 'INDEX': return Icons.bar_chart_rounded;
    case 'DEBT': return Icons.shield_outlined;
    case 'BALANCED_ADVANTAGE': return Icons.balance_outlined;
    default: return Icons.auto_awesome;
  }
}

/// All categories in display order
const allCategories = [
  'ALL',
  'LARGE_CAP',
  'MID_CAP',
  'SMALL_CAP',
  'FLEXI_CAP',
  'ELSS',
  'INDEX',
  'BALANCED_ADVANTAGE',
];

/// Chart color palette (for sector pie, comparison lines)
const chartColors = [
  Color(0xFF2563EB),
  Color(0xFF7C3AED),
  Color(0xFFEA580C),
  Color(0xFF059669),
  Color(0xFFDC2626),
  Color(0xFF0D9488),
  Color(0xFFCA8A04),
  Color(0xFFDB2777),
  Color(0xFF4F46E5),
  Color(0xFF0284C7),
];
