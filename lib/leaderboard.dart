import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Leaderboard extends StatelessWidget {
  const Leaderboard({Key? key}) : super(key: key);

  Future<List<Map<String, dynamic>>> _fetchLeaderboardData(String difficulty) async {
    final usersCollection = FirebaseFirestore.instance.collection('users');
    final usersSnapshot = await usersCollection.get();

    List<Map<String, dynamic>> leaderboardData = [];

    for (var userDoc in usersSnapshot.docs) {
      final statsDoc = await usersCollection
          .doc(userDoc.id)
          .collection('stats')
          .doc(difficulty)
          .get();

      if (statsDoc.exists) {
        leaderboardData.add({
          'username': userDoc['username'],
          'wins': statsDoc['wins'],
        });
      }
    }

    // Sort by wins in descending order
    leaderboardData.sort((a, b) => b['wins'].compareTo(a['wins']));

    // Return top 10
    return leaderboardData.take(10).toList();
  }

  Color _getBackgroundColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.yellowAccent;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.grey.shade300;
    }
  }

  Widget _buildLeaderboard(String difficulty) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchLeaderboardData(difficulty),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final leaderboardData = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rank',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Username',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Wins',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardData.length,
                  itemBuilder: (context, index) {
                    final user = leaderboardData[index];
                    final rank = index + 1;
                    final username = user['username'];
                    final wins = user['wins'];
                    final backgroundColor = _getBackgroundColor(rank);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 40,
                            child: Text(
                              '#$rank',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              username,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                            ),
                          ),
                          trailing: Text(
                            wins.toString(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Leaderboard'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Easy'),
              Tab(text: 'Medium'),
              Tab(text: 'Hard'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeaderboard('easy'),
            _buildLeaderboard('medium'),
            _buildLeaderboard('hard'),
          ],
        ),
      ),
    );
  }
}