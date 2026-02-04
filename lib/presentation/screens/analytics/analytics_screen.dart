/// ==========================================================================
/// analytics_screen.dart
/// ==========================================================================
/// Statistika sahifasi - grafiklar va tahlil.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../providers/cards_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../../core/services/pdf_service.dart';
import '../../providers/auth_provider.dart';

final pdfServiceProvider = Provider((ref) => PdfService());

/// Statistika ekrani
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(analyticsSummaryProvider);
    final chartDataAsync = ref.watch(storeChartDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.analytics),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.filePdf, size: 18),
            onPressed: () => _exportPdf(context, ref),
            tooltip: 'PDF eksport',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(analyticsSummaryProvider);
          ref.invalidate(storeChartDataProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary kartlari
              summaryAsync.when(
                data: (summary) => _buildSummarySection(context, summary),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingLG),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: AppSizes.paddingLG),

              // Do'konlar bo'yicha statistika
              Text(
                AppStrings.topStores,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.paddingMD),

              // Bar chart
              chartDataAsync.when(
                data: (data) => data.isEmpty
                    ? _buildEmptyChart(context)
                    : _buildBarChart(context, data),
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _buildEmptyChart(context),
              ),

              const SizedBox(height: AppSizes.paddingLG),

              // Do'konlar ro'yxati
              chartDataAsync.when(
                data: (data) => _buildStoresList(context, data),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Summary bo'limi
  Widget _buildSummarySection(BuildContext context, AnalyticsSummary summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: FontAwesomeIcons.coins,
                title: AppStrings.totalPoints,
                value: summary.totalPoints.formatted,
                gradientColors: AppColors.primaryGradient,
              ),
            ),
            const SizedBox(width: AppSizes.paddingMD),
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: FontAwesomeIcons.creditCard,
                title: AppStrings.activeCards,
                value: summary.totalCards.toString(),
                gradientColors: AppColors.accentGradient,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.paddingMD),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: FontAwesomeIcons.arrowTrendUp,
                title: 'Bu oy yig\'ildi',
                value: '+${summary.earnedThisMonth.formatted}',
                gradientColors: [
                  AppColors.success,
                  AppColors.success.withValues(alpha: 0.7)
                ],
              ),
            ),
            const SizedBox(width: AppSizes.paddingMD),
            Expanded(
              child: _buildSummaryCard(
                context,
                icon: FontAwesomeIcons.arrowTrendDown,
                title: 'Bu oy sarflandi',
                value: '-${summary.spentThisMonth.formatted}',
                gradientColors: [
                  AppColors.error,
                  AppColors.error.withValues(alpha: 0.7)
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Summary kartasi
  Widget _buildSummaryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required List<Color> gradientColors,
  }) {
    return GlassmorphicCard(
      gradientColors: gradientColors,
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FaIcon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: AppSizes.paddingSM),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: AppSizes.fontSM,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: AppSizes.fontXXL,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Bo'sh grafik
  Widget _buildEmptyChart(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              FontAwesomeIcons.chartColumn,
              size: 48,
              color: context.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              'Ma\'lumotlar yo\'q',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTheme.bodySmall?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bar chart
  Widget _buildBarChart(BuildContext context, List<ChartBarData> data) {
    final maxValue = data.isEmpty
        ? 100.0
        : data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * 1.2,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.primaryColor,
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${data[group.x.toInt()].label}\n${rod.toY.toInt()} ball',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < data.length) {
                    final label = data[index].label;
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        label.length > 6
                            ? '${label.substring(0, 6)}...'
                            : label,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: AppSizes.fontXS,
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox();
                  return Text(
                    value.toInt().formattedPoints,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: AppSizes.fontXS,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxValue / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          barGroups: data.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value,
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.cardColors[
                          entry.value.colorIndex % AppColors.cardColors.length],
                      AppColors.cardColors[entry.value.colorIndex %
                              AppColors.cardColors.length]
                          .withValues(alpha: 0.7),
                    ],
                  ),
                  width: 24,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  /// Do'konlar ro'yxati
  Widget _buildStoresList(BuildContext context, List<ChartBarData> data) {
    if (data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Batafsil',
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSizes.paddingSM),
        ...data.asMap().entries.map((entry) {
          final item = entry.value;
          final index = entry.key;

          return Container(
            margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Raqam
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.cardColors[
                            item.colorIndex % AppColors.cardColors.length]
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.cardColors[
                            item.colorIndex % AppColors.cardColors.length],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingMD),

                // Do'kon nomi
                Expanded(
                  child: Text(
                    item.label,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                // Ball
                Row(
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.coins,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.value.toInt().formatted,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppSizes.fontLG,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// PDF eksport qilish
  Future<void> _exportPdf(BuildContext context, WidgetRef ref) async {
    final authState = ref.read(authProvider);
    final user = authState.value;
    final transactions = ref.read(transactionsProvider).transactions;

    if (user == null) return;

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Eksport qilish uchun tranzaksiyalar yo\'q')),
      );
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      await ref.read(pdfServiceProvider).exportTransactionsPdf(
            user: user,
            transactions: transactions,
          );

      if (context.mounted) Navigator.pop(context); // Close loading
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Eksportda xatolik: $e')),
        );
      }
    }
  }
}
