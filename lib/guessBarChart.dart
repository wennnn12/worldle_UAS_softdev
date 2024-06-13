import 'package:flutter/material.dart';

class GuessStatsBarChart extends StatelessWidget {
  final Map<int, int> guessStats;
  final int barsCount;

  const GuessStatsBarChart({required this.guessStats, required this.barsCount, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(barsCount, (index) {
        int count = guessStats[index + 1] ?? 0;
        double maxWidth = MediaQuery.of(context).size.width - 40; // Adjust width as needed
        double barWidth = (count / (guessStats.values.isEmpty ? 1 : guessStats.values.reduce((a, b) => a > b ? a : b))) * maxWidth;

        // Ensure a minimal width for bars with count 0
        if (barWidth == 0) {
          barWidth = 20; // Minimal width for count 0
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text('${index + 1}'),
              SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      width: barWidth,
                      color: Colors.green[300],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      }),
    );
  }
}
