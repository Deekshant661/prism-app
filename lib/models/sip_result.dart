class SipResult {
  final double monthlyAmount;
  final int years;
  final double expectedReturn;
  final double totalInvested;
  final double expectedValue;
  final double gains;
  final List<SipYearPoint> yearlyGrowth;

  const SipResult({
    required this.monthlyAmount,
    required this.years,
    required this.expectedReturn,
    required this.totalInvested,
    required this.expectedValue,
    required this.gains,
    required this.yearlyGrowth,
  });

  factory SipResult.calculate({
    required double monthlyAmount,
    required int years,
    required double annualReturn,
  }) {
    final monthlyRate = annualReturn / 100 / 12;
    final totalMonths = years * 12;
    final totalInvested = monthlyAmount * totalMonths;

    double corpus = 0;
    final yearlyGrowth = <SipYearPoint>[];

    for (int month = 1; month <= totalMonths; month++) {
      corpus = (corpus + monthlyAmount) * (1 + monthlyRate);
      if (month % 12 == 0) {
        yearlyGrowth.add(SipYearPoint(
          year: month ~/ 12,
          invested: monthlyAmount * month,
          corpus: corpus,
        ));
      }
    }

    return SipResult(
      monthlyAmount: monthlyAmount,
      years: years,
      expectedReturn: annualReturn,
      totalInvested: totalInvested,
      expectedValue: corpus,
      gains: corpus - totalInvested,
      yearlyGrowth: yearlyGrowth,
    );
  }
}

class SipYearPoint {
  final int year;
  final double invested;
  final double corpus;

  const SipYearPoint({
    required this.year,
    required this.invested,
    required this.corpus,
  });
}
