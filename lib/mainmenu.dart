import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart'; // Import the GameHard file
import 'login.dart';

class MainMenu extends StatelessWidget {
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Main Menu'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String difficulty = 'easy'; // Default to easy mode
                User? user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  // Fetch user-specific difficulty
                  var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
                  try {
                    difficulty = userData.get('difficultyLevel') == 1 ? 'medium' : userData.get('difficultyLevel') == 2 ? 'hard' : 'easy';
                  } catch (e) {
                    // Field doesn't exist, keep default value
                  }
                }
                String randomWord = await _fetchRandomWord(difficulty);
                if (difficulty == 'easy') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GameEasy(initialTargetWord: randomWord)),
                  );
                } else if (difficulty == 'medium') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GameMedium(initialTargetWord: randomWord)),
                  );
                } else if (difficulty == 'hard') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            GameHard(initialTargetWord: randomWord)),
                  );
                }
              },
              child: Text('Play'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
