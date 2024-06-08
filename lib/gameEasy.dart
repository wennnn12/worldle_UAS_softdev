import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result_dialog.dart';

class GameEasy extends StatefulWidget {
  final String initialTargetWord;

  const GameEasy({Key? key, required this.initialTargetWord}) : super(key: key);

  @override
  State<GameEasy> createState() => _GameEasyState();
}

class _GameEasyState extends State<GameEasy> {
  late String targetWord;
  List<String> gridContent = List.generate(30, (index) => '');
  List<Color> gridColors = List.generate(30, (index) => Colors.red);
  int currentRow = 0;
  int attempts = 0;
  bool isGuest = true;  // Assume user is a guest by default
  User? currentUser;
  Map<String, dynamic>? userStats; // Store user stats

  @override
  void initState() {
    super.initState();
    targetWord = widget.initialTargetWord;
    _checkUser();
  }

  Future<void> _checkUser() async {
    currentUser = FirebaseAuth.instance.currentUser;
    setState(() {
      isGuest = currentUser == null;
    });
    if (!isGuest) {
      await _fetchUserStats();
    }
  }

  Future<void> _fetchUserStats() async {
    final statsRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('stats').doc('easy');
    final statsDoc = await statsRef.get();
    if (statsDoc.exists) {
      setState(() {
        userStats = statsDoc.data();
      });
    }
  }

  Future<void> _fetchRandomWord() async {
    final wordList = await FirebaseFirestore.instance.collection('Wordlists').get();
    final words = wordList.docs.map((doc) => doc['word'] as String).toList();
    words.shuffle();
    setState(() {
      targetWord = words.isNotEmpty ? words.first : 'ERROR';
    });
  }

  void handleKeyPress(String letter) {
    setState(() {
      int startIndex = currentRow * 5;
      int endIndex = startIndex + 5;

      for (int i = startIndex; i < endIndex; i++) {
        if (gridContent[i].isEmpty) {
          gridContent[i] = letter;
          break;
        }
      }
    });
  }

  void handleDeletePress() {
    setState(() {
      int startIndex = currentRow * 5;
      int endIndex = startIndex + 5;

      for (int i = endIndex - 1; i >= startIndex; i--) {
        if (gridContent[i].isNotEmpty) {
          gridContent[i] = '';
          break;
        }
      }
    });
  }

  Future<void> handleSubmit() async {
    int startIndex = currentRow * 5;
    int endIndex = startIndex + 5;

    bool isRowComplete = true;
    for (int i = startIndex; i < endIndex; i++) {
      if (gridContent[i].isEmpty) {
        isRowComplete = false;
        break;
      }
    }

    if (isRowComplete) {
      attempts++;
      bool hasWon = true;

      Map<String, int> targetLetterCounts = {};
      for (int i = 0; i < targetWord.length; i++) {
        String letter = targetWord[i];
        if (!targetLetterCounts.containsKey(letter)) {
          targetLetterCounts[letter] = 0;
        }
        targetLetterCounts[letter] = targetLetterCounts[letter]! + 1;
      }

      for (int i = 0; i < 5; i++) {
        if (gridContent[startIndex + i] == targetWord[i]) {
          gridColors[startIndex + i] = Colors.green;
          targetLetterCounts[gridContent[startIndex + i]] =
              targetLetterCounts[gridContent[startIndex + i]]! - 1;
        } else {
          gridColors[startIndex + i] = Colors.grey;
          hasWon = false;
        }
      }

      for (int i = 0; i < 5; i++) {
        if (gridColors[startIndex + i] != Colors.green &&
            targetLetterCounts[gridContent[startIndex + i]] != null &&
            targetLetterCounts[gridContent[startIndex + i]]! > 0) {
          gridColors[startIndex + i] = Colors.yellow;
          targetLetterCounts[gridContent[startIndex + i]] =
              targetLetterCounts[gridContent[startIndex + i]]! - 1;
        }
      }

      if (hasWon) {
        await _updateStats(true);
        _showResultDialog(true);
      } else if (currentRow >= 5) {
        await _updateStats(false);
        _showResultDialog(false);
      } else {
        setState(() {
          currentRow++;
        });
      }
    }
  }

  void _showResultDialog(bool hasWon) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        hasWon: hasWon,
        attempts: attempts,
        onRetry: () async {
          await _fetchRandomWord();
          handleReset();
        },
        stats: isGuest ? null : userStats, // Only show stats if user is not a guest
        isGuest: isGuest,
      ),
    );
  }

  Future<void> _updateStats(bool hasWon) async {
    if (isGuest) return;

    final statsRef = FirebaseFirestore.instance.collection('users').doc(currentUser!.uid).collection('stats').doc('easy');

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final statsDoc = await transaction.get(statsRef);

      if (!statsDoc.exists) {
        transaction.set(statsRef, {
          'matchesPlayed': 1,
          'wins': hasWon ? 1 : 0,
          'winStreak': hasWon ? 1 : 0,
          'highestWinStreak': hasWon ? 1 : 0,
        });
      } else {
        final data = statsDoc.data()!;
        final matchesPlayed = data['matchesPlayed'] + 1;
        final wins = data['wins'] + (hasWon ? 1 : 0);
        final winStreak = hasWon ? data['winStreak'] + 1 : 0;
        final highestWinStreak = hasWon && winStreak > data['highestWinStreak'] ? winStreak : data['highestWinStreak'];

        transaction.update(statsRef, {
          'matchesPlayed': matchesPlayed,
          'wins': wins,
          'winStreak': winStreak,
          'highestWinStreak': highestWinStreak,
        });

        // Update the local state to reflect new stats
        setState(() {
          userStats = {
            'matchesPlayed': matchesPlayed,
            'winPercentage': (wins / matchesPlayed) * 100,
            'winStreak': winStreak,
            'highestWinStreak': highestWinStreak,
          };
        });
      }
    });
  }

  void handleReset() {
    setState(() {
      gridContent = List.generate(30, (index) => '');
      gridColors = List.generate(30, (index) => Colors.red);
      currentRow = 0;
      attempts = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Worldle'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 7,
            child: Container(
              color: Colors.yellow,
              child: Grid(gridContent: gridContent, gridColors: gridColors),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.green,
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: Keyboard(
                      onKeyPressed: handleKeyPress,
                      onDeletePressed: handleDeletePress,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: handleSubmit,
                            child: Text('Submit', style: TextStyle(fontSize: 18)),
                          ),
                          SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: handleReset,
                            child: Text('Reset', style: TextStyle(fontSize: 18)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Grid extends StatelessWidget {
  final List<String> gridContent;
  final List<Color> gridColors;

  const Grid({required this.gridContent, required this.gridColors, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(30, 20, 36, 20),
      itemCount: gridContent.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        crossAxisCount: 5,
      ),
      itemBuilder: (context, index) {
        return Container(
          color: gridColors[index],
          child: Center(
            child: Text(
              gridContent[index],
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}

class Keyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function() onDeletePressed;

  const Keyboard({required this.onKeyPressed, required this.onDeletePressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> keys = [
      'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
      'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
      'Z', 'X', 'C', 'V', 'B', 'N', 'M'
    ];

    return Column(
      children: [
        Expanded(
          flex: 4,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.all(10),
            itemCount: keys.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  onKeyPressed(keys[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      keys[index],
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          flex: 1,
          child: Center(
            child: ElevatedButton(
              onPressed: onDeletePressed,
              child: Text('Delete', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),
      ],
    );
  }
}
