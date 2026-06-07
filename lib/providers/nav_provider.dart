import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/nav_api.dart';
import '../models/nav_point.dart';

final navApiProvider = Provider((ref) => NavApi());

class NavParams {
  final String fundId;
  final String? from;
  final String? to;

  const NavParams({required this.fundId, this.from, this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavParams &&
          fundId == other.fundId &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(fundId, from, to);
}

final fundNavProvider =
    FutureProvider.family<List<NavPoint>, NavParams>((ref, params) async {
  return ref.watch(navApiProvider).getFundNav(
        params.fundId,
        from: params.from,
        to: params.to,
      );
});

class SchemeNavParams {
  final String schemeId;
  final String? from;
  final String? to;

  const SchemeNavParams({required this.schemeId, this.from, this.to});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchemeNavParams &&
          schemeId == other.schemeId &&
          from == other.from &&
          to == other.to;

  @override
  int get hashCode => Object.hash(schemeId, from, to);
}

final schemeNavProvider =
    FutureProvider.family<List<NavPoint>, SchemeNavParams>((ref, params) async {
  return ref.watch(navApiProvider).getSchemeNav(
        params.schemeId,
        from: params.from,
        to: params.to,
      );
});
