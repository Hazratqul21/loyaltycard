/// ==========================================================================
/// merchant_dashboard.dart
/// ==========================================================================
/// Sotuvchining asosiy ishchi stoli.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../../core/utils/extensions.dart';

class MerchantDashboard extends ConsumerWidget {
  const MerchantDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final repo = ref.watch(merchantRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Info Card
            _buildStoreHeader(context, authState.user),
            const SizedBox(height: AppSizes.paddingLG),

            // Statistics Grid
            FutureBuilder<Map<String, dynamic>>(
                future: repo
                    .getStoreOverview(authState.user?.storeId ?? 'demo_store'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data ?? {};
                  return _buildStatsGrid(context, data);
                }),

            const SizedBox(height: AppSizes.paddingLG),
            Text(
              'Bugungi skanerlar',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSizes.paddingMD),

            // Empty State placeholder for now
            _buildEmptyScans(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreHeader(BuildContext context, user) {
    return GlassmorphicCard(
      gradientColors: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const FaIcon(FontAwesomeIcons.shop,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Mening Do\'konim',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppSizes.fontLG,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ID: ${user?.storeId ?? "ST-88921"}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          _buildActiveBadge(),
        ],
      ),
    );
  }

  Widget _buildActiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'FAOL',
        style: TextStyle(
            color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, Map<String, dynamic> data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSizes.paddingMD,
      crossAxisSpacing: AppSizes.paddingMD,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          context,
          'Bugun',
          '${data['todayScans'] ?? 0} marta',
          FontAwesomeIcons.qrcode,
          AppColors.primaryColor,
        ),
        _buildStatCard(
          context,
          'Jami ball',
          '${data['totalPointsAwarded'] ?? 0}',
          FontAwesomeIcons.coins,
          AppColors.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              FaIcon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyScans(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingXL),
        child: Column(
          children: [
            FaIcon(FontAwesomeIcons.magnifyingGlass,
                size: 40, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              'Bugun hali skanerlash amalga oshirilmadi',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
