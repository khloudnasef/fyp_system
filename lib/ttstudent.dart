import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'bookconsultation.dart';
import 'bookconsultation_test.dart';

class StudentTimetable extends StatefulWidget {
  const StudentTimetable({super.key});

  @override
  State<StudentTimetable> createState() => _StudentTimetableState();
}

class _StudentTimetableState extends State<StudentTimetable> {
  // The number of hours in a day
  static const int _numberOfHours = 12;

  // The number of days in a week
  static const int _numberOfDays = 7;

  // The times for each hour of the day
  final List<String> _times = [
    '8 AM',
    '9 AM',
    '10 AM',
    '11 AM',
    '12 PM',
    '1 PM',
    '2 PM',
    '3 PM',
    '4 PM',
    '5 PM',
    '6 PM',
    '7 PM',
  ];

  // The days of the week
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // The timetable slots for each day of the week
  List<List<String>> _timetableSlots = List.generate(
      _numberOfDays, (dayIndex) => List.filled(_numberOfHours, ''));

  final List<Map<String, dynamic>> upcomingMeetings = [
    {
      'icon': Icons.calendar_today,
      'title': 'Review Chapter 1',
      'date': 'April 10, 2023, 3:00 PM',
    },
  ];
  @override
  void initState() {
    super.initState();
    // Load the timetable data when the widget initializes
    loadTimetable();
  }

  void loadTimetable() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String studentId;

      await firestore
          .collection('students')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot studentSnapshot = querySnapshot.docs.first;
          studentId = studentSnapshot.id;

          // Retrieve the timetable data from Firestore
          DocumentSnapshot timetableSnapshot =
              await studentSnapshot.reference.get();
          Map<String, dynamic>? timetableData =
              timetableSnapshot.data() as Map<String, dynamic>?;

          if (timetableData != null) {
            // Retrieve the nested timetable data
            Map<String, dynamic>? nestedTimetableData =
                timetableData['timetable'] as Map<String, dynamic>?;

            if (nestedTimetableData != null) {
              // Update the local timetable slots using the loaded data
              for (int day = 0; day < _numberOfDays; day++) {
                String dayOfWeek = _daysOfWeek[day];
                for (int hour = 0; hour < _numberOfHours; hour++) {
                  String time = _times[hour];
                  _timetableSlots[day][hour] =
                      nestedTimetableData[dayOfWeek]![time] as String? ?? '';
                }
              }
              // Refresh the widget after loading the timetable
              setState(() {});
            }
          }
        }
      });
    }
  }

  void saveTimetable() async {
    // Get a reference to the Firestore instance
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Get the current user from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String studentId;

      // Retrieve the current student's ID
      await firestore
          .collection('students')
          .where('userId', isEqualTo: user.uid)
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (querySnapshot.docs.isNotEmpty) {
          DocumentSnapshot studentSnapshot = querySnapshot.docs.first;
          studentId = studentSnapshot.id;

          // Convert the nested array into a nested object (map)
          Map<String, dynamic> timetableData = {};
          for (int day = 0; day < _numberOfDays; day++) {
            String dayOfWeek = _daysOfWeek[day];
            timetableData[dayOfWeek] = {};
            for (int hour = 0; hour < _numberOfHours; hour++) {
              String time = _times[hour];
              timetableData[dayOfWeek][time] = _timetableSlots[day][hour];
            }
          }

          // Update the student document with the timetable data
          DocumentReference studentDocument =
              firestore.collection('students').doc(studentId);
          await studentDocument.update({
            'timetable': timetableData,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Timetable saved successfully')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Student Timetable'),
          backgroundColor: Colors.red,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Timetable'),
              Tab(text: 'Upcoming Meetings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add Timetable Tab
            Stack(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        // Column for days of the week
                        const DataColumn(
                          label: SizedBox(width: 100),
                        ),
                        // Columns for each time slot
                        for (final time in _times)
                          DataColumn(
                            label: SizedBox(width: 100, child: Text(time)),
                          ),
                      ],
                      rows: [
                        // Rows for each day of the week
                        for (int day = 0; day < _numberOfDays; day++)
                          DataRow(cells: [
                            // Cell for day of the week
                            DataCell(
                              SizedBox(
                                width: 100,
                                child: Text(
                                  _daysOfWeek[day],
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // Cells for each time slot
                            for (int hour = 0; hour < _numberOfHours; hour++)
                              DataCell(
                                SizedBox(
                                  width: 100,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.1),
                                        width: 1.0,
                                      ),
                                      borderRadius: BorderRadius.circular(8.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          blurRadius: 2,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                      color: _timetableSlots[day][hour].isEmpty
                                          ? Colors.grey.withOpacity(0.2)
                                          : const Color.fromARGB(
                                              255, 175, 233, 205),
                                    ),
                                    child: TextField(
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        //fontWeight: FontWeight.bold,
                                      ),
                                      decoration: const InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 4.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      onChanged: (text) {
                                        setState(() {
                                          _timetableSlots[day][hour] = text;
                                        });
                                      },
                                      controller:
                                          TextEditingController.fromValue(
                                        TextEditingValue(
                                          text: _timetableSlots[day][hour],
                                          selection: TextSelection.collapsed(
                                            offset: _timetableSlots[day][hour]
                                                .length,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  margin: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                  child: FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BookConsultationTest()),
                      );
                    },
                    label: const Text(
                      'Book Consultation',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.calendar_today),
                    backgroundColor: Colors.red,
                  ),
                ),
                Positioned(
                  // move button to bottom right corner
                  bottom: 200,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      saveTimetable();
                    },
                    icon: const Icon(Icons.save),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    //make the text bigger
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // Set button color to red
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Upcoming Meetings Tab
            ListView.builder(
              itemCount: upcomingMeetings.length,
              itemBuilder: (context, index) {
                final meeting = upcomingMeetings[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon and title
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(32),
                          ),
                          child: Icon(
                            meeting['icon'],
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              meeting['title'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Friday, April 7 2023', // replace with actual date and time
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
