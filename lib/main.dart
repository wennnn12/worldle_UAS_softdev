import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mainmenu.dart';
import 'setting.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _isGameStarted = false; // Maintain the game state here
  bool _hasGuessed = false; // Track if a guess has been made

  void _toggleTheme(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  void _setGameStarted(bool isStarted) {
    setState(() {
      _isGameStarted = isStarted;
    });
  }

  void _setHasGuessed(bool hasGuessed) {
    setState(() {
      _hasGuessed = hasGuessed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Worldle',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MainMenu(
        toggleTheme: _toggleTheme,
        setGameStarted: _setGameStarted,
        isGameStarted: _isGameStarted,
        hasGuessed: _hasGuessed,
      ),
      routes: {
        '/mainmenu': (context) => MainMenu(
              toggleTheme: _toggleTheme,
              setGameStarted: _setGameStarted,
              isGameStarted: _isGameStarted,
              hasGuessed: _hasGuessed,
            ),
        '/settings': (context) => SettingPage(
              toggleTheme: _toggleTheme,
              isGameStarted: _isGameStarted,
              setGameStarted: _setGameStarted,
              hasGuessed: _hasGuessed,
            ),
      },
    );
  }
}
