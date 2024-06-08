import 'package:flutter/material.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _difficultyLevel = 0; // 0: Easy, 1: Medium, 2: Hard
  bool _isDarkMode = false;
  User? user;

  @override
  void initState() {
    super.initState();
    _loadUserSettings();
  }

Future<void> _loadUserSettings() async {
  user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    setState(() {
      _difficultyLevel = 0; // Default value
      _isDarkMode = false; // Default value
      try {
        _difficultyLevel = userDoc.get('difficultyLevel');
      } catch (e) {
        // Field doesn't exist, keep default value
      }
      try {
        _isDarkMode = userDoc.get('isDarkMode');
      } catch (e) {
        // Field doesn't exist, keep default value
      }
    });
  }
}


  Future<void> _saveUserSettings() async {
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'difficultyLevel': _difficultyLevel,
        'isDarkMode': _isDarkMode,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/mainmenu');
          },
        ),
        title: Center(child: Text('SETTING')),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Level',
              style: TextStyle(fontSize: 24),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Easy'),
                      Text('Medium'),
                      Text('Hard'),
                    ],
                  ),
                  Slider(
                    value: _difficultyLevel.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: _getDifficultyText(),
                    onChanged: (double value) {
                      setState(() {
                        _difficultyLevel = value.round();
                        _saveUserSettings(); // Save settings on change
                      });
                    },
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Theme',
                    style: TextStyle(fontSize: 24),
                  ),
                  SwitchListTile(
                    title: Text(_isDarkMode ? 'Night Mode' : 'Light Mode'),
                    value: _isDarkMode,
                    onChanged: (bool value) {
                      setState(() {
                        _isDarkMode = value;
                        _saveUserSettings(); // Save settings on change
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _applySettings,
        child: Icon(Icons.check),
      ),
    );
  }

  String _getDifficultyText() {
    switch (_difficultyLevel) {
      case 0:
        return 'Easy';
      case 1:
        return 'Medium';
      case 2:
        return 'Hard';
      default:
        return 'Easy';
    }
  }

  void _applySettings() {
    Widget targetPage;

    switch (_difficultyLevel) {
      case 0:
        targetPage = GameEasy(initialTargetWord: 'example'); // Provide the initial target word
        break;
      case 1:
        targetPage = GameMedium(initialTargetWord: 'example'); // Provide the initial target word
        break;
      case 2:
        targetPage = GameHard(initialTargetWord: 'example'); // Provide the initial target word
        break;
      default:
        targetPage = GameEasy(initialTargetWord: 'example'); // Provide the initial target word
        break;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }
}
