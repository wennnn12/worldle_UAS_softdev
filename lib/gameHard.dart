import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'result_dialog.dart';
import 'login.dart'; // Import the login.dart file
import 'setting.dart'; // Add this import
import 'mainmenu.dart'; // Add this import

class GameHard extends StatefulWidget {
  final String initialTargetWord;
  final Function(bool) toggleTheme;

  const GameHard({Key? key, required this.initialTargetWord, required this.toggleTheme}) : super(key: key);

  @override
  State<GameHard> createState() => _GameHardState();
}

class _GameHardState extends State<GameHard> with SingleTickerProviderStateMixin {
  late String targetWord;
  List<String> gridContent = List.generate(20, (index) => '');
  List<Color> gridColors = List.generate(20, (index) => Colors.red);
  int currentRow = 0;
  int attempts = 0;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDrawerOpen = false;
  String? username;
  User? user;
  int _difficultyLevel = 0;
  bool _isDarkMode = false;

   @override
  void initState() {
    super.initState();
    targetWord = widget.initialTargetWord;
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0)).animate(_animationController);
    _checkUser();
  }

  Future<void> _checkUser() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        username = userDoc.get('username');
        _difficultyLevel = userDoc.get('difficultyLevel') ?? 0;
        _isDarkMode = userDoc.get('isDarkMode') ?? false;
      });
      widget.toggleTheme(_isDarkMode);
    } else {
      setState(() {
        _difficultyLevel = 0;
        _isDarkMode = false;
      });
      widget.toggleTheme(false);
    }
  }

  Future<void> _saveUserSettings() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'difficultyLevel': _difficultyLevel,
        'isDarkMode': _isDarkMode,
      }, SetOptions(merge: true));
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      user = null;
      username = null;
      _difficultyLevel = 0;
      _isDarkMode = false;
    });
    await _saveUserSettings();
    widget.toggleTheme(false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainMenu(toggleTheme: widget.toggleTheme)),
    );
  }

  void _showLoginPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: AlertDialog(
            title: Text("You are not logged in"),
            content: Text("Please login first."),
            actions: [
              TextButton(
                child: Text("Okay"),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
            ],
          ),
        );
      },
    );
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
        } else if (currentRow >= 3) {
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
      gridContent = List.generate(20, (index) => '');
      gridColors = List.generate(20, (index) => Colors.red);
      currentRow = 0;
      attempts = 0;
    });
  }

  void toggleDrawer() {
    setState(() {
      if (_animationController.isDismissed) {
        _animationController.forward();
        _isDrawerOpen = true;
      } else {
        _animationController.reverse();
        _isDrawerOpen = false;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Worldle'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _isDarkMode ? Colors.black : Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: toggleDrawer,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.leaderboard,
                  size: 28,
                ),
                SizedBox(height: 4),
                Text(
                  username ?? 'Username',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
     body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 7,
                child: Container(
                  color: _isDarkMode ? Colors.grey[900] : Colors.yellow,
                  child: Grid(gridContent: gridContent, gridColors: gridColors),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  color: _isDarkMode ? Colors.black : Colors.green,
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
          if (_isDrawerOpen)
            GestureDetector(
              onTap: toggleDrawer,
              child: Container(
                color: Colors.black54,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
              ),
            ),
          SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Material(
                elevation: 8,
                child: Container(
                  width: 240,
                  height: 350,
                  color: _isDarkMode ? Colors.black : Colors.white,
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(Icons.help_outline, color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('Learn?', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          toggleDrawer();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings, color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('Setting', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          toggleDrawer();
                          if (user == null) {
                            _showLoginPopup(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SettingPage(toggleTheme: widget.toggleTheme)),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history, color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('History', style: TextStyle(color: _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          toggleDrawer();
                        },
                      ),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            if (user == null) {
                              toggleDrawer();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage(toggleTheme: widget.toggleTheme)),
                              );
                            } else {
                              _logout();
                              toggleDrawer();
                            }
                          },
                          child: Text(user == null ? 'Login' : 'Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: user == null ? Colors.white : Colors.red,
                            foregroundColor: user == null ? Colors.black : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 0,
                            side: BorderSide(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
