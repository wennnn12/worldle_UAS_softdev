import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package

class HistoryPage extends StatefulWidget {
  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  User? currentUser;
  List<Map<String, dynamic>> historyData = [];

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      fetchHistoryData();
    }
  }

  Future<void> fetchHistoryData() async {
    final userId = currentUser!.uid;
    final difficulties = ['easy', 'medium', 'hard']; // Adjust as needed
    List<Map<String, dynamic>> allHistoryData = [];

    for (String difficulty in difficulties) {
      final gamesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('guessStats')
          .doc(difficulty)
          .collection('games');

      final gamesDocs = await gamesRef.get();
      for (var gameDoc in gamesDocs.docs) {
        final gameData = gameDoc.data();
        final timestamp = gameData['timestamp'] as Timestamp?;
        String date = 'N/A';
        String time = 'N/A';
        DateTime? dateTime;
        if (timestamp != null) {
          dateTime = timestamp.toDate();
          date = DateFormat.yMMMd().format(dateTime);
          time = DateFormat.jm().format(dateTime);
        }
        allHistoryData.add({
          'date': date,
          'status': 'N/A', // Update this field if status data is available
          'guesses': gameData['attempts'] ?? 0,
          'time': time,
          'difficulty': difficulty,
          'timestamp': dateTime, // Add DateTime for sorting
        });
      }
    }

    // Sort the history data from latest to oldest
    allHistoryData.sort((a, b) {
      DateTime aDate = a['timestamp'] ?? DateTime(1970);
      DateTime bDate = b['timestamp'] ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });

    setState(() {
      historyData = allHistoryData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'HISTORY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: historyData.length,
                itemBuilder: (context, index) {
                  final data = historyData[index];
                  return HistoryCard(
                    index: index + 1,
                    date: data['date'] ?? 'N/A',
                    status: data['status'] ?? 'N/A',
                    guesses: data['guesses'] ?? 0,
                    time: data['time'] ?? 'N/A',
                    difficulty: data['difficulty'] ?? 'N/A',
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text('Previous'),
                ),
                Text(
                  'Page 1 of 2',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final int index;
  final String date;
  final String status;
  final int guesses;
  final String time;
  final String difficulty;

  HistoryCard({
    required this.index,
    required this.date,
    required this.status,
    required this.guesses,
    required this.time,
    required this.difficulty,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: status == 'WIN' ? Colors.green[100] : Colors.red[100],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$index',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(date),
                Text(status),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Time: $time'),
                TextButton(
                  onPressed: () {},
                  child: Text('See Details'),
                ),
              ],
            ),
            Text('$guesses Guess${guesses > 1 ? 'es' : ''}'),
            Text('Difficulty: $difficulty'),
          ],
        ),
      ),
    );
  }
}
