/// ==========================================================================
/// exchange_screen.dart
/// ==========================================================================
/// Ballarni ayirboshlash ekrani (Multi-currency points).
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/cards_provider.dart';
import '../../../core/services/partner_network_service.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../../domain/entities/loyalty_card.dart';

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key});

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  LoyaltyCard? _sourceCard;
  LoyaltyCard? _targetCard;
  final TextEditingController _amountController = TextEditingController();
  int _calculatedPoints = 0;
  bool _isExchanging = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateCalculatedPoints);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _updateCalculatedPoints() {
    if (_sourceCard == null ||
        _targetCard == null ||
        _amountController.text.isEmpty) {
      if (_calculatedPoints != 0) setState(() => _calculatedPoints = 0);
      return;
    }

    final amount = int.tryParse(_amountController.text) ?? 0;
    final service = ref.read(partnerNetworkServiceProvider);

    // In demo, we mock store IDs if they aren't in partners list
    final fromId = PartnerNetworkService.partners
            .any((p) => p.name == _sourceCard!.storeName)
        ? PartnerNetworkService.partners
            .firstWhere((p) => p.name == _sourceCard!.storeName)
            .id
        : 'korzinka';
    final toId = PartnerNetworkService.partners
            .any((p) => p.name == _targetCard!.storeName)
        ? PartnerNetworkService.partners
            .firstWhere((p) => p.name == _targetCard!.storeName)
            .id
        : 'makro';

    setState(() {
      _calculatedPoints =
          service.calculateConvertedPoints(fromId, toId, amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardsState = ref.watch(cardsProvider);
    final theme = Theme.of(context);

    // Filter cards that are in partner network (simplified for demo)
    final partnerCards = cardsState.cards;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ballarni Ayirboshlash'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Qaybi kartadan o\'tkazmoqchisiz?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCardSelector(partnerCards, true),
            const SizedBox(height: 24),
            const Center(
              child: FaIcon(FontAwesomeIcons.rightLeft,
                  color: AppColors.primaryColor, size: 24),
            ),
            const SizedBox(height: 24),
            const Text(
              'Qaysi kartaga o\'tkazmoqchisiz?',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCardSelector(partnerCards, false),
            const SizedBox(height: 32),
            if (_sourceCard != null && _targetCard != null) ...[
              Text(
                'O\'tkaziladigan miqdor (${_sourceCard!.storeName})',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ballar miqdorini kiriting',
                  suffixText: 'ball',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(FontAwesomeIcons.coins, size: 16),
                ),
              ),
              const SizedBox(height: 24),
              _buildExchangePreview(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isExchanging ? null : _handleExchange,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isExchanging
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Ayirboshlashni tasdiqlash'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardSelector(List<LoyaltyCard> cards, bool isSource) {
    final selectedCard = isSource ? _sourceCard : _targetCard;

    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          final isSelected = selectedCard?.id == card.id;

          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSource) {
                  _sourceCard = card;
                  if (_targetCard?.id == card.id) _targetCard = null;
                } else {
                  if (_sourceCard?.id != card.id) _targetCard = card;
                }
              });
              _updateCalculatedPoints();
            },
            child: Container(
              width: 160,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? card.color.withValues(alpha: 0.2)
                    : Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? card.color : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: card.color.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        card.storeName[0],
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.storeName,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${card.currentPoints} pts',
                          style:
                              const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExchangePreview() {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const Text('Sizdan',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text(
                  '${_amountController.text.isEmpty ? "0" : _amountController.text} pts',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_sourceCard!.storeName,
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
          const FaIcon(FontAwesomeIcons.arrowRight,
              size: 16, color: Colors.grey),
          Column(
            children: [
              const Text('Sizga',
                  style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text('$_calculatedPoints pts',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success)),
              Text(_targetCard!.storeName,
                  style: const TextStyle(fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleExchange() async {
    final amount = int.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return;
    if (amount > _sourceCard!.currentPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mablag\' yetarli emas')),
      );
      return;
    }

    setState(() => _isExchanging = true);

    final success = await ref.read(cardsProvider.notifier).exchangePoints(
          fromCardId: _sourceCard!.id,
          toCardId: _targetCard!.id,
          fromAmount: amount,
          toAmount: _calculatedPoints,
        );

    if (mounted) {
      setState(() => _isExchanging = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Muvaffaqiyatli ayirboshlandi! 🎉'),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xatolik yuz berdi')),
        );
      }
    }
  }
}
