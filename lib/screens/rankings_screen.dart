import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/rankings_provider.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/cards/fund_list_tile.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/empty_state.dart';

class RankingsScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  const RankingsScreen({super.key, this.initialCategory});

  @override
  ConsumerState<RankingsScreen> createState() => _RankingsScreenState();
}

class _RankingsScreenState extends ConsumerState<RankingsScreen> {
  late String _selectedCategory;
  String _sortBy = 'composite_score';

  static const _sortOptions = {
    'composite_score': 'Score',
    '1y': '1Y Return',
    '3y': '3Y CAGR',
    '5y': '5Y CAGR',
  };

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? 'ALL';
  }

  @override
  Widget build(BuildContext context) {
    final params = RankingsParams(
      category: _selectedCategory == 'ALL' ? null : _selectedCategory,
      sortBy: _sortBy,
      limit: 100,
    );
    final rankingsAsync = ref.watch(rankingsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rankings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (_) => _sortOptions.entries
                .map((e) => PopupMenuItem(
                      value: e.key,
                      child: Row(
                        children: [
                          if (e.key == _sortBy)
                            const Icon(Icons.check, size: 16, color: AppColors.primary),
                          if (e.key == _sortBy) const SizedBox(width: 8),
                          Text(e.value),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: allCategories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(cat == 'ALL' ? 'All' : categoryLabel(cat)),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          // Rankings list
          Expanded(
            child: rankingsAsync.when(
              loading: () => LoadingShimmer.listTile(),
              error: (error, _) => ErrorStateWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(rankingsProvider),
              ),
              data: (rankings) {
                if (rankings.funds.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.leaderboard_outlined,
                    title: 'No ranked funds',
                    subtitle: 'Run calculations first from the web dashboard',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(rankingsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    itemCount: rankings.funds.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final fund = rankings.funds[index];
                      return FundListTile(
                        rank: fund.rank,
                        fundName: fund.fundName,
                        amc: fund.amc,
                        category: fund.category,
                        oneYearReturn: fund.oneYearReturn,
                        compositeScore: fund.compositeScore,
                        onTap: () => context.push('/fund/${fund.fundId}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
