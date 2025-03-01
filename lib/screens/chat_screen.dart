import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import '../models/dialogue_model.dart';

class ChatScreen extends StatefulWidget {
  final List<Chat> dialogues;
  final Function(String)? onBotSpeak; // Optional Callback
  final Function(String)? onHint; // Optional Callback
  final Function(String)? onUserSpeak; // Optional Callback
  final Function()? onDialogueComplete; // Optional Callback
  final Function()? onStartAgain; // Optional Callback
  const ChatScreen({super.key,
    required this.dialogues,
    this.onBotSpeak,
    this.onUserSpeak,
    this.onDialogueComplete,
    this.onStartAgain,
    this.onHint,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  late List<Chat> _dialogues = [];
  int _currentIndex = 0;
  String _userSpeech = "";
  bool _isListening = false;
  bool _startAgain = false;
  int _maxRetry = 3;
  int _currentRetry = 0;
  bool _isSpeaking = false; // রোবট কথা বললে true
  double _soundLevel = 0.0; // সাউন্ড লেভেল ট্র্যাক করতে হবে
  bool _stopRequested = false; // ইউজার যদি স্টপ বাটন চাপ দেয়

  @override
  void initState() {
    super.initState();
    _dialogues = widget.dialogues;
  }


  Future<void> _speakBotDialogue() async {

    if (_dialogues.isNotEmpty && _currentIndex < _dialogues.length) {
      setState(() => _isSpeaking = true); // রোবট কথা বলছে

      // Trigger callback when bot starts speaking
      widget.onBotSpeak?.call(_dialogues[_currentIndex].bot);

      await _flutterTts.speak(_dialogues[_currentIndex].bot);

      _flutterTts.setCompletionHandler(() {
        setState(() => _isSpeaking = false); // কথা বলা শেষ
        // Trigger callback when bot starts speaking
        widget.onHint?.call(_dialogues[_currentIndex].user);
        _startListening(); // এখন ইউজারের কথা শোনা শুরু হবে
      });
    }
  }

  Future<void> _startListening() async {
    _justStopListening();

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
          if (_isSpeaking || _stopRequested) return;

          _soundLevel = level;

          if (level > 0.3) {
            // Reset silence timer if user is speaking
            silenceTimer?.cancel();
          }
          else {
            defaultSilenceTimer?.cancel();
            defaultSilenceTimer = Timer(const Duration(seconds: 4), () {
              if(_userSpeech == ""){
                _stopListening(); // Stop listening if no speech is detected for 2 seconds
              }
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
  void _justStopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
      _userSpeech = "";
    });
  }


  void _forceStopListening() {
    _speechToText.stop();
    setState(() {
      _isListening = false;
      _stopRequested = true; // ইউজার ইচ্ছা করে বন্ধ করলো
    });
  }


  Future<void> _checkUserResponse() async {

    // Trigger callback when bot starts speaking
    widget.onUserSpeak?.call(_userSpeech);

    if (_userSpeech.trim().toLowerCase() == _dialogues[_currentIndex].user.trim().toLowerCase()) {
      // Trigger callback when bot starts speaking
      widget.onBotSpeak?.call("Correct! Well done.");

      await _speakMessage("Correct! Well done.");
      setState(() async {
        _currentIndex++;
        _currentRetry = 0;
        if (_currentIndex < _dialogues.length) {
          _flutterTts.setCompletionHandler(() {
            _speakBotDialogue();

          });


        }
        else{

          // Trigger callback when bot starts speaking
          widget.onDialogueComplete?.call();
          _startAgain = true;
          // Trigger callback when bot starts speaking

          widget.onBotSpeak?.call("You are Successfully completed the dialogue.");
          await _speakMessage("You are Successfully completed the dialogue.");
        }
      });
    }
    else if(_userSpeech.trim().toLowerCase() ==""){
      _currentRetry++;
      // Trigger callback when bot starts speaking
      widget.onBotSpeak?.call("Sorry! You didn't say anything.");
      await _speakMessage("Sorry! You didn't say anything.");
      if (_currentRetry >= _maxRetry) {
        _forceStopListening();
        return;
      }


    }
    else {
      _currentRetry++;
      // Trigger callback when bot starts speaking
      widget.onBotSpeak?.call("Incorrect. Try again.");
      await _speakMessage("Incorrect. Try again.");

      if (_currentRetry >= _maxRetry) {
        _forceStopListening();
        return;
      }

    }

  }

  Future<void> _speakMessage(String message) async {
    setState(() => _isSpeaking = true); // রোবট কথা বলছে
    await _flutterTts.speak(message);
    _flutterTts.setCompletionHandler(() {

      setState(() => _isSpeaking = false); // রোবট কথা বলা শেষ
      if (_currentIndex < _dialogues.length) {
        _startListening(); // ইউজারের কথা শোনা শুরু হবে

      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return
      _startAgain ?
      IconButton(
        onPressed: (){
          setState(() {
            _startAgain = false;
            _currentIndex = 0;
          });

          // Trigger callback when bot starts speaking
          widget.onStartAgain?.call();
          _speakBotDialogue();
        },
        icon: Icon(
          Icons.restart_alt,
          color: Colors.white,
        ),
      )
      :
      _isListening ?
      IconButton(
        onPressed: (){
          _forceStopListening();
        },
        icon: Icon(
          Icons.stop_circle,
          color: Colors.white,
        ),
      )
      :

      IconButton(
      onPressed: (){
        setState(() {
          _currentRetry = 0;
          _stopRequested = false; // ইউজার ইচ্ছা করে বন্ধ করলো
        });

        _speakBotDialogue();


      },
      icon: Icon(
        Icons.play_circle_filled,
        color: Colors.white,
      ),
    );


  }
}
