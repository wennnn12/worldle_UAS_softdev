import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gameEasy.dart';
import 'gameMedium.dart'; // Import the GameMedium file
import 'gameHard.dart'; // Import the GameHard file
import 'admin/admin.dart';
import 'register.dart';
import 'setting.dart'; // Import setting.dart

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Function(bool) toggleTheme;

  LoginPage({required this.toggleTheme});

  Future<String> _fetchRandomWord() async {
    final wordList = await FirebaseFirestore.instance.collection('Wordlists').get();
    final words = wordList.docs.map((doc) => doc['word'] as String).toList();
    words.shuffle();
    return words.isNotEmpty ? words.first : 'ERROR'; // Fallback word if list is empty
  }
  
  Future<void> _loginUser(BuildContext context) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
      bool isAdmin = userData.get('isAdmin') ?? false;

      if (isAdmin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminPage()),
        );
      } else {
        // Fetch user-specific settings
        int difficultyLevel = 0; // Default to easy
        bool isDarkMode = false; // Default to light mode

        try {
          difficultyLevel = userData.get('difficultyLevel');
        } catch (e) {
          // Field doesn't exist, keep default value
        }

        try {
          isDarkMode = userData.get('isDarkMode');
        } catch (e) {
          // Field doesn't exist, keep default value
        }

        toggleTheme(isDarkMode);
        String randomWord = await _fetchRandomWord();

        // Navigate to the appropriate game screen based on difficulty level
        Widget targetPage;
        switch (difficultyLevel) {
          case 0:
            targetPage = GameEasy(initialTargetWord: randomWord, toggleTheme: toggleTheme);
            break;
          case 1:
            targetPage = GameMedium(initialTargetWord: randomWord, toggleTheme: toggleTheme);
            break;
          case 2:
            targetPage = GameHard(initialTargetWord: randomWord, toggleTheme: toggleTheme);
            break;
          default:
            targetPage = GameEasy(initialTargetWord: randomWord, toggleTheme: toggleTheme);
            break;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error logging in: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 250,
                    child: TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    width: 250,
                    child: TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _loginUser(context),
                child: Text('Login'),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterPage(toggleTheme: toggleTheme,)),
                  );
                },
                child: Text(
                  "Don't have an account? Signup",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
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
