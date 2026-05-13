import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../core/utils/pdf_generator.dart';
import 'package:printing/printing.dart';
import '../cubit/dashboard_cubit.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: 16),
                Text(state.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<DashboardCubit>().load(),
                  child: Text('retry'.tr()),
                ),
              ],
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DashboardHeader(state: state),
              const SizedBox(height: 16),
              _StatsGrid(state: state),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _SalesChart(state: state)),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _TopProductsCard(state: state)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final DashboardState state;
  const _DashboardHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('dashboard'.tr(), style: Theme.of(context).textTheme.headlineMedium),
            if (state.from != null)
              Text(
                '${DateFormatter.formatDisplayDate(state.from!)} → ${DateFormatter.formatDisplayDate(state.to!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        const Spacer(),
        Wrap(
          spacing: 8,
          children: [
            _QuickRangeBtn(label: 'today'.tr(), onTap: () => cubit.load()),
            _QuickRangeBtn(label: 'month'.tr(), onTap: () {
              final now = DateTime.now();
              cubit.load(from: DateFormatter.startOfMonth(now), to: DateFormatter.endOfMonth(now));
            }),
            _QuickRangeBtn(label: 'year'.tr(), onTap: () {
              final now = DateTime.now();
              cubit.load(from: DateFormatter.startOfYear(now), to: DateFormatter.endOfYear(now));
            }),
            ActionChip(
              label: Text('custom'.tr()),
              avatar: const Icon(Icons.date_range_rounded, size: 16),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (range != null) cubit.load(from: range.start, to: range.end);
              },
            ),
            const SizedBox(width: 8),
            ActionChip(
              label: Text('printReport'.tr(), style: const TextStyle(color: Colors.white)),
              backgroundColor: AppColors.primary,
              avatar: const Icon(Icons.print_rounded, size: 16, color: Colors.white),
              onPressed: () async {
                try {
                  final now = DateTime.now();
                  final f = state.from ?? DateFormatter.startOfDay(now);
                  final t = state.to ?? DateFormatter.endOfDay(now);
                  final bytes = await PdfGenerator.generateReport(from: f, to: t);
                  await Printing.layoutPdf(onLayout: (_) => bytes);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${'error'.tr()}: $e')));
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickRangeBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickRangeBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => ActionChip(label: Text(label), onPressed: onTap);
}

class _StatsGrid extends StatelessWidget {
  final DashboardState state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final cards = [
      StatCard(title: 'cashIncome'.tr(), value: state.cashIncome.toStringAsFixed(2),
          icon: Icons.payments_rounded, color: AppColors.cashColor),
      StatCard(title: 'cardIncome'.tr(), value: state.cardIncome.toStringAsFixed(2),
          icon: Icons.credit_card_rounded, color: AppColors.cardColor),
      StatCard(title: 'totalIncome'.tr(), value: state.totalIncome.toStringAsFixed(2),
          icon: Icons.account_balance_wallet_rounded, color: AppColors.accent),
      StatCard(title: 'totalExpenses'.tr(), value: state.totalExpenses.toStringAsFixed(2),
          icon: Icons.money_off_rounded, color: AppColors.error),
      StatCard(
          title: 'netProfit'.tr(),
          value: state.netProfit.toStringAsFixed(2),
          icon: Icons.trending_up_rounded,
          color: state.netProfit >= 0 ? AppColors.success : AppColors.error,
          subtitle: state.netProfit >= 0 ? '▲ ${'profit'.tr()}' : '▼ ${'loss'.tr()}'),
      StatCard(title: 'totalInvoices'.tr(), value: '${state.totalInvoices}',
          icon: Icons.receipt_long_rounded, color: AppColors.primary),
    ];

    if (isDesktop) {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.8,
        children: cards,
      );
    }
    return Column(
      children: cards.map((c) => Padding(padding: const EdgeInsets.only(bottom: 12), child: c)).toList(),
    );
  }
}

class _SalesChart extends StatelessWidget {
  final DashboardState state;
  const _SalesChart({required this.state});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = state.salesByDay.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['total'] as num).toDouble());
    }).toList();

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('salesTrend'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: spots.isEmpty
                ? Center(child: Text('noSalesData'.tr(),
                    style: const TextStyle(color: AppColors.textSecondary)))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        getDrawingHorizontalLine: (v) => FlLine(
                          color: isDark ? Colors.white10 : Colors.black12,
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (v) => const FlLine(color: Colors.transparent),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (spots.length / 5).ceilToDouble().clamp(1, 999),
                            getTitlesWidget: (v, _) {
                              final idx = v.toInt();
                              if (idx < 0 || idx >= state.salesByDay.length) return const SizedBox();
                              final day = state.salesByDay[idx]['day'] as String;
                              return Text(day.substring(5), style: const TextStyle(fontSize: 10));
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (v, _) =>
                                Text(v.toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          color: AppColors.accent,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.accent.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _TopProductsCard extends StatelessWidget {
  final DashboardState state;
  const _TopProductsCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final items = state.topProducts;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('topSellingProducts'.tr(), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('noData'.tr(), style: const TextStyle(color: AppColors.textSecondary)),
            )
          else
            ...items.asMap().entries.map((e) {
              final item = e.value;
              final maxQty = (items.first['total_qty'] as num).toDouble();
              final qty = (item['total_qty'] as num).toDouble();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Text('${e.key + 1}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accent)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item['product_name'] as String,
                            style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis)),
                        Text('×${qty.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maxQty > 0 ? qty / maxQty : 0,
                        backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                        color: AppColors.accent,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
