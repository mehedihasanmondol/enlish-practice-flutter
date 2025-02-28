class Chat {
  final String bot;
  final String user;

  Chat({required this.bot, required this.user});

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      bot: json["bot"] ?? "",
      user: json["user"] ?? "",
    );
  }
}

class Dialogue {
  final String name;
  final String lastMessage;
  final String image;
  final String time;
  final bool isActive;
  final List<Chat> chats;

  Dialogue({
    required this.name,
    required this.lastMessage,
    required this.image,
    required this.time,
    required this.isActive,
    required this.chats,
  });

  factory Dialogue.fromJson(Map<String, dynamic> json) {
    return Dialogue(
      name: json["name"] ?? "",
      lastMessage: json["lastMessage"] ?? "",
      image: json["image"] ?? "",
      time: json["time"] ?? "",
      isActive: json["isActive"] ?? false,
      chats: (json["dialogs"] as List<dynamic>)
          .map((chat) => Chat.fromJson(chat))
          .toList(),
    );
  }
}
