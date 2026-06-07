class Fund {
  final String id;
  final String name;
  final String category;
  final String? amc;
  final String? fundManager;
  final double? expenseRatio;
  final double? aumCr;
  final String? inceptionDate;
  final String? benchmarkIndex;

  const Fund({
    required this.id,
    required this.name,
    required this.category,
    this.amc,
    this.fundManager,
    this.expenseRatio,
    this.aumCr,
    this.inceptionDate,
    this.benchmarkIndex,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      amc: json['amc'] as String?,
      fundManager: json['fund_manager'] as String?,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble(),
      aumCr: (json['aum_cr'] as num?)?.toDouble(),
      inceptionDate: json['inception_date'] as String?,
      benchmarkIndex: json['benchmark_index'] as String?,
    );
  }

  String get fundType {
    switch (category) {
      case 'LARGE_CAP':
      case 'MID_CAP':
      case 'SMALL_CAP':
      case 'FLEXI_CAP':
        return 'Equity';
      case 'ELSS':
        return 'Tax Saving (ELSS)';
      case 'INDEX':
        return 'Index';
      case 'DEBT':
        return 'Debt';
      case 'BALANCED_ADVANTAGE':
        return 'Hybrid';
      default:
        return category;
    }
  }
}
