import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/locale_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/wallet/cards_wallet_screen.dart';
import 'presentation/screens/scanner/scanner_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

class LoyaltyCardApp extends ConsumerWidget {
  const LoyaltyCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'LoyaltyCard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: const [
        Locale('uz'),
        Locale('ru'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: authState.when(
        data: (user) =>
            user != null ? const MainNavigationScreen() : const LoginScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (err, stack) => Scaffold(
          body: Center(child: Text('Error: $err')),
        ),
      ),
    );
  }
}

// Main Navigation Screen with Bottom Navigation Bar
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CardsWalletScreen(),
    const ScannerScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
  ];

  /// Navigation items
  static const List<_NavItem> _navItems = [
    _NavItem(icon: FontAwesomeIcons.house, activeIcon: FontAwesomeIcons.house),
    _NavItem(
        icon: FontAwesomeIcons.wallet, activeIcon: FontAwesomeIcons.wallet),
    _NavItem(
        icon: FontAwesomeIcons.qrcode, activeIcon: FontAwesomeIcons.qrcode),
    _NavItem(icon: FontAwesomeIcons.heart, activeIcon: FontAwesomeIcons.heart),
    _NavItem(icon: FontAwesomeIcons.gear, activeIcon: FontAwesomeIcons.gear),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 10, bottom: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: _navItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isActive = index == _currentIndex;

            return GestureDetector(
              onTap: () => setState(() => _currentIndex = index),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FaIcon(
                      isActive ? item.activeIcon : item.icon,
                      size: 22,
                      color: isActive ? AppTheme.accentPurple : Colors.black45,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? AppTheme.accentPurple
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Navigation item model
class _NavItem {
  final IconData icon;
  final IconData activeIcon;

  const _NavItem({required this.icon, required this.activeIcon});
}
