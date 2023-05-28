import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatroom.dart';

class ChatRoomsScreen extends StatefulWidget {
  final String supervisorId; // Added supervisorId property

  ChatRoomsScreen({required this.supervisorId});
  @override
  _ChatRoomsScreenState createState() => _ChatRoomsScreenState();
}

class Student {
  final String id;
  final String name;
  final String projectTitle;
  final String supervisorName;
  final String supervisorId;

  Student({
    required this.id,
    required this.name,
    required this.projectTitle,
    required this.supervisorName,
    required this.supervisorId,
  });
}

class _ChatRoomsScreenState extends State<ChatRoomsScreen> {
  List<Student> supervisedStudents = [];

  @override
  void initState() {
    super.initState();
    fetchSupervisedStudents();
  }

  void fetchSupervisedStudents() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot supervisorQuerySnapshot = await FirebaseFirestore.instance
        .collection('supervisors')
        .where('userId', isEqualTo: user.uid)
        .get();

    if (supervisorQuerySnapshot.docs.isNotEmpty) {
      DocumentSnapshot supervisorDoc = supervisorQuerySnapshot.docs[0];
      String supervisorId = supervisorDoc.id;

      QuerySnapshot studentQuerySnapshot = await FirebaseFirestore.instance
          .collection('students')
          .where('supervisorId', isEqualTo: supervisorId)
          .get();

      List<Student> students = studentQuerySnapshot.docs.map((doc) {
        String id = doc.id;
        String name = doc.get('studentName');
        String projectTitle = doc.get('projectTitle');
        String supervisorName = doc.get('supervisorName');
        String supervisorId = doc.get('supervisorId');
        return Student(
          id: id,
          name: name,
          projectTitle: projectTitle,
          supervisorName: supervisorName,
          supervisorId: supervisorId,
        );
      }).toList();

      setState(() {
        supervisedStudents = students;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Rooms'),
        backgroundColor: Colors.red,
      ),
      body: supervisedStudents.isEmpty
          ? Center(child: Text('No chat rooms'))
          : ListView.builder(
              itemCount: supervisedStudents.length,
              itemBuilder: (context, index) {
                print("supervisedStudents[index]");
                print(supervisedStudents[index]);
                Student student = supervisedStudents[index];

                return GestureDetector(
                  onTap: () {
                    print(
                        "..................................... get student id ${student.id} ");
                    print(
                        "..................................... get supervisor Id ${student.supervisorId} ");
                    print(
                        "..................................... get supervisor Id ${student.name} ");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          supervisorId: student.supervisorId,
                          studentId: student.id,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            backgroundColor: Colors.grey,
                            radius: 20,
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
