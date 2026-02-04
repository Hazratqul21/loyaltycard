/// ==========================================================================
/// otp_verify_screen.dart
/// ==========================================================================
/// SMS kodni tasdiqlash ekrani.
/// ==========================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OtpVerifyScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController();
  int _timerSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _timerSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) return;

    final success =
        await ref.read(authNotifierProvider.notifier).signInWithPhoneCode(
              verificationId: widget.verificationId,
              smsCode: _otpController.text,
            );

    if (success.isSuccess) {
      if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success.errorMessage ?? 'Kod noto\'g\'ri kiritildi'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                      Container(
                        padding: const EdgeInsets.all(AppSizes.paddingLG),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(
                          FontAwesomeIcons.envelopeOpenText,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXL),
                      const Text(
                        'Kodni kiriting',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingSM),
                      Text(
                        '${widget.phoneNumber} raqamiga yuborilgan 6 xonali kodni kiriting',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXXL),
                      GlassmorphicCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSizes.paddingMD,
                          horizontal: AppSizes.paddingXL,
                        ),
                        child: TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 10,
                          ),
                          maxLength: 6,
                          decoration: const InputDecoration(
                            counterText: '',
                            hintText: '000000',
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            if (value.length == 6) _verifyOtp();
                          },
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXXL),
                      GradientButton.primary(
                        text: 'Tasdiqlash',
                        isLoading: authState.isLoading,
                        onPressed: _verifyOtp,
                        width: double.infinity,
                      ),
                      const SizedBox(height: AppSizes.paddingLG),
                      _timerSeconds > 0
                          ? Text(
                              'Qayta yuborish: ${_timerSeconds}s',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5)),
                            )
                          : TextButton(
                              onPressed: () {
                                setState(() => _timerSeconds = 60);
                                _startTimer();
                                // TODO: Qayta yuborish logikasini authProvider ga qo'shish
                              },
                              child: const Text(
                                'Kodni qayta yuborish',
                                style: TextStyle(color: Colors.white),
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
