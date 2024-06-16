import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';
import 'login.dart';

class MainMenu extends StatelessWidget {
  final Function(bool) toggleTheme;
  final Function(bool) setGameStarted;
  final bool isGameStarted;
  final bool hasGuessed;

  MainMenu({
    required this.toggleTheme,
    required this.setGameStarted,
    required this.isGameStarted,
    required this.hasGuessed,
  });

  Future<String> _fetchRandomWord(String difficulty) async {
    final wordList = await FirebaseFirestore.instance
        .collection('Wordlists')
        .where('difficulty', isEqualTo: difficulty)
        .get();
    final words = wordList.docs.map((doc) => doc['word'] as String).toList();
    words.shuffle();
    return words.isNotEmpty
        ? words.first
        : 'ERROR'; // Fallback word if list is empty
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor:
            Color.fromARGB(255, 245, 245, 238), // Set the background color
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                height: 300.0,
              ),
              SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  String difficulty = 'easy'; // Default to easy mode
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    // Fetch user-specific difficulty
                    var userData = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .get();
                    try {
                      difficulty = userData.get('difficultyLevel') == 1
                          ? 'medium'
                          : userData.get('difficultyLevel') == 2
                              ? 'hard'
                              : 'easy';
                      bool isDarkMode = userData.get('isDarkMode') ?? false;
                      toggleTheme(isDarkMode); // Apply user-specific theme
                    } catch (e) {
                      // Field doesn't exist, keep default value
                    }
                  }
                  String randomWord = await _fetchRandomWord(difficulty);
                  if (difficulty == 'easy') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameEasy(
                              initialTargetWord: randomWord,
                              toggleTheme: toggleTheme,
                              onGameStarted: setGameStarted)),
                    );
                  } else if (difficulty == 'medium') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameMedium(
                              initialTargetWord: randomWord,
                              toggleTheme: toggleTheme,
                              onGameStarted: setGameStarted)),
                    );
                  } else if (difficulty == 'hard') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => GameHard(
                              initialTargetWord: randomWord,
                              toggleTheme: toggleTheme,
                              onGameStarted: setGameStarted)),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 140, 255, 186), // Set the button color to green
                  minimumSize: Size(200, 60), // Increase the button size
                ),
                child: Text(
                  'PLAY',
                  style: TextStyle(
                    fontFamily:
                        'FranklinGothic-Bold', // Use Franklin Gothic font
                    fontWeight: FontWeight.bold, // Set the font weight to bold
                    color: const Color.fromARGB(
                        255, 0, 45, 10), // Set the text color to dimmer green
                    fontSize: 30, // Increase the text size
                  ),
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage(
                            toggleTheme: toggleTheme,
                            setGameStarted: setGameStarted,
                            isGameStarted: isGameStarted)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 192, 204, 220), // Set the button color to green
                  minimumSize: Size(100, 50), // Increase the button size
                ),
                child: Text(
                  'LOGIN',
                  style: TextStyle(
                    fontFamily:
                        'FranklinGothic-Bold', // Use Franklin Gothic font
                    fontWeight: FontWeight.bold, // Set the font weight to bold
                    color: const Color.fromARGB(
                        255, 8,4,52), // Set the text color to dimmer green
                    fontSize: 20, // Increase the text size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
