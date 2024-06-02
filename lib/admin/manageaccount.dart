// manageaccount.dart

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

          List<DataRow> rows = users.map<DataRow>((user) {
            var userData = user.data() as Map<String, dynamic>;
            String username = userData['username'] ?? ''; // Check for null value
            bool isAdmin = userData['isAdmin'] ?? false;

            if (!isAdmin) {
              return DataRow(cells: [
                DataCell(Text('${users.indexOf(user) + 1}')),
                DataCell(Text(username)),
                DataCell(
                  ElevatedButton(
                    onPressed: () {
                      // Move the account to deleted_accounts collection
                      Map<String, dynamic> deletedData = {
                        'username': username,
                        'deletedAt': DateTime.now(),
                      };
                      FirebaseFirestore.instance.collection('deleted_accounts').add(deletedData);
                      // Delete the account from users collection
                      FirebaseFirestore.instance.collection('users').doc(user.id).delete();
                    },
                    child: Text('Delete'),
                  ),
                ),
              ]);
            } else {
              // Return an empty row for admin accounts
              return DataRow(cells: [
                DataCell(Text('')),
                DataCell(Text('')),
                DataCell(Text('')),
              ]);
            }
          }).toList();

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
