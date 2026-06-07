import 'fund.dart';
import 'fund_metrics.dart';
import 'holding.dart';
import 'sector_allocation.dart';
import 'scheme.dart';

class FundDetail {
  final String id;
  final String name;
  final String category;
  final String? amc;
  final String? fundManager;
  final double? expenseRatio;
  final double? aumCr;
  final String? inceptionDate;
  final String? benchmarkIndex;
  final FundMetrics? metrics;
  final List<Holding> holdings;
  final List<SectorAllocation> sectorAllocations;
  final List<Scheme> schemes;

  const FundDetail({
    required this.id,
    required this.name,
    required this.category,
    this.amc,
    this.fundManager,
    this.expenseRatio,
    this.aumCr,
    this.inceptionDate,
    this.benchmarkIndex,
    this.metrics,
    this.holdings = const [],
    this.sectorAllocations = const [],
    this.schemes = const [],
  });

  factory FundDetail.fromJson(Map<String, dynamic> json) {
    return FundDetail(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      amc: json['amc'] as String?,
      fundManager: json['fund_manager'] as String?,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble(),
      aumCr: (json['aum_cr'] as num?)?.toDouble(),
      inceptionDate: json['inception_date'] as String?,
      benchmarkIndex: json['benchmark_index'] as String?,
      metrics: json['metrics'] != null
          ? FundMetrics.fromJson(json['metrics'] as Map<String, dynamic>)
          : null,
      holdings: (json['holdings'] as List?)
              ?.map((h) => Holding.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      sectorAllocations: (json['sector_allocations'] as List?)
              ?.map((s) => SectorAllocation.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
      schemes: (json['schemes'] as List?)
              ?.map((s) => Scheme.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
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

  /// Get the primary scheme (Direct Growth)
  Scheme? get primaryScheme =>
      schemes.where((s) => s.isPrimary).firstOrNull;

  /// Convert to a simpler Fund object
  Fund toFund() => Fund(
        id: id,
        name: name,
        category: category,
        amc: amc,
        fundManager: fundManager,
        expenseRatio: expenseRatio,
        aumCr: aumCr,
        inceptionDate: inceptionDate,
        benchmarkIndex: benchmarkIndex,
      );
}
