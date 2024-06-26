 

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
            return Center(child: CircularProgressIndicator());
          }
          List<DocumentSnapshot> users = snapshot.data!.docs;

          int nonAdminIndex = 0;  

          List<DataRow> rows = users
              .map<DataRow?>((user) {
                var userData = user.data() as Map<String, dynamic>;
                String username =
                    userData['username'] ?? '';  
                bool isAdmin = userData['isAdmin'] ?? false;

                if (!isAdmin) {
                  nonAdminIndex++;  
                  return DataRow(cells: [
                    DataCell(Text('$nonAdminIndex')),
                    DataCell(Text(username)),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                           
                          Map<String, dynamic> deletedData = {
                            'username': username,
                            'deletedAt': DateTime.now(),
                          };
                          FirebaseFirestore.instance
                              .collection('deleted_accounts')
                              .add(deletedData);
                           
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.id)
                              .delete();
                        },
                        child: Text('Delete'),
                      ),
                    ),
                  ]);
                } else {
                  return null;
                }
              })
              .where((element) => element != null)
              .toList()
              .cast<DataRow>();

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
