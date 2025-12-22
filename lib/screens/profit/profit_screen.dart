import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:expense_tracker/providers/auth_provider.dart';
import 'package:expense_tracker/providers/summary_provider.dart';
import 'package:expense_tracker/utils/helpers.dart';
import 'package:expense_tracker/utils/constants.dart';

class ProfitScreen extends ConsumerWidget {
  const ProfitScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit Analysis'),
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) return const Center(child: Text('Please login'));

          final userId = user.id!;
          final monthlySummaryAsync = ref.watch(monthlySummaryProvider(userId));
          final profitDataAsync = ref.watch(monthlyProfitDataProvider(userId));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Monthly Summary Card
                monthlySummaryAsync.when(
                  data: (summary) {
                    return Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'This Month',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            _MetricRow(
                              label: 'Total Income',
                              value: summary.totalIncome,
                              color: AppColors.income,
                            ),
                            const SizedBox(height: 8),
                            _MetricRow(
                              label: 'Total Expense',
                              value: summary.totalExpense,
                              color: AppColors.expense,
                            ),
                            const Divider(height: 24),
                            _MetricRow(
                              label: summary.profit >= 0 ? 'Net Profit' : 'Net Loss',
                              value: summary.profit.abs(),
                              color: summary.profit >= 0
                                  ? AppColors.profit
                                  : AppColors.error,
                              isBold: true,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),

                const SizedBox(height: 24),

                // Chart
                Text(
                  'Last 6 Months Trend',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),

                profitDataAsync.when(
                  data: (profitData) {
                    if (profitData.isEmpty) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(
                            child: Text('No data available'),
                          ),
                        ),
                      );
                    }

                    // Calculate min and max values for better chart scaling
                    double maxValue = 0;
                    double minValue = 0;
                    for (var data in profitData) {
                      if (data.income > maxValue) maxValue = data.income;
                      if (data.expense > maxValue) maxValue = data.expense;
                      if (data.profit < minValue) minValue = data.profit;
                    }

                    return Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 320,
                              child: LineChart(
                                LineChartData(
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: true,
                                    horizontalInterval: maxValue > 0 ? maxValue / 5 : 1,
                                    getDrawingHorizontalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withValues(alpha: 0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                    getDrawingVerticalLine: (value) {
                                      return FlLine(
                                        color: Colors.grey.withValues(alpha: 0.2),
                                        strokeWidth: 1,
                                      );
                                    },
                                  ),
                                  titlesData: FlTitlesData(
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 30,
                                        getTitlesWidget: (value, meta) {
                                          if (value.toInt() >= 0 &&
                                              value.toInt() < profitData.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Text(
                                                Helpers.formatMonthYear(
                                                        profitData[value.toInt()].date)
                                                    .split(' ')
                                                    .first
                                                    .substring(0, 3),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 50,
                                        interval: maxValue > 0 ? maxValue / 5 : 1,
                                        getTitlesWidget: (value, meta) {
                                          return Text(
                                            Helpers.formatCurrencyCompact(value),
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                  ),
                                  borderData: FlBorderData(
                                    show: true,
                                    border: Border.all(
                                      color: Colors.grey.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  minY: minValue < 0 ? minValue * 1.1 : 0,
                                  maxY: maxValue * 1.1,
                                  lineBarsData: [
                                    // Profit/Loss Line
                                    LineChartBarData(
                                      spots: profitData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                              e.key.toDouble(), e.value.profit))
                                          .toList(),
                                      isCurved: true,
                                      color: AppColors.profit,
                                      barWidth: 4,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 4,
                                            color: profitData[index].profit >= 0
                                                ? AppColors.profit
                                                : AppColors.error,
                                            strokeWidth: 2,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                      belowBarData: BarAreaData(
                                        show: true,
                                        color: AppColors.profit.withValues(alpha: 0.1),
                                      ),
                                    ),
                                    // Income Line
                                    LineChartBarData(
                                      spots: profitData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                              e.key.toDouble(), e.value.income))
                                          .toList(),
                                      isCurved: true,
                                      color: AppColors.income,
                                      barWidth: 3,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: AppColors.income,
                                            strokeWidth: 1.5,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                    // Expense Line
                                    LineChartBarData(
                                      spots: profitData
                                          .asMap()
                                          .entries
                                          .map((e) => FlSpot(
                                              e.key.toDouble(), e.value.expense))
                                          .toList(),
                                      isCurved: true,
                                      color: AppColors.expense,
                                      barWidth: 3,
                                      dotData: FlDotData(
                                        show: true,
                                        getDotPainter: (spot, percent, barData, index) {
                                          return FlDotCirclePainter(
                                            radius: 3,
                                            color: AppColors.expense,
                                            strokeWidth: 1.5,
                                            strokeColor: Colors.white,
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                  lineTouchData: LineTouchData(
                                    enabled: true,
                                    touchTooltipData: LineTouchTooltipData(
                                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                        return touchedSpots.map((LineBarSpot touchedSpot) {
                                          String label = '';
                                          Color color = Colors.white;
                                          
                                          if (touchedSpot.barIndex == 0) {
                                            label = 'Profit: ${Helpers.formatCurrency(touchedSpot.y)}';
                                            color = touchedSpot.y >= 0 ? AppColors.profit : AppColors.error;
                                          } else if (touchedSpot.barIndex == 1) {
                                            label = 'Income: ${Helpers.formatCurrency(touchedSpot.y)}';
                                            color = AppColors.income;
                                          } else {
                                            label = 'Expense: ${Helpers.formatCurrency(touchedSpot.y)}';
                                            color = AppColors.expense;
                                          }
                                          
                                          return LineTooltipItem(
                                            label,
                                            TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          );
                                        }).toList();
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 20,
                              runSpacing: 12,
                              children: [
                                _LegendItem(
                                  color: AppColors.profit,
                                  label: 'Profit/Loss',
                                ),
                                _LegendItem(
                                  color: AppColors.income,
                                  label: 'Income',
                                ),
                                _LegendItem(
                                  color: AppColors.expense,
                                  label: 'Expense',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Text('Error: $error'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final bool isBold;

  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          Helpers.formatCurrency(value),
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}
