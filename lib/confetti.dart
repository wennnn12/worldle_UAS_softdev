import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

class ConfettiAnimation extends StatefulWidget {
  final bool hasWon;

  const ConfettiAnimation({required this.hasWon, Key? key}) : super(key: key);

  @override
  _ConfettiAnimationState createState() => _ConfettiAnimationState();
}

class _ConfettiAnimationState extends State<ConfettiAnimation> {
  late ConfettiController _controllerLeft;
  late ConfettiController _controllerRight;

  @override
  void initState() {
    super.initState();
    _controllerLeft = ConfettiController(duration: const Duration(seconds: 2));
    _controllerRight = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controllerLeft.play();
      _controllerRight.play();
    });
  }

  @override
  void dispose() {
    _controllerLeft.dispose();
    _controllerRight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 500, // Adjust this value to ensure visibility
          left: 0,
          child: ConfettiWidget(
            confettiController: _controllerLeft,
            blastDirection: -pi / 3, // Blasts at a 60-degree angle to the right
            maxBlastForce: 150, // Adjust blast force to cover the screen
            minBlastForce: 10,
            emissionFrequency: 0.5,
            numberOfParticles: 2,
            gravity: 1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ], // Add colors to confetti
          ),
        ),
        Positioned(
          bottom: 500, // Adjust this value to ensure visibility
          right: 0,
          child: ConfettiWidget(
            confettiController: _controllerRight,
            blastDirection: -2 * pi / 3, // Blasts at a 120-degree angle to the left
            maxBlastForce: 150, // Adjust blast force to cover the screen
            minBlastForce: 10,
            emissionFrequency: 0.5,
            numberOfParticles: 2,
            gravity: 1,
            shouldLoop: false,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
            ], // Add colors to confetti
          ),
        ),
      ],
    );
  }
}
