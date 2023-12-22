import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/history.dart';
import 'package:flutter_application_1/modules/myHomePage.dart';
import 'package:flutter_application_1/modules/user_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderHistoryPage extends StatefulWidget {
  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<HistoryItem> myRoutes = [];
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
            ],
          )),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            'History',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/background.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('trips')
              .doc(FirebaseAuth.instance.currentUser
                  ?.uid) // Document ID is set to the user ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return Center(
                child: Text('No order history available.'),
              );
            }
// if (snapshot.hasData) {
//               myRoutes = snapshot.data!.docs
//                   .map((doc) =>
//                       HistoryItem.fromMap(doc.data() as Map<String, dynamic>))
//                   .toList();
//             }
            if (snapshot.hasData) {
              Map<String, dynamic>? data =
                  snapshot.data!.data() as Map<String, dynamic>?;

              if (data != null) {
                myRoutes = [HistoryItem.fromMap(data)];
              }
            }
            // List<HistoryItem> myRoutes = snapshot.data!.docs
            //     .map((doc) =>
            //         HistoryItem.fromMap(doc.data() as Map<String, dynamic>))
            //     .toList();

            return ListView.builder(
              itemCount: myRoutes.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, myRoutes[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, HistoryItem order) {
    return Card(
      margin: EdgeInsets.all(10.0),
      child: ListTile(
        title: Text('price : ${order.price}'),
        subtitle: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('From: ${order.source}'),
              Text('To: ${order.destination}'),
              Text('Time: ${order.time}'),
              // Add your RatingBar widget here
            ],
          ),
        ),
        onTap: () {},
      ),
    );
  }
}
