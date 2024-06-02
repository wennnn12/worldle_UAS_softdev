import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final bool hasWon;
  final int attempts;
  final Future<void> Function() onRetry;

  const ResultDialog({
    required this.hasWon,
    required this.attempts,
    required this.onRetry,
    Key? key,
  }) : super(key: key);

  void handleReset(BuildContext context) async {
    Navigator.pop(context);
    await onRetry();
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
