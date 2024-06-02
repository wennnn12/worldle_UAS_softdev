import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart'; // Assuming you have this file
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
                String difficulty = await _showDifficultyDialog(context);
                if (difficulty != null) {
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

  Future _showDifficultyDialog(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose Difficulty'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'easy');
              },
              child: Text('Easy'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'medium');
              },
              child: Text('Medium'),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, 'hard');
              },
              child: Text('Hard'),
            ),
          ],
        );
      },
    );
  }
}