/// ==========================================================================
/// notification_settings_screen.dart
/// ==========================================================================
/// Bildirishnoma sozlamalari ekrani.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/notification_service.dart';
import '../../widgets/glassmorphic_card.dart';

/// Notification settings provider
final notificationSettingsProvider =
    StateProvider<NotificationSettings>((ref) => const NotificationSettings());

/// NotificationService provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = NotificationService.instance;
  ref.onDispose(() => service.dispose());
  return service;
});

/// Notification Settings Screen
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final service = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirishnomalar'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asosiy switch
            GlassmorphicCard(
              gradientColors: settings.enabled
                  ? AppColors.primaryGradient
                  : [Colors.grey.shade400, Colors.grey.shade500],
              padding: const EdgeInsets.all(AppSizes.paddingMD),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const FaIcon(
                      FontAwesomeIcons.bell,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingMD),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bildirishnomalar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: AppSizes.fontLG,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          settings.enabled ? 'Yoqilgan' : 'O\'chirilgan',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: AppSizes.fontSM,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: settings.enabled,
                    onChanged: (value) {
                      final newSettings = settings.copyWith(enabled: value);
                      ref.read(notificationSettingsProvider.notifier).state =
                          newSettings;
                      service.updateSettings(newSettings);
                    },
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingLG),

            // Kategoriyalar
            _buildSectionTitle(context, 'Kategoriyalar'),
            _buildSettingsCard(
              context,
              enabled: settings.enabled,
              children: [
                _buildToggleTile(
                  context: context,
                  icon: FontAwesomeIcons.tag,
                  title: 'Aksiyalar',
                  subtitle: 'Chegirmalar va maxsus takliflar',
                  value: settings.promotions,
                  enabled: settings.enabled,
                  onChanged: (value) {
                    final newSettings = settings.copyWith(promotions: value);
                    ref.read(notificationSettingsProvider.notifier).state =
                        newSettings;
                    service.updateSettings(newSettings);
                  },
                ),
                const Divider(height: 1),
                _buildToggleTile(
                  context: context,
                  icon: FontAwesomeIcons.gift,
                  title: 'Sovg\'alar',
                  subtitle: 'Yangi mukofotlar haqida',
                  value: settings.rewards,
                  enabled: settings.enabled,
                  onChanged: (value) {
                    final newSettings = settings.copyWith(rewards: value);
                    ref.read(notificationSettingsProvider.notifier).state =
                        newSettings;
                    service.updateSettings(newSettings);
                  },
                ),
                const Divider(height: 1),
                _buildToggleTile(
                  context: context,
                  icon: FontAwesomeIcons.coins,
                  title: 'Ballar',
                  subtitle: 'Ball qo\'shilganda/sarflanganda',
                  value: settings.points,
                  enabled: settings.enabled,
                  onChanged: (value) {
                    final newSettings = settings.copyWith(points: value);
                    ref.read(notificationSettingsProvider.notifier).state =
                        newSettings;
                    service.updateSettings(newSettings);
                  },
                ),
                const Divider(height: 1),
                _buildToggleTile(
                  context: context,
                  icon: FontAwesomeIcons.store,
                  title: 'Do\'konlar',
                  subtitle: 'Do\'konlardan yangiliklar',
                  value: settings.stores,
                  enabled: settings.enabled,
                  onChanged: (value) {
                    final newSettings = settings.copyWith(stores: value);
                    ref.read(notificationSettingsProvider.notifier).state =
                        newSettings;
                    service.updateSettings(newSettings);
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingLG),

            // Sozlamalar
            _buildSectionTitle(context, 'Sozlamalar'),
            _buildSettingsCard(
              context,
              enabled: settings.enabled,
              children: [
                _buildToggleTile(
                  context: context,
                  icon: FontAwesomeIcons.volumeHigh,
                  title: 'Ovoz',
                  subtitle: 'Bildirishnoma ovozi',
                  value: settings.sound,
                  enabled: settings.enabled,
                  onChanged: (value) {
                    final newSettings = settings.copyWith(sound: value);
                    ref.read(notificationSettingsProvider.notifier).state =
                        newSettings;
                    service.updateSettings(newSettings);
                  },
                ),
                const Divider(height: 1),
                _buildToggleTile(
                  context: context,
                  icon: FontAwesomeIcons.mobile,
                  title: 'Tebranish',
                  subtitle: 'Telefon tebranishi',
                  value: settings.vibration,
                  enabled: settings.enabled,
                  onChanged: (value) {
                    final newSettings = settings.copyWith(vibration: value);
                    ref.read(notificationSettingsProvider.notifier).state =
                        newSettings;
                    service.updateSettings(newSettings);
                  },
                ),
              ],
            ),

            const SizedBox(height: AppSizes.paddingLG),

            // Test notification
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: settings.enabled
                    ? () => service.sendTestNotification()
                    : null,
                icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 16),
                label: const Text('Test bildirishnoma yuborish'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSizes.paddingMD,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
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

  Widget _buildSettingsCard(
    BuildContext context, {
    required bool enabled,
    required List<Widget> children,
  }) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        ),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildToggleTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required ValueChanged<bool> onChanged,
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
          child: FaIcon(icon, size: 16, color: AppColors.primaryColor),
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch.adaptive(
        value: value && enabled,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
