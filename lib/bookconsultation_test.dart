import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/timetable_model.dart';
import 'models/student_model.dart';
import 'models/meeting_model.dart';
import 'utils/sort_time_array.dart';

class BookConsultationTest extends StatefulWidget {
  const BookConsultationTest({super.key});

  @override
  State<BookConsultationTest> createState() => _BookConsultationTestState();
}

class _BookConsultationTestState extends State<BookConsultationTest> {
  TimetableModel? studTimetable;
  TimetableModel? svTimetable;
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

  bool _isDisposed = false;

  @override
  void dispose() {
    reasonController.dispose();
    _isDisposed = true;
    super.dispose();
  }

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

  Future<void> saveConfirmedMeeting(MeetingModel meeting) async {
    final meetingsCollection = db.collection('meetings');
    await meetingsCollection.add({
      'studentName': meeting.studentName,
      'reason': meeting.reason,
      'day': meeting.day,
      'date': meeting.date,
      'time': meeting.time,
    });
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
                          //final studentData = student!;

                          return FutureBuilder<List<TimetableModel?>>(
                            future: Future.wait([
                              readStudentTimetable(),
                              readSupervisorTimetable(student.supervisorId)
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
                                  final studTimetable1 = timetables[0];
                                  studTimetable = timetables[0];
                                  final svTimetable1 = timetables[1];
                                  svTimetable = timetables[1];
                                  if (studTimetable == null ||
                                      svTimetable == null) {
                                    // Error handling
                                    return Center(
                                        child: Text('Timetables not found'));
                                  }
                                  final currentDate = DateTime.now();

                                  String currDay = '...';
                                  String freeTime = '...';
                                  Map<String, String> freeDaysAndTime = {};
                                  final todayStr =
                                      DateFormat('EEEE').format(currentDate);
                                  final todayIndex = days.indexOf(todayStr);

                                  //String todayStr =
                                  //DateFormat('EEEE').format(DateTime.now());
                                  //int today = 0;

                                  for (var dayIndex = todayIndex;
                                      dayIndex < days.length;
                                      dayIndex++) {
                                    final day = days[dayIndex];
                                    currDay = DateFormat('MMMM dd').format(
                                        currentDate.add(Duration(
                                            days: dayIndex - todayIndex)));

                                    final freeTimes =
                                        findAndSortCommonFreeTimes(
                                            day, studTimetable!, svTimetable!);
                                    if (freeTimes.isNotEmpty) {
                                      // Get the first free time of the day
                                      freeTime = freeTimes[0];
                                      freeDaysAndTime[day] = freeTime;
                                    }
                                  }

                                  // Generate the list of free days and time
                                  return ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: freeDaysAndTime.length,
                                      itemBuilder: (context, index) {
                                        final day = freeDaysAndTime.keys
                                            .elementAt(index);
                                        final time = freeDaysAndTime.values
                                            .elementAt(index);
                                        final formattedDay =
                                            DateFormat('MMMM dd').format(
                                                currentDate.add(Duration(
                                                    days: days.indexOf(day) -
                                                        todayIndex)));
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
                                                  '$formattedDay - $day, $time'),
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
                          onPressed: () async {
                            if (_selectedTimeSlot != -1) {
                              final student = await readStudent();
                              final currentDate = DateTime.now();
                              final selectedDay = days[_selectedTimeSlot];
                              final selectedDate = DateFormat('MMMM dd').format(
                                  currentDate
                                      .add(Duration(days: _selectedTimeSlot)));
                              print("studTimetable.........................");
                              print(studTimetable);
                              final selectedTime = findAndSortCommonFreeTimes(
                                  selectedDay,
                                  studTimetable!,
                                  svTimetable!)[_selectedTimeSlot];

                              final confirmedMeeting = MeetingModel(
                                studentName: student?.studentName ??
                                    '', // Replace with the actual field from StudentModel
                                reason: reasonController.text,
                                day: selectedDay,
                                date: selectedDate,
                                time: selectedTime,
                              );

                              await saveConfirmedMeeting(confirmedMeeting);

                              reasonController.clear();
                              setState(() => _selectedTimeSlot = -1);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Meeting scheduled successfully')),
                              );

                              // Navigate back to the previous screen
                              Navigator.pop(context, confirmedMeeting);
                            }
                          },
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
