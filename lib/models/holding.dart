class Holding {
  final String? id;
  final String companyName;
  final double allocationPct;
  final String? factsheetDate;

  const Holding({
    this.id,
    required this.companyName,
    required this.allocationPct,
    this.factsheetDate,
  });

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      id: json['id'] as String?,
      companyName: json['company_name'] as String,
      allocationPct: (json['allocation_pct'] as num).toDouble(),
      factsheetDate: json['factsheet_date'] as String?,
    );
  }
}
