import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Implement your authentication logic here

  static String getCurrentStudentId() {
    // Implement your logic here to get the current student ID
    // This can be based on user authentication or any other mechanism in your app

    // For example, if you are using Firebase Authentication and the user is authenticated:
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    if (currentUser != null) {
      String userId = currentUser
          .uid; // Assuming the user ID is the student ID in this case

      // Retrieve the student ID from Firestore based on the user ID
      FirebaseFirestore.instance
          .collection('students')
          .where('userId', isEqualTo: userId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          // Retrieve the first document with matching user ID
          DocumentSnapshot studentSnapshot = querySnapshot.docs.first;
          String studentId = studentSnapshot.get(
              'studentId'); // Assuming 'studentId' is the field name for the student ID in the Firestore documennt
        }
      });

      return userId;
    } else {
      throw Exception(
          'User is not authenticated'); // Handle the case when the user is not authenticated
    }
  }
}
