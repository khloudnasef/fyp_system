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
import '../supervisorhome.dart';

class ProjectCoordinatorHome extends StatelessWidget {
  final String name;
  const ProjectCoordinatorHome({Key? key, required this.name})
      : super(key: key);

  Future<void> handleUploadStudents(BuildContext context) async {
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

        final auth = FirebaseAuth.instance;
        final firestore = FirebaseFirestore.instance;

        // Remove the first row in studentRows
        studentRows.removeAt(0);

        for (final studentRow in studentRows) {
          final studentId = studentRow[0].value.toString();
          final studentName = studentRow[1].value.toString();
          final studentEmail = studentRow[2].value.toString();
          final studentPassword = studentRow[3].value.toString();
          final supervisorId = studentRow[4].value.toString();
          final supervisorName = studentRow[5].value.toString();
          final projectTitle = studentRow[6].value.toString();

          // Check if the student already exists
          final studentSnapshot =
              await firestore.collection('students').doc(studentId).get();

          if (!studentSnapshot.exists) {
            // Create user in Firebase Authentication
            final UserCredential studentAuthResult =
                await auth.createUserWithEmailAndPassword(
              email: studentEmail,
              password: studentPassword,
            );

            // Get the newly created student user's ID
            final studentUserId = studentAuthResult.user!.uid;

            // Create a new document in the "students" collection with the studentId as the document ID
            await firestore.collection('students').doc(studentId).set({
              'studentId': studentId,
              'studentName': studentName,
              'studentEmail': studentEmail,
              'supervisorId': supervisorId,
              'supervisorName': supervisorName,
              'projectTitle': projectTitle,
              'userId':
                  studentUserId, // Store the Firebase Authentication user ID
            });
          }
        }

        // Show success message or navigate to the next screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Student details upload successful')),
        );
      }
    } catch (e) {
      // Handle error
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Student details upload failed')),
      );
    }
  }

  Future<void> handleUploadSupervisors(BuildContext context) async {
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

        // Assuming the supervisor details are in the first sheet
        final Sheet supervisorSheet = excel.tables['Supervisor']!;
        final List<dynamic> supervisorRows = supervisorSheet.rows;

        final auth = FirebaseAuth.instance;
        final firestore = FirebaseFirestore.instance;

        // Remove the first row in supervisorRows
        supervisorRows.removeAt(0);

        // Upload supervisor details to Firebase
        for (final supervisorRow in supervisorRows) {
          // Get supervisorId, supervisorName, supervisorEmail, supervisorPassword
          final supervisorId = supervisorRow[0].value.toString();
          final supervisorName = supervisorRow[1].value.toString();
          final supervisorEmail = supervisorRow[2].value.toString();
          final supervisorPassword = supervisorRow[3].value.toString();
          final supervisorContact = supervisorRow[4].value.toString();

          // Check if the supervisor already exists
          final supervisorSnapshot =
              await firestore.collection('supervisors').doc(supervisorId).get();

          if (!supervisorSnapshot.exists) {
            // Create user in Firebase Authentication
            final UserCredential supervisorAuthResult =
                await auth.createUserWithEmailAndPassword(
              email: supervisorEmail,
              password: supervisorPassword,
            );

            // Get the newly created supervisor user's ID
            final supervisorUserId = supervisorAuthResult.user!.uid;

            // Create a new document in the "supervisors" collection with the supervisorId as the document ID
            await firestore.collection('supervisors').doc(supervisorId).set({
              'supervisorId': supervisorId,
              'supervisorName': supervisorName,
              'supervisorEmail': supervisorEmail,
              'supervisorContact': supervisorContact,
              'userId':
                  supervisorUserId, // Store the Firebase Authentication user ID
            });
          }
        }

        // Show success message or navigate to the next screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supervisor details upload successful')),
        );
      }
    } catch (e) {
      // Handle error
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Supervisor details upload failed')),
      );
    }
  }

  Future<void> handleUploadImportantDueDates(BuildContext context) async {
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

        // Assuming the important due dates are in the first sheet
        final Sheet dueDatesSheet = excel.tables[excel.tables.keys.first]!;
        final List<dynamic> dueDatesRows = dueDatesSheet.rows;

        final firestore = FirebaseFirestore.instance;

        // Remove the first row in dueDatesRows if it contains headers
        if (dueDatesRows.isNotEmpty) {
          dueDatesRows.removeAt(0);
        }

        // Get the existing due dates from Firebase
        final QuerySnapshot dueDatesSnapshot =
            await firestore.collection('important_due_dates').get();

        // Create a map of existing due dates using the titles as keys
        final Map<String, QueryDocumentSnapshot> existingDueDates = {
          for (final doc in dueDatesSnapshot.docs) doc['title']: doc
        };

        // Update or create new due dates in Firebase
        for (final dueDatesRow in dueDatesRows) {
          // Get the due date information from the row
          final title = dueDatesRow[0].value.toString();
          final dueDate = dueDatesRow[1].value.toString();

          // Check if the due date already exists in Firebase
          if (existingDueDates.containsKey(title)) {
            // Update the existing due date document
            final existingDoc = existingDueDates[title]!;
            await firestore
                .collection('important_due_dates')
                .doc(existingDoc.id)
                .update({'dueDate': dueDate});
          } else {
            // Create a new document in the "important_due_dates" collection
            await firestore.collection('important_due_dates').add({
              'title': title,
              'dueDate': dueDate,
            });
          }

          // Remove the processed due date from existingDueDates map
          existingDueDates.remove(title);
        }

        // Delete remaining due dates from Firebase that were not present in the updated Excel sheet
        for (final doc in existingDueDates.values) {
          await firestore
              .collection('important_due_dates')
              .doc(doc.id)
              .delete();
        }

        // Show success message or navigate to the next screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Important due dates upload successful')),
        );
      }
    } catch (e) {
      // Handle error
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Important due dates upload failed')),
      );
    }
  }

  Future<void> handleUploadDocumentation(BuildContext context) async {
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

        // Assuming the important due dates are in the first sheet
        final Sheet dueDatesSheet = excel.tables[excel.tables.keys.first]!;
        final List<dynamic> dueDatesRows = dueDatesSheet.rows;

        final firestore = FirebaseFirestore.instance;

        // Remove the first row in dueDatesRows if it contains headers
        if (dueDatesRows.isNotEmpty) {
          dueDatesRows.removeAt(0);
        }

        // Get the existing due dates from Firebase
        final QuerySnapshot dueDatesSnapshot =
            await firestore.collection('documentation').get();

        // Create a map of existing due dates using the titles as keys
        final Map<String, QueryDocumentSnapshot> existingDueDates = {
          for (final doc in dueDatesSnapshot.docs) doc['title']: doc
        };

        // Update or create new due dates in Firebase
        for (final dueDatesRow in dueDatesRows) {
          // Get the due date information from the row
          final title = dueDatesRow[0].value.toString();
          final dueDate = dueDatesRow[1].value.toString();

          // Check if the due date already exists in Firebase
          if (existingDueDates.containsKey(title)) {
            // Update the existing due date document
            final existingDoc = existingDueDates[title]!;
            await firestore
                .collection('documentation')
                .doc(existingDoc.id)
                .update({'dueDate': dueDate});
          } else {
            // Create a new document in the "important_due_dates" collection
            await firestore.collection('documentation').add({
              'title': title,
              'dueDate': dueDate,
            });
          }

          // Remove the processed due date from existingDueDates map
          existingDueDates.remove(title);
        }

        // Delete remaining due dates from Firebase that were not present in the updated Excel sheet
        for (final doc in existingDueDates.values) {
          await firestore.collection('documentation').doc(doc.id).delete();
        }

        // Show success message or navigate to the next screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Documentation upload successful')),
        );
      }
    } catch (e) {
      // Handle error
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Documentation upload failed')),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '* Please upload using excel format (.xlsx)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            SizedBox(height: 10),
            Padding(
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
                              size: 35,
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
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle upload students button tap
                                          handleUploadStudents(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                          onPrimary: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 12.0,
                                          ),
                                        ),
                                        icon: Icon(Icons.cloud_upload),
                                        label: Text(
                                          'Students',
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Flexible(
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          // Handle upload supervisors button tap
                                          handleUploadSupervisors(context);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          primary: Colors.red,
                                          onPrimary: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.0),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                            vertical: 10.0,
                                            horizontal: 12.0,
                                          ),
                                        ),
                                        icon: Icon(Icons.cloud_upload),
                                        label: Text(
                                          'Supervisors',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
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
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 35,
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
                                      handleUploadImportantDueDates(context);
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
                              Icons.file_copy,
                              color: Colors.white,
                              size: 35,
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
                                  'Add documentation that need to be submitted here',
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
                                      handleUploadDocumentation(context);
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
          ],
        ),
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
