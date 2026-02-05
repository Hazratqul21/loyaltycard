/// ==========================================================================
/// merchant_history_screen.dart
/// ==========================================================================
/// Sotuvchi tomonidan qilingan skanerlar tarixi.
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/utils/extensions.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/auth_provider.dart';

class MerchantHistoryScreen extends ConsumerWidget {
  const MerchantHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final repo = ref.watch(merchantRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Skanerlash Tarixi'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: repo.getMerchantScans(authState.user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _buildHistoryItem(context, tx);
            },
          );
        },
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, tx) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withValues(alpha: 0.1),
          child: const FaIcon(FontAwesomeIcons.user,
              size: 14, color: AppColors.primaryColor),
        ),
        title: Text(
          'Mijoz: ${tx.userId.substring(0, 8)}...',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        subtitle: Text(
          tx.date.timeAgo,
          style: const TextStyle(fontSize: 11),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '+${tx.points}',
              style: const TextStyle(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (tx.amount != null)
              Text(
                '${tx.amount.toStringAsFixed(0)} so\'m',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(FontAwesomeIcons.clockRotateLeft,
              size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Hozircha tarix mavjud emas',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
