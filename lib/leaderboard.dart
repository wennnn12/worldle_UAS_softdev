import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Leaderboard extends StatefulWidget {
  final bool isDarkMode;

  const Leaderboard({Key? key, required this.isDarkMode}) : super(key: key);

  @override
  _LeaderboardState createState() => _LeaderboardState();
}

class _LeaderboardState extends State<Leaderboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

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

     
    leaderboardData.sort((a, b) => b['wins'].compareTo(a['wins']));

     
    return leaderboardData.take(10).toList();
  }

  Widget _buildTrophyIcon(int rank) {
    switch (rank) {
      case 1:
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/gold.png', width: 40, height: 40),
          ],
        );
      case 2:
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/silver.png', width: 40, height: 40),
          ],
        );
      case 3:
        return Stack(
          alignment: Alignment.center,
          children: [
            Image.asset('assets/bronze.png', width: 40, height: 40),
          ],
        );
      default:
        return Text(
          '#$rank',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black),
        );
    }
  }

  Color _getBackgroundColor(int rank) {
    switch (rank) {
      case 1:
        return Color.fromARGB(255, 116, 215, 156);
      case 2:
        return Color.fromARGB(255, 227, 228, 163);
      case 3:
        return Color.fromARGB(255, 224, 160, 168);
      default:
        return widget.isDarkMode ? const Color.fromARGB(255, 80, 80, 80) : const Color.fromARGB(255, 240, 240, 240);
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
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black),
                    ),
                    Text(
                      'Username',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black),
                    ),
                    Text(
                      'Wins',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black),
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
                          leading: _buildTrophyIcon(rank),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Text(
                              username,
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: widget.isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                          trailing: Text(
                            wins.toString(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: widget.isDarkMode ? Colors.white : Colors.black),
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
          title: Text(
            'Leaderboard',
            style: TextStyle(
              fontFamily: 'FranklinGothic',
              fontWeight: FontWeight.bold,
              fontSize: 38,
              color: widget.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: widget.isDarkMode 
          ? Colors.black 
          : const Color.fromARGB(255, 250, 250, 250),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Easy'),
              Tab(text: 'Medium'),
              Tab(text: 'Hard'),
            ],
            labelStyle: TextStyle(
              fontFamily: 'FranklinGothic',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
            unselectedLabelStyle: TextStyle(
              fontFamily: 'FranklinGothic',
              fontSize: 16,
            ),
            labelColor: widget.isDarkMode ? Colors.white : const Color.fromARGB(255, 39, 39, 39),
            unselectedLabelColor: widget.isDarkMode ? Colors.grey[600] : Colors.grey,
            indicatorColor: widget.isDarkMode ? Colors.white : const Color.fromARGB(255, 39, 39, 39),
          ),
        ),
        body: Container(
          color: widget.isDarkMode ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildLeaderboard('easy'),
              _buildLeaderboard('medium'),
              _buildLeaderboard('hard'),
            ],
          ),
        ),
      ),
    );
  }
}
