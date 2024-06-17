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
        backgroundColor: Color.fromRGBO(249,254,254, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'STATISTICS',
                style: TextStyle(
                  fontFamily: 'FranklinGothic',
                  fontWeight: FontWeight.bold,
                  fontSize: 38,
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return DisplayBox(title: 'Accounts', value: 'Loading...');
                        }
                        int registeredCount = snapshot.data!.docs.length;
                        return DisplayBox(title: 'Accounts', value: registeredCount.toString());
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('Wordlists').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return DisplayBox(title: 'Words List', value: 'Loading...');
                        }
                        int wordListsCount = snapshot.data!.docs.length;
                        return DisplayBox(title: 'Words List', value: wordListsCount.toString());
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('deleted_accounts').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return DisplayBox(title: 'Accounts Banned', value: 'Loading...');
                        }
                        int deletedCount = snapshot.data!.docs.length;
                        return DisplayBox(title: 'Accounts Banned', value: deletedCount.toString());
                      },
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('ProhibitedWords').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return DisplayBox(title: 'Prohibited Words', value: 'Loading...');
                        }
                        int prohibitedWordsCount = snapshot.data!.docs.length;
                        return DisplayBox(title: 'Prohibited Words', value: prohibitedWordsCount.toString());
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ManageAccountPage()),
                        );
                      },
                      child: Text(
                        'MANAGE ACCOUNT',
                        style: TextStyle(
                          fontFamily: 'FranklinGothic',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 70, 70, 70)
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 164,211,255),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WordListsPage()),
                        );
                      },
                      child: Text(
                        'MANAGE WORDS',
                        style: TextStyle(
                          fontFamily: 'FranklinGothic',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 254, 219)
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 70, 70, 70),
                        minimumSize: Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
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
                child: Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'FranklinGothic',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color.fromARGB(255, 70, 70, 70)
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 208, 214, 219),
                  minimumSize: Size(150, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
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
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 208, 214, 219),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'FranklinGothic',
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'FranklinGothic',
              fontWeight: FontWeight.bold,
              fontSize: 40,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
