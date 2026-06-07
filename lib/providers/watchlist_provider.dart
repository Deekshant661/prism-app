import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _watchlistKey = 'mf_watchlist';

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_watchlistKey) ?? [];
    state = list;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchlistKey, state);
  }

  Future<void> add(String fundId) async {
    if (!state.contains(fundId)) {
      state = [...state, fundId];
      await _save();
    }
  }

  Future<void> remove(String fundId) async {
    state = state.where((id) => id != fundId).toList();
    await _save();
  }

  Future<void> toggle(String fundId) async {
    if (state.contains(fundId)) {
      await remove(fundId);
    } else {
      await add(fundId);
    }
  }

  bool contains(String fundId) => state.contains(fundId);
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<String>>(
  (ref) => WatchlistNotifier(),
);
