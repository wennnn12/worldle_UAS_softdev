import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final bool hasWon;
  final int attempts;
  final VoidCallback onRetry;

  const ResultDialog({
    required this.hasWon,
    required this.attempts,
    required this.onRetry,
    Key? key,
  }) : super(key: key);

  void handleReset(BuildContext context) {
    Navigator.pop(context);
    onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(hasWon ? 'YOU WIN' : 'YOU LOSE'),
      content: Text('Attempts: $attempts'),
      actions: [
        TextButton(
          onPressed: () => handleReset(context),
          child: Text('Retry'),
        ),
      ],
    );
  }
}
