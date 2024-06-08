import 'package:flutter/material.dart';

class ResultDialog extends StatelessWidget {
  final bool hasWon;
  final int attempts;
  final Future<void> Function() onRetry;
  final Map<String, dynamic>? stats; 
  final bool isGuest;

  const ResultDialog({
    required this.hasWon,
    required this.attempts,
    required this.onRetry,
    this.stats,
    this.isGuest = true,
    Key? key,
  }) : super(key: key);

  void handleReset(BuildContext context) async {
    Navigator.pop(context);
    await onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(hasWon ? 'AMAZING!' : 'BETTER LUCK NEXT TIME!'),
      content: isGuest
         ? Text(hasWon ? 'Attempts: $attempts' : 'Better luck next time!')
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(hasWon ? Icons.thumb_up : Icons.thumb_down, size: 40, color: hasWon ? Colors.green : Colors.red),
                SizedBox(height: 10),
                Text(
                  'STATISTICS',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                stats != null
                   ? Column(
                        children: [
                          Text('Match: ${stats!['matchesPlayed']}'),
                          Text('Win %: ${(stats!['winPercentage']).toStringAsFixed(0)}'),
                          Text('Streak: ${stats!['winStreak']}'),
                          Text('Max Streak: ${stats!['highestWinStreak']}'),
                        ],
                      )
                    : Text('No statistics available'),
                SizedBox(height: 20),
                Text('GUESSES'),
                // Add guesses bar chart here if needed
              ],
            ),
      actions: [
        TextButton(
          onPressed: () => handleReset(context),
          child: Text('Play Again?'),
        ),
      ],
    );
  }
}
