import 'api_client.dart';
import '../models/nav_point.dart';

class NavApi {
  Future<List<NavPoint>> getFundNav(String fundId, {String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final response = await api.get('/funds/$fundId/nav', queryParameters: params);
    final list = response.data as List;
    return list.map((j) => NavPoint.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<NavPoint>> getSchemeNav(String schemeId, {String? from, String? to}) async {
    final params = <String, dynamic>{};
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    final response = await api.get('/schemes/$schemeId/nav', queryParameters: params);
    final list = response.data as List;
    return list.map((j) => NavPoint.fromJson(j as Map<String, dynamic>)).toList();
  }
}
