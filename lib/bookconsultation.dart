import 'package:flutter/material.dart';
import 'ttstudent.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bookconsultation.dart';
import 'package:intl/intl.dart';

class Consultation extends StatefulWidget {
  const Consultation({Key? key}) : super(key: key);

  @override
  State<Consultation> createState() => _ConsultationState();
}

class _ConsultationState extends State<Consultation> {
  String? _selectedTimeSlot;
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

  List<String> _commonAvailableTimeSlots = [];
  Set<String> _selectedTimeSlots = {};

  @override
  void initState() {
    super.initState();
    findCommonAvailableTimeSlots();
  }

  Future<void> findCommonAvailableTimeSlots() async {
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

          // Retrieve the student's timetable from Firestore
          DocumentSnapshot timetableSnapshot =
              await firestore.collection('students').doc(studentId).get();

          // Retrieve the supervisor's timetable from Firestore
          DocumentSnapshot supervisorSnapshot = await firestore
              .collection('supervisors')
              .doc(studentSnapshot.get('supervisorId'))
              .get();

          // Get the timetables as nested objects (maps)
          Map<String, dynamic>? studentTimetable =
              timetableSnapshot.data() as Map<String, dynamic>?;
          Map<String, dynamic>? supervisorTimetable =
              supervisorSnapshot.data() as Map<String, dynamic>?;

          if (studentTimetable != null && supervisorTimetable != null) {
            // Get the current date
            DateTime currentDate = DateTime.now();

            // Get the start and end dates for the week (from Monday to Sunday)
            DateTime startDate =
                currentDate.subtract(Duration(days: currentDate.weekday - 1));
            DateTime endDate = startDate.add(Duration(days: 6));

            // Iterate through the time slots and find the common available ones for the week
            _commonAvailableTimeSlots.clear();
            for (DateTime date = startDate;
                date.isBefore(endDate);
                date = date.add(Duration(days: 1))) {
              String formattedDate = DateFormat('dd MMM yyyy').format(date);

              for (String timeSlot in _times) {
                bool isCommonAvailable = true;

                // Check if the time slot is available in both student and supervisor timetables for the current date
                if (studentTimetable.containsKey(formattedDate) &&
                    supervisorTimetable.containsKey(formattedDate)) {
                  // Check if the time slot has a value in both timetables
                  if (studentTimetable[formattedDate][timeSlot] != '' &&
                      supervisorTimetable[formattedDate][timeSlot] != '') {
                    // You can add more conditions for determining availability based on your data structure

                    // The time slot is available in both timetables for the current date
                    _commonAvailableTimeSlots.add('$formattedDate, $timeSlot');
                  }
                }
              }
            }
          }

          // Update the UI with the new available time slots
          setState(() {});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Consultation'),
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Meeting Reason',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter meeting reason',
                  contentPadding: EdgeInsets.all(12.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Date & Time',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _commonAvailableTimeSlots.length,
                itemBuilder: (context, index) {
                  final timeSlot = _commonAvailableTimeSlots[index];
                  return ListTile(
                    onTap: () {
                      setState(() {
                        _selectedTimeSlot = timeSlot;
                      });
                    },
                    title: Text(timeSlot),
                    leading: Radio<String>(
                      value: timeSlot,
                      groupValue: _selectedTimeSlot,
                      onChanged: (value) {
                        setState(() {
                          _selectedTimeSlot = value;
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle button press
                },
                child: Text('Confirm'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.red,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
