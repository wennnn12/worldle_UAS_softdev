import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:worldle_game/history.dart';
import 'confetti.dart';
import 'fliptile_anim.dart';
import 'result_dialog.dart';
import 'login.dart';
import 'mainmenu.dart';
import 'setting.dart';
import 'leaderboard.dart';

class GameEasy extends StatefulWidget {
  final String initialTargetWord;
  final Function(bool) toggleTheme;
  final Function(bool) onGameStarted;

  const GameEasy(
      {required this.initialTargetWord,
      required this.toggleTheme,
      required this.onGameStarted});

  @override
  State<GameEasy> createState() => _GameEasyState();
}

class _GameEasyState extends State<GameEasy>
    with SingleTickerProviderStateMixin {
  late String targetWord;
  List<String> gridContent = List.generate(30, (index) => '');
  bool _isDarkMode = false;  
  late List<Color> gridColors;
  Map<String, Color> keyboardColors = {};
  int currentRow = 0;
  int attempts = 0;
  bool isGuest = true;
  User? currentUser;
  Map<String, dynamic>? userStats;  
  List<GlobalKey<FlipTileState>> flipTileKeys =
      List.generate(30, (index) => GlobalKey<FlipTileState>());  

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isDrawerOpen = false;
  String? username;
  User? user;
  int _difficultyLevel = 0;  
  bool _isGameStarted = false;
  late Stopwatch _stopwatch;  

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();  
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
    initializeGridColors();  
  }

  void initializeGridColors() {
    gridColors = _isDarkMode
        ? List.generate(
            30,
            (index) =>
                const Color.fromARGB(255, 50, 50, 50))  
        : List.generate(
            30,
            (index) =>
                const Color.fromARGB(255, 250, 250, 250));  
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
        .doc('easy');
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
      initializeGridColors();  
    } else {
       
      setState(() {
        _difficultyLevel = 0;
        _isDarkMode = false;
      });
      widget.toggleTheme(false);  
      initializeGridColors();  
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
    if (!_stopwatch.isRunning) {
      _stopwatch.start();  
    }

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

bool _isSubmitting = false;

Future<void> handleSubmit() async {
  if (_isSubmitting) return;  

  setState(() {
    _isGameStarted = true;
    widget.onGameStarted(true);
    _isSubmitting = true;  
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
    String inputtedWord = gridContent.sublist(startIndex, endIndex).join();

    if (!await _isValidWord(inputtedWord)) {
      _showInvalidWordMessage();
      setState(() {
        _isSubmitting = false;  
      });
      return;  
    }

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

    List<bool> markedCorrect = List.generate(5, (index) => false);
    for (int i = 0; i < 5; i++) {
      if (gridContent[startIndex + i] == targetWord[i]) {
        gridColors[startIndex + i] = Color.fromARGB(255, 140, 255, 186);
        keyboardColors[gridContent[startIndex + i]] =
            Color.fromARGB(255, 140, 255, 186);
        targetLetterCounts[gridContent[startIndex + i]] =
            targetLetterCounts[gridContent[startIndex + i]]! - 1;
        markedCorrect[i] = true;
      } else {
        gridColors[startIndex + i] = Colors.grey;
        hasWon = false;
      }
    }

     
    for (int i = startIndex; i < endIndex; i++) {
      flipTileKeys[i].currentState?.flip();
    }

     
    for (int i = 0; i < 5; i++) {
      if (!markedCorrect[i] &&
          targetLetterCounts[gridContent[startIndex + i]] != null &&
          targetLetterCounts[gridContent[startIndex + i]]! > 0) {
        gridColors[startIndex + i] = Color.fromARGB(220, 254, 255, 182);
        if (keyboardColors[gridContent[startIndex + i]] !=
            Color.fromARGB(255, 140, 255, 186)) {
          keyboardColors[gridContent[startIndex + i]] =
              Color.fromARGB(220, 254, 255, 182);
        }
        targetLetterCounts[gridContent[startIndex + i]] =
            targetLetterCounts[gridContent[startIndex + i]]! - 1;
      } else if (gridColors[startIndex + i] == Colors.grey &&
          !keyboardColors.containsKey(gridContent[startIndex + i])) {
        keyboardColors[gridContent[startIndex + i]] = Colors.grey;
      }
    }

    if (hasWon) {
      _stopwatch.stop();  
      await _updateStats(true);
      await Future.delayed(Duration(seconds: 1));  
      _showResultDialog(true);
    } else if (currentRow >= 5) {
      _stopwatch.stop();  
      await _updateStats(false);
      await Future.delayed(Duration(seconds: 1));
      _showResultDialog(false);
    } else {
      setState(() {
        currentRow++;
      });
    }
  }

   
  await Future.delayed(Duration(seconds: 2));

  setState(() {
    _isSubmitting = false;  
  });
}

Future<bool> _isValidWord(String word) async {
  final wordList = await FirebaseFirestore.instance
      .collection('Wordlists')
      .where('word', isEqualTo: word)
      .get();
  return wordList.docs.isNotEmpty;
}

void _showInvalidWordMessage() {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).size.height * 0.3,  
      left: MediaQuery.of(context).size.width * 0.1,
      right: MediaQuery.of(context).size.width * 0.1,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: Colors.red.withOpacity(0.8),
          child: Text(
            "That's not a valid word",
            style: TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  );

  overlay?.insert(overlayEntry);
  Future.delayed(Duration(seconds: 2), () {
    overlayEntry.remove();
  });
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
    String difficulty = 'easy';  
    int barsCount = difficulty == 'easy'
        ? 6
        : difficulty == 'medium'
            ? 5
            : 4;
    Map<int, int> guessStats = await _fetchGuessStats(difficulty);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          ResultDialog(
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
            stats: isGuest ? null : userStats,
            isGuest: isGuest,
            guessStats: guessStats,
            barsCount: barsCount,
          ),
          if (hasWon) ConfettiAnimation(hasWon: hasWon),
        ],
      ),
    );

     
    if (hasWon) {
      await Future.delayed(Duration(seconds: 2));
    }
  }

Future<void> _updateStats(bool hasWon) async {
  if (isGuest) return;

  final duration = _stopwatch.elapsed.inSeconds;  
  final difficulty = 'easy';  
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

     
    transaction.set(guessStatsRef, {
      'attempts': attempts,
      'duration': duration,  
      'status': hasWon ? 'WIN' : 'LOSE',  
      'targetWord': targetWord,  
      'timestamp': FieldValue.serverTimestamp(),
    });
  });
}

void handleReset() {
  setState(() {
    _isGameStarted = false;
    widget.onGameStarted(false);
    gridContent = List.generate(30, (index) => '');
    gridColors = _isDarkMode
        ? List.generate(30, (index) => const Color.fromARGB(255, 50, 50, 50))  
        : List.generate(30, (index) => const Color.fromARGB(255, 250, 250, 250));  
    keyboardColors.clear();
    currentRow = 0;
    attempts = 0;
    _stopwatch.reset();  

     
    for (int i = 0; i < flipTileKeys.length; i++) {
      flipTileKeys[i].currentState?.reset();
    }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          backgroundColor: _isDarkMode
              ? const Color.fromARGB(255, 35, 35, 35)
              : const Color.fromARGB(255, 250, 250, 250),
          title: Text("How to Play",
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Text("Guess the word in 4/5/6 tries",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text("Guess must be a valid 5 letter word",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 10),
                Text(
                  "After submission, tiles will change color as shown below",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile('G', Color.fromARGB(255, 140, 255, 186)),
                    _buildTile('H', Colors.grey.shade300),
                    _buildTile('O', Colors.grey.shade300),
                    _buildTile('S', Colors.grey.shade300),
                    _buildTile('T', Colors.grey.shade300),
                  ],
                ),
                SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    text: "G",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: " is in the word and in the correct spot.",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile('S', Colors.grey.shade300),
                    _buildTile('T', Color.fromARGB(255, 254, 255, 182)),
                    _buildTile('A', Colors.grey.shade300),
                    _buildTile('I', Colors.grey.shade300),
                    _buildTile('N', Colors.grey.shade300),
                  ],
                ),
                SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    text: "T",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: " is in the word but in the wrong spot.",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTile('P', Colors.grey.shade300),
                    _buildTile('L', Colors.grey.shade300),
                    _buildTile('A', Colors.grey),
                    _buildTile('Y', Colors.grey.shade300),
                    _buildTile('S', Colors.grey.shade300),
                  ],
                ),
                SizedBox(height: 5),
                Text.rich(
                  TextSpan(
                    text: "A",
                    style: TextStyle(fontWeight: FontWeight.bold),
                    children: <TextSpan>[
                      TextSpan(
                        text: " is not in the word in any spot.",
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              child: Text(
                "Close",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 54, 54, 54),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();  
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(
                    255, 255, 182, 190),  
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
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
          style: TextStyle(
            color: Color.fromARGB(255, 39, 39, 39),
            fontSize: 24,
            fontFamily: 'FranklinGothic-Bold',
            fontWeight: FontWeight.bold,
          ),
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
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(
            'Worldle',
            style: TextStyle(
              fontFamily: 'Fraunces',
              fontWeight: FontWeight.bold,
              fontSize: 32,
              color: _isDarkMode  
                  ? const Color.fromARGB(255, 255, 255, 255)
                  : Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: _isDarkMode
              ? Colors.black
              : const Color.fromARGB(255, 250, 250, 250),
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
                      builder: (context) =>
                          Leaderboard(isDarkMode: _isDarkMode),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.leaderboard,
                      size: 28,
                      color: _isDarkMode  
                          ? Color.fromARGB(255, 255, 255, 255)
                          : Color.fromARGB(255, 0, 0, 0),
                    ),
                    SizedBox(height: 1),
                    Text(
                      username ?? 'Username',
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color.fromARGB(255, 130, 130, 130),
                      ),
                    ),
                  ],
                ),
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
                    color: _isDarkMode  
                        ? Color.fromARGB(255, 33, 33, 33)
                        : Color.fromARGB(255, 255, 255, 255),
                    child: Grid(
                        gridContent: gridContent,
                        gridColors: gridColors,
                        isDarkMode: _isDarkMode,
                        flipTileKeys: flipTileKeys),  
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    color: _isDarkMode
                        ? Color.fromARGB(
                            255, 26, 26, 26)  
                        : const Color.fromARGB(255, 250, 250, 250),
                    child: Column(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Keyboard(
                            onKeyPressed: handleKeyPress,
                            onDeletePressed: handleDeletePress,
                            isDarkMode: _isDarkMode,
                            keyboardColors:
                                keyboardColors,  
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
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isDarkMode
                                        ? Color.fromARGB(255, 44, 44, 44)
                                        : Color.fromARGB(255, 210, 214, 219),
                                    minimumSize: Size(130, 40),
                                  ),
                                  child: Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontFamily: 'FranklinGothic-Bold',
                                      fontWeight: FontWeight.bold,
                                      color: _isDarkMode
                                          ? Color.fromARGB(255, 255, 255, 255)
                                          : const Color.fromARGB(
                                              255, 39, 39, 39),
                                      fontSize: 20,
                                    ),
                                  ),
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
                    width: 200,
                    height: 350,
                    color: _isDarkMode ? Colors.black : Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.help_outline,
                              color: _isDarkMode ? Colors.white : Colors.black),
                          title: Text('Learn?',
                              style: TextStyle(
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
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
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
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
                                        0,  
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
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                          onTap: () {
                            toggleDrawer();
                            if (user == null) {
                              _showLoginPopup(context);
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HistoryPage(
                                      isDarkMode:
                                          _isDarkMode),  
                                ),
                              );
                            }
                          },
                        ),
                        SizedBox(height: 80),
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
                              backgroundColor: user == null
                                  ? Colors.white
                                  : const Color.fromARGB(
                                      255, 45, 45, 45),  
                              foregroundColor: user == null
                                  ? Colors.black
                                  : Colors.white,  
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
      ),
    );
  }
}

class Grid extends StatelessWidget {
  final List<String> gridContent;
  final List<Color> gridColors;
  final bool isDarkMode;
  final List<GlobalKey<FlipTileState>> flipTileKeys;  

  const Grid({
    required this.gridContent,
    required this.gridColors,
    required this.isDarkMode,
    required this.flipTileKeys,  
    Key? key,
  }) : super(key: key);

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
        return FlipTile(
          key: flipTileKeys[index],  
          letter: gridContent[index],
          color: gridColors[index],
          delay: (index % 5) * 100,  
          isDarkMode: isDarkMode,  
        );
      },
    );
  }
}

class Keyboard extends StatelessWidget {
  final Function(String) onKeyPressed;
  final Function() onDeletePressed;
  final Map<String, Color> keyboardColors;
  final bool isDarkMode;  

  const Keyboard({
    required this.onKeyPressed,
    required this.onDeletePressed,
    required this.keyboardColors,
    required this.isDarkMode,  
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<List<String>> keys = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M', '⌫']
    ];

    final double keyWidth = MediaQuery.of(context).size.width / 10 - 8;
    final double keyHeight = 40;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var row in keys) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((letter) {
              final keyColor = isDarkMode  
                  ? keyboardColors[letter] ?? Color.fromARGB(255, 60, 60, 60)
                  : keyboardColors[letter] ??
                      Color.fromARGB(255, 210, 214, 219);
              return GestureDetector(
                onTap: () {
                  if (letter == '⌫') {
                    onDeletePressed();
                  } else {
                    onKeyPressed(letter);
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(2),
                  width: letter == '⌫' ? keyWidth * 1.5 : keyWidth,
                  height: keyHeight,
                  decoration: BoxDecoration(
                    color: keyColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        color: isDarkMode  
                            ? Color.fromARGB(255, 255, 255, 255)
                            : Color.fromARGB(255, 39, 39, 39),
                        fontSize: 20,
                        fontFamily: 'FranklinGothic-Bold',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 8),
        ],
      ],
    );
  }
}
