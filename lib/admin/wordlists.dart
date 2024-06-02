import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordListsPage extends StatefulWidget {
  @override
  _WordListsPageState createState() => _WordListsPageState();
}

class _WordListsPageState extends State<WordListsPage> {
  final TextEditingController wordController = TextEditingController();

  void _addWord() {
    String word = wordController.text.trim().toUpperCase(); // Convert to uppercase
    if (word.length == 5) {
      FirebaseFirestore.instance.collection('Wordlists').add({'word': word});
      wordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Word must be 5 characters long.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Lists'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: wordController,
              maxLength: 5,
              decoration: InputDecoration(
                hintText: 'Enter a word (5 characters)',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addWord,
            child: Text('Add Word'),
          ),
          SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('Wordlists').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              List<DocumentSnapshot> words = snapshot.data!.docs;
              return ListView.builder(
                shrinkWrap: true,
                itemCount: words.length,
                itemBuilder: (context, index) {
                  var wordData = words[index].data() as Map<String, dynamic>;
                  String word = wordData['word'] ?? ''; // Check for null value
                  return ListTile(
                    title: Text(word),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        FirebaseFirestore.instance.collection('Wordlists').doc(words[index].id).delete();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
