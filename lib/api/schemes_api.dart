import 'api_client.dart';
import '../models/scheme.dart';

class SchemesApi {
  Future<List<Scheme>> getFundSchemes(String fundId) async {
    final response = await api.get('/schemes/$fundId');
    final list = response.data as List;
    return list.map((j) => Scheme.fromJson(j as Map<String, dynamic>)).toList();
  }
}
