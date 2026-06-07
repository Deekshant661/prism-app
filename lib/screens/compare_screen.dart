import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/funds_provider.dart';
import '../providers/nav_provider.dart';
import '../providers/comparison_provider.dart';
import '../models/fund.dart';
import '../models/nav_point.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/charts/compare_chart.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/common/empty_state.dart';

class CompareScreen extends ConsumerStatefulWidget {
  const CompareScreen({super.key});

  @override
  ConsumerState<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends ConsumerState<CompareScreen> {
  final _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIds = ref.watch(comparisonProvider);
    final fundsAsync = ref.watch(fundListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Funds'),
        actions: [
          if (selectedIds.isNotEmpty)
            TextButton(
              onPressed: () => ref.read(comparisonProvider.notifier).clear(),
              child: const Text('Clear', style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: fundsAsync.when(
        loading: () => LoadingShimmer.listTile(count: 4),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (allFunds) {
          final selectedFunds =
              allFunds.where((f) => selectedIds.contains(f.id)).toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // Search / Add fund
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Selected chips
                    if (selectedFunds.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedFunds.map((f) {
                          return Chip(
                            label: Text(f.name, style: const TextStyle(fontSize: 12)),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () =>
                                ref.read(comparisonProvider.notifier).remove(f.id),
                            backgroundColor: AppColors.primary.withOpacity(0.08),
                            side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
                          );
                        }).toList(),
                      ),
                    const SizedBox(height: 12),
                    if (!ref.read(comparisonProvider.notifier).isFull)
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search to add fund (max 4)...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          isDense: true,
                        ),
                        onChanged: (_) => setState(() => _showSearch = true),
                      ),
                    // Search results dropdown
                    if (_showSearch && _searchController.text.length >= 2)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 200),
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          children: allFunds
                              .where((f) =>
                                  f.name
                                      .toLowerCase()
                                      .contains(_searchController.text.toLowerCase()) &&
                                  !selectedIds.contains(f.id))
                              .take(8)
                              .map((f) => ListTile(
                                    dense: true,
                                    title: Text(f.name, style: const TextStyle(fontSize: 13)),
                                    subtitle: Text(categoryLabel(f.category),
                                        style: const TextStyle(fontSize: 11)),
                                    onTap: () {
                                      ref.read(comparisonProvider.notifier).add(f.id);
                                      _searchController.clear();
                                      setState(() => _showSearch = false);
                                    },
                                  ))
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),

              if (selectedFunds.length < 2)
                const EmptyStateWidget(
                  icon: Icons.compare_arrows,
                  title: 'Select at least 2 funds',
                  subtitle: 'Search and add up to 4 funds to compare',
                ),

              if (selectedFunds.length >= 2) ...[
                // Comparison table
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _ComparisonTable(fundIds: selectedIds),
                ),
                const SizedBox(height: 16),
                // NAV overlay chart
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NAV Comparison (Normalised to 100)',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _CompareNavChart(fundIds: selectedIds, allFunds: allFunds),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ComparisonTable extends ConsumerWidget {
  final List<String> fundIds;
  const _ComparisonTable({required this.fundIds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text('Metrics', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ...fundIds.map((id) {
              final detailAsync = ref.watch(fundDetailProvider(id));
              return detailAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(12),
                  child: LinearProgressIndicator(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Error loading fund', style: TextStyle(color: AppColors.negative)),
                ),
                data: (fund) {
                  final m = fund.metrics;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 140,
                          child: Text(fund.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                        _Cell(formatReturn(m?.oneYearReturn)),
                        _Cell(formatReturn(m?.threeYearCagr)),
                        _Cell(formatReturn(m?.fiveYearCagr)),
                        _Cell(formatScore(m?.compositeScore)),
                        _Cell(formatScore(m?.sharpeRatio)),
                      ],
                    ),
                  );
                },
              );
            }),
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  const SizedBox(width: 140),
                  _HeaderCell('1Y'),
                  _HeaderCell('3Y'),
                  _HeaderCell('5Y'),
                  _HeaderCell('Score'),
                  _HeaderCell('Sharpe'),
                ],
              ),
            ),
          ].reversed.toList(), // Put header at top
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  const _Cell(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        child: Text(text,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12)),
      );
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 64,
        child: Text(text,
            textAlign: TextAlign.right,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
      );
}

class _CompareNavChart extends ConsumerWidget {
  final List<String> fundIds;
  final List<Fund> allFunds;
  const _CompareNavChart({required this.fundIds, required this.allFunds});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final from = DateTime(DateTime.now().year - 3).toIso8601String().split('T')[0];
    final fundData = <String, List<NavPoint>>{};
    bool anyLoading = false;

    for (final id in fundIds) {
      final navAsync = ref.watch(fundNavProvider(NavParams(fundId: id, from: from)));
      navAsync.when(
        loading: () => anyLoading = true,
        error: (_, __) {},
        data: (data) {
          final fund = allFunds.where((f) => f.id == id).firstOrNull;
          if (fund != null && data.isNotEmpty) {
            fundData[fund.name] = data;
          }
        },
      );
    }

    if (anyLoading) return LoadingShimmer.chart();
    if (fundData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: Text('No NAV data available')),
      );
    }

    return CompareChart(fundData: fundData);
  }
}
