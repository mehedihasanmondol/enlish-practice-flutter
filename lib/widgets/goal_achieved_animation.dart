import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class GoalAchievedScreen extends StatefulWidget {
  const GoalAchievedScreen({super.key});

  @override
  _GoalAchievedScreenState createState() => _GoalAchievedScreenState();
}

class _GoalAchievedScreenState extends State<GoalAchievedScreen> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: Duration(seconds: 2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onGoalAchieved() {
    _controller.play(); // Start confetti animation
    // You can also show a dialog or navigate to another screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Goal Achievement")),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _onGoalAchieved,
              child: Text("Achieve Goal"),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.red, Colors.blue, Colors.green, Colors.yellow],
            ),
          ),
        ],
      ),
    );
  }
}
