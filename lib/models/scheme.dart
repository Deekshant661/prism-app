class Scheme {
  final String schemeId;
  final String schemeCode;
  final String planType;
  final String optionType;
  final double? expenseRatio;
  final bool isPrimary;

  const Scheme({
    required this.schemeId,
    required this.schemeCode,
    required this.planType,
    required this.optionType,
    this.expenseRatio,
    this.isPrimary = false,
  });

  factory Scheme.fromJson(Map<String, dynamic> json) {
    return Scheme(
      schemeId: json['scheme_id'] as String,
      schemeCode: json['scheme_code'] as String,
      planType: json['plan_type'] as String,
      optionType: json['option_type'] as String,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble(),
      isPrimary: json['is_primary'] as bool? ?? false,
    );
  }
}
