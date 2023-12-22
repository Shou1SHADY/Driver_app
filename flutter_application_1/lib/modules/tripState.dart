import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// ... Your other imports and code ...

class YourWidget extends StatelessWidget {
  final User? user; // Assuming you have access to the user object

  YourWidget({this.user});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('trips')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while waiting for data
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(8.0.r),
              child: ListTile(title: Text('There is no trips yet')),
            ),
          ); // Handle case where the document does not exist
        }

        // Assuming 'tripState' is a field in your Firestore document
        String tripState = snapshot.data!['tripState'];

        return Card(
          child: Padding(
            padding: EdgeInsets.all(8.0.r),
            child: ListTile(
              title: Text('Trip State: $tripState'),
              // Other card content...
            ),
          ),
        );
      },
    );
  }
}
