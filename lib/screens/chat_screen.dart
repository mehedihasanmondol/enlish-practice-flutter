import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/dialogue_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  List<Dialogue> _dialogues = [];
  int _currentIndex = 0;
  String _userSpeech = "";
  bool _isListening = false;
  int _maxRetry = 3;
  int _currentRetry = 0;
  bool _isSpeaking = false; // রোবট কথা বললে true
  double _soundLevel = 0.0; // সাউন্ড লেভেল ট্র্যাক করতে হবে
  bool _stopRequested = false; // ইউজার যদি স্টপ বাটন চাপ দেয়

  @override
  void initState() {
    super.initState();
    _speakBotDialogue();
  }


  Future<void> _speakBotDialogue() async {
    if (_dialogues.isNotEmpty && _currentIndex < _dialogues.length) {
      setState(() => _isSpeaking = true); // রোবট কথা বলছে

      await _flutterTts.speak(_dialogues[_currentIndex].bot);

      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false); // কথা বলা শেষ
        _startListening(); // এখন ইউজারের কথা শোনা শুরু হবে
      });
    }
  }

  Future<void> _startListening() async {

    if (_isSpeaking || _isListening || _stopRequested) return;

    bool available = await _speechToText.initialize();
    if (available) {
      setState(() {
        _isListening = true;
      });

      Timer? silenceTimer; // Timer to detect silence
      Timer? defaultSilenceTimer; // Timer to detect silence by default behavior

      _speechToText.listen(
        onResult: (result) {
          debugPrint("User said: " + result.toString());
          setState(() {
            _userSpeech = result.recognizedWords;
          });

          // Reset silence timer when user speaks
          silenceTimer?.cancel();
          silenceTimer = Timer(const Duration(seconds: 2), () {
            _stopListening(); // Stop listening if no speech is detected for 2 seconds
          });
        },
        onSoundLevelChange: (level) {
          if (_stopRequested) return;


          _soundLevel = level;

          if (level > 0.3) {
            // Reset silence timer if user is speaking
            silenceTimer?.cancel();
          }
          else{
            defaultSilenceTimer?.cancel();
            defaultSilenceTimer = Timer(const Duration(seconds: 1), () {
              _stopListening(); // Stop listening if no speech is detected for 2 seconds
            });

          }

        },
      );
    }
  }

  void _stopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _checkUserResponse();
  }

  void _forceStopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
      _stopRequested = true; // ইউজার ইচ্ছা করে বন্ধ করলো
    });
  }


  Future<void> _checkUserResponse() async {

    print("current try: $_currentRetry");
    if (_userSpeech.trim().toLowerCase() == _dialogues[_currentIndex].user.trim().toLowerCase()) {
      await _speakMessage("Correct! Well done.");
      setState(() {
        _currentIndex++;
        _currentRetry = 0;
        if (_currentIndex < _dialogues.length) {
          _speakBotDialogue();
        }
      });
    }
    else if(_userSpeech.trim().toLowerCase() ==""){
      _currentRetry++;
      await _speakMessage("Sorry! You didn't say anything.");
      if (_currentRetry >= _maxRetry) {
        _forceStopListening();
        return;
      }
      if(!_stopRequested){
        _startListening();
      }

    }
    else {
      _currentRetry++;
      await _speakMessage("Incorrect. Try again.");

      if (_currentRetry >= _maxRetry) {
        _forceStopListening();
        return;
      }
      if(!_stopRequested){
        _startListening();
      }
    }
  }

  Future<void> _speakMessage(String message) async {
    setState(() => _isSpeaking = true); // রোবট কথা বলছে
    await _flutterTts.speak(message);
    _flutterTts.setCompletionHandler(() {
      setState(() => _isSpeaking = false); // রোবট কথা বলা শেষ
      _startListening(); // ইউজারের কথা শোনা শুরু হবে
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Practice Chat")),
      body: Column(
        children: [
          Text(
            _dialogues.isNotEmpty ? _dialogues[_currentIndex].bot : "Loading...",
            style: const TextStyle(fontSize: 20),
          ),
          !_isListening ?
          ElevatedButton(
            onPressed: (){
              setState(() {
                _currentRetry = 0;
                _stopRequested = false; // ইউজার ইচ্ছা করে বন্ধ করলো
              });

              if (_isListening) {
                _stopListening();
              }
              else{
                _startListening();
              }

            },
            child: Text(_isListening ? "Listening..." : "Tap to Speak"),
          )
          :
          ElevatedButton(
            onPressed: _forceStopListening, // নতুন স্টপ বাটন
            child: const Text("Stop Listening"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red,foregroundColor: Colors.white),
          ),
          Text("You said: $_userSpeech", style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
