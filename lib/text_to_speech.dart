
import 'package:flutter_tts/flutter_tts.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TextToSpeechService {
  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  TextToSpeechService(this._flutterTts) {
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage('ar-SA'); // Arabic (Saudi Arabia)
    await _flutterTts.setSpeechRate(0.5); // Slower for learning
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    _flutterTts.setCompletionHandler(() {
      print('TTS Completed');
    });

    _flutterTts.setErrorHandler((msg) {
      print('TTS Error: $msg');
    });

    _isInitialized = true;
  }

  Future<void> speak(String text) async {
    if (!_isInitialized) await _initializeTts();
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume);
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch);
  }

  Future<void> setLanguage(String language) async {
    await _flutterTts.setLanguage(language);
  }

  Future<bool> isLanguageAvailable(String language) async {
    return await _flutterTts.isLanguageAvailable(language) ?? false;
  }

  Future<List<dynamic>> getLanguages() async {
    return await _flutterTts.getLanguages;
  }

  Future<List<dynamic>> getVoices() async {
    return await _flutterTts.getVoices;
  }

  Future<void> setVoice(Map<String, String> voice) async {
    await _flutterTts.setVoice(voice);
  }

  // Speak question with options
  Future<void> speakQuestion(String question, List<String> options) async {
    String fullText = question + '. ';
    for (var i = 0; i < options.length; i++) {
      fullText += 'الخيار ${i + 1}: ${options[i]}. ';
    }
    await speak(fullText);
  }

  // Speak feedback
  Future<void> speakFeedback(bool isCorrect, String explanation) async {
    if (isCorrect) {
      await speak('إجابة صحيحة! $explanation');
    } else {
      await speak('إجابة خاطئة. $explanation');
    }
  }

  Future<bool> isSpeaking() async {
    return await _flutterTts.isSpeaking;
  }
}
