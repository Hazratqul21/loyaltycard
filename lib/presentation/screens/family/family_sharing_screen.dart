/// ==========================================================================
/// family_sharing_screen.dart
/// ==========================================================================
/// Oilaviy guruh va ballarni birgalikda yig'ish ekrani.
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/family_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class FamilySharingScreen extends ConsumerWidget {
  const FamilySharingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyState = ref.watch(familyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oilaviy Hamyon'),
        centerTitle: true,
      ),
      body: familyState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : familyState.group == null
              ? _buildNoGroup(context)
              : _buildGroupContent(context, familyState.group!),
    );
  }

  Widget _buildNoGroup(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLG),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(FontAwesomeIcons.users, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            const Text(
              'Hali oilaviy guruhga qo\'shilmagansiz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Oila a\'zolaringiz bilan ballarni birgalikda yig\'ing va sovg\'alarga tezroq erishing!',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Guruh yaratish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupContent(BuildContext context, familyGroup) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shared Balance Card
          _buildBalanceCard(familyGroup),
          const SizedBox(height: 24),

          const Text(
            'Guruh a\'zolari',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: familyGroup.members.length,
            itemBuilder: (context, index) {
              final member = familyGroup.members[index];
              return _buildMemberTile(member);
            },
          ),

          const SizedBox(height: 24),
          _buildAddMemberButton(context),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(familyGroup) {
    return GlassmorphicCard(
      gradientColors: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Column(
        children: [
          const Text(
            'UMUMIY OILAVIY HAMYON',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${familyGroup.sharedWalletBalance} ball',
            style: const TextStyle(
                color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatsItem('A\'zolar', '${familyGroup.members.length} ta'),
              Container(width: 1, height: 30, color: Colors.white24),
              _buildStatsItem('Guruh nomi', familyGroup.name),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 10)),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMemberTile(member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryColor.withOpacity(0.1),
          child: Text(member.displayName[0],
              style: const TextStyle(color: AppColors.primaryColor)),
        ),
        title: Text(member.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(member.role == 'admin' ? 'Administrator' : 'A\'zo',
            style: const TextStyle(fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('+${member.contributedPoints}',
                style: const TextStyle(
                    color: AppColors.success, fontWeight: FontWeight.bold)),
            const Text('qo\'shgan',
                style: TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddMemberButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Oila a\'zosini taklif qilish'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
