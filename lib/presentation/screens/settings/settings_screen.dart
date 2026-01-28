/// ==========================================================================
/// settings_screen.dart
/// ==========================================================================
/// Sozlamalar sahifasi - profil, tema, backup/restore, sync status.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/sync_service.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cards_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/merchant_provider.dart';
import '../../providers/social_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../auth/login_screen.dart';
import '../../../core/services/referral_service.dart';

final referralServiceProvider = Provider((ref) => ReferralService());

/// Sozlamalar ekrani
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;
  bool _isBackingUp = false;
  bool _isRestoring = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeModeProvider);
    final connectivityStatus = ref.watch(connectivityStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
        centerTitle: true,
        actions: [
          // Connectivity indicator
          connectivityStatus.when(
            data: (status) => Padding(
              padding: const EdgeInsets.only(right: AppSizes.paddingMD),
              child: Icon(
                status == ConnectivityStatus.connected
                    ? Icons.cloud_done
                    : Icons.cloud_off,
                color: status == ConnectivityStatus.connected
                    ? AppColors.success
                    : Colors.grey,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const Icon(Icons.cloud_off, color: Colors.grey),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sync status banner
            if (authState.isAuthenticated) _buildSyncStatusBanner(),

            // Profil bo'limi
            if (authState.isAuthenticated) ...[
              _buildSectionTitle('Profil'),
              _buildProfileCard(authState.user!),
              const SizedBox(height: AppSizes.paddingLG),
            ],

            // Tema sozlamalari
            _buildSectionTitle('Ko\'rinish'),
            _buildThemeSettings(themeMode),
            const SizedBox(height: AppSizes.paddingLG),

            // Sinxronizatsiya
            if (authState.isAuthenticated) ...[
              _buildSectionTitle('Ma\'lumotlar'),
              _buildSyncSettings(),
              const SizedBox(height: AppSizes.paddingLG),
            ],

            // Hisob boshqaruvi
            _buildSectionTitle('Sodiqlik'),
            _buildReferralSection(authState.user!),
            const SizedBox(height: AppSizes.paddingLG),

            // Sotuvchi rejimi (Faqat test/demo uchun hamma ko'ra oladi, aslida role tekshiriladi)
            _buildSectionHeader(context, 'Premium & Ekosistema'),
            _buildPremiumToggle(context, ref),
            _buildMerchantMode(context, ref),
            _buildVoiceMode(context, ref),
            const SizedBox(height: AppSizes.paddingLG),

            // Til sozlamalari
            _buildSectionTitle('Til'),
            _buildLanguageSettings(ref),
            const SizedBox(height: AppSizes.paddingLG),

            _buildSectionTitle('Hisob'),
            _buildAccountSettings(authState),

            const SizedBox(height: AppSizes.paddingXL),

            // Chiqish tugmasi
            if (authState.isAuthenticated) _buildLogoutButton(),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  /// Sync status banner
  Widget _buildSyncStatusBanner() {
    final syncService = ref.read(syncServiceProvider);
    final lastSync = syncService.lastSyncTime;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingMD),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor.withOpacity(0.1),
            AppColors.accentColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        border: Border.all(
          color: AppColors.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const FaIcon(
              FontAwesomeIcons.cloudArrowUp,
              size: 16,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bulut sinxronizatsiya',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  lastSync != null
                      ? 'Oxirgi: ${_formatTime(lastSync)}'
                      : 'Hali sinxronlanmagan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          if (_isSyncing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.sync, color: AppColors.primaryColor),
              onPressed: _syncData,
            ),
        ],
      ),
    );
  }

  /// Vaqtni formatlash
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa oldin';
    if (diff.inHours < 24) return '${diff.inHours} soat oldin';
    return '${diff.inDays} kun oldin';
  }

  /// Bo'lim sarlavhasi
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSizes.paddingSM,
        bottom: AppSizes.paddingSM,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.primaryColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPremiumToggle(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const FaIcon(FontAwesomeIcons.crown, color: AppColors.warning, size: 20),
      title: const Text('Premium Obuna'),
      subtitle: const Text('Eksklyuziv takliflar va yuqori ayirboshlash kursi'),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text('AKTIVLASHTIRISH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.warning)),
      ),
      onTap: () {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hozirda premium obuna qo\'shilmoqda...')),
        );
      },
    );
  }

  Widget _buildMerchantMode(BuildContext context, WidgetRef ref) {
    final isMerchant = ref.watch(isMerchantModeProvider);
    return SwitchListTile.adaptive(
      title: const Text('Sotuvchi rejimi'),
      subtitle: const Text('Do\'kon xodimlari uchun maxsus interfeys'),
      secondary: const FaIcon(FontAwesomeIcons.store, size: 20),
      value: isMerchant,
      activeColor: AppColors.primaryColor,
      onChanged: (val) {
        ref.read(isMerchantModeProvider.notifier).state = val;
      },
    );
  }

  Widget _buildVoiceMode(BuildContext context, WidgetRef ref) {
    return SwitchListTile.adaptive(
      title: const Text('Ovozli boshqaruv'),
      subtitle: const Text('Komandalar orqali tezkor boshqarish'),
      secondary: const FaIcon(FontAwesomeIcons.microphone, size: 20),
      value: true,
      activeColor: AppColors.primaryColor,
      onChanged: (val) {},
    );
  }


  /// Til sozlamalari
  Widget _buildLanguageSettings(WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          _buildLanguageTile(ref, 'uz', 'O\'zbekcha', '🇺🇿', currentLocale.languageCode == 'uz'),
          const Divider(height: 1),
          _buildLanguageTile(ref, 'ru', 'Русский', '🇷🇺', currentLocale.languageCode == 'ru'),
          const Divider(height: 1),
          _buildLanguageTile(ref, 'en', 'English', '🇺🇸', currentLocale.languageCode == 'en'),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(WidgetRef ref, String code, String name, String flag, bool isSelected) {
    return _buildSettingsTile(
      icon: null, // We use flag instead
      title: name,
      onTap: () => ref.read(localeProvider.notifier).setLocale(code),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          if (isSelected)
            const Icon(Icons.check_circle, color: AppColors.primaryColor, size: 20)
          else
            const Icon(Icons.circle_outlined, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  /// Sotuvchi rejimi switch (Deprecated, use _buildMerchantMode)


  /// Profil kartasi
  Widget _buildProfileCard(user) {
    return GlassmorphicCard(
      gradientColors: AppColors.primaryGradient,
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage:
                    user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null
                    ? Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: AppSizes.fontXL,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: FaIcon(
                    _getTierIcon(user.tier),
                    size: 10,
                    color: _getTierColor(user.tier),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSizes.paddingMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.displayNameOrEmail,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppSizes.fontLG,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildTierBadge(user.tier),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: AppSizes.fontSM,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Tier Badge
  Widget _buildTierBadge(String tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTierColor(tier).withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getTierColor(tier).withOpacity(0.5)),
      ),
      child: Text(
        tier.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Tier Icon
  IconData _getTierIcon(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold': return FontAwesomeIcons.medal;
      case 'silver': return FontAwesomeIcons.award;
      case 'platinum': return FontAwesomeIcons.crown;
      default: return FontAwesomeIcons.star;
    }
  }

  /// Tier Color
  Color _getTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'gold': return const Color(0xFFFFD700);
      case 'silver': return const Color(0xFFC0C0C0);
      case 'platinum': return const Color(0xFFE5E4E2);
      default: return const Color(0xFFCD7F32); // Bronze
    }
  }

  /// Referral Section
  Widget _buildReferralSection(user) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: FontAwesomeIcons.userPlus,
            title: 'Do\'stlarni taklif qilish',
            subtitle: 'Har bir do\'stingiz uchun bonus oling',
            onTap: () => _shareReferral(user),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.referralCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          StreamBuilder<int>(
            stream: ref.read(referralServiceProvider).getReferralCount(user.uid),
            builder: (context, snapshot) {
              return _buildSettingsTile(
                icon: FontAwesomeIcons.users,
                title: 'Takliflarim',
                subtitle: '${snapshot.data ?? user.referralCount} ta do\'st taklif qilingan',
                trailing: const Icon(Icons.chevron_right),
                onTap: () {}, // Stats detail screen later
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _shareReferral(user) async {
    await ref.read(referralServiceProvider).shareReferralCode(user);
  }

  /// Tema sozlamalari
  Widget _buildThemeSettings(ThemeMode currentMode) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: FontAwesomeIcons.sun,
            title: 'Kunduzgi rejim',
            trailing: Radio<ThemeMode>(
              value: ThemeMode.light,
              groupValue: currentMode,
              onChanged: (value) => _setThemeMode(value!),
            ),
            onTap: () => _setThemeMode(ThemeMode.light),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: FontAwesomeIcons.moon,
            title: 'Tungi rejim',
            trailing: Radio<ThemeMode>(
              value: ThemeMode.dark,
              groupValue: currentMode,
              onChanged: (value) => _setThemeMode(value!),
            ),
            onTap: () => _setThemeMode(ThemeMode.dark),
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: FontAwesomeIcons.circleHalfStroke,
            title: 'Tizim rejimi',
            trailing: Radio<ThemeMode>(
              value: ThemeMode.system,
              groupValue: currentMode,
              onChanged: (value) => _setThemeMode(value!),
            ),
            onTap: () => _setThemeMode(ThemeMode.system),
          ),
        ],
      ),
    );
  }

  /// Sinxronizatsiya sozlamalari
  Widget _buildSyncSettings() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: FontAwesomeIcons.cloudArrowUp,
            title: 'Backup qilish',
            subtitle: 'Barcha ma\'lumotlarni bulutga saqlash',
            trailing: _isBackingUp
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isBackingUp ? null : _showBackupDialog,
          ),
          const Divider(height: 1),
          _buildSettingsTile(
            icon: FontAwesomeIcons.cloudArrowDown,
            title: 'Restore qilish',
            subtitle: 'Bulutdan ma\'lumotlarni tiklash',
            trailing: _isRestoring
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.chevron_right),
            onTap: _isRestoring ? null : _showRestoreDialog,
          ),
        ],
      ),
    );
  }

  /// Hisob sozlamalari
  Widget _buildAccountSettings(AuthState authState) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
      ),
      child: Column(
        children: [
          if (!authState.isAuthenticated)
            _buildSettingsTile(
              icon: FontAwesomeIcons.rightToBracket,
              title: 'Kirish',
              subtitle: 'Ma\'lumotlarni sinxronlash uchun',
              onTap: _navigateToLogin,
            ),
          _buildSettingsTile(
            icon: FontAwesomeIcons.circleInfo,
            title: 'Ilova haqida',
            subtitle: 'Versiya 1.0.0',
            onTap: _showAboutDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSizes.radiusSM),
        ),
        child: Center(
          child: FaIcon(icon, size: 18, color: AppColors.primaryColor),
        ),
      ),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const FaIcon(FontAwesomeIcons.rightFromBracket, size: 18),
        label: const Text('Chiqish'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: AppSizes.paddingMD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMD),
          ),
        ),
      ),
    );
  }

  // ==================== Actions ====================

  void _setThemeMode(ThemeMode mode) {
    ref.read(themeModeProvider.notifier).setThemeMode(mode);
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    final syncService = ref.read(syncServiceProvider);
    final result = await syncService.syncAll();

    setState(() => _isSyncing = false);

    _showResultSnackBar(
      result.isSuccess,
      result.isSuccess
          ? 'Sinxronlash muvaffaqiyatli!'
          : result.errorMessage ?? 'Xatolik!',
    );
  }

  void _showBackupDialog() {
    _showGlassmorphicDialog(
      title: 'Backup qilish',
      icon: FontAwesomeIcons.cloudArrowUp,
      iconColor: AppColors.primaryColor,
      message:
          'Barcha kartalar, tranzaksiyalar va sovg\'alar bulutga yuklanadi.',
      confirmText: 'Backup',
      onConfirm: _backupData,
    );
  }

  Future<void> _backupData() async {
    Navigator.pop(context);
    setState(() => _isBackingUp = true);

    final syncService = ref.read(syncServiceProvider);
    final result = await syncService.backup();

    setState(() => _isBackingUp = false);

    _showResultSnackBar(
      result.isSuccess,
      result.isSuccess
          ? 'Backup muvaffaqiyatli! ${result.uploadedCount} ta element saqlandi'
          : result.errorMessage ?? 'Xatolik!',
    );
  }

  void _showRestoreDialog() {
    _showGlassmorphicDialog(
      title: 'Restore qilish',
      icon: FontAwesomeIcons.triangleExclamation,
      iconColor: AppColors.warning,
      message:
          'Diqqat! Joriy ma\'lumotlar o\'chib, bulutdagi ma\'lumotlar bilan almashtiriladi.',
      confirmText: 'Restore',
      confirmColor: AppColors.warning,
      onConfirm: _restoreData,
    );
  }

  Future<void> _restoreData() async {
    Navigator.pop(context);
    setState(() => _isRestoring = true);

    final syncService = ref.read(syncServiceProvider);
    final result = await syncService.restore();

    setState(() => _isRestoring = false);

    if (result.isSuccess) {
      // Reload data
      await ref.read(cardsProvider.notifier).loadCards();
      await ref.read(transactionsProvider.notifier).loadTransactions();
      await ref.read(rewardsProvider.notifier).loadRewards();
    }

    _showResultSnackBar(
      result.isSuccess,
      result.isSuccess
          ? 'Restore muvaffaqiyatli! ${result.downloadedCount} ta element tiklandi'
          : result.errorMessage ?? 'Xatolik!',
    );
  }

  void _showLogoutDialog() {
    _showGlassmorphicDialog(
      title: 'Chiqish',
      icon: FontAwesomeIcons.rightFromBracket,
      iconColor: AppColors.error,
      message: 'Haqiqatan ham hisobingizdan chiqmoqchimisiz?',
      confirmText: 'Chiqish',
      confirmColor: AppColors.error,
      onConfirm: () async {
        Navigator.pop(context);
        await ref.read(authProvider.notifier).signOut();
        Navigator.pop(context); // Close settings
      },
    );
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'LoyaltyCard',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        padding: const EdgeInsets.all(AppSizes.paddingSM),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: AppColors.primaryGradient),
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: const FaIcon(FontAwesomeIcons.crown, color: Colors.white),
      ),
      children: const [
        Text('Universal sodiqlik kartasi ilovasi.'),
        SizedBox(height: 8),
        Text('© 2026 LoyaltyCard'),
      ],
    );
  }

  // ==================== Dialogs & Helpers ====================

  void _showGlassmorphicDialog({
    required String title,
    required IconData icon,
    required Color iconColor,
    required String message,
    required String confirmText,
    Color confirmColor = AppColors.primaryColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassmorphicCard(
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingMD),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: FaIcon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: AppSizes.paddingMD),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.paddingSM),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSizes.paddingLG),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Bekor qilish'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMD),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(confirmText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showResultSnackBar(bool success, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
      ),
    );
  }
}
