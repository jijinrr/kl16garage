import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/glassmorphism_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/staff_provider.dart';
import '../../../providers/stock_provider.dart';
import '../widgets/chart_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalyticsProvider>().fetchSummary();
      context.read<StaffProvider>().startListening();
      context.read<StockProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analytics = context.watch<AnalyticsProvider>();
    final staff = context.watch<StaffProvider>();
    final stock = context.watch<StockProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.analytics),
        actions: [
          // Period selector
          _PeriodChips(analytics: analytics),
          const SizedBox(width: AppSizes.sm),
        ],
      ),
      body: analytics.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.pagePaddingH,
                vertical: AppSizes.pagePaddingV,
              ),
              children: [
                // ── Summary stats ─────────────────────────────────────
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSizes.md,
                  mainAxisSpacing: AppSizes.md,
                  childAspectRatio: 1.55,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    StatCard(
                      label: AppStrings.totalRevenue,
                      value: analytics.totalRevenue,
                      icon: Icons.currency_rupee,
                      isCurrency: true,
                      iconColor: AppColors.primary,
                      valueColor: AppColors.primary,
                    ),
                    StatCard(
                      label: AppStrings.profit,
                      value: analytics.profit,
                      icon: Icons.trending_up,
                      isCurrency: true,
                      iconColor: AppColors.success,
                      valueColor: AppColors.success,
                    ),
                    StatCard(
                      label: 'Total Expenses',
                      value: analytics.totalExpenses,
                      icon: Icons.receipt_long_outlined,
                      isCurrency: true,
                      iconColor: AppColors.warning,
                    ),
                    StatCard(
                      label: 'Total Vehicles',
                      value: analytics.totalVehicles,
                      icon: Icons.directions_car_outlined,
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.xxl),

                // ── Revenue line chart ────────────────────────────────
                ChartCard(
                  title: 'Revenue Overview',
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: 180,
                      child: LineChart(
                        _buildLineChartData(analytics.totalRevenue),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Payment breakdown pie chart ────────────────────────
                ChartCard(
                  title: 'Payment Breakdown',
                  child: RepaintBoundary(
                    child: SizedBox(
                      height: 180,
                      child: PieChart(
                        _buildPieChartData(
                          analytics.paymentCompleted,
                          analytics.paymentPartial,
                          analytics.paymentPending,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Staff overview ────────────────────────────────────
                GlassmorphismCard(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Staff Overview',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _OverviewItem(
                              label: 'Active',
                              value: staff.activeCount,
                              color: AppColors.success,
                            ),
                          ),
                          Expanded(
                            child: _OverviewItem(
                              label: 'Inactive',
                              value: staff.inactiveCount,
                              color: AppColors.error,
                            ),
                          ),
                          Expanded(
                            child: _OverviewItem(
                              label: 'Total',
                              value: staff.staff.length,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Payment stats ─────────────────────────────────────
                const SizedBox(height: AppSizes.lg),
                GlassmorphismCard(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Payment Analytics',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: AppSizes.lg),
                      _PaymentBar(
                          label: AppStrings.statusCompleted,
                          count: analytics.paymentCompleted,
                          total: analytics.totalVehicles,
                          color: AppColors.success),
                      const SizedBox(height: AppSizes.sm),
                      _PaymentBar(
                          label: AppStrings.statusPartial,
                          count: analytics.paymentPartial,
                          total: analytics.totalVehicles,
                          color: AppColors.warning),
                      const SizedBox(height: AppSizes.sm),
                      _PaymentBar(
                          label: AppStrings.statusPending,
                          count: analytics.paymentPending,
                          total: analytics.totalVehicles,
                          color: AppColors.error),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Vehicle Closing Performance ───────────────────────
                GlassmorphismCard(
                  redBorder: true,
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_car,
                              color: AppColors.primary,
                              size: AppSizes.iconSm),
                          const SizedBox(width: AppSizes.sm),
                          const Text(
                            'Vehicle Closing Performance',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: AppSizes.fontLg,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      // Closing rate ring + stats
                      Row(
                        children: [
                          _ClosingRing(rate: analytics.closingRate),
                          const SizedBox(width: AppSizes.xl),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ClosingStatRow(
                                  label: 'Closed Today',
                                  value:
                                      '${analytics.closedVehicles}',
                                  color: AppColors.success,
                                ),
                                const SizedBox(height: AppSizes.sm),
                                _ClosingStatRow(
                                  label: 'Total Vehicles',
                                  value:
                                      '${analytics.totalVehicles}',
                                  color: AppColors.textPrimary,
                                ),
                                const SizedBox(height: AppSizes.sm),
                                _ClosingStatRow(
                                  label: 'Peak Time',
                                  value: analytics.peakClosingTime,
                                  color: AppColors.warning,
                                ),
                                const SizedBox(height: AppSizes.sm),
                                _ClosingStatRow(
                                  label: 'Best Day',
                                  value: analytics.bestClosingDay,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSizes.lg),
                      // Closing trend bar chart
                      const Text(
                        'Weekly Closing Trend',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppSizes.fontSm,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      RepaintBoundary(
                        child: SizedBox(
                          height: 100,
                          child: BarChart(
                            _buildClosingBarChart(
                                analytics.closingTrend),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.lg),

                // ── Stock overview ────────────────────────────────────
                GlassmorphismCard(
                  padding: const EdgeInsets.all(AppSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stock Overview',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: AppSizes.fontLg,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSizes.lg),
                      Row(
                        children: [
                          Expanded(
                            child: _OverviewItem(
                              label: 'Total Items',
                              value: stock.totalItems,
                              color: AppColors.primary,
                            ),
                          ),
                          Expanded(
                            child: _OverviewItem(
                              label: 'Low Stock',
                              value: stock.lowStockCount,
                              color: AppColors.warning,
                            ),
                          ),
                          Expanded(
                            child: _OverviewItem(
                              label: 'Out of Stock',
                              value: stock.outOfStockCount,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
    );
  }

  LineChartData _buildLineChartData(double revenue) {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: [
            const FlSpot(0, 0),
            FlSpot(1, revenue * 0.3),
            FlSpot(2, revenue * 0.5),
            FlSpot(3, revenue * 0.4),
            FlSpot(4, revenue * 0.7),
            FlSpot(5, revenue * 0.6),
            FlSpot(6, revenue),
          ],
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withValues(alpha: 0.1),
          ),
          dotData: const FlDotData(show: false),
        ),
      ],
    );
  }

  BarChartData _buildClosingBarChart(List<double> trend) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final maxY = trend.isEmpty ? 10.0 : trend.reduce((a, b) => a > b ? a : b);
    return BarChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, _) {
              final i = value.toInt();
              return Text(
                i < days.length ? days[i] : '',
                style: const TextStyle(
                    color: AppColors.textHint, fontSize: 10),
              );
            },
          ),
        ),
      ),
      maxY: maxY * 1.2,
      barGroups: trend.asMap().entries.map((e) {
        final isLast = e.key == trend.length - 1;
        return BarChartGroupData(
          x: e.key,
          barRods: [
            BarChartRodData(
              toY: e.value,
              color: isLast
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.45),
              width: 14,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  PieChartData _buildPieChartData(int completed, int partial, int pending) {
    final total = (completed + partial + pending).toDouble();
    if (total == 0) {
      return PieChartData(sections: [
        PieChartSectionData(
            value: 1,
            color: AppColors.border,
            title: '',
            radius: 60),
      ]);
    }
    return PieChartData(
      sections: [
        if (completed > 0)
          PieChartSectionData(
            value: completed.toDouble(),
            color: AppColors.success,
            title: '${(completed / total * 100).round()}%',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600),
          ),
        if (partial > 0)
          PieChartSectionData(
            value: partial.toDouble(),
            color: AppColors.warning,
            title: '${(partial / total * 100).round()}%',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600),
          ),
        if (pending > 0)
          PieChartSectionData(
            value: pending.toDouble(),
            color: AppColors.error,
            title: '${(pending / total * 100).round()}%',
            radius: 60,
            titleStyle: const TextStyle(
                color: Colors.white,
                fontSize: AppSizes.fontSm,
                fontWeight: FontWeight.w600),
          ),
      ],
      centerSpaceRadius: 40,
    );
  }
}

class _PeriodChips extends StatelessWidget {
  const _PeriodChips({required this.analytics});
  final AnalyticsProvider analytics;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _chip(context, 'Today', AnalyticsPeriod.today),
        _chip(context, 'Week', AnalyticsPeriod.weekly),
        _chip(context, 'Month', AnalyticsPeriod.monthly),
      ],
    );
  }

  Widget _chip(
      BuildContext context, String label, AnalyticsPeriod period) {
    final selected = analytics.period == period;
    return GestureDetector(
      onTap: () => analytics.setPeriod(period),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusRound),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textSecondary,
            fontSize: AppSizes.fontXs,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  const _OverviewItem(
      {required this.label, required this.value, required this.color});
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(
                color: color,
                fontSize: AppSizes.fontXxl,
                fontWeight: FontWeight.w700)),
        Text(label,
            style: const TextStyle(
                color: AppColors.textHint, fontSize: AppSizes.fontSm)),
      ],
    );
  }
}

class _ClosingRing extends StatelessWidget {
  const _ClosingRing({required this.rate});
  final double rate;

  @override
  Widget build(BuildContext context) {
    final pct = rate.clamp(0.0, 100.0);
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: pct / 100,
            strokeWidth: 8,
            backgroundColor: AppColors.surfaceVariant,
            color: AppColors.success,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${pct.round()}%',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: AppSizes.fontMd,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'closed',
                style: TextStyle(
                  color: AppColors.textHint,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ClosingStatRow extends StatelessWidget {
  const _ClosingStatRow(
      {required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: AppSizes.fontSm),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: AppSizes.fontSm,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PaymentBar extends StatelessWidget {
  const _PaymentBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });
  final String label;
  final int count;
  final int total;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = total == 0 ? 0.0 : count / total;
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppSizes.fontSm)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusRound),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppColors.surfaceVariant,
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.sm),
        Text('$count',
            style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: AppSizes.fontSm)),
      ],
    );
  }
}
