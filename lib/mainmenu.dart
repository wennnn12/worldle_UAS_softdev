import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'login.dart';

class MainMenu extends StatelessWidget {
  Future<String> _fetchRandomWord() async {
    final wordList = await FirebaseFirestore.instance.collection('Wordlists').get();
    final words = wordList.docs.map((doc) => doc['word'] as String).toList();
    words.shuffle();
    return words.isNotEmpty ? words.first : 'ERROR'; // Fallback word if list is empty
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
                String randomWord = await _fetchRandomWord();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(initialTargetWord: randomWord)),
                );
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
