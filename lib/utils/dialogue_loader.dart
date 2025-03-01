import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import '../models/dialogue_model.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DialogueLoader {
  static const String fileName = "dialogues.json";
  static const String url = "https://cdn.websitelimited.com/dialogues.json";

  /// Loads dialogues, checking if a downloaded file exists
  static Future<List<Dialogue>> loadDialogues() async {
    // First, try loading from local storage
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName';

    File file = File(filePath);

    if (await file.exists()) {
      // If the file exists, load dialogues from the downloaded file
      String data = await file.readAsString();
      List<dynamic> jsonResult = json.decode(data);
      return jsonResult.map((e) => Dialogue.fromJson(e)).toList();
    } else {
      // If no downloaded file exists, load from the default assets file
      String data = await rootBundle.loadString('assets/$fileName');
      List<dynamic> jsonResult = json.decode(data);
      return jsonResult.map((e) => Dialogue.fromJson(e)).toList();
    }
  }

  /// Downloads the JSON file and saves it locally, returns a list of dialogues
  static Future<List<Dialogue>> downloadJson() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Directory directory = await getApplicationDocumentsDirectory();
        String filePath = '${directory.path}/$fileName';

        File file = File(filePath);
        await file.writeAsString(response.body); // Save as string instead of bytes

        // Parse the downloaded JSON and return the list of Dialogue objects
        List<dynamic> jsonResult = json.decode(response.body);
        return jsonResult.map((e) => Dialogue.fromJson(e)).toList();
      } else {
        throw Exception("Failed to download file: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error downloading JSON: ${e.toString()}");
    }
  }
}
