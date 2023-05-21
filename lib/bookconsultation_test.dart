import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/timetable_model.dart';
import 'models/student_model.dart';
import 'utils/sort_time_array.dart';

class BookConsultationTest extends StatefulWidget {
  const BookConsultationTest({super.key});

  @override
  State<BookConsultationTest> createState() => _BookConsultationTestState();
}

class _BookConsultationTestState extends State<BookConsultationTest> {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  final reasonController = TextEditingController();
  final days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  int _selectedTimeSlot = -1;

  Future<StudentModel?> readStudent() async {
    final studCollection = db.collection('students');
    final currStudID = auth.currentUser!.uid;

    // Get the student's document ID as it is different from the student's user ID
    String currStudDocID = await studCollection
        .where('userId', isEqualTo: currStudID)
        .get()
        .then((value) => value.docs[0].id);

    final studDoc = studCollection.doc(currStudDocID);
    final studSnap = await studDoc.get();

    // Convert the student's document snapshot to StudentModel for easier usage
    return StudentModel.fromJson(studSnap.data()!);
  }

  Future<TimetableModel?> readStudentTimetable() async {
    final studCollection = db.collection('students');
    final currStudID = auth.currentUser!.uid;

    String currStudDocID = await studCollection
        .where('userId', isEqualTo: currStudID)
        .get()
        .then((value) => value.docs[0].id);

    final studDoc = studCollection.doc(currStudDocID);
    final studSnap = await studDoc.get();
    final studTimetable = studSnap['timetable'];

    // Convert the student's timetable from JSON to TimetableModel for easier usage
    return TimetableModel.fromJson(studTimetable);
  }

  Future<TimetableModel?> readSupervisorTimetable(String supervisorId) async {
    final svCollection = db.collection('supervisors');
    final svDoc = svCollection.doc(supervisorId);
    final svSnap = await svDoc.get();
    final svTimetable = svSnap['timetable'];

    // Convert the supervisor's timetable from JSON to TimetableModel for easier usage
    return TimetableModel.fromJson(svTimetable);
  }

  List<String> findAndSortCommonFreeTimes(
      String day, TimetableModel studTimetable, TimetableModel svTimetable) {
    List<String> studFreeTimes = [];
    List<String> svFreeTimes = [];
    List<String> commonFreeTimes = [];

    // Find the free times of the student
    studTimetable.days[day]!.forEach((time, subject) {
      if (subject == '') {
        studFreeTimes.add(time);
      }
    });

    // Find the free times of the supervisor
    svTimetable.days[day]!.forEach((time, subject) {
      if (subject == '') {
        svFreeTimes.add(time);
      }
    });

    // Find the common free times of the student and supervisor
    for (var time in studFreeTimes) {
      if (svFreeTimes.contains(time)) {
        commonFreeTimes.add(time);
      }
    }

    // Sort the common free times to ascending order for easier reading
    commonFreeTimes = sortTimeArray(commonFreeTimes);

    return commonFreeTimes;
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Book Consultation'),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meeting Reason
                  const Text(
                    'Meeting Reason',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: reasonController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12.0),
                      hintText: 'Enter meeting reason',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date & Time
                  const Text(
                    'Date & Time',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Nested FutureBuilders where the first fuyturebuilder is to get the student's supervisor's ID and the second futurebuilder is to get the student's timetable and the supervisor's timetable (using the supervisor's ID)
                  FutureBuilder<StudentModel?>(
                    future: readStudent(),
                    builder: (context, snapshot) {
                      final student = snapshot.data;

                      if (snapshot.hasError) {
                        // Error handling
                        return Center(child: Text(snapshot.toString()));
                      } else if (snapshot.hasData) {
                        if (student == null) {
                          // Error handling
                          return Center(child: Text(snapshot.toString()));
                        } else {
                          final svID = student.supervisorId;

                          return FutureBuilder<List<TimetableModel?>>(
                            future: Future.wait([
                              readStudentTimetable(),
                              readSupervisorTimetable(svID)
                            ]),
                            builder: (context, snapshot) {
                              final timetables = snapshot.data;

                              if (snapshot.hasError) {
                                return Center(child: Text(snapshot.toString()));
                              } else if (snapshot.hasData) {
                                if (timetables == null) {
                                  // Error handling
                                  return Center(
                                      child: Text(snapshot.toString()));
                                } else {
                                  final studTimetable = timetables[0]!;
                                  final svTimetable = timetables[1]!;

                                  String currDay = '...';
                                  String freeTime = '...';
                                  Map<String, String> freeDaysAndTime = {};
                                  String todayStr =
                                      DateFormat('EEEE').format(DateTime.now());
                                  int today = 0;

                                  days.asMap().forEach((key, value) {
                                    if (value == todayStr) today = key;
                                  });

                                  for (var day = today;
                                      day < days.length;
                                      day++) {
                                    currDay = days[day];

                                    final freeTimes =
                                        findAndSortCommonFreeTimes(currDay,
                                            studTimetable, svTimetable);
                                    if (freeTimes.isNotEmpty) {
                                      // Get the first free time of the day
                                      freeTime = freeTimes[0];
                                      freeDaysAndTime.addEntries(
                                          [MapEntry(currDay, freeTime)]);
                                    }
                                  }

                                  // Generate the list of free days and time
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: freeDaysAndTime.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                            elevation: 5,
                                            shadowColor: Colors.grey[400],
                                            child: RadioListTile(
                                              value: index,
                                              groupValue: _selectedTimeSlot,
                                              onChanged: (value) => setState(
                                                  () => _selectedTimeSlot =
                                                      value as int),
                                              title: Text(
                                                  '${freeDaysAndTime.keys.elementAt(index)}, ${freeDaysAndTime.values.elementAt(index)}'),
                                            ));
                                      });
                                }
                              } else {
                                // Error handling
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                            },
                          );
                        }
                      } else {
                        // Error handling
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            reasonController.clear();
                            setState(() => _selectedTimeSlot = -1);
                          },
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.grey[600],
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          child: const Text('Reset')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              shape: const StadiumBorder(),
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          child: const Text('Confirm'))
                    ],
                  ),
                ],
              )),
        ));
  }
}
