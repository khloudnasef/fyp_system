import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'studentfiles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

//import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class FileUploadPage extends StatefulWidget {
  final String title;

  const FileUploadPage({Key? key, required this.title}) : super(key: key);

  @override
  _FileUploadPageState createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  List<UploadedFile> uploadedFiles = [];
  bool isUploading = false;

  Future<void> uploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        isUploading = true;
      });

      try {
        String filePath = result.files.single.path!;
        File file = File(filePath);
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';

        // Upload the file to Firebase Storage
        firebase_storage.Reference ref =
            firebase_storage.FirebaseStorage.instance.ref().child(fileName);
        await ref.putFile(file);

        // Get the download URL for the uploaded file
        String downloadURL = await ref.getDownloadURL();

        setState(() {
          isUploading = false;
          uploadedFiles.add(
              UploadedFile(name: result.files.single.name, url: downloadURL));
        });
        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) return;

        print("iasdhfoiashdfosaihdoa8do88ry3iuhdisajbcjkasb");
        print(user.uid);

        QuerySnapshot studentQuerySnapshot = await FirebaseFirestore.instance
            .collection('students')
            .where('userId', isEqualTo: user.uid)
            .get();

        print(studentQuerySnapshot);

        List<Student> students = studentQuerySnapshot.docs.map((doc) {
          String id = doc.id;
          String name = doc.get('studentName');
          String s_id = doc.get('supervisorId');
          return Student(id: id, name: name, s_ID: s_id);
        }).toList();

        print("students[0].s_IDjksahgdkgsakgu");
        print(students[0].s_ID);

        FirebaseFirestore.instance.collection('files').add({
          'studentName': students[0].name,
          'userId': user.uid,
          'studentId': students[0].id,
          'fileName': result.files.single.name,
          'supervisorId': students[0].s_ID,
          'fileUrl': downloadURL,
          'timestamp': DateTime.now(),
        });

        // Show a success message or navigate to a different page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully.'),
          ),
        );
      } catch (error) {
        setState(() {
          isUploading = false;
        });

        // Show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: $error'),
          ),
        );
      }
    } else {
      // User canceled the file picker
    }
  }

  Widget buildUploadButton() {
    return ElevatedButton(
      onPressed: isUploading ? null : uploadFile,
      child: isUploading ? CircularProgressIndicator() : Text('Upload'),
    );
  }

  Widget buildFilePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (UploadedFile file in uploadedFiles)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewPage(
                    url: file.url,
                    name: file.name,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 5.0,
              shadowColor: Colors.grey[400],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          file.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                        onTap: () async {
                          print("dksahdkshdlhasdlihsdl");

                          setState(() {
                            uploadedFiles.remove(file);
                          });
                          QuerySnapshot studentQuerySnapshot =
                              await FirebaseFirestore.instance
                                  .collection('files')
                                  .where('fileName', isEqualTo: file.name)
                                  .get();
                          print("hjasdgusygduyasgdw7e837freuwfvd");
                          print(studentQuerySnapshot.docs.first.id);
                          FirebaseFirestore.instance
                              .collection('files')
                              .doc(studentQuerySnapshot.docs.first.id)
                              .delete();

                          print(uploadedFiles.length);
                        },
                        child: Icon(Icons.delete_forever))
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload File'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildUploadButton(),
            buildFilePreview(),
          ],
        ),
      ),
    );
  }
}

class UploadedFile {
  final String name;
  final String url;

  UploadedFile({required this.name, required this.url});
}

class PDFViewPage extends StatefulWidget {
  final String url;
  final String name;

  const PDFViewPage({Key? key, required this.url, required this.name})
      : super(key: key);

  @override
  State<PDFViewPage> createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
        ),
        body: Container(
          child: SfPdfViewer.network(widget.url),
        )

        // PDFView(
        //   filePath: widget.url,
        //   enableSwipe: true,
        //   swipeHorizontal: true,
        //   autoSpacing: false,
        //   pageFling: false,
        //   onRender: (_pages) {
        //     setState(() {
        //       pages = _pages;
        //       isReady = true;
        //     });
        //   },
        //   onError: (error) {
        //     print(error.toString());
        //   },
        //   onPageError: (page, error) {
        //     print('$page: ${error.toString()}');
        //   },
        //   onViewCreated: (PDFViewController pdfViewController) {
        //     _controller.complete(pdfViewController);
        //   },
        //
        // ),
        );
  }
}

class Student {
  final String id;
  final String name;
  final String s_ID;

  Student({
    required this.id,
    required this.name,
    required this.s_ID,
  });
}
