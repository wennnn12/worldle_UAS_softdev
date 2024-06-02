import 'package:flutter/material.dart';
import 'result_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const String targetWord = "GHOST";
  List<String> gridContent = List.generate(30, (index) => '');
  List<Color> gridColors = List.generate(30, (index) => Colors.red);
  int currentRow = 0;
  int attempts = 0;

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

        for (int i = 0; i < 5; i++) {
          if (gridContent[startIndex + i] == targetWord[i]) {
            gridColors[startIndex + i] = Colors.green;
          } else if (targetWord.contains(gridContent[startIndex + i])) {
            gridColors[startIndex + i] = Colors.yellow;
          } else {
            gridColors[startIndex + i] = Colors.grey;
          }

          if (gridContent[startIndex + i] != targetWord[i]) {
            hasWon = false;
          }
        }

        if (hasWon) {
          showDialog(
            context: context,
            builder: (context) => ResultDialog(
              hasWon: true,
              attempts: attempts,
              onRetry: handleReset,
            ),
          );
        } else if (currentRow >= 5) {
          showDialog(
            context: context,
            builder: (context) => ResultDialog(
              hasWon: false,
              attempts: attempts,
              onRetry: handleReset,
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
