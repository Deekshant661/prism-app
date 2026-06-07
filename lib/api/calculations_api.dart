import 'api_client.dart';

class CalculationsApi {
  Future<Map<String, dynamic>> runAll() async {
    final response = await api.post('/calculations/run-all');
    return response.data as Map<String, dynamic>;
  }
}
