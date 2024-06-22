import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mainmenu.dart';
import 'setting.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';

 
final ThemeData customDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.grey[900],
  
  scaffoldBackgroundColor: Colors.grey[850],

   
);

final ThemeData customLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[100],  
);

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
  bool _isGameStarted = false;  
  bool _hasGuessed = false;  

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
      theme: _isDarkMode ? customDarkTheme : customLightTheme,
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
