import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Account'),
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List<DocumentSnapshot> users = snapshot.data!.docs;
          List<DataRow> rows = [];

          // Filter out admin account and create DataRow for each user
          users.forEach((user) {
            var userData = user.data() as Map<String, dynamic>;
            String username = userData['username'] ?? ''; // Check for null value

            if (userData['isAdmin'] != true) {
              rows.add(DataRow(cells: [
                DataCell(Text('${users.indexOf(user) + 1}')),
                DataCell(Text(username)),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      // Add action here for managing account
                    },
                    child: Text('Manage'),
                  ),
                ),
              ]));
            }
          });

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('Account Number')),
                DataColumn(label: Text('Username')),
                DataColumn(label: Text('Actions')),
              ],
              rows: rows,
            ),
          );
        },
      ),
    );
  }
}
