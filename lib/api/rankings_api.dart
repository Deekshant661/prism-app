import 'api_client.dart';
import '../models/ranking.dart';

class RankingsApi {
  Future<RankingsResponse> getRankings({
    String? category,
    String sortBy = 'composite_score',
    String order = 'desc',
    int limit = 50,
    int offset = 0,
  }) async {
    final params = <String, dynamic>{
      'sort_by': sortBy,
      'order': order,
      'limit': limit,
      'offset': offset,
    };
    if (category != null && category != 'ALL') {
      params['category'] = category;
    }
    final response = await api.get('/rankings', queryParameters: params);
    return RankingsResponse.fromJson(response.data as Map<String, dynamic>);
  }
}
