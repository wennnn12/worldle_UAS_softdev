import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'setting.dart';
import 'mainmenu.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Worldle',
      theme: ThemeData(),
      home: MainMenu(),
      routes: {
        '/mainmenu': (context) => MainMenu(),
        '/settings': (context) => SettingPage(),
      },
    );
  }
}
