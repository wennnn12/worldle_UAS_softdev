import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:worldle_game/history.dart';
import 'leaderboard.dart';
import 'result_dialog.dart';
import 'login.dart';
import 'setting.dart';
import 'mainmenu.dart';

class GameMedium extends StatefulWidget {
  final String initialTargetWord;
  final Function(bool) toggleTheme;
  final Function(bool) onGameStarted;

  const GameMedium(
      {required this.initialTargetWord,
      required this.toggleTheme,
      required this.onGameStarted});

  @override
  State<GameMedium> createState() => _GameMediumState();
}

class _GameMediumState extends State<GameMedium>
    with SingleTickerProviderStateMixin {
  late String targetWord;
  List<String> gridContent = List.generate(25, (index) => '');
  List<Color> gridColors = List.generate(25, (index) => Colors.red);
  Map<String, Color> keyboardColors = {};
  int currentRow = 0;
  int attempts = 0;
  bool isGuest = true;
  User? currentUser;
  Map<String, dynamic>? userStats;

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDrawerOpen = false;
  String? username;
  User? user;
  int _difficultyLevel = 0;
  bool _isDarkMode = false;
  bool _isGameStarted = false;
  late Stopwatch _stopwatch; // Add a stopwatch to track game duration

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch(); // Initialize the stopwatch
    _stopwatch.start(); // Start the stopwatch as soon as the game screen loads
    _fetchRandomWord().then((newWord) {
      setState(() {
        targetWord = newWord;
      });
    });
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(begin: Offset(-1, 0), end: Offset(0, 0))
        .animate(_animationController);
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
    final statsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stats')
        .doc('medium');
    final statsDoc = await statsRef.get();
    if (statsDoc.exists) {
      setState(() {
        userStats = statsDoc.data();
      });
    }
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
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

  Future<String> _fetchRandomWord() async {
    final wordList =
        await FirebaseFirestore.instance.collection('Wordlists').get();
    final words = wordList.docs.map((doc) => doc['word'] as String).toList();
    words.shuffle();
    return words.isNotEmpty ? words.first : 'ERROR';
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
    setState(() {
      _isGameStarted = true;
      widget.onGameStarted(true);
    });

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
          keyboardColors[gridContent[startIndex + i]] = Colors.green;
          targetLetterCounts[gridContent[startIndex + i]] =
              targetLetterCounts[gridContent[startIndex + i]]! - 1;
        } else {
          gridColors[startIndex + i] = Colors.grey;
          hasWon = false;
        }
      }

      // Second pass: Mark present but misplaced letters (yellow)
      for (int i = 0; i < 5; i++) {
        if (gridColors[startIndex + i] != Colors.green &&
            targetLetterCounts[gridContent[startIndex + i]] != null &&
            targetLetterCounts[gridContent[startIndex + i]]! > 0) {
          gridColors[startIndex + i] = Colors.yellow;
          if (keyboardColors[gridContent[startIndex + i]] != Colors.green) {
            keyboardColors[gridContent[startIndex + i]] = Colors.yellow;
          }
          targetLetterCounts[gridContent[startIndex + i]]! - 1;
        } else if (gridColors[startIndex + i] == Colors.grey &&
            !keyboardColors.containsKey(gridContent[startIndex + i])) {
          keyboardColors[gridContent[startIndex + i]] = Colors.grey;
        }
      }

      if (hasWon) {
        _stopwatch.stop(); // Stop the stopwatch if the user wins
        await _updateStats(true);
        _showResultDialog(true);
      } else if (currentRow >= 4) {
        _stopwatch.stop(); // Stop the stopwatch if the user loses
        await _updateStats(false);
        _showResultDialog(false);
      } else {
        setState(() {
          currentRow++;
        });
      }
    }
  }

  Future<Map<int, int>> _fetchGuessStats(String difficulty) async {
    if (isGuest) return {};

    final guessStatsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('guessStats')
        .doc(difficulty)
        .collection('games');
    final guessStatsDocs = await guessStatsRef.get();
    Map<int, int> guessStats = {};

    for (var doc in guessStatsDocs.docs) {
      int attempts = doc['attempts'];
      if (guessStats.containsKey(attempts)) {
        guessStats[attempts] = guessStats[attempts]! + 1;
      } else {
        guessStats[attempts] = 1;
      }
    }

    return guessStats;
  }

  void _showResultDialog(bool hasWon) async {
    String difficulty = 'medium'; // Replace with current difficulty
    int barsCount = 5; // 5 bars for medium difficulty
    Map<int, int> guessStats = await _fetchGuessStats(difficulty);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ResultDialog(
        hasWon: hasWon,
        attempts: attempts,
        onRetry: () async {
          await _fetchRandomWord().then((newWord) {
            setState(() {
              targetWord = newWord;
            });
          });
          handleReset();
        },
        stats: isGuest
            ? null
            : userStats, // Only show stats if user is not a guest
        isGuest: isGuest,
        guessStats: guessStats,
        barsCount: barsCount,
      ),
    );
  }

  Future<void> _updateStats(bool hasWon) async {
    if (isGuest) return;

    final duration = _stopwatch.elapsed.inSeconds; // Get the elapsed time
    final difficulty = 'medium'; // Replace with current difficulty
    final statsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stats')
        .doc(difficulty);
    final guessStatsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('guessStats')
        .doc(difficulty)
        .collection('games')
        .doc();

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
        final highestWinStreak = hasWon && winStreak > data['highestWinStreak']
            ? winStreak
            : data['highestWinStreak'];

        transaction.update(statsRef, {
          'matchesPlayed': matchesPlayed,
          'wins': wins,
          'winStreak': winStreak,
          'highestWinStreak': highestWinStreak,
        });

        setState(() {
          userStats = {
            'matchesPlayed': matchesPlayed,
            'winPercentage': (wins / matchesPlayed) * 100,
            'winStreak': winStreak,
            'highestWinStreak': highestWinStreak,
          };
        });
      }

      // Save guess stats
      transaction.set(guessStatsRef, {
        'attempts': attempts,
        'duration': duration, // Save the duration
        'status': hasWon ? 'WIN' : 'LOSE', // Save the game result
        'targetWord': targetWord, // Save the target word
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  void handleReset() async {
    await _fetchRandomWord(); // Fetch a new random word on reset
    setState(() {
      _isGameStarted = false;
      widget.onGameStarted(false);
      gridContent = List.generate(25, (index) => '');
      gridColors = List.generate(25, (index) => Colors.red);
      keyboardColors.clear();
      currentRow = 0;
      attempts = 0;
      _stopwatch.reset(); // Reset the stopwatch when the game is reset
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
      MaterialPageRoute(
        builder: (context) => MainMenu(
          toggleTheme: widget.toggleTheme,
          setGameStarted: widget.onGameStarted,
          isGameStarted: _isGameStarted,
          hasGuessed: false,
        ),
      ),
    );
  }

  Future<void> _saveUserSettings() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'difficultyLevel': _difficultyLevel,
        'isDarkMode': _isDarkMode,
      }, SetOptions(merge: true));
    }
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
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showLearnPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("How to Play"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Guess the hidden word in 4/5/6 tries"),
                SizedBox(height: 10),
                Text("Guess must be a valid 5 letter word"),
                SizedBox(height: 10),
                Text("After submission, tiles will change color as shown below"),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile('G', Colors.green),
                    _buildTile('H', Colors.orange),
                    _buildTile('O', Colors.orange),
                    _buildTile('S', Colors.orange),
                    _buildTile('T', Colors.orange),
                  ],
                ),
                SizedBox(height: 5),
                Text("G is in the word and in the correct spot."),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile('S', Colors.orange),
                    _buildTile('T', Colors.yellow),
                    _buildTile('A', Colors.orange),
                    _buildTile('I', Colors.orange),
                    _buildTile('N', Colors.orange),
                  ],
                ),
                SizedBox(height: 5),
                Text("T is in the word but in the wrong spot."),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile('P', Colors.orange),
                    _buildTile('L', Colors.orange),
                    _buildTile('A', Colors.grey),
                    _buildTile('Y', Colors.orange),
                    _buildTile('S', Colors.orange),
                  ],
                ),
                SizedBox(height: 5),
                Text("A is not in the word in any spot."),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTile(String letter, Color color) {
    return Container(
      width: 40,
      height: 40,
      margin: EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _stopwatch.stop();
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
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Leaderboard(),
                    ),
                  );
                },
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
              )),
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
                          keyboardColors: keyboardColors, // Pass keyboard colors
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
                                child: Text('Submit',
                                    style: TextStyle(fontSize: 18)),
                              ),
                              SizedBox(width: 20),
                              ElevatedButton(
                                onPressed: handleReset,
                                child: Text('Reset',
                                    style: TextStyle(fontSize: 18)),
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
                        leading: Icon(Icons.help_outline,
                            color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('Learn?',
                            style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          toggleDrawer();
                          _showLearnPopup(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.settings,
                            color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('Setting',
                            style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          toggleDrawer();
                          if (user == null) {
                            _showLoginPopup(context);
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SettingPage(
                                  toggleTheme: widget.toggleTheme,
                                  isGameStarted: _isGameStarted,
                                  setGameStarted: widget.onGameStarted,
                                  hasGuessed: currentRow >
                                      0, // Pass true if at least one guess is made
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.history,
                            color: _isDarkMode ? Colors.white : Colors.black),
                        title: Text('History',
                            style: TextStyle(
                                color:
                                    _isDarkMode ? Colors.white : Colors.black)),
                        onTap: () {
                          toggleDrawer();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  HistoryPage(), // Ensure you have imported HistoryPage
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: ElevatedButton(
                          onPressed: () {
                            if (user == null) {
                              toggleDrawer();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginPage(
                                    toggleTheme: widget.toggleTheme,
                                    setGameStarted: widget.onGameStarted,
                                    isGameStarted: _isGameStarted,
                                  ),
                                ),
                              );
                            } else {
                              _logout();
                              toggleDrawer();
                            }
                          },
                          child: Text(user == null ? 'Login' : 'Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                user == null ? Colors.white : Colors.red,
                            foregroundColor:
                                user == null ? Colors.black : Colors.white,
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

  const Grid({required this.gridContent, required this.gridColors, Key? key})
      : super(key: key);

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
  final Map<String, Color> keyboardColors;

  const Keyboard(
      {required this.onKeyPressed,
      required this.onDeletePressed,
      required this.keyboardColors,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<String> keys = [
      'Q',
      'W',
      'E',
      'R',
      'T',
      'Y',
      'U',
      'I',
      'O',
      'P',
      'A',
      'S',
      'D',
      'F',
      'G',
      'H',
      'J',
      'K',
      'L',
      'Z',
      'X',
      'C',
      'V',
      'B',
      'N',
      'M'
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
              final letter = keys[index];
              final keyColor = keyboardColors[letter] ?? Colors.blueGrey;

              return GestureDetector(
                onTap: () {
                  onKeyPressed(keys[index]);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: keyColor,
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
