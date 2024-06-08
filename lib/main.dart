import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'setting.dart';
import 'mainmenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void _toggleTheme(bool isDarkMode) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        _isDarkMode = isDarkMode;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Worldle',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MainMenu(toggleTheme: _toggleTheme),
      routes: {
        '/mainmenu': (context) => MainMenu(toggleTheme: _toggleTheme),
        '/settings': (context) => SettingPage(toggleTheme: _toggleTheme),
      },
    );
  }
}
