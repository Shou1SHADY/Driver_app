import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/local/db.dart';
import 'package:flutter_application_1/modules/register.dart';
import 'package:flutter_application_1/modules/user_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<MyHomePage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    // checkLoggedInUser();
  }

// void checkLoggedInUser() async {

//     String? userEmail = await getUserEmail();
//     if (userEmail != null && userEmail.isNotEmpty) {
//       // User is already logged in, navigate to the UserDetailsPage or any other page.
//       // Example:
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//             builder: (_) => UserDetailsPage(user: null)),
//       );
//     }
//   }

  Future<void> _login() async {
    UserCredential userCredential;
    try {
      userCredential = await _auth.signInWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

      User? user = userCredential.user;

      saveUserEmail(user?.email);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("uuid", "${user!.uid}");
      prefs.setString("user_password", "${passwordController.text.toString()}");
      // Successful login
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Login Successful"),
            content: Text("Welcome, ${userCredential.user!.email}!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );

      // Navigator.push(
      //     context, MaterialPageRoute(builder: (_) => StartTripPage()));

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => UserDetailsPage(
                    user: user,
                  )));
    } on FirebaseAuthException catch (e) {
      print("FAAAAIIIILLLL");
      // Failed login
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Login Failed"),
            content: Text(e.message ?? "Invalid username or password"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  // Function to save the user's email in SharedPreferences
  Future<void> saveUserEmail(String? email) async {
    // final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_email', email ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          "Login Page",
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 20.h,
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Car',
                      style: TextStyle(
                        color: Colors.blue, // Change color for the letter 'C'
                        fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                    TextSpan(
                      text: 'Pooling',
                      style: TextStyle(
                        color: Colors
                            .green, // Change color for the rest of the text
                        fontWeight: FontWeight.bold,
                        fontSize: 50.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 15.h,
              ),
              Image.asset(
                "assets/images/4660770.png",
                width: 160.w,
                height: 140.h,
              ),
              SizedBox(
                height: 30.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0.r),
                      borderSide: BorderSide(),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(),
                    ),
                  ),
                  controller: passwordController,
                  obscureText: true,
                ),
              ),
              SizedBox(height: 27.h),
              Row(
                children: [
                  // Styled Register Button
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          "Not Registered Yet ?",
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 68, 124),
                              fontSize: 12.sp),
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => RegisterPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 50.w),
                          ),
                          child: Text(
                            "Register",
                            style: TextStyle(
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),

                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 28.h,
                        ),
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            primary: Theme.of(context).colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0.r),
                            ),
                            padding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 60.w),
                          ),
                          child: Text(
                            "Login",
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15.h),
            ],
          ),
        ),
      ),
    );
  }
}
