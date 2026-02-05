/// ==========================================================================
/// phone_login_screen.dart
/// ==========================================================================
/// Telefon raqami orqali kirish ekrani.
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';
import 'otp_verify_screen.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (!_formKey.currentState!.validate()) return;
    if (_phoneController.text.length < 9) return;

    await ref.read(authNotifierProvider.notifier).verifyPhoneNumber(
          phoneNumber: '+998${_phoneController.text}',
          onCodeSent: (verificationId, resendToken) {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtpVerifyScreen(
                    verificationId: verificationId,
                    phoneNumber: '+998${_phoneController.text}',
                  ),
                ),
              );
            }
          },
          onVerificationFailed: (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Xatolik: ${e.message}')),
              );
            }
          },
          onVerificationCompleted: (credential) {
            // Auto sign-in handled by listener or separate logic if needed
          },
          onCodeAutoRetrievalTimeout: (verificationId) {
            // Timeout handling
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon:
                      const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.paddingLG),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSizes.paddingXL),
                      // Animatsiyali Icon
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 800),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.paddingLG),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const FaIcon(
                            FontAwesomeIcons.mobileScreenButton,
                            size: 48,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                      const Text(
                        'Telefon raqami',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSM),
                      Text(
                        'Tasdiqlash kodini yuborish uchun raqamingizni kiriting',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXXL),

                      // Glass Input
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        child: Form(
                          key: _formKey,
                          child: Row(
                            children: [
                              const Text(
                                '+998',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    letterSpacing: 2,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '90 123 45 67',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      letterSpacing: 2,
                                    ),
                                    border: InputBorder.none,
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Raqamni kiriting';
                                    }
                                    if (value.replaceAll(' ', '').length < 9) {
                                      return 'Raqam noto\'g\'ri';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXXL),

                      GradientButton.primary(
                        text: 'Kodni yuborish',
                        isLoading: authState.isLoading,
                        onPressed: _sendCode,
                        width: double.infinity,
                      ),
                      const SizedBox(height: AppSizes.paddingLG),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Boshqa usul bilan kirish',
                          style:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
