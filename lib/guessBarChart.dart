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
                      color: Colors.grey[300],
                    ),
                    Container(
                      height: 20,
                      width: (count / (guessStats.values.isEmpty ? 1 : guessStats.values.reduce((a, b) => a > b ? a : b))) * MediaQuery.of(context).size.width,
                      color: Colors.green[300],
                    ),
                    Positioned.fill(
                      child: Center(
                        child: Text('$count', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
