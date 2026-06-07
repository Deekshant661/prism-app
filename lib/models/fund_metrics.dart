class FundMetrics {
  final double? oneMonthReturn;
  final double? threeMonthReturn;
  final double? sixMonthReturn;
  final double? oneYearReturn;
  final double? threeYearCagr;
  final double? fiveYearCagr;
  final double? tenYearCagr;
  final double? consistencyScore;
  final double? downsideProtectionScore;
  final double? maxDrawdown;
  final double? sharpeRatio;
  final double? sortinoRatio;
  final double? annualisedVolatility;
  final double? rolling1yMin;
  final double? rolling1yMax;
  final double? rolling1yMean;
  final double? rolling1yStd;
  final double? compositeScore;
  final int? rankWithinCategory;
  final int? oneYearRank;
  final int? fiveYearRank;
  final int? tenYearRank;
  final int? fundAgeDays;
  final double? fundAgeYears;
  final bool? rankingEligible;
  final String? ineligibilityReason;
  final String? dataSufficiency;

  const FundMetrics({
    this.oneMonthReturn,
    this.threeMonthReturn,
    this.sixMonthReturn,
    this.oneYearReturn,
    this.threeYearCagr,
    this.fiveYearCagr,
    this.tenYearCagr,
    this.consistencyScore,
    this.downsideProtectionScore,
    this.maxDrawdown,
    this.sharpeRatio,
    this.sortinoRatio,
    this.annualisedVolatility,
    this.rolling1yMin,
    this.rolling1yMax,
    this.rolling1yMean,
    this.rolling1yStd,
    this.compositeScore,
    this.rankWithinCategory,
    this.oneYearRank,
    this.fiveYearRank,
    this.tenYearRank,
    this.fundAgeDays,
    this.fundAgeYears,
    this.rankingEligible,
    this.ineligibilityReason,
    this.dataSufficiency,
  });

  factory FundMetrics.fromJson(Map<String, dynamic> json) {
    return FundMetrics(
      oneMonthReturn: (json['one_month_return'] as num?)?.toDouble(),
      threeMonthReturn: (json['three_month_return'] as num?)?.toDouble(),
      sixMonthReturn: (json['six_month_return'] as num?)?.toDouble(),
      oneYearReturn: (json['one_year_return'] as num?)?.toDouble(),
      threeYearCagr: (json['three_year_cagr'] as num?)?.toDouble(),
      fiveYearCagr: (json['five_year_cagr'] as num?)?.toDouble(),
      tenYearCagr: (json['ten_year_cagr'] as num?)?.toDouble(),
      consistencyScore: (json['consistency_score'] as num?)?.toDouble(),
      downsideProtectionScore: (json['downside_protection_score'] as num?)?.toDouble(),
      maxDrawdown: (json['max_drawdown'] as num?)?.toDouble(),
      sharpeRatio: (json['sharpe_ratio'] as num?)?.toDouble(),
      sortinoRatio: (json['sortino_ratio'] as num?)?.toDouble(),
      annualisedVolatility: (json['annualised_volatility'] as num?)?.toDouble(),
      rolling1yMin: (json['rolling_1y_min'] as num?)?.toDouble(),
      rolling1yMax: (json['rolling_1y_max'] as num?)?.toDouble(),
      rolling1yMean: (json['rolling_1y_mean'] as num?)?.toDouble(),
      rolling1yStd: (json['rolling_1y_std'] as num?)?.toDouble(),
      compositeScore: (json['composite_score'] as num?)?.toDouble(),
      rankWithinCategory: json['rank_within_category'] as int?,
      oneYearRank: json['one_year_rank'] as int?,
      fiveYearRank: json['five_year_rank'] as int?,
      tenYearRank: json['ten_year_rank'] as int?,
      fundAgeDays: json['fund_age_days'] as int?,
      fundAgeYears: (json['fund_age_years'] as num?)?.toDouble(),
      rankingEligible: json['ranking_eligible'] as bool?,
      ineligibilityReason: json['ineligibility_reason'] as String?,
      dataSufficiency: json['data_sufficiency'] as String?,
    );
  }
}
