import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'login.dart';
import 'studenthome.dart';
import 'package:excel/excel.dart';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:path/path.dart';

class ProjectCoordinatorHome extends StatelessWidget {
  final String name;
  const ProjectCoordinatorHome({Key? key, required this.name})
      : super(key: key);

  Future<void> handleUpload(BuildContext context) async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true,
      );

      if (result != null) {
        final PlatformFile file = result.files.first;
        final bytes = file.bytes!;
        final excel = Excel.decodeBytes(bytes);

        // Assuming the student details are in the first sheet
        final Sheet studentSheet = excel.tables['Student']!;
        final List<dynamic> studentRows = studentSheet.rows;

        // Assuming the supervisor details are in the second sheet
        final Sheet supervisorSheet = excel.tables['Supervisor']!;
        final List<dynamic> supervisorRows = supervisorSheet.rows;

        final firestore = FirebaseFirestore.instance;
        await Firebase
            .initializeApp(); // Initialize Firebase (if not done already)

        final FirebaseAuth auth = FirebaseAuth.instance;

        // remove the first row in studentRows
        studentRows.removeAt(0);

        for (final studentRow in studentRows) {
          final studentId = studentRow[0].value.toString();
          final studentName = studentRow[1].value.toString();
          final studentEmail = studentRow[2].value.toString();
          final studentPassword = studentRow[3].value.toString();
          final supervisorId = studentRow[4].value.toString();
          final supervisorName = studentRow[5].value.toString();
          final projectTitle = studentRow[6].value.toString();

          // Create a new document in the "students" collection
          final studentDoc = await firestore.collection('students').add({
            'studentId': studentId,
            'studentName': studentName,
            'studentEmail': studentEmail,
            'studentPassword': studentPassword,
            'supervisorId': supervisorId,
            'supervisorName': supervisorName,
            'projectTitle': projectTitle,
          });

          // Create user account for the student in Firebase Authentication
          await auth.createUserWithEmailAndPassword(
            email: studentEmail,
            password: studentPassword,
          );

          // Associate the student's document ID with their user ID in a separate collection
          await firestore.collection('studentUsers').doc(studentDoc.id).set({
            'userId': auth.currentUser!.uid,
          });
        }

        supervisorRows.removeAt(0);

        // Upload supervisor details to Firebase
        for (final supervisorRow in supervisorRows) {
          // get supervisorId, supervisorName, supervisorEmail, supervisorPassword
          final supervisorId = supervisorRow[0].value.toString();
          final supervisorName = supervisorRow[1].value.toString();
          final supervisorEmail = supervisorRow[2].value.toString();
          final supervisorPassword = supervisorRow[3].value.toString();
          final supervisorContact = supervisorRow[4].value.toString();

          // Create a new document in the "supervisors" collection
          final supervisorDoc = await firestore.collection('supervisors').add({
            'supervisorId': supervisorId,
            'supervisorName': supervisorName,
            'supervisorEmail': supervisorEmail,
            'supervisorPassword': supervisorPassword,
            'supervisorContact': supervisorContact,
          });

          // Create user account for the supervisor in Firebase Authentication
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: supervisorEmail,
            password: supervisorPassword,
          );

          // Associate the supervisor's document ID with their user ID in a separate collection
          await firestore
              .collection('supervisorUsers')
              .doc(supervisorDoc.id)
              .set({
            'userId': FirebaseAuth.instance.currentUser!.uid,
          });
        }

        // Show success message or navigate to the next screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful')),
        );
      }
    } catch (e) {
      // Handle error
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        automaticallyImplyLeading: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_circle),
                SizedBox(width: 4),
                Text('Project Coordinator'),
              ],
            ),
            SizedBox(height: 4),
            Text(
              'Welcome, $name',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Navigate to profile page
            },
          ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '* Please upload using excel format',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Student & Supervisor',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add student & supervisors details here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Handle upload button tap
                                      handleUpload(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                    icon: Icon(Icons.cloud_upload),
                                    label: Text('Upload'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Important Due Dates',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add important dates here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Handle upload button tap
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                    icon: Icon(Icons.cloud_upload),
                                    label: Text('Upload'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Card(
                    elevation: 5.0,
                    shadowColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                            ),
                            padding: EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Documentation',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Add documentation that need to be sumbitted here',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // Handle upload button tap
                                    },
                                    style: ElevatedButton.styleFrom(
                                      primary: Colors.red,
                                      onPrimary: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                    ),
                                    icon: Icon(Icons.cloud_upload),
                                    label: Text('Upload'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
