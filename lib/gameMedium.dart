import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'result_dialog.dart';

class GameMedium extends StatefulWidget {
  final String initialTargetWord;

  const GameMedium({Key? key, required this.initialTargetWord}) : super(key: key);

  @override
  State<GameMedium> createState() => _GameMediumState();
}

class _GameMediumState extends State<GameMedium> {
  late String targetWord;
  List<String> gridContent = List.generate(25, (index) => '');
  List<Color> gridColors = List.generate(25, (index) => Colors.red);
  int currentRow = 0;
  int attempts = 0;

  @override
  void initState() {
    super.initState();
    targetWord = widget.initialTargetWord;
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

 void handleSubmit() {
  setState(() {
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

      // First pass: Identify and mark correct letters (green)
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
          targetLetterCounts[gridContent[startIndex + i]] = targetLetterCounts[gridContent[startIndex + i]]! - 1;
        } else {
          gridColors[startIndex + i] = Colors.grey;
          hasWon = false;
        }
      }

      // Second pass: Identify correct letters in incorrect positions (yellow)
      for (int i = 0; i < 5; i++) {
        if (gridColors[startIndex + i] != Colors.green && targetLetterCounts[gridContent[startIndex + i]] != null && targetLetterCounts[gridContent[startIndex + i]]! > 0) {
          gridColors[startIndex + i] = Colors.yellow;
          targetLetterCounts[gridContent[startIndex + i]] = targetLetterCounts[gridContent[startIndex + i]]! - 1;
        }
      }

      if (hasWon) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ResultDialog(
            hasWon: true,
            attempts: attempts,
            onRetry: () async {
              await _fetchRandomWord();
              handleReset();
            },
          ),
        );
      } else if (currentRow >= 4) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => ResultDialog(
            hasWon: false,
            attempts: attempts,
            onRetry: () async {
              await _fetchRandomWord();
              handleReset();
            },
          ),
        );
      } else {
        currentRow++;
      }
    }
  });
}


  void handleReset() {
    setState(() {
      gridContent = List.generate(25, (index) => '');
      gridColors = List.generate(25, (index) => Colors.red);
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
