import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SupervisorFiles extends StatefulWidget {
  const SupervisorFiles({super.key});

  @override
  State<SupervisorFiles> createState() => _SupervisorFilesState();
}

class _SupervisorFilesState extends State<SupervisorFiles> {
  List<Widget> documentationCardsS = [];

  @override
  void initState() {
    super.initState();
    fetchDocumentationCardsS().then((value) {});
  }

  Future<void> fetchDocumentationCardsS() async {
    try {
      final QuerySnapshot documentationSnapshot =
          await FirebaseFirestore.instance.collection('documentation').get();

      print("834798374983748937498374987347237943 889988988989889889");
      print(documentationSnapshot.docs.length);

      setState(() {
        documentationCardsS = documentationSnapshot.docs.map((doc) {
          final title = doc['title'];
          final dueDate = doc['dueDate'];

          return Card(
            elevation: 5.0,
            shadowColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                      Icons.description,
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
                            'Due Date: $dueDate',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SStudentFiles(),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList();
      });
    } catch (error) {
      print('Error fetching documentation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Student Files'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card(
          //   elevation: 5.0,
          //   shadowColor: Colors.grey[400],
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(15.0),
          //   ),
          //   margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Row(
          //       children: [
          //         Container(
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.red,
          //           ),
          //           padding: EdgeInsets.all(8.0),
          //           child: Icon(
          //             Icons.description,
          //             color: Colors.white,
          //             size: 30,
          //           ),
          //         ),
          //         SizedBox(width: 16),
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'Chapter 1 Report',
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             SizedBox(height: 8),
          //             Row(
          //               children: [
          //                 Icon(Icons.access_time, size: 16),
          //                 SizedBox(width: 4),
          //                 Text(
          //                   'Last updated: April 3 2023',
          //                   style: TextStyle(
          //                     fontSize: 14,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(height: 16),
          //             GestureDetector(
          //               onTap: () {
          //                 // Handle view button tap
          //               },
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(8.0),
          //                 ),
          //                 padding: EdgeInsets.symmetric(
          //                     horizontal: 16.0, vertical: 8.0),
          //                 child: Text(
          //                   'View',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold,
          //                     fontSize: 14,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Card(
            elevation: 5.0,
            shadowColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                      Icons.book,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Logbook',
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
                            'Last updated: April 3 2023',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          // Handle view button tap
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: documentationCardsS,
            ),
          )
        ],
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Color.fromARGB(255, 103, 101, 101),
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

class SStudentFiles extends StatefulWidget {
  const SStudentFiles({super.key});

  @override
  State<SStudentFiles> createState() => _SStudentFilesState();
}

class _SStudentFilesState extends State<SStudentFiles> {
  List<Widget> documentationCards = [];

  @override
  void initState() {
    super.initState();
    fetchDocumentationCards().then((value) {});
  }

  Future<void> fetchDocumentationCards() async {
    try {
      final QuerySnapshot documentationSnapshot =
          await FirebaseFirestore.instance.collection('files').get();

      print("834798374983748937498374987347237943");
      print(documentationSnapshot.docs.length);

      setState(() {
        documentationCards = documentationSnapshot.docs.map((doc) {
          print(doc['fileName']);
          final fileName = doc['fileName'];
          final url = doc['fileUrl'];
          final s_name = doc['studentName'];
          // final dueDate = doc['dueDate'];

          return Card(
            elevation: 5.0,
            shadowColor: Colors.grey[400],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                      Icons.description,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            'Submitted By: $s_name',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PDFViewPage(
                                url: url,
                                name: fileName,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            'View',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList();
      });
    } catch (error) {
      print('Error fetching documentation: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Student Files'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card(
          //   elevation: 5.0,
          //   shadowColor: Colors.grey[400],
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(15.0),
          //   ),
          //   margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Row(
          //       children: [
          //         Container(
          //           decoration: BoxDecoration(
          //             shape: BoxShape.circle,
          //             color: Colors.red,
          //           ),
          //           padding: EdgeInsets.all(8.0),
          //           child: Icon(
          //             Icons.book,
          //             color: Colors.white,
          //             size: 30,
          //           ),
          //         ),
          //         SizedBox(width: 16),
          //         Column(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Text(
          //               'Logbook',
          //               style: TextStyle(
          //                 fontSize: 18,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //             ),
          //             SizedBox(height: 8),
          //             Row(
          //               children: [
          //                 Icon(Icons.access_time, size: 16),
          //                 SizedBox(width: 4),
          //                 Text(
          //                   'Last updated: April 3 2023',
          //                   style: TextStyle(
          //                     fontSize: 14,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(height: 16),
          //             GestureDetector(
          //               onTap: () {
          //                 // Handle view button tap
          //               },
          //               child: Container(
          //                 decoration: BoxDecoration(
          //                   color: Colors.red,
          //                   borderRadius: BorderRadius.circular(8.0),
          //                 ),
          //                 padding: EdgeInsets.symmetric(
          //                     horizontal: 16.0, vertical: 8.0),
          //                 child: Text(
          //                   'View',
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.bold,
          //                     fontSize: 14,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //           ],
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          Expanded(
            child: ListView(
              children: documentationCards,
            ),
          )
        ],
      ),
    );
  }
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
