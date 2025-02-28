import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }
}
