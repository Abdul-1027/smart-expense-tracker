// screens/analytics/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/transaction_provider.dart';
import '../../utils/constants.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final txn = context.watch<TransactionProvider>();
    final fmt = NumberFormat('#,###', 'en_US');
    final catData = txn.expenseByCategory;
    final trendData = txn.monthlyTrend;
    final totalExp = txn.totalExpense;

    // Fix: sort separately, don't chain ..sort()..map()
    final sortedCatEntries = catData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Row(children: [
              _MetricCard(
                  label: 'Total Income',
                  value: 'Rs ${fmt.format(txn.totalIncome)}',
                  color: AppColors.income),
              const SizedBox(width: 10),
              _MetricCard(
                  label: 'Total Expenses',
                  value: 'Rs ${fmt.format(txn.totalExpense)}',
                  color: AppColors.expense),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              _MetricCard(
                  label: 'Net Savings',
                  value: 'Rs ${fmt.format(txn.balance)}',
                  color: txn.balance >= 0
                      ? AppColors.income
                      : AppColors.expense),
              const SizedBox(width: 10),
              _MetricCard(
                  label: 'Transactions',
                  value: '${txn.transactions.length}',
                  color: AppColors.primary),
            ]),
            const SizedBox(height: 20),

            // Pie Chart
            const Text('Spending by Category',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: catData.isEmpty
                  ? const SizedBox(
                  height: 160,
                  child: Center(
                      child: Text('No expense data',
                          style: TextStyle(
                              color: AppColors.textSecondary))))
                  : Column(children: [
                SizedBox(
                  height: 200,
                  child: PieChart(PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (_, response) {
                        setState(() {
                          _touchedIndex = response
                              ?.touchedSection
                              ?.touchedSectionIndex ??
                              -1;
                        });
                      },
                    ),
                    sections: catData.entries
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final idx = entry.key;
                      final e = entry.value;
                      final isTouched = idx == _touchedIndex;
                      final pct = totalExp > 0
                          ? e.value / totalExp * 100
                          : 0.0;
                      return PieChartSectionData(
                        value: e.value,
                        color: AppCategories.getCategoryColor(
                            e.key),
                        radius: isTouched ? 70 : 60,
                        title: pct >= 5
                            ? '${pct.round()}%'
                            : '',
                        titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                        badgeWidget: isTouched
                            ? Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                            BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.border),
                          ),
                          child: Text(
                              'Rs ${fmt.format(e.value)}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: AppColors
                                      .textPrimary)),
                        )
                            : null,
                        badgePositionPercentageOffset: 1.3,
                      );
                    }).toList(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  )),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: catData.entries.map((e) {
                    final pct = totalExp > 0
                        ? e.value / totalExp * 100
                        : 0.0;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppCategories
                                .getCategoryColor(e.key),
                            borderRadius:
                            BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${e.key} (${pct.round()}%)',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ]),
            ),
            const SizedBox(height: 20),

            // Bar Chart
            const Text('Monthly Spending Trend',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: trendData.values.every((v) => v == 0)
                  ? const SizedBox(
                  height: 160,
                  child: Center(
                      child: Text('No expense data',
                          style: TextStyle(
                              color: AppColors.textSecondary))))
                  : SizedBox(
                height: 200,
                child: BarChart(BarChartData(
                  gridData: FlGridData(
                    drawVerticalLine: false,
                    horizontalInterval: (trendData.values
                        .reduce((a, b) =>
                    a > b ? a : b) /
                        4)
                        .clamp(1, double.infinity),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final keys =
                          trendData.keys.toList();
                          if (v.toInt() >= keys.length) {
                            return const SizedBox();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 8),
                            child: Text(keys[v.toInt()],
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors
                                        .textSecondary)),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 48,
                        getTitlesWidget: (v, _) => Text(
                          v >= 1000
                              ? '${(v / 1000).round()}K'
                              : v.round().toString(),
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles:
                        SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: trendData.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value.value,
                          color: AppColors.primary,
                          width: 24,
                          borderRadius:
                          BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, _, rod, __) {
                        final key = trendData.keys
                            .toList()[group.x];
                        return BarTooltipItem(
                          '$key\nRs ${fmt.format(rod.toY)}',
                          const TextStyle(
                              color: Colors.white,
                              fontSize: 12),
                        );
                      },
                    ),
                  ),
                )),
              ),
            ),
            const SizedBox(height: 20),

            // Category Breakdown List
            const Text('Category Breakdown',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            catData.isEmpty
                ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                  child: Text('No data available',
                      style: TextStyle(
                          color: AppColors.textSecondary))),
            )
                : Column(
              children: sortedCatEntries.map((e) {
                final pct =
                totalExp > 0 ? e.value / totalExp : 0.0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: AppColors.border),
                  ),
                  child: Column(children: [
                    Row(children: [
                      Icon(
                          AppCategories.getCategoryIcon(
                              e.key),
                          color: AppCategories
                              .getCategoryColor(e.key),
                          size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text(e.key,
                              style: const TextStyle(
                                  fontWeight:
                                  FontWeight.w500))),
                      Text('Rs ${fmt.format(e.value)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text('${(pct * 100).round()}%',
                          style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12)),
                    ]),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct,
                        minHeight: 5,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation(
                            AppCategories.getCategoryColor(
                                e.key)),
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricCard(
      {required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color)),
        ]),
      ),
    );
  }
}