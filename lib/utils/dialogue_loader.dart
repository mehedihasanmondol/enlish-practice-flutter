import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/dialogue_model.dart';

class DialogueLoader {
  static Future<List<Dialogue>> loadDialogues() async {
    String data = await rootBundle.loadString('assets/dialogues.json');
    List<dynamic> jsonResult = json.decode(data);
    return jsonResult.map((e) => Dialogue.fromJson(e)).toList();
  }
}
