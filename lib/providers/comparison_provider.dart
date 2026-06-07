import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparisonNotifier extends StateNotifier<List<String>> {
  ComparisonNotifier() : super([]);

  void add(String fundId) {
    if (!state.contains(fundId) && state.length < 4) {
      state = [...state, fundId];
    }
  }

  void remove(String fundId) {
    state = state.where((id) => id != fundId).toList();
  }

  void clear() {
    state = [];
  }

  bool contains(String fundId) => state.contains(fundId);
  bool get isFull => state.length >= 4;
}

final comparisonProvider =
    StateNotifierProvider<ComparisonNotifier, List<String>>(
  (ref) => ComparisonNotifier(),
);
