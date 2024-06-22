import 'package:flutter/material.dart';

class GuessStatsBarChart extends StatelessWidget {
  final Map<int, int> guessStats;
  final int barsCount;
  final bool hasWon;
  final int attempts;

  const GuessStatsBarChart({
    required this.guessStats,
    required this.barsCount,
    required this.hasWon,
    required this.attempts,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(barsCount, (index) {
        int count = guessStats[index + 1] ?? 0;
        double maxWidth = MediaQuery.of(context).size.width - 40;  
        double barWidth = (count / (guessStats.values.isEmpty ? 1 : guessStats.values.reduce((a, b) => a > b ? a : b))) * maxWidth;

         
        if (barWidth == 0) {
          barWidth = 20;  
        }

         
        Color barColor = Colors.grey;
        if (hasWon && index + 1 == attempts) {
          barColor = Color.fromARGB(255, 140, 255, 186);
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
                      color: barColor,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                '$count',
                style: TextStyle(color: Color.fromARGB(255, 140, 140, 140)),
              ),
            ],
          ),
        );
      }),
    );
  }
}
