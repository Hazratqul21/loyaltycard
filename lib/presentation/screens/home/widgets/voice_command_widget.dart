/// ==========================================================================
/// voice_command_widget.dart
/// ==========================================================================
/// Ovozli komandalar interfeysi (Avatar Glow bilan).
/// ==========================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/services/voice_assistant_service.dart';
import '../../../providers/cards_provider.dart';
import '../../exchange/exchange_screen.dart';

class VoiceCommandWidget extends ConsumerStatefulWidget {
  const VoiceCommandWidget({super.key});

  @override
  ConsumerState<VoiceCommandWidget> createState() => _VoiceCommandWidgetState();
}

class _VoiceCommandWidgetState extends ConsumerState<VoiceCommandWidget> {
  bool _isListening = false;
  String _text = 'Sizni eshityapman...';

  void _startVoice() async {
    final service = ref.read(voiceAssistantServiceProvider);
    setState(() {
      _isListening = true;
      _text = 'Sizni eshityapman...';
    });

    await service.startListening((recognizedText) {
      setState(() => _text = recognizedText);
      _processText(recognizedText);
    });
  }

  void _processText(String text) async {
    final service = ref.read(voiceAssistantServiceProvider);
    final intent = service.parseCommand(text);

    await Future.delayed(const Duration(seconds: 1));

    if (intent == 'get_points') {
      final totalPoints = await ref.read(totalPointsProvider.future);
      await service
          .speak('Sizning jami ballaringiz $totalPoints tani tashkil etadi.');
      if (mounted) Navigator.pop(context);
    } else if (intent == 'open_exchange') {
      await service.speak('Ayirboshlash bo\'limini ochyapman.');
      if (mounted) {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ExchangeScreen()));
      }
    } else if (intent == 'show_card') {
      await service.speak('Hamyoningizni ochyapman.');
      // Bu yerda Navigation tabini o'zgartirish kerak (MainNavigationScreen orqali)
      if (mounted) Navigator.pop(context);
    } else {
      await service.speak('Kechirasiz, komandani tushunmadim.');
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            _isListening ? 'Ovozli Boshqaruv' : 'Tayyormisiz?',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          AvatarGlow(
            animate: _isListening,
            glowColor: AppColors.primaryColor,
            endRadius: 60.0,
            duration: const Duration(milliseconds: 2000),
            repeatPauseDuration: const Duration(milliseconds: 100),
            repeat: true,
            child: GestureDetector(
              onTap: _isListening ? null : _startVoice,
              child: CircleAvatar(
                backgroundColor: AppColors.primaryColor,
                radius: 35.0,
                child: FaIcon(
                  _isListening
                      ? FontAwesomeIcons.microphone
                      : FontAwesomeIcons.microphoneSlash,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: _isListening ? AppColors.primaryColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Masalan: "Qancha ballim bor?" yoki "Ayirboshlash"',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
