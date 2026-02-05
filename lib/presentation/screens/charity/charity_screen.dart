/// ==========================================================================
/// charity_screen.dart
/// ==========================================================================
/// Ballarni xayriyaga yo'naltirish ekrani.
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/cards_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class CharityScreen extends ConsumerWidget {
  const CharityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPoints = ref.watch(totalPointsProvider).value ?? 0;

    // Mock charity partners
    final partners = [
      const CharityPartner(
        id: 'c1',
        name: 'Ezgu Amal',
        description: 'Saraton bilan og\'rigan bolalarga yordam fondi',
        logoUrl: 'https://placeholder.com/ezgu_amal',
        category: 'Salomatlik',
        totalRaisedPoints: 1250000,
      ),
      const CharityPartner(
        id: 'c2',
        name: 'Orolni Qutqar',
        description: 'Orol dengizi atrofini ko\'kalamzorlashtirish',
        logoUrl: 'https://placeholder.com/aral',
        category: 'Ekologiya',
        totalRaisedPoints: 850000,
      ),
      const CharityPartner(
        id: 'c3',
        name: 'Mehrli Qo\'llar',
        description: 'Kam ta\'minlangan oilalarga oziq-ovqat yordami',
        logoUrl: 'https://placeholder.com/mehr',
        category: 'Ijtimoiy',
        totalRaisedPoints: 2100000,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Xayriya'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, totalPoints),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCharityItem(context, partners[index]),
                childCount: partners.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int points) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.05),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const FaIcon(FontAwesomeIcons.handHoldingHeart,
              size: 50, color: AppColors.primaryColor),
          const SizedBox(height: 16),
          const Text(
            'Ezgu ishga hissa qo\'shing',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Sizning jami ballaringiz: $points',
            style: const TextStyle(
                color: AppColors.primaryColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildCharityItem(BuildContext context, partner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicCard(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(child: Text(partner.name[0])),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(partner.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(partner.category,
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(partner.description,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.7,
              backgroundColor: Colors.white10,
              valueColor: const AlwaysStoppedAnimation(AppColors.primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${partner.totalRaisedPoints} ball yig\'ildi',
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                TextButton(
                  onPressed: () {},
                  child: const Text('Ball berish',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CharityPartner {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final int totalRaisedPoints;
  final String category;

  const CharityPartner({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    this.totalRaisedPoints = 0,
    required this.category,
  });
}
