import 'package:flutter/material.dart';
import 'gameEasy.dart';
import 'gameMedium.dart';
import 'gameHard.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  int _difficultyLevel = 0; // 0: Easy, 1: Medium, 2: Hard
  bool _isDarkMode = false;

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
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
}


void main() {
  runApp(MaterialApp(
    home: SettingPage(),
  ));
}
