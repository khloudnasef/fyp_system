import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'utils/authservice.dart';

class AddLogbookPage extends StatefulWidget {
  final String studentId;

  const AddLogbookPage({Key? key, required this.studentId}) : super(key: key);
  @override
  _AddLogbookPageState createState() => _AddLogbookPageState();
}

class _AddLogbookPageState extends State<AddLogbookPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController startDateController = TextEditingController();
  TextEditingController endDateController = TextEditingController();
  TextEditingController tasksAccomplishedController = TextEditingController();
  TextEditingController tasksToDoController = TextEditingController();
  TextEditingController supervisorRemarksController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Logbook'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: startDateController,
                decoration: InputDecoration(labelText: 'Start Date'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the start date';
                  }
                  return null;
                },
              ),
              // Add more input fields for end date, tasks accomplished, tasks to be done, and supervisor remarks
              TextFormField(
                controller: endDateController,
                decoration: InputDecoration(labelText: 'End Date'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the end date';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tasksAccomplishedController,
                decoration: InputDecoration(labelText: 'Tasks Accomplished'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the tasks accomplished';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: tasksToDoController,
                decoration: InputDecoration(labelText: 'Tasks to be Done'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the tasks to be done';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: supervisorRemarksController,
                decoration: InputDecoration(labelText: 'Supervisor Remarks'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter the supervisor remarks';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Save the logbook entry to the database
                    saveLogbookEntry();

                    Navigator.pop(context); // Return to LogbookListPage
                  }
                },
                child: Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void saveLogbookEntry() async {
    final logbookEntry = {
      'startDate': startDateController.text,
      // Add more fields for end date, tasks accomplished, tasks to be done, supervisor remarks
      'submissionTime': DateTime.now().toString(),
    };

    final currentStudentId = AuthService.getCurrentStudentId();
    final currentWeekNumber = await getCurrentWeekNumber(currentStudentId);

    await FirebaseFirestore.instance
        .collection('students')
        .doc(currentStudentId)
        .collection('logbooks')
        .doc('Week $currentWeekNumber')
        .set(logbookEntry);
  }

  Future<int> getCurrentWeekNumber(String studentId) async {
    final logbooksSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .doc(studentId)
        .collection('logbooks')
        .get();

    final numberOfLogbooks = logbooksSnapshot.docs.length;
    return numberOfLogbooks + 1;
  }
}
