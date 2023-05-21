import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'supervisorfiles.dart';
import 'supervisorprofile.dart';
import 'ttsupervisor.dart';

class ListofStudents extends StatefulWidget {
  const ListofStudents({super.key});

  @override
  State<ListofStudents> createState() => _ListofStudentsState();
}

class Student {
  final String id;
  final String name;
  final String projectTitle;

  Student({
    required this.id,
    required this.name,
    required this.projectTitle,
  });
}

class _ListofStudentsState extends State<ListofStudents> {
  List<Student> supervisedStudents = [];

  @override
  void initState() {
    super.initState();
    fetchSupervisedStudents();
  }

  void fetchSupervisedStudents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('supervisors')
        .where('userId', isEqualTo: user.uid)
        .get()
        .then((QuerySnapshot supervisorQuerySnapshot) {
      if (supervisorQuerySnapshot.docs.isNotEmpty) {
        DocumentSnapshot supervisorDoc = supervisorQuerySnapshot.docs[0];
        String supervisorId = supervisorDoc.id;

        FirebaseFirestore.instance
            .collection('students')
            .where('supervisorId', isEqualTo: supervisorId)
            .get()
            .then((QuerySnapshot studentQuerySnapshot) {
          List<Student> students = [];
          studentQuerySnapshot.docs.forEach((DocumentSnapshot doc) {
            String id = doc.id;
            String name = doc.get('studentName');
            String projectTitle = doc.get('projectTitle');
            Student student = Student(
              id: id,
              name: name,
              projectTitle: projectTitle,
            );
            students.add(student);
          });

          setState(() {
            supervisedStudents = students;
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('List of Students'),
      ),
      body: supervisedStudents.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Project Title',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: supervisedStudents
                    .asMap()
                    .entries
                    .map(
                      (entry) => DataRow(
                        color: entry.key % 2 == 0
                            ? MaterialStateColor.resolveWith(
                                (states) => Colors.white)
                            : MaterialStateColor.resolveWith(
                                (states) => Colors.grey[200]!),
                        cells: [
                          DataCell(
                            Text(entry.value.id),
                            onTap: () {
                              // Handle cell tap if needed
                            },
                          ),
                          DataCell(
                            Text(entry.value.name),
                            onTap: () {
                              // Handle cell tap if needed
                            },
                          ),
                          DataCell(
                            Text(entry.value.projectTitle),
                            onTap: () {
                              // Handle cell tap if needed
                            },
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
