import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'gameEasy.dart';
import 'gameMedium.dart'; // Import the GameMedium file
import 'gameHard.dart'; // Import the GameHard file
import 'admin/admin.dart';
import 'register.dart';
import 'setting.dart'; // Import setting.dart
import 'dart:math' as Math;

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final Function(bool) toggleTheme;
  final Function(bool) setGameStarted;
  final bool isGameStarted;

  LoginPage({
    required this.toggleTheme,
    required this.setGameStarted,
    required this.isGameStarted,
  });

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
          MaterialPageRoute(
            builder: (context) => AdminPage(
              toggleTheme: toggleTheme,
              setGameStarted: setGameStarted,
              isGameStarted: isGameStarted,
              hasGuessed: false, // Adjust as necessary
            ),
          ),
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
            targetPage = GameEasy(
              initialTargetWord: randomWord,
              toggleTheme: toggleTheme,
              onGameStarted: setGameStarted,
            );
            break;
          case 1:
            targetPage = GameMedium(
              initialTargetWord: randomWord,
              toggleTheme: toggleTheme,
              onGameStarted: setGameStarted,
            );
            break;
          case 2:
            targetPage = GameHard(
              initialTargetWord: randomWord,
              toggleTheme: toggleTheme,
              onGameStarted: setGameStarted,
            );
            break;
          default:
            targetPage = GameEasy(
              initialTargetWord: randomWord,
              toggleTheme: toggleTheme,
              onGameStarted: setGameStarted,
            );
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
      backgroundColor: Color.fromARGB(255, 245, 245, 238),
      body: Stack(
        children: [
          CustomPaint(
            painter: BackgroundPainter(),
            size: Size.infinite,
          ),
          CustomPaint(
            painter: MirroredBackgroundPainter(),
            size: Size.infinite,
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Image.asset(
                    'assets/logo.png',
                    height: 300,
                  ),
                  SizedBox(height: 40),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        width: 300,
                        child: TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            hintText: 'example@gmail.com',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Container(
                        width: 300,
                        child: TextField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _loginUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 192, 204, 220),
                      minimumSize: Size(200, 50),
                    ),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        fontFamily: 'FranklinGothic-Bold',
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 8, 4, 52),
                        fontSize: 26,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(
                            toggleTheme: toggleTheme,
                            setGameStarted: setGameStarted,
                            isGameStarted: isGameStarted,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      "Don't have an account? Signup",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.black,
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

class BackgroundPainter extends CustomPainter {
  double degToRad(double deg) => deg * (Math.pi / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.grey.shade300, Colors.black],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(size.width, 0);
    path.quadraticBezierTo(size.width * -0.25, size.height * -0.25, size.width * 0.0, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class MirroredBackgroundPainter extends CustomPainter {
  double degToRad(double deg) => deg * (Math.pi / 180.0);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [Colors.grey.shade300, Color.fromARGB(255, 98, 98, 98) ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 1.20, size.height * 1.35, size.width, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}