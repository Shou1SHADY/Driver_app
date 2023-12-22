import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/modules/history.dart';
import 'package:flutter_application_1/modules/myHomePage.dart';
import 'package:flutter_application_1/modules/user_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RideDetailsPage extends StatefulWidget {
  final String fromRoute;
  final String toRoute;
  final double price;
  final String departureDate;
  RideDetailsPage({
    Key? key,
    required this.fromRoute,
    required this.toRoute,
    required this.price,
    required this.departureDate,
  }) : super(key: key);

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  deleteTrip() async {
    User? user = _auth.currentUser;
    //  final SharedPreferences prefs = await SharedPreferences.getInstance();
    // String email = prefs.getString('user_email')!;
    CollectionReference users = FirebaseFirestore.instance.collection('trips');
    DocumentSnapshot userDoc = await users.doc(user?.uid).get();
    if (user != null) {
      try {
        // Reference to the document you want to delete
        DocumentReference documentReference =
            FirebaseFirestore.instance.collection('trips').doc(user.uid);

        // Delete the document
        await documentReference.delete();

        print('Document deleted successfully');
      } catch (e) {
        print('Error deleting document: $e');
      }
    }
  }

  Future<void> changedState(String stateUpdate) async {
    try {
      // if (_validateTime()) {
      User? user = _auth.currentUser;
      //  final SharedPreferences prefs = await SharedPreferences.getInstance();
      // String email = prefs.getString('user_email')!;
      CollectionReference users =
          FirebaseFirestore.instance.collection('trips');
      DocumentSnapshot userDoc = await users.doc(user?.uid).get();
      Map<String, dynamic> userData;

      // User document found, you can access its data
      userData = userDoc.data() as Map<String, dynamic>;

      String clientID = userData['userId'];
      // Access specific fields
      // stateUpdate = userData['tripState'];

      // stateUpdate = "approvedByDriver";

      if (user != null) {
        if (userData['tripState'].toString().contains("approvedByDriver")) {
          // if (tripFire) {
          await _firestore.collection('trips').doc(user.uid).set({
            'userId': clientID,
            'source': widget.fromRoute, // Replace with your source logic
            'destination': widget.toRoute,
            "tripState": stateUpdate,
            'time': widget.departureDate,
            "price": widget.price
          });
          // } else {
          //   await _firestore.collection('trips').doc(user.uid).set({
          //     'userId': user.uid,
          //     'source': 'Anywhere', // Replace with your source logic
          //     'destination': 'Gate 3/4',
          //     "tripState": stateUpdate,
          //     'time': tripTime,
          //     "price": _tripPrice
          //   });
          // }
          // Create a trip document in Firestore
        }
        // Display success message or navigate to the next page
      } else {
        print('User not signed in.');
      }
      // } else {
      // Display an error message or take appropriate action
      //   print('Invalid time to start the trip.');
      // }
    } catch (e) {
      // Handle errors
      print('Error starting trip: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User signed out successfully.');
    } catch (e) {
      print('Error signing out: $e');
      // Handle errors here
    }
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove('user_email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          width: 200.w,
          child: ListView(
            children: [
              Divider(),
              InkWell(
                onTap: () async {
                  User? userBack = await FirebaseAuth.instance.currentUser;
                  // userFunc();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => UserDetailsPage(
                                user: userBack,
                              )));
                },
                child: ListTile(
                  leading: Icon(
                    Icons.person, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "Profile",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () async {
                  final currentContext = context;
                  await signOut();

                  Navigator.pushAndRemoveUntil(
                    currentContext,
                    MaterialPageRoute(builder: (_) => MyHomePage()),
                    (route) => false,
                  );
                },
                child: ListTile(
                  leading: Icon(
                    Icons.exit_to_app, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () async {
                  // userFunc();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => OrderHistoryPage()));
                },
                child: ListTile(
                  leading: const Icon(
                    Icons.history, // Add your desired icon
                    color: Colors.black, // Set the color of the icon
                  ),
                  tileColor: Colors.grey[200],
                  title: Text(
                    "History",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Divider(),
            ],
          )),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Color.fromARGB(255, 0, 168, 129)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 1, // Remove the shadow
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20.r),
            bottomRight: Radius.circular(20.r),
          ),
        ),
        title: Center(
          child: Text(
            'Ride detail',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(230, 241, 253, 1),
              Color.fromARGB(1, 132, 248, 221)
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(255, 160, 255, 245).withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 5.0,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${widget.fromRoute}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('To: ${widget.toRoute}'),
                      Text('Price: \$${widget.price.toString()}'),
                      Text('Departure Date: ${widget.departureDate}'),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: ElevatedButton(
                        onPressed: () {
                          changedState("finished");
                          deleteTrip();
                          // Action when the first button is pressed
                          print('First Button Pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        child: Text(
                          'Finish',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(20.r),
                      child: ElevatedButton(
                        onPressed: () {
                          changedState("OnGoing");
                          // Action when the second button is pressed
                          print('OnGoing');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                        child: Text(
                          'OnGoing',
                          style: TextStyle(fontSize: 18.0, color: Colors.white),
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
    );
  }
}

// Example usage:
// RideDetailsPage(
//   fromRoute: 'Start Location',
//   toRoute: 'End Location',
//   price: 25.0,
//   departureDate: '2023-12-01 18:30',
// )
