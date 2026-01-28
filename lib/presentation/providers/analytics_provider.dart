/// ==========================================================================
/// analytics_provider.dart
/// ==========================================================================
/// Statistika uchun qo'shimcha providerlar.
/// ==========================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cards_provider.dart';

/// Statistika summary
class AnalyticsSummary {
  final int totalPoints;
  final int totalCards;
  final int totalTransactions;
  final int earnedThisMonth;
  final int spentThisMonth;
  final Map<String, int> pointsByStore;

  const AnalyticsSummary({
    required this.totalPoints,
    required this.totalCards,
    required this.totalTransactions,
    required this.earnedThisMonth,
    required this.spentThisMonth,
    required this.pointsByStore,
  });
}

/// Statistika summary provider
final analyticsSummaryProvider = FutureProvider<AnalyticsSummary>((ref) async {
  final repository = ref.watch(loyaltyRepositoryProvider);
  
  // Parallel ravishda ma'lumotlarni yuklash
  final results = await Future.wait([
    repository.getTotalPoints(),
    repository.getActiveCardsCount(),
    repository.getAllTransactions(),
    repository.getStatsByStore(),
  ]);
  
  final totalPoints = results[0] as int;
  final totalCards = results[1] as int;
  final transactions = results[2] as List;
  final pointsByStore = results[3] as Map<String, int>;
  
  // Joriy oy statistikasi
  final now = DateTime.now();
  final thisMonth = transactions.where((t) {
    final date = t.date as DateTime;
    return date.year == now.year && date.month == now.month;
  });
  
  int earnedThisMonth = 0;
  int spentThisMonth = 0;
  
  for (final t in thisMonth) {
    if (t.type.index == 0) {
      earnedThisMonth += t.points as int;
    } else {
      spentThisMonth += t.points as int;
    }
  }
  
  return AnalyticsSummary(
    totalPoints: totalPoints,
    totalCards: totalCards,
    totalTransactions: transactions.length,
    earnedThisMonth: earnedThisMonth,
    spentThisMonth: spentThisMonth,
    pointsByStore: pointsByStore,
  );
});

/// Chart uchun bar data
class ChartBarData {
  final String label;
  final double value;
  final int colorIndex;

  const ChartBarData({
    required this.label,
    required this.value,
    required this.colorIndex,
  });
}

/// Do'konlar bo'yicha chart data
final storeChartDataProvider = FutureProvider<List<ChartBarData>>((ref) async {
  final stats = await ref.watch(storeStatsProvider.future);
  
  int index = 0;
  return stats.entries.map((e) {
    return ChartBarData(
      label: e.key,
      value: e.value.toDouble(),
      colorIndex: index++,
    );
  }).toList()
    ..sort((a, b) => b.value.compareTo(a.value)); // Kattadan kichikka
});
