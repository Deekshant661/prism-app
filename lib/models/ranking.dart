class RankedFund {
  final int? rank;
  final int? overallRank;
  final String fundId;
  final String fundName;
  final String? amc;
  final String category;
  final String? fundType;
  final String? fundAge;
  final double? expenseRatio;
  final double? aumCr;
  final double? oneYearReturn;
  final int? oneYearRank;
  final double? threeYearCagr;
  final double? fiveYearCagr;
  final int? fiveYearRank;
  final double? tenYearCagr;
  final int? tenYearRank;
  final double? consistencyScore;
  final double? downsideProtectionScore;
  final double? maxDrawdown;
  final double? sharpeRatio;
  final double? sortinoRatio;
  final double? annualisedVolatility;
  final double? compositeScore;
  final bool rankingEligible;
  final String? dataSufficiency;

  const RankedFund({
    this.rank,
    this.overallRank,
    required this.fundId,
    required this.fundName,
    this.amc,
    required this.category,
    this.fundType,
    this.fundAge,
    this.expenseRatio,
    this.aumCr,
    this.oneYearReturn,
    this.oneYearRank,
    this.threeYearCagr,
    this.fiveYearCagr,
    this.fiveYearRank,
    this.tenYearCagr,
    this.tenYearRank,
    this.consistencyScore,
    this.downsideProtectionScore,
    this.maxDrawdown,
    this.sharpeRatio,
    this.sortinoRatio,
    this.annualisedVolatility,
    this.compositeScore,
    this.rankingEligible = true,
    this.dataSufficiency,
  });

  factory RankedFund.fromJson(Map<String, dynamic> json) {
    return RankedFund(
      rank: json['rank'] as int?,
      overallRank: json['overall_rank'] as int?,
      fundId: json['fund_id'] as String,
      fundName: json['fund_name'] as String,
      amc: json['amc'] as String?,
      category: json['category'] as String,
      fundType: json['fund_type'] as String?,
      fundAge: json['fund_age'] as String?,
      expenseRatio: (json['expense_ratio'] as num?)?.toDouble(),
      aumCr: (json['aum_cr'] as num?)?.toDouble(),
      oneYearReturn: (json['one_year_return'] as num?)?.toDouble(),
      oneYearRank: json['one_year_rank'] as int?,
      threeYearCagr: (json['three_year_cagr'] as num?)?.toDouble(),
      fiveYearCagr: (json['five_year_cagr'] as num?)?.toDouble(),
      fiveYearRank: json['five_year_rank'] as int?,
      tenYearCagr: (json['ten_year_cagr'] as num?)?.toDouble(),
      tenYearRank: json['ten_year_rank'] as int?,
      consistencyScore: (json['consistency_score'] as num?)?.toDouble(),
      downsideProtectionScore: (json['downside_protection_score'] as num?)?.toDouble(),
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble(),
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble(),
      sortinoRatio: (json['sortino_ratio'] as num?)?.toDouble(),
      annualisedVolatility: (json['annualised_volatility'] as num?)?.toDouble(),
      compositeScore: (json['composite_score'] as num?)?.toDouble(),
      rankingEligible: json['ranking_eligible'] as bool? ?? true,
      dataSufficiency: json['data_sufficiency'] as String?,
    );
  }
}

class RankingsResponse {
  final String category;
  final int total;
  final String generatedAt;
  final List<RankedFund> funds;

  const RankingsResponse({
    required this.category,
    required this.total,
    required this.generatedAt,
    required this.funds,
  });

  factory RankingsResponse.fromJson(Map<String, dynamic> json) {
    return RankingsResponse(
      category: json['category'] as String,
      total: json['total'] as int,
      generatedAt: json['generated_at'] as String,
      funds: (json['funds'] as List)
          .map((f) => RankedFund.fromJson(f as Map<String, dynamic>))
          .toList(),
    );
  }
}
