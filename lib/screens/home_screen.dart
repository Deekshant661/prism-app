import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/rankings_provider.dart';
import '../utils/constants.dart';
import '../widgets/cards/category_card.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/common/error_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch all rankings to compute per-category stats
    final rankingsAsync = ref.watch(rankingsProvider(const RankingsParams(limit: 200)));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent, AppColors.emerald],
                ),
              ),
              child: const Icon(Icons.diamond_outlined, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Prism'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: rankingsAsync.when(
        loading: () => GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: List.generate(7, (_) => LoadingShimmer.card(height: 160)),
        ),
        error: (error, _) => ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(rankingsProvider),
        ),
        data: (rankings) {
          // Compute per-category stats
          final categories = allCategories.where((c) => c != 'ALL').toList();
          final categoryStats = <String, _CategoryStats>{};

          for (final cat in categories) {
            final funds = rankings.funds.where((f) => f.category == cat).toList();
            if (funds.isEmpty) continue;
            final scores = funds
                .where((f) => f.compositeScore != null)
                .map((f) => f.compositeScore!)
                .toList();
            final returns = funds
                .where((f) => f.oneYearReturn != null)
                .map((f) => f.oneYearReturn!)
                .toList();

            categoryStats[cat] = _CategoryStats(
              count: funds.length,
              avgScore: scores.isNotEmpty
                  ? scores.reduce((a, b) => a + b) / scores.length
                  : null,
              bestReturn: returns.isNotEmpty
                  ? returns.reduce((a, b) => a > b ? a : b)
                  : null,
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(rankingsProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${rankings.funds.length} funds tracked',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.05,
                  children: categories
                      .where((c) => categoryStats.containsKey(c))
                      .map((cat) {
                    final stats = categoryStats[cat]!;
                    return CategoryCard(
                      category: cat,
                      fundCount: stats.count,
                      avgScore: stats.avgScore,
                      bestReturn: stats.bestReturn,
                      onTap: () => context.go('/rankings?category=$cat'),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CategoryStats {
  final int count;
  final double? avgScore;
  final double? bestReturn;
  const _CategoryStats({required this.count, this.avgScore, this.bestReturn});
}
