import 'package:speech_to_text/speech_to_text.dart';

class SpeechRecognition {
  final SpeechToText _speechToText = SpeechToText();

  Future<bool> initialize() async {
    return await _speechToText.initialize();
  }

  Future<void> startListening(Function(String) onResult) async {
    await _speechToText.listen(onResult: (result) {
      onResult(result.recognizedWords);
    });
  }

  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}
