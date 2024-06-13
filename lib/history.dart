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
  int currentPage = 0;
  int itemsPerPage = 6;

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
        DateTime? dateTime;
        if (timestamp != null) {
          dateTime = timestamp.toDate();
          date = DateFormat.yMMMd().format(dateTime);
        }
        allHistoryData.add({
          'date': date,
          'status': gameData['status'] ?? 'N/A',
          'guesses': gameData['attempts'] ?? 0,
          'duration': gameData['duration'] ?? 0,
          'difficulty': difficulty,
          'timestamp': dateTime,
          'targetWord': gameData['targetWord'] ?? 'N/A',
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
    int startIndex = currentPage * itemsPerPage;
    int endIndex = startIndex + itemsPerPage;
    List<Map<String, dynamic>> pageData = historyData.sublist(startIndex,
        endIndex > historyData.length ? historyData.length : endIndex);

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
                itemCount: pageData.length,
                itemBuilder: (context, index) {
                  final data = pageData[index];
                  return HistoryCard(
                    index: startIndex + index + 1,
                    date: data['date'] ?? 'N/A',
                    status: data['status'] ?? 'N/A',
                    guesses: data['guesses'] ?? 0,
                    duration: data['duration'] ?? 0,
                    difficulty: data['difficulty']?.toUpperCase() ?? 'N/A',
                    targetWord: data['targetWord'] ?? 'N/A',
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: currentPage > 0
                      ? () {
                          setState(() {
                            currentPage--;
                          });
                        }
                      : null,
                  child: Text('Previous'),
                ),
                Text(
                  'Page ${currentPage + 1} of ${((historyData.length - 1) / itemsPerPage).ceil() + 1}',
                  style: TextStyle(fontSize: 16),
                ),
                TextButton(
                  onPressed: endIndex < historyData.length
                      ? () {
                          setState(() {
                            currentPage++;
                          });
                        }
                      : null,
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
  final String difficulty;
  final int duration;
  final String targetWord;

  HistoryCard({
    required this.index,
    required this.date,
    required this.status,
    required this.guesses,
    required this.difficulty,
    required this.duration,
    required this.targetWord,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDuration = Duration(seconds: duration);
    final durationStr =
        '${formattedDuration.inMinutes}:${(formattedDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        color: Colors.white,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 110,
              color: status == 'WIN' ? Colors.green[200] : Colors.red[200],
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            VerticalDivider(
              color: Colors.black,
              thickness: 2,
              width: 1,
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10.0),
                color: status == 'WIN' ? Colors.green[100] : Colors.red[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: status == 'WIN' ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.black, thickness: 1),
                    Row(
                      children: List.generate(
                          5,
                          (i) => Padding(
                                padding: EdgeInsets.symmetric(horizontal: 2.0),
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      i < targetWord.length
                                          ? targetWord[i]
                                          : '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$guesses Guess${guesses > 1 ? 'es' : ''}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          durationStr,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          difficulty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
