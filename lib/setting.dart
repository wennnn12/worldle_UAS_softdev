import 'package:flutter/material.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isGameStarted;
  final Function(bool) setGameStarted;
  final bool hasGuessed; // Track if the user has guessed

  SettingPage({
    required this.toggleTheme,
    required this.isGameStarted,
    required this.setGameStarted,
    required this.hasGuessed,
  });

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _difficultyLevel = 0; // 0: Easy, 1: Medium, 2: Hard
  bool _isDarkMode = false;
  User? user;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isGameStarted; // Initialize _isDarkMode with the game state
    _loadUserSettings();
  }

  Future<void> _loadUserSettings() async {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      setState(() {
        _difficultyLevel = userDoc.get('difficultyLevel') ?? 0; // Default value
        _isDarkMode = userDoc.get('isDarkMode') ?? false; // Default value
      });
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

  Future<String> _fetchRandomWord(String difficulty) async {
    final wordList = await FirebaseFirestore.instance
        .collection('Wordlists')
        .where('difficulty', isEqualTo: difficulty)
        .get();
    final words = wordList.docs.map((doc) => doc['word'] as String).toList();
    words.shuffle();
    return words.isNotEmpty ? words.first : 'ERROR'; // Fallback word if list is empty
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(child: Text('SETTING')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Level',
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Easy'),
                      Text('Medium'),
                      Text('Hard'),
                    ],
                  ),
                  Slider(
                    value: _difficultyLevel.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: _getDifficultyText(),
                    onChanged: widget.isGameStarted
                        ? null
                        : (double value) {
                            setState(() {
                              _difficultyLevel = value.round();
                              _saveUserSettings(); // Save settings on change
                            });
                          },
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Theme',
                    style: TextStyle(fontSize: 24),
                  ),
                  SwitchListTile(
                    title: Text(_isDarkMode ? 'Night Mode' : 'Light Mode'),
                    value: _isDarkMode,
                    onChanged: widget.isGameStarted
                        ? null
                        : (bool value) {
                            // Disable if the game has started
                            setState(() {
                              _isDarkMode = value;
                              widget.toggleTheme(_isDarkMode);
                              _saveUserSettings(); // Save settings on change
                            });
                          },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!widget.hasGuessed) {
            // Refresh the word if no guess has been made
            String newWord = await _fetchRandomWord(_getDifficultyText().toLowerCase());
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) {
                  switch (_difficultyLevel) {
                    case 0:
                      return GameEasy(
                        initialTargetWord: newWord,
                        toggleTheme: widget.toggleTheme,
                        onGameStarted: widget.setGameStarted,
                      );
                    case 1:
                      return GameMedium(
                        initialTargetWord: newWord,
                        toggleTheme: widget.toggleTheme,
                        onGameStarted: widget.setGameStarted,
                      );
                    case 2:
                      return GameHard(
                        initialTargetWord: newWord,
                        toggleTheme: widget.toggleTheme,
                        onGameStarted: widget.setGameStarted,
                      );
                    default:
                      return GameEasy(
                        initialTargetWord: newWord,
                        toggleTheme: widget.toggleTheme,
                        onGameStarted: widget.setGameStarted,
                      );
                  }
                },
              ),
            );
          } else {
            Navigator.pop(context); // Just go back to the game
          }
        },
        child: Icon(Icons.check),
      ),
    );
  }

  String _getDifficultyText() {
    switch (_difficultyLevel) {
      case 0:
        return 'Easy';
      case 1:
        return 'Medium';
      case 2:
        return 'Hard';
      default:
        return 'Easy';
    }
  }
}
