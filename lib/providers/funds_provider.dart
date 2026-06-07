import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/funds_api.dart';
import '../models/fund.dart';
import '../models/fund_detail.dart';

final fundsApiProvider = Provider((ref) => FundsApi());

final fundListProvider = FutureProvider<List<Fund>>((ref) async {
  return ref.watch(fundsApiProvider).listFunds();
});

final fundDetailProvider =
    FutureProvider.family<FundDetail, String>((ref, fundId) async {
  return ref.watch(fundsApiProvider).getFund(fundId);
});
