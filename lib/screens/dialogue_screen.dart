import 'package:english_practice/screens/practice_screen.dart';
import 'package:flutter/material.dart';
import '../models/dialogue_model.dart';
import '../utils/dialogue_loader.dart';
import '../utils/image_loader.dart';
import '../widgets/smart_image.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});
  static List chatsData = [];

  @override
  DialogueScreenState createState() => DialogueScreenState();
}

class DialogueScreenState extends State<DialogueScreen> {
  bool isDownloading = false;
  Future<void> startDownload() async {
    setState(() {
      isDownloading = true;
    });

    try {
      var loadedData = await DialogueLoader.downloadJson();
      setState(() {
        DialogueScreen.chatsData = loadedData;
      });

    } catch (e) {
      print("Error: ${e.toString()}");
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadDialogues();
  }

  Future<void> _loadDialogues() async {

    var loadedData = await DialogueLoader.loadDialogues();
    setState(() {
      DialogueScreen.chatsData = loadedData;
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
            BackButton(),
            const Text("Dialogues")
          ],
        ),

      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
            color: const Color(0xFF00BF6D),
            child: Row(
              children: [
                const SizedBox(width: 16.0),
                FillOutlineButton(
                  press: () {
                    isDownloading ? null : startDownload();
                  },
                  text: isDownloading ? "Downloading..." : "Update Dialogue",
                  isFilled: false,
                  icon: Icons.cloud_download,

                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: DialogueScreen.chatsData.length,
              itemBuilder: (context, index) => ChatCard(
                chat: DialogueScreen.chatsData[index],
                press: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PracticeScreen(dialogue: DialogueScreen.chatsData[index])),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00BF6D),
        child: const Icon(
          Icons.person_add_alt_1,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ChatCard extends StatelessWidget {
  const ChatCard({
    super.key,
    required this.chat,
    required this.press,
  });

  final Dialogue chat;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0 * 0.75),
        child: Row(
          children: [
            CircleAvatarWithActiveIndicator(
              image: chat.image,
              isActive: chat.isActive,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Opacity(
                      opacity: 0.64,
                      child: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Opacity(
              opacity: 0.64,
              child: Text(chat.time),
            ),
          ],
        ),
      ),
    );
  }
}

class FillOutlineButton extends StatelessWidget {
  const FillOutlineButton({
    super.key,
    this.isFilled = true,
    required this.press,
    required this.text,
    this.icon, // Optional icon parameter
  });

  final bool isFilled;
  final VoidCallback press;
  final String text;
  final IconData? icon; // Nullable icon

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: Colors.white),
      ),
      elevation: isFilled ? 2 : 0,
      color: isFilled ? Colors.white : Colors.transparent,
      onPressed: press,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: isFilled ? const Color(0xFF1D1D35) : Colors.white),
            const SizedBox(width: 8), // Space between icon and text
          ],
          Text(
            text,
            style: TextStyle(
              color: isFilled ? const Color(0xFF1D1D35) : Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class CircleAvatarWithActiveIndicator extends StatelessWidget {
  const CircleAvatarWithActiveIndicator({
    super.key,
    this.image,
    this.radius = 24,
    this.isActive = false, // Default value to prevent null errors
  });

  final String? image;
  final double? radius;
  final bool? isActive;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SmartImage(imageUrl: image),
        if (isActive == true) // Prevent null errors
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              height: 16,
              width: 16,
              decoration: BoxDecoration(
                color: const Color(0xFF00BF6D),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

