class SectorAllocation {
  final String? id;
  final String sectorName;
  final double allocationPct;
  final String? factsheetDate;

  const SectorAllocation({
    this.id,
    required this.sectorName,
    required this.allocationPct,
    this.factsheetDate,
  });

  factory SectorAllocation.fromJson(Map<String, dynamic> json) {
    return SectorAllocation(
      id: json['id'] as String?,
      sectorName: json['sector_name'] as String,
      allocationPct: (json['allocation_pct'] as num).toDouble(),
      factsheetDate: json['factsheet_date'] as String?,
    );
  }
}
