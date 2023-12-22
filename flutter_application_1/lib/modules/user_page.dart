import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/components/floating_button.dart';
import 'package:flutter_application_1/core/local/db.dart';
import 'package:flutter_application_1/models/driver.user.dart';
import 'package:flutter_application_1/modules/history.dart';
import 'package:flutter_application_1/modules/myHomePage.dart';
import 'package:flutter_application_1/modules/start_trip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDetailsPage extends StatefulWidget {
  final User? user;

  const UserDetailsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  bool _isLoading = false;
  String paths = "";
  String userProfilePicture = ''; // Store the user's profile picture
  late DbHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DbHelper();
    _dbHelper.initDatabase();
    // Load the user's profile picture from Firestore when the widget initializes
    loadUserProfilePicture();
  }

  // Function to pick an image
  Future<void> _pickImage() async {
    XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        paths = pickedImage.path;
      });
    }
  }

  // Function to update user profile picture and upload to Firebase
  Future<void> _updateUserProfile() async {
    if (paths.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Upload the image to Firebase Storage
        String? imageUrl = await DriverUser.uploadImageToFirebase(paths);

        if (imageUrl != null) {
          // Update the user's profile picture in Firestore
          await DriverUser.updateUserProfile(widget.user!.uid, imageUrl);

          await _dbHelper.insertOrUpdateDriverUser(
            DriverUser(
              id: widget.user!.uid,
              username: widget.user!.email!, // Use email as username for now
              password: '', // You may leave this empty or set a default value
              image: imageUrl,
            ),
          );
          // Refresh the UI with the new image
          setState(() {
            userProfilePicture = imageUrl;
          });
        } else {
          // Handle error uploading image
          // You may show a snackbar or print an error message
        }
      } catch (e) {
        // Handle other errors
        // You may show a snackbar or print an error message
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Show a message or handle validation error
      // You may show a snackbar or print an error message
    }
  }

  // Function to load the user's profile picture from Firestore
  Future<void> loadUserProfilePicture() async {
    try {
      // Retrieve the user's profile picture URL from Firestore
      String? imageUrl = await DriverUser.getProfilePicture(widget.user!.uid);

      if (imageUrl != null) {
        // Update the state with the retrieved profile picture URL
        setState(() {
          userProfilePicture = imageUrl;
        });
      }
    } catch (e) {
      // Handle errors loading the profile picture
      // You may show a snackbar or print an error message
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
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => StartTripPage()));
        },
      ),
      drawer: Drawer(
          width: 200.w,
          child: ListView(
            children: [
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 110.w,
                  height: 110.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: userProfilePicture.isNotEmpty
                          ? NetworkImage(userProfilePicture)
                              as ImageProvider<Object>
                          : AssetImage('assets/images/4660770.png')
                              as ImageProvider<
                                  Object>, // Cast to ImageProvider<Object>
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50.h),
              Text(
                '${widget.user!.email}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: TextStyle(color: Colors.white),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Pick Image',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUserProfile,
                style: ElevatedButton.styleFrom(
                  primary: Colors.teal,
                  textStyle: TextStyle(color: Colors.white),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        'Update Profile',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
              SizedBox(
                height: 65.h,
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 72.w),
                child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => OrderHistoryPage()));
                    },
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Text(
                              "History",
                              style: TextStyle(fontSize: 22.sp),
                            ),
                          ),
                          SizedBox(width: 7.w),
                          Icon(Icons.history_edu_rounded)
                        ],
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
