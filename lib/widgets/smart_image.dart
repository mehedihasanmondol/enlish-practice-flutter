import 'package:english_practice/utils/image_loader.dart';
import 'package:flutter/material.dart';

class SmartImage extends StatelessWidget {
  final String? imageUrl;
  final double? radius;

  const SmartImage({
    super.key,
    required this.imageUrl,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ImageProvider>(
      future: ImageLoader.loadImage(imageUrl ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300], // Placeholder color
            child: CircularProgressIndicator(), // Show loading indicator
          );
        } else if (snapshot.hasError || !snapshot.hasData) {
          return CircleAvatar(
            radius: radius,
            backgroundColor: Colors.grey[300], // Placeholder if error
            child: Icon(Icons.error),
          );
        } else {
          return CircleAvatar(
            radius: radius,
            backgroundImage: snapshot.data,
          );
        }
      },
    );
  }
}
