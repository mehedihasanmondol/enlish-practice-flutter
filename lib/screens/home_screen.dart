import 'package:flutter/material.dart';
import 'dialogue_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Spoken English Practice")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const DialogueScreen()),
            );
          },
          child: const Text("Start Practicing"),
        ),
      ),
    );
  }
}
