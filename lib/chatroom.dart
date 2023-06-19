import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chatbot.dart';

class ChatScreen extends StatefulWidget {
  final String supervisorId;
  final String studentId;

  ChatScreen({required this.supervisorId, required this.studentId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  String chatWithStudentName = '';
  String chatWithSupervisorName = '';
  bool supervisor = false;

  void CheckUser() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    print("user.uid..............................................");
    print(user.uid);
    print(user.email);
    FirebaseFirestore.instance
        .collection('supervisors')
        .doc(widget.supervisorId)
        .get()
        .then((DocumentSnapshot supervisorSnapshot) {
      if (supervisorSnapshot.exists) {
        if (user.uid == supervisorSnapshot.get('userId')) {
          setState(() {
            supervisor = true;
          });
        }
      }
    });
  }

  void fetchChatWithName() {
    FirebaseFirestore.instance
        .collection('supervisors')
        .doc(widget.supervisorId)
        .get()
        .then((DocumentSnapshot supervisorSnapshot) {
      if (supervisorSnapshot.exists) {
        String name = supervisorSnapshot.get('supervisorName');
        setState(() {
          chatWithSupervisorName = name;
        });
      }
    });

    FirebaseFirestore.instance
        .collection('students')
        .doc(widget.studentId)
        .get()
        .then((DocumentSnapshot studentSnapshot) {
      if (studentSnapshot.exists) {
        String name = studentSnapshot.get('studentName');
        setState(() {
          chatWithStudentName = name;
        });
      }
    });

    print(
        "..................................... get student Name $chatWithStudentName");
    print(
        "..................................... get supervisor Name $chatWithSupervisorName");
  }

  @override
  void initState() {
    super.initState();
    CheckUser();
    fetchChatWithName();
  }

  void sendMessage(String message, String supervisorId) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    String chatRoomId = generateChatRoomId(supervisorId, widget.studentId);

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .add({
      'senderId': user.uid,
      'senderName': supervisor ? chatWithSupervisorName : chatWithStudentName,
      'message': message,
      'timestamp': DateTime.now(),
    });
  }

  Stream<QuerySnapshot> getChatMessages(String supervisorId) {
    String chatRoomId = generateChatRoomId(supervisorId, widget.studentId);

    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  String generateChatRoomId(String supervisorId, String studentId) {
    List<String> ids = [supervisorId, studentId]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(supervisor ? chatWithStudentName : chatWithSupervisorName),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getChatMessages(widget.supervisorId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return Center(child: Text('No messages yet'));
                }

                List<QueryDocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    String senderId = messages[index]['senderId'];
                    String senderName = messages[index]['senderName'];
                    String message = messages[index]['message'];
                    DateTime timestamp = messages[index]['timestamp'].toDate();
                    bool isSentByMe =
                        senderId == FirebaseAuth.instance.currentUser?.uid;

                    return Align(
                      alignment: isSentByMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(isSentByMe ? 0 : 20),
                            topLeft: Radius.circular(isSentByMe ? 20 : 0),
                          ),
                          color: isSentByMe
                              ? Colors.red.withOpacity(0.7)
                              : Colors.grey[300],
                        ),
                        constraints: BoxConstraints(
                            maxWidth:
                                MediaQuery.of(context).size.width * 2 / 3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              senderName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              message,
                              style: TextStyle(
                                color: isSentByMe ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              DateFormat('HH:mm').format(timestamp),
                              style: TextStyle(
                                fontSize: 12,
                                color: isSentByMe ? Colors.white : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.red,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.red.withOpacity(0.5),
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(
                      _controller.text,
                      widget.supervisorId,
                    );
                    _controller.clear();
                  },
                  icon: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
