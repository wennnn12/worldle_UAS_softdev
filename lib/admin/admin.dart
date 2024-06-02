import 'package:flutter/material.dart';

import 'manageaccount.dart';
import 'wordlists.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            Text(
              'STATISTICS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DisplayBox(title: 'Account Registered'),
                DisplayBox(title: 'Word Lists'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                DisplayBox(title: 'Account Banned'),
                DisplayBox(title: 'Prohibited Words'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageAccountPage()),
                );
              },
              child: Text('Manage Account'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordListsPage()),
                );
              },
              child: Text('Manage Words'),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayBox extends StatelessWidget {
  final String title;

  const DisplayBox({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Text(title),
    );
  }
}
