import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/funds_provider.dart';
import '../providers/nav_provider.dart';
import '../providers/watchlist_provider.dart';
import '../models/nav_point.dart';
import '../models/scheme.dart';
import '../models/sip_result.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/cards/metric_card.dart';
import '../widgets/cards/stat_row.dart';
import '../widgets/charts/nav_chart.dart';
import '../widgets/charts/sector_pie_chart.dart';
import '../widgets/charts/sip_growth_chart.dart';
import '../widgets/common/loading_shimmer.dart';
import '../widgets/common/error_state.dart';
import '../widgets/common/section_header.dart';
import '../widgets/common/category_badge.dart';

class FundDetailScreen extends ConsumerStatefulWidget {
  final String fundId;
  const FundDetailScreen({super.key, required this.fundId});

  @override
  ConsumerState<FundDetailScreen> createState() => _FundDetailScreenState();
}

class _FundDetailScreenState extends ConsumerState<FundDetailScreen> {
  String _dateRange = '3Y';
  String _selectedPlan = 'DIRECT';
  String _selectedOption = 'GROWTH';
  List<NavPoint>? _schemeNavData;
  bool _schemeNavLoading = false;

  String get _fromDate {
    final now = DateTime.now();
    switch (_dateRange) {
      case '1M': return DateTime(now.year, now.month - 1, now.day).toIso8601String().split('T')[0];
      case '6M': return DateTime(now.year, now.month - 6, now.day).toIso8601String().split('T')[0];
      case '1Y': return DateTime(now.year - 1, now.month, now.day).toIso8601String().split('T')[0];
      case '3Y': return DateTime(now.year - 3, now.month, now.day).toIso8601String().split('T')[0];
      case '5Y': return DateTime(now.year - 5, now.month, now.day).toIso8601String().split('T')[0];
      default: return '';
    }
  }

  Future<void> _fetchSchemeNav(Scheme scheme) async {
    if (scheme.isPrimary) {
      setState(() => _schemeNavData = null);
      return;
    }
    setState(() => _schemeNavLoading = true);
    try {
      final navApi = ref.read(navApiProvider);
      final data = await navApi.getSchemeNav(
        scheme.schemeId,
        from: _fromDate.isEmpty ? null : _fromDate,
      );
      data.sort((a, b) => a.date.compareTo(b.date));
      setState(() => _schemeNavData = data);
    } catch (e) {
      setState(() => _schemeNavData = null);
    } finally {
      setState(() => _schemeNavLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fundAsync = ref.watch(fundDetailProvider(widget.fundId));
    final watchlist = ref.watch(watchlistProvider);
    final isBookmarked = watchlist.contains(widget.fundId);

    return fundAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: LoadingShimmer.listTile(count: 6),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorStateWidget(
          message: error.toString(),
          onRetry: () => ref.invalidate(fundDetailProvider(widget.fundId)),
        ),
      ),
      data: (fund) {
        final m = fund.metrics;
        final navParams = NavParams(
          fundId: widget.fundId,
          from: _fromDate.isEmpty ? null : _fromDate,
        );
        final navAsync = ref.watch(fundNavProvider(navParams));
        final schemes = fund.schemes;
        final activeScheme = schemes.where(
          (s) => s.planType == _selectedPlan && s.optionType == _selectedOption,
        ).firstOrNull ?? schemes.where((s) => s.isPrimary).firstOrNull;
        final isPrimarySelected = activeScheme?.isPrimary ?? true;
        final hasMultipleSchemes = schemes.length > 1;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              fund.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: isBookmarked ? AppColors.primary : null,
                ),
                onPressed: () =>
                    ref.read(watchlistProvider.notifier).toggle(widget.fundId),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.only(bottom: 80),
            children: [
              // Fund header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CategoryBadge(category: fund.category),
                        const SizedBox(width: 8),
                        Text(
                          fund.amc ?? '',
                          style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _InfoChip(
                          label: 'AUM',
                          value: fund.aumCr != null ? formatAUM(fund.aumCr) : '—',
                        ),
                        const SizedBox(width: 8),
                        _InfoChip(
                          label: 'Expense',
                          value: formatExpenseRatio(
                            activeScheme?.expenseRatio ?? fund.expenseRatio,
                          ),
                        ),
                        if (fund.fundManager != null) ...[
                          const SizedBox(width: 8),
                          _InfoChip(label: 'Manager', value: fund.fundManager!),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Plan/Option selector
              if (hasMultipleSchemes)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        _Dropdown(
                          label: 'Plan',
                          value: _selectedPlan,
                          items: ['DIRECT', 'REGULAR'],
                          displayItems: ['Direct', 'Regular'],
                          onChanged: (v) {
                            setState(() => _selectedPlan = v);
                            if (activeScheme != null) _fetchSchemeNav(activeScheme);
                          },
                        ),
                        const SizedBox(width: 16),
                        _Dropdown(
                          label: 'Option',
                          value: _selectedOption,
                          items: ['GROWTH', 'IDCW'],
                          displayItems: ['Growth', 'IDCW'],
                          onChanged: (v) {
                            setState(() => _selectedOption = v);
                            if (activeScheme != null) _fetchSchemeNav(activeScheme);
                          },
                        ),
                        if (!isPrimarySelected) ...[
                          const Spacer(),
                          if (_schemeNavLoading)
                            const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),

              // Returns row
              if (m != null) ...[
                const SectionHeader(title: 'Returns'),
                SizedBox(
                  height: 72,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      MetricCard(label: '1M', value: m.oneMonthReturn),
                      const SizedBox(width: 8),
                      MetricCard(label: '3M', value: m.threeMonthReturn),
                      const SizedBox(width: 8),
                      MetricCard(label: '6M', value: m.sixMonthReturn),
                      const SizedBox(width: 8),
                      MetricCard(label: '1Y', value: m.oneYearReturn),
                      const SizedBox(width: 8),
                      MetricCard(label: '3Y', value: m.threeYearCagr),
                      const SizedBox(width: 8),
                      MetricCard(label: '5Y', value: m.fiveYearCagr),
                      const SizedBox(width: 8),
                      MetricCard(label: '10Y', value: m.tenYearCagr),
                    ],
                  ),
                ),
              ],

              // Composite score
              if (m != null && m.compositeScore != null) ...[
                const SectionHeader(title: 'Risk & Score'),
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
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Composite Score',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(
                              '${formatScore(m.compositeScore)}/100',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (m.compositeScore ?? 0) / 100,
                            backgroundColor: AppColors.border,
                            color: AppColors.primary,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StatRow(
                          label: 'Sharpe Ratio',
                          value: formatScore(m.sharpeRatio),
                        ),
                        StatRow(
                          label: 'Sortino Ratio',
                          value: formatScore(m.sortinoRatio),
                        ),
                        StatRow(
                          label: 'Volatility',
                          value: m.annualisedVolatility != null
                              ? '${m.annualisedVolatility!.toStringAsFixed(1)}%'
                              : '—',
                        ),
                        StatRow(
                          label: 'Max Drawdown',
                          value: m.maxDrawdown != null
                              ? '${m.maxDrawdown!.toStringAsFixed(1)}%'
                              : '—',
                          valueColor: AppColors.negative,
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // NAV Chart
              const SectionHeader(title: 'NAV History'),
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
                    children: [
                      // Date range selector
                      Row(
                        children: ['1M', '6M', '1Y', '3Y', '5Y', 'MAX'].map((range) {
                          final isActive = _dateRange == range;
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: ChoiceChip(
                              label: Text(range, style: const TextStyle(fontSize: 11)),
                              selected: isActive,
                              onSelected: (_) => setState(() => _dateRange = range),
                              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                              visualDensity: VisualDensity.compact,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: isActive ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      navAsync.when(
                        loading: () => LoadingShimmer.chart(),
                        error: (e, _) => const SizedBox(
                          height: 220,
                          child: Center(child: Text('Failed to load chart')),
                        ),
                        data: (navData) {
                          final displayData =
                              isPrimarySelected ? navData : (_schemeNavData ?? navData);
                          return NavChart(data: displayData);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Holdings
              if (fund.holdings.isNotEmpty) ...[
                SectionHeader(
                  title: 'Top Holdings',
                  trailing: Text(
                    '${fund.holdings.length} holdings',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: fund.holdings.take(10).map((h) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  h.companyName,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: h.allocationPct / 100,
                                    backgroundColor: AppColors.border,
                                    color: AppColors.primary.withOpacity(0.7),
                                    minHeight: 6,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 44,
                                child: Text(
                                  '${h.allocationPct.toStringAsFixed(1)}%',
                                  textAlign: TextAlign.right,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],

              // Sector allocation
              if (fund.sectorAllocations.isNotEmpty) ...[
                const SectionHeader(title: 'Sector Allocation'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SectorPieChart(sectors: fund.sectorAllocations),
                  ),
                ),
              ],

              // SIP Calculator
              const SizedBox(height: 8),
              _EmbeddedSipCalc(defaultReturn: m?.fiveYearCagr ?? 12),
            ],
          ),
        );
      },
    );
  }
}

// ─── Helper Widgets ─── //

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final List<String> displayItems;
  final ValueChanged<String> onChanged;
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.displayItems,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
              items: items.asMap().entries.map((e) {
                return DropdownMenuItem(value: e.value, child: Text(displayItems[e.key]));
              }).toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _EmbeddedSipCalc extends StatefulWidget {
  final double defaultReturn;
  const _EmbeddedSipCalc({required this.defaultReturn});

  @override
  State<_EmbeddedSipCalc> createState() => _EmbeddedSipCalcState();
}

class _EmbeddedSipCalcState extends State<_EmbeddedSipCalc> {
  double _sipAmount = 10000;
  int _years = 10;
  late double _expectedReturn;

  @override
  void initState() {
    super.initState();
    _expectedReturn = widget.defaultReturn;
  }

  @override
  Widget build(BuildContext context) {
    final result = SipResult.calculate(
      monthlyAmount: _sipAmount,
      years: _years,
      annualReturn: _expectedReturn,
    );

    return Padding(
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
            const Text('SIP Calculator',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Text('Monthly: ${formatINR(_sipAmount)}',
                style: const TextStyle(fontSize: 13)),
            Slider(
              value: _sipAmount,
              min: 500, max: 100000, divisions: 199,
              onChanged: (v) => setState(() => _sipAmount = v),
            ),
            Text('Duration: $_years years',
                style: const TextStyle(fontSize: 13)),
            Slider(
              value: _years.toDouble(),
              min: 1, max: 40, divisions: 39,
              onChanged: (v) => setState(() => _years = v.round()),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SipStat(label: 'Invested', value: formatINRShort(result.totalInvested)),
                _SipStat(
                  label: 'Expected',
                  value: formatINRShort(result.expectedValue),
                  color: AppColors.emerald,
                ),
                _SipStat(
                  label: 'Gains',
                  value: formatINRShort(result.gains),
                  color: AppColors.positive,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SipGrowthChart(result: result, height: 180),
          ],
        ),
      ),
    );
  }
}

class _SipStat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _SipStat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
