/// ==========================================================================
/// voice_assistant_service.dart
/// ==========================================================================
/// Ovozli boshqaruv va matnni nutqqa aylantirish xizmati.
/// ==========================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceAssistantService {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();

  bool _isSpeechInitialized = false;

  Future<bool> initialize() async {
    if (_isSpeechInitialized) return true;
    _isSpeechInitialized = await _speech.initialize();

    // Configure TTS
    await _tts.setLanguage('uz-UZ');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    return _isSpeechInitialized;
  }

  /// Ovozli eshitishni boshlash
  Future<void> startListening(Function(String) onResult) async {
    if (!_isSpeechInitialized) await initialize();

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          onResult(result.recognizedWords);
        }
      },
      localeId: 'uz_UZ', // O'zbek tili
    );
  }

  /// Eshitishni to'xtatish
  Future<void> stopListening() async {
    await _speech.stop();
  }

  /// Matnni nutqqa aylantirish
  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  /// Komandani tushunish va bajarish (Parsing intent)
  String? parseCommand(String input) {
    final text = input.toLowerCase();

    if (text.contains('ball') || text.contains('ochko')) {
      return 'get_points';
    }
    if (text.contains('karta') || text.contains('show')) {
      return 'show_card';
    }
    if (text.contains('almashtir') || text.contains('ayirbosh')) {
      return 'open_exchange';
    }

    return null;
  }
}

final voiceAssistantServiceProvider =
    Provider((ref) => VoiceAssistantService());
