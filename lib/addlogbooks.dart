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
        backgroundColor: Colors.red,
      ),
      body: SingleChildScrollView(
        // Wrap the Form with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: startDateController,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the start date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                // Add more input fields with similar styling
                TextFormField(
                  controller: endDateController,
                  decoration: InputDecoration(
                    labelText: 'End Date',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the end date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: tasksAccomplishedController,
                  decoration: InputDecoration(
                    labelText: 'Tasks Accomplished',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the tasks accomplished';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: tasksToDoController,
                  decoration: InputDecoration(
                    labelText: 'Tasks to be Done',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the tasks to be done';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: supervisorRemarksController,
                  decoration: InputDecoration(
                    labelText: 'Supervisor Remarks',
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter the supervisor remarks';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Save the logbook entry to the database
                      saveLogbookEntry();
                      Navigator.pop(context); // Return to LogbookListPage
                    }
                  },
                  child: Text('Confirm', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void saveLogbookEntry() async {
    final logbookEntry = {
      'startDate': startDateController.text,
      'endDate': endDateController.text,
      'tasksAccomplished': tasksAccomplishedController.text,
      'tasksToDo': tasksToDoController.text,
      'supervisorRemarks': supervisorRemarksController.text,
      'submissionTime': DateTime.now().toString(),
      'weekNumber': await getCurrentWeekNumber(widget.studentId),
    };

    final currentStudentId = widget.studentId;

    await FirebaseFirestore.instance
        .collection('students')
        .doc(currentStudentId)
        .collection('logbooks')
        .add(logbookEntry);
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
