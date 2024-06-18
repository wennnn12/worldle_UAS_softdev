import 'package:flutter/material.dart';
import 'guessBarChart.dart';

class ResultDialog extends StatelessWidget {
  final bool hasWon;
  final int attempts;
  final Future<void> Function() onRetry;
  final Map<String, dynamic>? stats;
  final bool isGuest;
  final Map<int, int> guessStats;
  final int barsCount;

  const ResultDialog({
    required this.hasWon,
    required this.attempts,
    required this.onRetry,
    this.stats,
    this.isGuest = true,
    required this.guessStats,
    required this.barsCount,
    Key? key,
  }) : super(key: key);

  void handleReset(BuildContext context) async {
    Navigator.pop(context);
    await onRetry();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFCDD2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      hasWon ? Icons.thumb_up : Icons.thumb_down,
                      size: 40,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              hasWon ? 'AMAZING!' : 'NICE TRY!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
                fontFamily: 'Fraunces',
              ),
            ),
          ],
        ),
        content: isGuest
            ? Text(
                hasWon ? ' $attempts Attempts! Impressive... LOGIN to see all your statistics! ' : 'LOGIN to see all your statistics!',
                style: TextStyle(fontFamily: 'Schyler', fontSize: 16),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'STATISTICS',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'FranklinGothic',
                      color: Colors.grey, // Light grey color
                    ),
                  ),
                  if (stats != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              '${stats!['matchesPlayed']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFamily: 'Schyler',
                              ),
                            ),
                            Text(
                              'Match',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${(stats!['winPercentage']).toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFamily: 'Schyler',
                              ),
                            ),
                            Text(
                              'Win %',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${stats!['winStreak']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFamily: 'Schyler',
                              ),
                            ),
                            Text(
                              'Streak',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              '${stats!['highestWinStreak']}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                fontFamily: 'Schyler',
                              ),
                            ),
                            Text(
                              'Max Streaks',
                              style: TextStyle(
                                fontFamily: 'Schyler',
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Text(
                      'No statistics available',
                      style: TextStyle(
                        fontFamily: 'Schyler',
                      ),
                    ),

                  SizedBox(height: 10),
                  GuessStatsBarChart(
                    guessStats: guessStats, 
                    barsCount: barsCount,
                    hasWon: hasWon,
                    attempts: attempts,
                  ),
                ],
              ),
        actions: [
          Column(
            children: [
              Text(
                'Play Again?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'FranklinGothic',
                  color: Colors.grey,
                ),
              ),
              Divider(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 140, 255, 186),
                  minimumSize: Size(175, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                onPressed: () => handleReset(context),
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 0, 45, 10),
                    fontFamily: 'FranklinGothic',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
