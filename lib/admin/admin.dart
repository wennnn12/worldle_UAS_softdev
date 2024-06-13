import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../mainmenu.dart';

import 'manageaccount.dart';
import 'wordlists.dart';

class AdminPage extends StatelessWidget {
  final Function(bool) toggleTheme;
  final Function(bool) setGameStarted;
  final bool isGameStarted;
  final bool hasGuessed;

  AdminPage({
    required this.toggleTheme,
    required this.setGameStarted,
    required this.isGameStarted,
    required this.hasGuessed,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin'),
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false, // Remove the back button
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
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DisplayBox(title: 'Account Registered', value: 'Loading...');
                      }
                      int registeredCount = snapshot.data!.docs.length;
                      return DisplayBox(title: 'Account Registered', value: registeredCount.toString());
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('Wordlists').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DisplayBox(title: 'Word Lists', value: 'Loading...');
                      }
                      int wordListsCount = snapshot.data!.docs.length;
                      return DisplayBox(title: 'Word Lists', value: wordListsCount.toString());
                    },
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('deleted_accounts').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return DisplayBox(title: 'Deleted Accounts', value: 'Loading...');
                      }
                      int deletedCount = snapshot.data!.docs.length;
                      return DisplayBox(title: 'Deleted Accounts', value: deletedCount.toString());
                    },
                  ),
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MainMenu(
                        toggleTheme: toggleTheme,
                        setGameStarted: setGameStarted,
                        isGameStarted: isGameStarted,
                        hasGuessed: hasGuessed,
                      ),
                    ),
                  );
                },
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DisplayBox extends StatelessWidget {
  final String title;
  final String value;

  const DisplayBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(),
      ),
      child: Column(
        children: [
          Text(title),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
