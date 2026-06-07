class NavPoint {
  final DateTime date;
  final double navValue;

  const NavPoint({required this.date, required this.navValue});

  factory NavPoint.fromJson(Map<String, dynamic> json) {
    return NavPoint(
      date: DateTime.parse(json['nav_date'] as String),
      navValue: (json['nav_value'] as num).toDouble(),
    );
  }
}
