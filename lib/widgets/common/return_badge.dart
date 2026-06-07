import 'package:flutter/material.dart';
import '../../utils/formatters.dart';

class ReturnBadge extends StatelessWidget {
  final double? value;
  final double fontSize;

  const ReturnBadge({super.key, this.value, this.fontSize = 13});

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text('—', style: TextStyle(fontSize: fontSize, color: Colors.grey)),
      );
    }
    final isPositive = value! >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPositive ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        formatReturn(value),
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: isPositive ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
        ),
      ),
    );
  }
}
