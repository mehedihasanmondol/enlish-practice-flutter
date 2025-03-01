import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ImageLoader {
  // Function to check and load image either locally or from network
  static Future<ImageProvider> loadImage(String imageUrl) async {
    // Get the directory to save image
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/images/${Uri.parse(imageUrl).pathSegments.last}';

    // Check if the image exists locally
    final file = File(filePath);
    if (await file.exists()) {
      return FileImage(file); // Return local image
    } else {
      await _downloadImage(imageUrl, file);
      return FileImage(file); // Return newly downloaded image
    }
  }

  // Download image and save it locally
  static Future<void> _downloadImage(String url, File file) async {
    try {
      final response = await Dio().get(url, options: Options(responseType: ResponseType.bytes));
      final bytes = response.data;
      if (bytes != null) {
        await file.create(recursive: true);
        await file.writeAsBytes(bytes);
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
  }
}
