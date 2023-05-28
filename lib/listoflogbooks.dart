import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'addlogbooks.dart';
import 'package:flutter/material.dart';
import 'package:fyp_system2/utils/authservice.dart';

class LogbookListPage extends StatefulWidget {
  const LogbookListPage({Key? key}) : super(key: key);

  @override
  _LogbookListPageState createState() => _LogbookListPageState();
}

class _LogbookListPageState extends State<LogbookListPage> {
  @override
  Widget build(BuildContext context) {
    final String studentId = AuthService.getCurrentStudentId();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Completed Logbooks'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('students')
            .doc(studentId) // Use the retrieved student ID here
            .collection('logbooks')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final logbooks = snapshot.data!.docs;

          if (logbooks.isEmpty) {
            return Center(
              child: Text('No logbooks completed'),
            );
          }

          return ListView.builder(
            itemCount: logbooks.length,
            itemBuilder: (context, index) {
              final logbook = logbooks[index].data() as Map<String, dynamic>;

              final weekNumber = logbook['weekNumber'];
              final submissionTime = logbook['submissionTime'];

              return Card(
                child: ListTile(
                  title: Text('Week $weekNumber'),
                  subtitle: Text('Submitted: $submissionTime'),
                  // Add more details or actions as needed
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          String studentId = AuthService.getCurrentStudentId();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddLogbookPage(studentId: studentId)),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
