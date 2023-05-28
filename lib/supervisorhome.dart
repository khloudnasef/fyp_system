import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp_system2/chatscreens.dart';
import 'package:intl/intl.dart';
import 'supervisorfiles.dart';
import 'ttsupervisor.dart';
import 'supervisorprofile.dart';
import 'login.dart';
import 'chatbot.dart';
import 'messages.dart';
import 'listofstudents.dart';
import 'chatscreens.dart';

class SupervisorHome extends StatefulWidget {
  const SupervisorHome({Key? key, required this.name}) : super(key: key);
  final String name;

  @override
  _SupervisorHomeState createState() => _SupervisorHomeState();
}

class _SupervisorHomeState extends State<SupervisorHome> {
  int _selectedIndex = 0;
  String? supervisorName;

  List<DocumentSnapshot> dueDates = [];

  @override
  void initState() {
    super.initState();
    fetchDueDates();
    // Call fetchSupervisorName() here
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
              builder: (context) => SupervisorHome(name: widget.name)),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SupervisorTimetable()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SupervisorFiles()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => SupervisorProfile()),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false, // Remove the back button icon
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(width: 4),
                Text('Supervisor'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Welcome, ${widget.name}',
              style: TextStyle(fontSize: 15),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[200]!, // Light grey color at the top
              Colors.white, // White color at the bottom
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Announcements',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListofStudents()),
                      );
                    },
                    icon: Icon(Icons.person),
                    label: Text('List of Students'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Set button color to red
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
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
            ),
            Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
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
            MaterialPageRoute(
              builder: (context) => ChatRoomsScreen(
                supervisorId: 'supervisorId',
              ),
            ),
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
