import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/funds_provider.dart';
import '../utils/constants.dart';
import '../widgets/common/category_badge.dart';

const _recentKey = 'recent_searches';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  List<String> _recents = [];

  @override
  void initState() {
    super.initState();
    _loadRecents();
  }

  Future<void> _loadRecents() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _recents = prefs.getStringList(_recentKey) ?? []);
  }

  Future<void> _saveRecent(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _recents.remove(query);
    _recents.insert(0, query);
    if (_recents.length > 10) _recents = _recents.take(10).toList();
    await prefs.setStringList(_recentKey, _recents);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fundsAsync = ref.watch(fundListProvider);
    final query = _controller.text.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search funds...',
            border: InputBorder.none,
          ),
          onChanged: (_) => setState(() {}),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _controller.clear();
                setState(() {});
              },
            ),
        ],
      ),
      body: fundsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (funds) {
          if (query.length < 2) {
            // Show recent searches
            if (_recents.isEmpty) {
              return const Center(
                child: Text(
                  'Type at least 2 characters to search',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }
            return ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Recent Searches',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                ..._recents.map((r) => ListTile(
                      leading: const Icon(Icons.history, size: 20),
                      title: Text(r),
                      dense: true,
                      onTap: () {
                        _controller.text = r;
                        setState(() {});
                      },
                    )),
              ],
            );
          }

          final filtered = funds.where((f) {
            return f.name.toLowerCase().contains(query) ||
                (f.amc?.toLowerCase().contains(query) ?? false);
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Text(
                'No funds matching "$query"',
                style: const TextStyle(color: AppColors.textMuted),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final fund = filtered[index];
              return ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white,
                leading: CategoryBadge(category: fund.category),
                title: Text(
                  fund.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  fund.amc ?? '',
                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                onTap: () {
                  _saveRecent(fund.name);
                  context.push('/fund/${fund.id}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
