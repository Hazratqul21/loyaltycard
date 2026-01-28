/// ==========================================================================
/// rewards_screen.dart
/// ==========================================================================
/// Sovg'alar do'koni sahifasi.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/extensions.dart';
import '../../../domain/entities/reward.dart';
import '../../providers/cards_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';

/// Sovg'alar ekrani
class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardsState = ref.watch(rewardsProvider);
    final totalPointsAsync = ref.watch(totalPointsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.rewards),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(rewardsProvider.notifier).loadRewards();
          ref.invalidate(totalPointsProvider);
        },
        child: CustomScrollView(
          slivers: [
            // Joriy ballar karti
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: totalPointsAsync.when(
                  data: (points) => _buildPointsCard(context, points),
                  loading: () => _buildPointsCard(context, 0, isLoading: true),
                  error: (_, __) => _buildPointsCard(context, 0),
                ),
              ),
            ),

            // Sarlavha
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.paddingMD,
                  vertical: AppSizes.paddingSM,
                ),
                child: Text(
                  AppStrings.availableRewards,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Sovg'alar gridi
            if (rewardsState.isLoading)
              const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSizes.paddingXL),
                    child: CircularProgressIndicator(),
                  ),
                ),
              )
            else if (rewardsState.rewards.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(context))
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSizes.paddingMD,
                    crossAxisSpacing: AppSizes.paddingMD,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final reward = rewardsState.rewards[index];
                      final totalPoints = totalPointsAsync.valueOrNull ?? 0;
                      return _buildRewardCard(
                        context,
                        ref,
                        reward,
                        totalPoints,
                      );
                    },
                    childCount: rewardsState.rewards.length,
                  ),
                ),
              ),

            // Pastki bo'shliq
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// Ballar karti
  Widget _buildPointsCard(BuildContext context, int points, {bool isLoading = false}) {
    return GlassmorphicCard(
      gradientColors: AppColors.accentGradient,
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSizes.radiusMD),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.wallet,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sarflash uchun mavjud',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: AppSizes.fontMD,
                  ),
                ),
                const SizedBox(height: 4),
                isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        '${points.formatted} ball',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontHeading,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bo'sh holat
  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingXL),
      child: Column(
        children: [
          FaIcon(
            FontAwesomeIcons.gift,
            size: 64,
            color: context.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Text(
            'Hozircha sovg\'alar yo\'q',
            style: context.textTheme.titleMedium?.copyWith(
              color: context.textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Text(
            'Tez orada yangi sovg\'alar qo\'shiladi!',
            style: context.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Sovg'a kartasi
  Widget _buildRewardCard(
    BuildContext context,
    WidgetRef ref,
    Reward reward,
    int userPoints,
  ) {
    final canRedeem = userPoints >= reward.requiredPoints && reward.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Rasm qismi
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cardColors[reward.id.hashCode % AppColors.cardColors.length],
                    AppColors.cardColors[reward.id.hashCode % AppColors.cardColors.length]
                        .withOpacity(0.7),
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLG),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: FaIcon(
                      _getCategoryIcon(reward.category),
                      color: Colors.white.withOpacity(0.5),
                      size: 48,
                    ),
                  ),
                  // Kategoriya tegi
                  Positioned(
                    top: AppSizes.paddingSM,
                    left: AppSizes.paddingSM,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingSM,
                        vertical: AppSizes.paddingXS,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXS),
                      ),
                      child: Text(
                        reward.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontXS,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Ma'lumot qismi
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.title,
                    style: context.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reward.storeName ?? 'Universal',
                    style: context.textTheme.bodySmall,
                    maxLines: 1,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.coins,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reward.requiredPoints.formatted,
                        style: const TextStyle(
                          fontSize: AppSizes.fontMD,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.paddingSM),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: canRedeem
                          ? () => _showRedeemDialog(context, ref, reward, userPoints)
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
                        ),
                      ),
                      child: Text(
                        canRedeem ? AppStrings.redeem : AppStrings.notEnoughPoints,
                        style: const TextStyle(fontSize: AppSizes.fontSM),
                      ),
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

  /// Kategoriya ikonkasi
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'chegirma':
        return FontAwesomeIcons.percent;
      case 'ichimlik':
        return FontAwesomeIcons.mugHot;
      case 'sovg\'a':
        return FontAwesomeIcons.gift;
      case 'mahsulot':
        return FontAwesomeIcons.box;
      default:
        return FontAwesomeIcons.star;
    }
  }

  /// Olish dialogini ko'rsatish
  void _showRedeemDialog(
    BuildContext context,
    WidgetRef ref,
    Reward reward,
    int userPoints,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        title: Row(
          children: [
            const FaIcon(
              FontAwesomeIcons.gift,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(width: AppSizes.paddingSM),
            const Text('Sovg\'ani olish'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reward.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppSizes.paddingSM),
            Text(reward.description),
            const SizedBox(height: AppSizes.paddingMD),
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSizes.radiusMD),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Sarflanadi:'),
                  Text(
                    '${reward.requiredPoints.formatted} ball',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.warning,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await ref
                  .read(rewardsProvider.notifier)
                  .redeemReward(reward.id, userPoints);
              
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    success
                        ? 'Tabriklaymiz! Sovg\'a olindi!'
                        : 'Xatolik yuz berdi',
                  ),
                  backgroundColor: success ? AppColors.success : AppColors.error,
                ),
              );
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }
}
