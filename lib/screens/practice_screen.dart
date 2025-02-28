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
            CircleAvatar(
              backgroundImage: NetworkImage(widget.dialogue.image),
            ),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView.builder(
                itemCount: chatMessages.length,
                itemBuilder: (context, index) =>
                    Message(message: chatMessages[index]),
              ),
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00BF6D),
        child: ChatScreen(
          dialogues:widget.dialogue.chats,
          onBotSpeak: (botMessage) {

            setState(() {
              chatMessages.add(
                  ChatMessage(
                    text: botMessage,
                    messageType: ChatMessageType.text,
                    messageStatus: MessageStatus.viewed,
                    isSender: false,
                  )
              );
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
            });

            // You can update UI, log, or trigger other actions here
          },

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
      child: Row(
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
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        message!.text,
        style: TextStyle(
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

enum MessageStatus { notSent, notView, viewed }

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


