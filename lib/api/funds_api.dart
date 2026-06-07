import 'api_client.dart';
import '../models/fund.dart';
import '../models/fund_detail.dart';

class FundsApi {
  Future<List<Fund>> listFunds() async {
    final response = await api.get('/funds');
    final list = response.data as List;
    return list.map((j) => Fund.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<FundDetail> getFund(String id) async {
    final response = await api.get('/funds/$id');
    return FundDetail.fromJson(response.data as Map<String, dynamic>);
  }
}
