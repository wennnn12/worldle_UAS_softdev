import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';
import 'login.dart';
import 'dart:math' as Math;

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
        : 'ERROR';  
  }

    @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 245, 245, 238),  
        body: Stack(
          children: [
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
              painter: BackgroundPainter(),
            ),
            CustomPaint(
              size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
              painter: MirroredBackgroundPainter(),
            ),
            Center(
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
                      String difficulty = 'easy';  
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                         
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
                          toggleTheme(isDarkMode);  
                        } catch (e) {
                           
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
                          255, 140, 255, 186),  
                      minimumSize: Size(200, 60),  
                    ),
                    child: Text(
                      'PLAY',
                      style: TextStyle(
                        fontFamily: 'FranklinGothic',  
                        fontWeight: FontWeight.bold,  
                        color: const Color.fromARGB(
                            255, 0, 45, 10),  
                        fontSize: 34,  
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
                          255, 192, 204, 220),  
                      minimumSize: Size(190, 55),  
                    ),
                    child: Text(
                      'LOGIN',
                      style: TextStyle(
                        fontFamily: 'FranklinGothic',  
                        fontWeight: FontWeight.bold,  
                        color: const Color.fromARGB(
                            255, 8, 4, 52),  
                        fontSize: 26,  
                      ),
                    ),
                  ),
                  Text(
                    'dev_vvvvvv',
                    style: TextStyle(
                    fontFamily: 'FranklinGothic',
                    fontSize: 15,
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
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
    path.quadraticBezierTo(size.width * -0.25, size.height * -0.05, size.width * 0.0, size.height);
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
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Colors.grey.shade300, Colors.black ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    Path path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(size.width * 1.25, size.height * 1.05, size.width, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
