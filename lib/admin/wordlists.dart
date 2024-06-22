import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WordListsPage extends StatefulWidget {
  @override
  _WordListsPageState createState() => _WordListsPageState();
}

class _WordListsPageState extends State<WordListsPage> {
  final TextEditingController wordController = TextEditingController();

  void _addWord() {
    List<String> words = wordController.text.split('\n').map((word) => word.trim().toUpperCase()).toList();
    bool allWordsValid = true;

    for (String word in words) {
      if (word.length == 5) {
        FirebaseFirestore.instance.collection('Wordlists').add({'word': word});
      } else {
        allWordsValid = false;
      }
    }

    if (allWordsValid) {
      wordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Each word must be 5 characters long.'),
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
<<<<<<< Updated upstream
      resizeToAvoidBottomInset: true, // This helps to prevent the overflow
      body: SingleChildScrollView( // This helps to scroll the content when the keyboard appears
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(20),
              child: TextField(
                controller: wordController,
                maxLines: null, // Allow multiple lines
                decoration: InputDecoration(
                  hintText: 'Enter words (each 5 characters) separated by new lines',
                ),
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _addWord,
              child: Text('Add Words'),
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
                  physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling conflict
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
=======
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              controller: wordController,
              maxLines: null,  
              decoration: InputDecoration(
                hintText: 'Enter words (each 5 characters) separated by new lines',
              ),
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _addWord,
            child: Text('Add Words'),
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
                  String word = wordData['word'] ?? '';  
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
>>>>>>> Stashed changes
      ),
    );
  }
}
