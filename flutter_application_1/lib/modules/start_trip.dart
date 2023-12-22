import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/modules/history.dart';
import 'package:flutter_application_1/modules/myHomePage.dart';
import 'package:flutter_application_1/modules/rides_details.dart';
import 'package:flutter_application_1/modules/tripState.dart';
import 'package:flutter_application_1/modules/user_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_button_view/swipeable_button_view.dart';

class Trip {
  DateTime selectedTime = DateTime.now();
}

class StartTripPage extends StatefulWidget {
  @override
  _StartTripPageState createState() => _StartTripPageState();
}

class _StartTripPageState extends State<StartTripPage> {
  String tripAccepted = "f";
  TextEditingController _tripPriceController = TextEditingController();
  bool agreeUpdate = false;
  List adjustTime = [];
  late Trip _trip;
  bool _bypassTimeValidation = false;
  bool tripFire = false;
  String _selectedDestination = '';
  double _tripPrice = 10.0;
  bool isFinished = false;
  final List<String> destinationLocations = [
    "Mohandessin",
    "Masr-Gedida",
    "Nasr City",
    "Zamalek",
  ];
  bool approvedByDriveMoveToNext = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  getApproveShared() async {
    SharedPreferences prefState = await SharedPreferences.getInstance();
    tripAccepted = prefState.getString("approvedByDriveMoveToNext") ?? "false";
  }

  @override
  void initState() {
    super.initState();
    _trip = Trip();
    _selectedDestination = destinationLocations[0];
    _tripPriceController.text = _tripPrice.toString();
    approvedByDriveMoveToNext = false;
    getApproveShared();
  }

  Future<void> _selectDestination() async {
    // Use the selected destination in your logic
    // For now, just print it as an example
    print('Selected Destination: $_selectedDestination');

    // Implement your pricing logic based on the selected destination
    // For simplicity, let's assume a fixed price for now
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Specify Trip Price'),
          content: TextField(
            controller: _tripPriceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
            ],
            decoration: InputDecoration(labelText: 'Enter trip price'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                double userInputPrice =
                    double.tryParse(_tripPriceController.text) ?? 0.0;
                setState(() {
                  _tripPrice = userInputPrice;
                });
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
    setState(() {
      _tripPrice = calculateTripPrice(_selectedDestination);
    });
  }

  double calculateTripPrice(String destination) {
    // Implement your pricing logic based on the selected destination
    // For example, you can have a map of destinations with corresponding prices
    // For simplicity, let's assume a fixed price for each destination
    Map<String, double> destinationPrices = {
      "Mohandessin": 10.0,
      "Masr-Gedida": 15.0,
      "Nasr City": 12.0,
      "Zamalek": 20.0,
    };

    return destinationPrices[destination] ?? 0.0;
  }

  Future<void> _selectTime(BuildContext context) async {
    updatePermission();
    TimeOfDay initialTime = TimeOfDay.now();

    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: initialTime.hour, minute: initialTime.minute),
    );

//    Duration timeDifference = pickedTime?.difference(_trip.selectedTime);

    if (pickedTime != null) {
      // Check if the picked time is within the allowed range (7:30 am to 5:30 pm)
      if (pickedTime.hour < 7 ||
          (pickedTime.hour == 17 && pickedTime.minute > 30)) {
        // Show an error or inform the user that the selected time is not allowed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Selected time is too early. Please choose a time between 7:30 am and 5:30 pm.'),
          ),
        );

        // Adjust the time to the nearest allowed time (7:30 am)
        pickedTime = TimeOfDay(hour: 7, minute: 30);
      } else if (pickedTime.hour > 17 ||
          (pickedTime.hour == 17 && pickedTime.minute > 30)) {
        // Show an error or inform the user that the selected time is not allowed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Selected time is too late. Please choose a time between 7:30 am and 5:30 pm.'),
          ),
        );

        // Adjust the time to the nearest allowed time (5:30 pm)
        pickedTime = TimeOfDay(hour: 17, minute: 30);
      } else if ((pickedTime.hour != 17 && pickedTime.minute != 30) ||
          (pickedTime.hour != 7 && pickedTime.minute != 30)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please choose a time either 7:30 am or 5:30 pm.'),
          ),
        );
        pickedTime = TimeOfDay(hour: 17, minute: 30);
      }
      // Add 1 day to selected time if it's in AM and current time is in PM
      if (_trip.selectedTime.hour >= 12 && pickedTime.hour < 12) {
        print("AM");
        _trip.selectedTime = DateTime(
          _trip.selectedTime.year,
          _trip.selectedTime.month,
          _trip.selectedTime.day + 1,
          pickedTime.hour,
          pickedTime.minute,
        );
      } else {
        print("PM");
        _trip.selectedTime = DateTime(
          _trip.selectedTime.year,
          _trip.selectedTime.month,
          _trip.selectedTime.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      }
      // adjustTime.add(_trip.selectedTime.day);
      // Duration timeDifference =
      //     adjustTime[adjustTime.length - 1].difference(adjustTime[0]);
      // if (timeDifference.inDays > 1) {
      //   _trip.selectedTime.day - 1;
      // }
      setState(() {});
    }
  }

  void _handleTimeValidationSwitch(bool value) {
    setState(() {
      _bypassTimeValidation = value;
    });
  }

  bool _validateTimeDriver() {
    DateTime currentTime = DateTime.now();

    if (tripFire) {
      // Afternoon trip
      DateTime afternoonDeadline = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        16, // 4:30 pm
        30, // 30 minutes
      );

      // Check if the current time is before the afternoon deadline
      if (currentTime.isBefore(afternoonDeadline) || _bypassTimeValidation) {
        // Order must be confirmed before 4:30 pm for afternoon ride
        return true;
      }
    } else {
      // Morning trip
      DateTime morningDeadline = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        23, // 11:30 pm
        30, // 30 minutes
      );

      // Check if the current time is before the morning deadline
      if (currentTime.isBefore(morningDeadline) || _bypassTimeValidation) {
        // Order must be confirmed before 11:30 pm for morning ride
        return true;
      }
    }

    // Order cannot be confirmed after the specified time
    return false;
  }

  bool _validateTime() {
    // Implement time validation logic based on constraints
    DateTime now = DateTime.now();
    DateTime cutoffTime;
    DateTime currenTime = DateTime.now();
    if (_trip.selectedTime.hour >= 7 && _trip.selectedTime.hour < 17) {
      // For trips at 7:30 am
      cutoffTime = DateTime(now.year, now.month, now.day, 22, 0);

      // Calculate the difference between _trip.selectedTime and cutoffTime
      Duration timeDifference = _trip.selectedTime.difference(currenTime);

      // Check if the difference is equal to or more than 9 hours and 30 minutes
      return _bypassTimeValidation ||
          (timeDifference.inHours >= 9 &&
              timeDifference.inMinutes.remainder(60) >= 30);
    } else if (_trip.selectedTime.hour >= 17) {
      print("AM I HERE?");
      tripFire = true;
      // For trips at 5:30 pm
      cutoffTime = DateTime(now.year, now.month, now.day, 13, 0);

      // Calculate the difference between _trip.selectedTime and cutoffTime
      Duration timeDifference = _trip.selectedTime.difference(currenTime);
      print(_trip.selectedTime);
      print(cutoffTime);
      print(timeDifference);
      // Check if the difference is equal to or more than 4 hours and 30 minutes
      return _bypassTimeValidation ||
          (timeDifference.inHours >= 4 &&
              timeDifference.inMinutes.remainder(60) >= 30);
    } else {
      // For other cases
      return false;
    }
  }

  Future<void> approvedByDriver() async {
    try {
      String stateUpdate = "approved";
      //   if (_validateTime()) {
      User? user = _auth.currentUser;
      //  final SharedPreferences prefs = await SharedPreferences.getInstance();
      // String email = prefs.getString('user_email')!;
      CollectionReference users =
          FirebaseFirestore.instance.collection('trips');
      DocumentSnapshot userDoc = await users.doc(user?.uid).get();
      Map<String, dynamic> userData;

      // User document found, you can access its data
      userData = userDoc.data() as Map<String, dynamic>;

      // Access specific fields
      stateUpdate = userData['tripState'];
      String src = userData['source'];
      String dest = userData['destination'];
      stateUpdate = "approvedByDriver";
      String clientID = userData['userId'];
      String tripTime =
          DateFormat('EEEE, hh:mm a').format(_trip.selectedTime.toLocal());
      if (user != null) {
        if (userData['tripState'].toString().contains("approved") ||
            userData['tripState'].toString().contains("approvedByDriver")) {
          approvedByDriveMoveToNext = true;
          SharedPreferences prefState = await SharedPreferences.getInstance();
          prefState.setString("approvedByDriveMoveToNext", "true");
          if (tripFire) {
            await _firestore.collection('trips').doc(user.uid).set({
              'userId': clientID,
              'source': src, // Replace with your source logic
              'destination': dest,
              "tripState": stateUpdate,
              'time': tripTime,
              "price": _tripPrice
            });
          } else {
            await _firestore.collection('trips').doc(user.uid).set({
              'userId': clientID,
              'source': src, // Replace with your source logic
              'destination': dest,
              "tripState": stateUpdate,
              'time': tripTime,
              "price": _tripPrice
            });
          }
          // Create a trip document in Firestore
        }
        // Display success message or navigate to the next page
        print('Trip started successfully at ${_trip.selectedTime}');
      } else {
        print('User not signed in.');
      }
      // } else {
      //   // Display an error message or take appropriate action
      //   print('Invalid time to start the trip.');
      // }
    } catch (e) {
      // Handle errors
      print('Error starting trip: $e');
    }
  }

  updatePermission() async {
    User? user = _auth.currentUser;

    CollectionReference users = FirebaseFirestore.instance.collection('trips');
    DocumentSnapshot userDoc = await users.doc(user?.uid).get();
    if (userDoc.exists) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Trip Exists"),
            content: Text("you are updating an already existing trip."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  agreeUpdate = true;
                  // Perform any action you want when the user clicks "Ok"
                  // For example, navigate to another screen or perform some operation
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: Text("Ok"),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _startTrip() async {
    try {
      print("IAMSHOU");
      if (_validateTime()) {
        User? user = _auth.currentUser;

        CollectionReference users =
            FirebaseFirestore.instance.collection('trips');
        DocumentSnapshot userDoc = await users.doc(user?.uid).get();

// if (userDoc == null || !userDoc.exists) {
//           // The document does not exist or is null
//           print('Document does not exist or is null');
//         } else {
//           // The document exists and is not null
//           print('Document exists');
//         }

        String tripTime =
            DateFormat('EEEE, hh:mm a').format(_trip.selectedTime.toLocal());
        if (user != null) {
          print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB");
          ///////////////////////////////////////////////////////////////////////////////////////////

          ///////////////////////////////////////////////////////////////////////////////////////////
          if (!userDoc.exists || agreeUpdate) {
            if (tripFire) {
              print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
              await _firestore.collection('trips').doc(user.uid).set({
                'userId': user.uid,
                'source': 'Gate 3/4', // Replace with your source logic
                'destination': _selectedDestination,
                "tripState": "Pending",
                'time': tripTime,
                "price": _tripPrice
              });
            } else {
              print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAC");
              await _firestore.collection('trips').doc(user.uid).set({
                'userId': user.uid,
                'source':
                    _selectedDestination, // Replace with your source logic
                'destination': 'Gate 3/4',
                "tripState": "Pending",
                'time': tripTime,
                "price": _tripPrice
              });
            }
          }

          // Create a trip document in Firestore
          print('Trip started successfully at ${_trip.selectedTime}');
          //   }
          ///////////////////////////////////////////////////////////////////////////////////////////
          // Display success message or navigate to the next page
        } else {
          print('User not signed in.');
        }
      } else {
        // Display an error message or take appropriate action
        print('Invalid time to start the trip.');
      }
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: AppBar(
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
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          title: Center(
            child: Text(
              'Start Trip',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
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
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Destination:'),
                    DropdownButton<String>(
                      value: _selectedDestination,
                      items: destinationLocations
                          .map((location) => DropdownMenuItem<String>(
                                value: location,
                                child: Text(location),
                              ))
                          .toList(),
                      onChanged: (value) {
                        updatePermission();
                        setState(() {
                          _selectedDestination = value!;
                        });
                        _selectDestination();
                      },
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Trip Price: \$${_tripPrice}',
                      style: TextStyle(fontSize: 13.sp),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                Card(
                  //color: color,
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16.0.r),
                    child: Column(
                      children: [
                        Text(
                          'Select Trip Time',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        Row(
                          children: [
                            SizedBox(width: 20.w),
                            ElevatedButton(
                              onPressed: () => _selectTime(context),
                              style: ElevatedButton.styleFrom(
                                primary: Colors.teal, // Set button color
                                textStyle: TextStyle(
                                    color: Colors.white), // Set text color
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(9.0.r),
                                child: Text(
                                  'Pick Time',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.sp),
                                ),
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Text(
                              '${DateFormat('EEEE, hh:mm a').format(_trip.selectedTime.toLocal())}',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 46.h),
                Row(
                  children: [
                    Text(
                      'Bypass Time Validation:',
                      style: TextStyle(fontSize: 18),
                    ),
                    Switch(
                      value: _bypassTimeValidation,
                      onChanged: _handleTimeValidationSwitch,
                      activeColor: Colors.teal, // Set switch active color
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startTrip();
                    });
                    _startTrip;
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.teal, // Set button color
                    textStyle: TextStyle(color: Colors.white), // Set text color
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(9.r),
                    child: Text(
                      'Start Trip',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: 155.h,
                // ),
                SizedBox(
                  height: 30.h,
                ),
                YourWidget(user: _auth.currentUser),
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SwipeableButtonView(
                      buttonText: 'SLIDE TO TRIP',
                      buttonWidget: Container(
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Colors.grey,
                        ),
                      ),
                      activeColor: Color(0xFF009C41),
                      isFinished: isFinished,
                      onWaitingProcess: () {
                        Future.delayed(Duration(seconds: 2), () {
                          setState(() {
                            isFinished = true;
                          });
                        });
                      },
                      onFinish: () async {
                        //await approvedByDriver(); Last commit
                        String tripTime = DateFormat('EEEE, hh:mm a')
                            .format(_trip.selectedTime.toLocal());
                        //TODO: For reverse ripple effect animation
                        setState(() {
                          isFinished = false;
                        });

                        if (_validateTimeDriver() ||
                            approvedByDriveMoveToNext ||
                            tripAccepted == "true") {
                          await approvedByDriver();
                          if (approvedByDriveMoveToNext) {
                            print(approvedByDriveMoveToNext);
                            if (tripFire) {
                              //after 5:30 pm
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RideDetailsPage(
                                        fromRoute: "Gate3/4",
                                        toRoute: _selectedDestination,
                                        price: _tripPrice,
                                        departureDate: tripTime)),
                              );
                            } else {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => RideDetailsPage(
                                          fromRoute: _selectedDestination,
                                          toRoute: "Gate3/4",
                                          price: _tripPrice,
                                          departureDate: tripTime)));
                            }
                          }
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
