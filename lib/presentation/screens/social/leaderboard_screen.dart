/// ==========================================================================
/// leaderboard_screen.dart
/// ==========================================================================
/// Global va do'stlar orasidagi reyting ekrani.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/social_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final socialState = ref.watch(socialProvider);
    final currentUser = ref.watch(authProvider).user;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reyting'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Multi-tab header (Global / Friends)
          _buildPrivacyToggle(ref, socialState.isPrivacyOptIn),
          
          Expanded(
            child: socialState.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : _buildList(socialState.globalLeaderboard, currentUser?.uid),
          ),
          
          // User's own rank indicator at the bottom
          if (socialState.isPrivacyOptIn && currentUser != null)
            _buildUserRankSummary(currentUser),
        ],
      ),
    );
  }

  Widget _buildPrivacyToggle(WidgetRef ref, bool isOptIn) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: GlassmorphicCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reytingda qatnashish', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  Text('Ballaringiz barcha foydalanuvchilarga ko\'rinadi', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            Switch.adaptive(
              value: isOptIn,
              onChanged: (val) => ref.read(socialProvider.notifier).togglePrivacy(val),
              activeColor: AppColors.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<LeaderboardEntry> entries, String? currentUserId) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isMe = entry.userId == currentUserId;
        final rank = index + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: isMe ? AppColors.primaryColor.withOpacity(0.1) : Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: isMe ? Border.all(color: AppColors.primaryColor.withOpacity(0.3)) : null,
          ),
          child: ListTile(
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildRankBadge(rank),
                const SizedBox(width: 12),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                  child: Text(entry.displayName[0], style: const TextStyle(color: AppColors.primaryColor)),
                ),
              ],
            ),
            title: Text(entry.displayName, style: TextStyle(fontWeight: isMe ? FontWeight.bold : FontWeight.normal)),
            subtitle: Text(entry.tier, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${entry.points.toString()} pts', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (isMe) const Text('Siz', style: TextStyle(fontSize: 10, color: AppColors.primaryColor, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankBadge(int rank) {
    Color color = Colors.grey;
    if (rank == 1) color = AppColors.warning; // Gold
    if (rank == 2) color = Colors.blueGrey; // Silver
    if (rank == 3) color = Colors.brown; // Bronze

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: rank <= 3 ? color : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: TextStyle(
            color: rank <= 3 ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildUserRankSummary(user) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('SIZNING O\'RNINGIZ', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('#8 Dunyo bo\'yicha', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Top 10 ga kirish'),
          ),
        ],
      ),
    );
  }
}
