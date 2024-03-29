import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp_system2/studentfiles.dart';
import 'package:fyp_system2/studentprofile.dart';
import 'package:fyp_system2/ttstudent.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'login.dart';
import 'chatbot.dart';
import 'messages.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;
  String? supervisorName;

  List<DocumentSnapshot> dueDates = [];

  @override
  void initState() {
    super.initState();
    fetchDueDates();
    fetchSupervisorName(); // Call fetchSupervisorName() here
  }

  Future<void> fetchDueDates() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('important_due_dates')
          .get();

      setState(() {
        dueDates = querySnapshot.docs;
      });
    } catch (error) {
      print('Error fetching due dates: $error');
    }
  }

  void fetchSupervisorName() {
    User? user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('students')
        .where('userId', isEqualTo: user!.uid)
        .get()
        .then((QuerySnapshot studentQuerySnapshot) {
      if (studentQuerySnapshot.docs.isNotEmpty) {
        String supervisorId = studentQuerySnapshot.docs[0].get('supervisorId');
        FirebaseFirestore.instance
            .collection('supervisors')
            .where('supervisorId', isEqualTo: supervisorId)
            .get()
            .then((QuerySnapshot supervisorQuerySnapshot) {
          if (supervisorQuerySnapshot.docs.isNotEmpty) {
            String supervisorName =
                supervisorQuerySnapshot.docs[0].get('supervisorName');
            setState(() {
              this.supervisorName = supervisorName;
            });
          }
        });
      }
    });
  }

  static const List<Widget> _widgetOptions = <Widget>[
    SizedBox.shrink(),
    SizedBox.shrink(),
    SizedBox.shrink(),
    SizedBox.shrink(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentHome(name: widget.name)),
        );
        break;
      case 1:
        // Handle "Calendar" icon tap
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StudentTimetable(name: widget.name)),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentFiles()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => StudentProfile()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: AppBar(
          backgroundColor: Colors.red,
          automaticallyImplyLeading: false,
          title: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(width: 4),
                  Text('Student'),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'Welcome, ${widget.name}',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                logout(context);
              },
              icon: Icon(
                Icons.logout,
              ),
            )
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Supervised by: $supervisorName',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.normal),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Announcements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: dueDates.length,
                itemBuilder: (context, index) {
                  final doc = dueDates[index];
                  final title = doc[
                      'title']; // Make sure 'title' field exists in the document
                  final dueDate = doc[
                      'dueDate']; // Make sure 'dueDate' field exists in the document

                  return Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    margin:
                        EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.paste,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Due on $dueDate',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 103, 101, 101),
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatBot()),
          );
        },
        child: Icon(Icons.message),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 5.0,
        highlightElevation: 10.0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> logout(BuildContext context) async {
    CircularProgressIndicator();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
