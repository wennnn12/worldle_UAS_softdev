import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  

class HistoryPage extends StatefulWidget {
  final bool isDarkMode;  

  const HistoryPage({Key? key, required this.isDarkMode}) : super(key: key);  

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
    final difficulties = ['easy', 'medium', 'hard'];  
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

     
    allHistoryData.sort((a, b) {
      DateTime aDate = a['timestamp'] ?? DateTime(1970);
      DateTime bDate = b['timestamp'] ?? DateTime(1970);
      return bDate.compareTo(aDate);
    });

     
    if (allHistoryData.length > 30) {
      allHistoryData = allHistoryData.sublist(0, 30);
    }

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
        title: Text(
          'History',
          style: TextStyle(
            fontFamily: 'FranklinGothic',
            fontWeight: FontWeight.bold,
            fontSize: 38,
            color: widget.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      ),
      body: Container(
        color: widget.isDarkMode ? const Color.fromARGB(255, 26, 26, 26) : Colors.white,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    isDarkMode: widget.isDarkMode,  
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
                  style: TextStyle(fontSize: 16, color: widget.isDarkMode ? Colors.white : Colors.black),
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
  final bool isDarkMode;  

  HistoryCard({
    required this.index,
    required this.date,
    required this.status,
    required this.guesses,
    required this.difficulty,
    required this.duration,
    required this.targetWord,
    required this.isDarkMode,  
  });

  @override
  Widget build(BuildContext context) {
    final formattedDuration = Duration(seconds: duration);
    final durationStr =
        '${formattedDuration.inMinutes}:${(formattedDuration.inSeconds % 60).toString().padLeft(2, '0')}';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      margin: EdgeInsets.symmetric(vertical: 6.0),
      color: (status == 'WIN' ? Color.fromARGB(255, 205, 255, 225) : const Color.fromARGB(255, 255, 224, 227)),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 110,
            decoration: BoxDecoration(
              color: (status == 'WIN' ? Color.fromARGB(255, 140, 255, 186) : Color.fromARGB(255, 255, 182, 190)),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                bottomLeft: Radius.circular(15.0),
              ),
            ),
            child: Center(
              child: Text(
                '$index',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          VerticalDivider(
            color: Color.fromARGB(255, 0, 0, 0),
            thickness: 2,
            width: 2,
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: (status == 'WIN' ? Color.fromARGB(255, 205, 255, 225) : const Color.fromARGB(255, 255, 224, 227)),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
              ),
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
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: status == 'WIN' ? Color.fromARGB(255, 36, 36, 36) : Color.fromARGB(255, 36, 36, 36),
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
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Center(
                                  child: Text(
                                    i < targetWord.length ? targetWord[i] : '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:Colors.black,
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
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        durationStr,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        difficulty.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
    );
  }
}
