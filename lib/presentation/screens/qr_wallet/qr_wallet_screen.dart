/// ==========================================================================
/// qr_wallet_screen.dart
/// ==========================================================================
/// QR hamyon sahifasi - foydalanuvchi QR kodi.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/qr_service.dart';
import '../../../core/services/storage_service.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';

/// User ID provider - lazy initialization
final userIdProvider = StateProvider<String>((ref) {
  var userId = StorageService.getUserId();
  if (userId == null) {
    userId = QrService.generateUuid();
    StorageService.setUserId(userId);
  }
  return userId;
});

/// QR Wallet ekrani
class QrWalletScreen extends ConsumerStatefulWidget {
  const QrWalletScreen({super.key});

  @override
  ConsumerState<QrWalletScreen> createState() => _QrWalletScreenState();
}

class _QrWalletScreenState extends ConsumerState<QrWalletScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppSizes.animationMedium),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
    if (_isFullScreen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);
    final qrData = QrService.generateUserQrCode(userId);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text(AppStrings.wallet),
              centerTitle: true,
            ),
      body: GestureDetector(
        onTap: _isFullScreen ? _toggleFullScreen : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: AppSizes.animationMedium),
          color: _isFullScreen
              ? Colors.white
              : Theme.of(context).scaffoldBackgroundColor,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // QR kod kartasi
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: _isFullScreen ? _scaleAnimation.value : 1.0,
                        child: child,
                      ),
                      child: GestureDetector(
                        onTap: _isFullScreen ? null : _toggleFullScreen,
                        child: GlassmorphicCard(
                          padding: const EdgeInsets.all(AppSizes.paddingLG),
                          gradientColors: _isFullScreen
                              ? null
                              : AppColors.primaryGradient,
                          child: Column(
                            children: [
                              if (!_isFullScreen) ...[
                                const FaIcon(
                                  FontAwesomeIcons.qrcode,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                const SizedBox(height: AppSizes.paddingSM),
                                const Text(
                                  AppStrings.yourQrCode,
                                  style: TextStyle(
                                    fontSize: AppSizes.fontXL,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingXS),
                                const Text(
                                  AppStrings.showToScanner,
                                  style: TextStyle(
                                    fontSize: AppSizes.fontSM,
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: AppSizes.paddingMD),
                              ],
                              
                              // QR kod
                              Container(
                                padding: const EdgeInsets.all(AppSizes.paddingMD),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusLG,
                                  ),
                                ),
                                child: QrImageView(
                                  data: qrData,
                                  version: QrVersions.auto,
                                  size: _isFullScreen ? 280 : 200,
                                  backgroundColor: Colors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.primaryColor,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              
                              if (!_isFullScreen) ...[
                                const SizedBox(height: AppSizes.paddingMD),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingMD,
                                    vertical: AppSizes.paddingSM,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(
                                      AppSizes.radiusSM,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const FaIcon(
                                        FontAwesomeIcons.fingerprint,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'ID: ${QrService.shortenId(userId)}',
                                        style: const TextStyle(
                                          fontSize: AppSizes.fontSM,
                                          color: Colors.white,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (!_isFullScreen) ...[
                      const SizedBox(height: AppSizes.paddingXL),

                      // Ko'rsatmalar
                      _buildInstructionCard(
                        context,
                        isDarkMode,
                        icon: FontAwesomeIcons.one,
                        title: 'QR kodni ko\'rsating',
                        description:
                            'To\'lov vaqtida kassirga QR kodingizni ko\'rsating',
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      _buildInstructionCard(
                        context,
                        isDarkMode,
                        icon: FontAwesomeIcons.two,
                        title: 'Ballarni yig\'ing',
                        description: 'Har bir xaridda ballar avtomatik yig\'iladi',
                      ),
                      const SizedBox(height: AppSizes.paddingMD),
                      _buildInstructionCard(
                        context,
                        isDarkMode,
                        icon: FontAwesomeIcons.three,
                        title: 'Sovg\'alar oling',
                        description: 'Ballarni chegirmalar va sovg\'alarga ayirboshlang',
                      ),

                      const SizedBox(height: AppSizes.paddingXL),

                      // Katta ko'rish tugmasi
                      GradientButton.accent(
                        text: 'To\'liq ekranda ko\'rish',
                        icon: FontAwesomeIcons.expand,
                        onPressed: _toggleFullScreen,
                        width: double.infinity,
                      ),
                    ],

                    if (_isFullScreen) ...[
                      const SizedBox(height: AppSizes.paddingLG),
                      const Text(
                        'Yopish uchun bosing',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: AppSizes.fontMD,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(
    BuildContext context,
    bool isDarkMode, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSizes.radiusSM),
            ),
            child: Center(
              child: FaIcon(
                icon,
                color: AppColors.primaryColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
