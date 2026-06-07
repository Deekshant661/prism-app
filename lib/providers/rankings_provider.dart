import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/rankings_api.dart';
import '../models/ranking.dart';

final rankingsApiProvider = Provider((ref) => RankingsApi());

/// Parameters for rankings query
class RankingsParams {
  final String? category;
  final String sortBy;
  final String order;
  final int limit;
  final int offset;

  const RankingsParams({
    this.category,
    this.sortBy = 'composite_score',
    this.order = 'desc',
    this.limit = 50,
    this.offset = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RankingsParams &&
          category == other.category &&
          sortBy == other.sortBy &&
          order == other.order &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode =>
      Object.hash(category, sortBy, order, limit, offset);
}

final rankingsProvider =
    FutureProvider.family<RankingsResponse, RankingsParams>((ref, params) async {
  return ref.watch(rankingsApiProvider).getRankings(
        category: params.category,
        sortBy: params.sortBy,
        order: params.order,
        limit: params.limit,
        offset: params.offset,
      );
});
