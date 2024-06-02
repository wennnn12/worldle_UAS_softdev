import 'package:flutter/material.dart';

class HomePage extends StatefulWidget{
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> gridContent = List.generate(30, (index) => '');
  int currentRow = 0;

  void handleKeyPress(String letter) {
    setState(() {
      // Calculate the start and end index of the current row
      int startIndex = currentRow * 5;
      int endIndex = startIndex + 5;

      // Find the first empty slot in the current row
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
      // Calculate the start and end index of the current row
      int startIndex = currentRow * 5;
      int endIndex = startIndex + 5;

      // Find the last filled slot in the current row
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
      // Calculate the start and end index of the current row
      int startIndex = currentRow * 5;
      int endIndex = startIndex + 5;

      // Check if the current row is fully populated
      bool isRowComplete = true;
      for (int i = startIndex; i < endIndex; i++) {
        if (gridContent[i].isEmpty) {
          isRowComplete = false;
          break;
        }
      }

      // Move to the next row if the current row is complete
      if (isRowComplete && currentRow < 5) {
        currentRow++;
      }
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
              child: Grid(gridContent: gridContent),
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
                      child: ElevatedButton(
                        onPressed: handleSubmit,
                        child: Text('Submit', style: TextStyle(fontSize: 18)),
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

  const Grid({required this.gridContent, Key? key}) : super(key: key);

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
          color: Colors.red,
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


//ON screen Keyboard
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
