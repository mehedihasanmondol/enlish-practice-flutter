import 'dart:ffi';

import 'package:confetti/confetti.dart';
import 'package:english_practice/widgets/smart_image.dart';
import 'package:flutter/material.dart';

import '../models/dialogue_model.dart';
import 'chat_screen.dart';

class PracticeScreen extends StatefulWidget {
  final Dialogue dialogue;
  const PracticeScreen({super.key, required this.dialogue});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();

}

class _PracticeScreenState extends State<PracticeScreen> {
  final List<ChatMessage> chatMessages = [];
  final ScrollController _scrollController = ScrollController(); // Add Scroll Controller
  late ConfettiController _confettiController; // Confetti Controller
  bool _speakingMessage = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5)); // Initialize Confetti
  }

  @override
  void dispose() {
    _confettiController.dispose(); // Dispose controller to avoid memory leaks
    super.dispose();

  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        backgroundColor: const Color(0xFF00BF6D),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const BackButton(),
            SmartImage(imageUrl: widget.dialogue.image),
            const SizedBox(width: 16.0 * 0.75),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.dialogue.name,
                  style: const TextStyle(fontSize: 16),
                ),
                Text(
                  widget.dialogue.time,
                  style: const TextStyle(fontSize: 12),
                )
              ],
            )
          ],
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.local_phone),
        //     onPressed: () {},
        //   ),
        //   IconButton(
        //     icon: const Icon(Icons.videocam),
        //     onPressed: () {},
        //   ),
        //   const SizedBox(width: 16.0 / 2),
        // ],
      ),
      body: Column(
        children: [
          ConfettiWidget(
            confettiController: _confettiController, // Make sure to pass the controller
            blastDirectionality: BlastDirectionality.explosive, // Choose the direction
            shouldLoop: false, // Set to true if you want continuous confetti
            colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow], // Confetti colors
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                controller: _scrollController, // Attach Scroll Controller
                itemCount: chatMessages.length,
                itemBuilder: (context, index) =>
                    Message(message: chatMessages[index]),
              ),
            ),
          ),

          const SizedBox(height: 100)
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00BF6D),
        child: ChatScreen(
          dialogues:widget.dialogue.chats,
          onBotSpeak: (botMessage) {

            setState(() {
              _speakingMessage = false;
              chatMessages.add(
                  ChatMessage(
                    text: botMessage,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.viewed,
                    isSender: false,
                  )
              );
              _scrollToBottom(); // Scroll to bottom
            });

            // You can update UI, log, or trigger other actions here
          },
          onUserSpeak: (botMessage) {

            setState(() {
              chatMessages.add(
                  ChatMessage(
                    text: botMessage,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.viewed,
                    isSender: true,
                  )
              );
              _scrollToBottom(); // Scroll to bottom
            });

            // You can update UI, log, or trigger other actions here
          },
          onUserSpeaking: (botMessage) {
            if(_speakingMessage){
              chatMessages.removeLast();
            }
            // for (var position in _speakingMessageIndex) {
            //   chatMessages.removeAt(position);
            //
            // }
            // _speakingMessageIndex = [];

            setState(() {
              chatMessages.add(
                  ChatMessage(
                    text: botMessage,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.viewed,
                    isSender: true,
                  )
              );
              _speakingMessage = true;

              _scrollToBottom(); // Scroll to bottom
            });

            // You can update UI, log, or trigger other actions here
          },

            onHint: (botMessage) {
            setState(() {
              chatMessages.add(
                  ChatMessage(
                    text: botMessage,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.hint,
                    isSender: true,
                  )
              );
              _scrollToBottom(); // Scroll to bottom
            });

            // You can update UI, log, or trigger other actions here
          },

          onDialogueComplete: () {
            _confettiController.play(); // Play confetti animation
          },
          onStartAgain:(){
            setState(() {
              chatMessages.clear();
            });
          }

        ),
      ),
    );
  }
}



class Message extends StatelessWidget {
  const Message({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    Widget messageContaint(ChatMessage message) {
      switch (message.messageType) {
        case ChatMessageType.text:
          return TextMessage(message: message);

        default:
          return const SizedBox();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child:
      message.messageStatus == MessageStatus.hint ?
      Row(
        children: [
          Expanded(
            child: messageContaint(message),
          )
        ],
      )
      :
      Row(
        mainAxisAlignment:
        message.isSender ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isSender) ...[
            const CircleAvatar(
              radius: 12,
              backgroundImage:
              AssetImage("assets/bot_avatar.png"),
            ),
            const SizedBox(width: 16.0 / 2),
          ],
          messageContaint(message),
          if (message.isSender) MessageStatusDot(status: message.messageStatus)
        ],
      ),
    );
  }
}


class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    this.message,
  });

  final ChatMessage? message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0 * 0.75,
        vertical: 16.0 / 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF00BF6D).withOpacity(message!.isSender ? 1 : 0.1),
        borderRadius:
        message?.messageStatus == MessageStatus.hint ?
        BorderRadius.circular(0):
          BorderRadius.circular(30),
      ),
      child: Text(
        message!.text,
        style: TextStyle(

          fontSize:
          message?.messageStatus == MessageStatus.hint ?
          20.0:
          14.0
          , // Adjust the font size as needed
          color: message!.isSender
              ? Colors.white
              : Theme.of(context).textTheme.bodyLarge!.color,
        ),
      ),
    );
  }
}

class MessageStatusDot extends StatelessWidget {
  final MessageStatus? status;

  const MessageStatusDot({super.key, this.status});
  @override
  Widget build(BuildContext context) {
    Color dotColor(MessageStatus status) {
      switch (status) {
        case MessageStatus.notSent:
          return const Color(0xFFF03738);
        case MessageStatus.notView:
          return Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.1);
        case MessageStatus.viewed:
          return const Color(0xFF00BF6D);
        default:
          return Colors.transparent;
      }
    }

    return Container(
      margin: const EdgeInsets.only(left: 16.0 / 2),
      height: 12,
      width: 12,
      decoration: BoxDecoration(
        color: dotColor(status!),
        shape: BoxShape.circle,
      ),
      child: Icon(
        status == MessageStatus.notSent ? Icons.close : Icons.done,
        size: 8,
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}

enum ChatMessageType { text, audio, image, video }

enum MessageStatus { notSent, notView, viewed, hint }

class ChatMessage {
  final String text;
  final ChatMessageType messageType;
  final MessageStatus messageStatus;
  final bool isSender;

  ChatMessage({
    this.text = '',
    required this.messageType,
    required this.messageStatus,
    required this.isSender,
  });
}


