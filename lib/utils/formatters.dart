import 'package:intl/intl.dart';

String formatReturn(double? value) {
  if (value == null) return '—';
  final prefix = value > 0 ? '+' : '';
  return '$prefix${value.toStringAsFixed(1)}%';
}

String formatINR(double value) {
  final format = NumberFormat('#,##,###', 'en_IN');
  return '₹${format.format(value.round())}';
}

String formatINRShort(double value) {
  if (value.abs() >= 10000000) {
    return '₹${(value / 10000000).toStringAsFixed(1)}Cr';
  } else if (value.abs() >= 100000) {
    return '₹${(value / 100000).toStringAsFixed(1)}L';
  } else if (value.abs() >= 1000) {
    return '₹${(value / 1000).toStringAsFixed(1)}K';
  }
  return '₹${value.toStringAsFixed(0)}';
}

String formatAUM(double? value) {
  if (value == null) return '—';
  if (value >= 10000) {
    return '₹${(value / 10000).toStringAsFixed(1)}L Cr';
  }
  return '₹${value.toStringAsFixed(0)} Cr';
}

String formatNavDate(DateTime date) {
  return DateFormat("MMM ''yy").format(date);
}

String formatFullDate(DateTime date) {
  return DateFormat('dd MMM yyyy').format(date);
}

String formatScore(double? value) {
  if (value == null) return '—';
  return value.toStringAsFixed(1);
}

String formatExpenseRatio(double? value) {
  if (value == null) return '—';
  return '${value.toStringAsFixed(2)}%';
}

String categoryLabel(String category) {
  switch (category) {
    case 'LARGE_CAP': return 'Large Cap';
    case 'MID_CAP': return 'Mid Cap';
    case 'SMALL_CAP': return 'Small Cap';
    case 'FLEXI_CAP': return 'Flexi Cap';
    case 'ELSS': return 'ELSS';
    case 'INDEX': return 'Index';
    case 'DEBT': return 'Debt';
    case 'BALANCED_ADVANTAGE': return 'Balanced Advantage';
    default: return category;
  }
}
