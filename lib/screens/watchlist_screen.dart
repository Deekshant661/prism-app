import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/watchlist_provider.dart';
import '../providers/funds_provider.dart';
import '../utils/constants.dart';
import '../widgets/cards/fund_list_tile.dart';
import '../widgets/common/empty_state.dart';
import '../widgets/common/loading_shimmer.dart';

class WatchlistScreen extends ConsumerWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watchlistIds = ref.watch(watchlistProvider);
    final fundsAsync = ref.watch(fundListProvider);

    if (watchlistIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Watchlist')),
        body: const EmptyStateWidget(
          icon: Icons.bookmark_outline,
          title: 'No funds saved',
          subtitle: 'Tap the bookmark icon on any fund to save it here',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Watchlist (${watchlistIds.length})'),
      ),
      body: fundsAsync.when(
        loading: () => LoadingShimmer.listTile(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allFunds) {
          final watchlistFunds = allFunds
              .where((f) => watchlistIds.contains(f.id))
              .toList();

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: watchlistFunds.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final fund = watchlistFunds[index];
              return Dismissible(
                key: ValueKey(fund.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.negative.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: AppColors.negative),
                ),
                onDismissed: (_) {
                  ref.read(watchlistProvider.notifier).remove(fund.id);
                },
                child: FundListTile(
                  fundName: fund.name,
                  amc: fund.amc,
                  category: fund.category,
                  onTap: () => context.push('/fund/${fund.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
