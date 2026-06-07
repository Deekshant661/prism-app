import 'package:flutter/material.dart';
import '../models/sip_result.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';
import '../widgets/charts/sip_growth_chart.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  double _sipAmount = 10000;
  int _years = 15;
  double _expectedReturn = 12;
  final _returnController = TextEditingController(text: '12');

  @override
  void dispose() {
    _returnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = SipResult.calculate(
      monthlyAmount: _sipAmount,
      years: _years,
      annualReturn: _expectedReturn,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('SIP Calculator')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Amount slider
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monthly SIP Amount',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      formatINR(_sipAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _sipAmount,
                  min: 500, max: 100000, divisions: 199,
                  label: formatINR(_sipAmount),
                  onChanged: (v) => setState(() => _sipAmount = v),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Duration',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(
                      '$_years years',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _years.toDouble(),
                  min: 1, max: 40, divisions: 39,
                  label: '$_years years',
                  onChanged: (v) => setState(() => _years = v.round()),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Expected Return (%)',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _returnController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          suffixText: '%',
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v);
                          if (parsed != null && parsed > 0 && parsed <= 50) {
                            setState(() => _expectedReturn = parsed);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Results
          Row(
            children: [
              Expanded(child: _ResultCard(
                label: 'Invested',
                value: formatINR(result.totalInvested),
                icon: Icons.savings_outlined,
                color: AppColors.primary,
              )),
              const SizedBox(width: 8),
              Expanded(child: _ResultCard(
                label: 'Expected Value',
                value: formatINRShort(result.expectedValue),
                icon: Icons.trending_up,
                color: AppColors.emerald,
              )),
              const SizedBox(width: 8),
              Expanded(child: _ResultCard(
                label: 'Gains',
                value: formatINRShort(result.gains),
                icon: Icons.auto_awesome,
                color: AppColors.positive,
              )),
            ],
          ),
          const SizedBox(height: 20),
          // Growth chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Growth Projection',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _LegendDot(color: AppColors.primary, label: 'Invested'),
                    const SizedBox(width: 16),
                    _LegendDot(color: AppColors.emerald, label: 'Corpus'),
                  ],
                ),
                const SizedBox(height: 16),
                SipGrowthChart(result: result, height: 240),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _ResultCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.08), color.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(label,
              style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          const SizedBox(height: 2),
          FittedBox(
            child: Text(
              value,
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
