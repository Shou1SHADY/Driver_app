import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/modules/connection.dart';
import 'package:flutter_application_1/modules/myHomePage.dart';
import 'package:flutter_application_1/modules/register.dart';
import 'package:flutter_application_1/modules/start_trip.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import '../modules/user_page.dart';

const ColorScheme myColorScheme = ColorScheme(
  primary: Color.fromARGB(255, 167, 130, 231),
  secondary: Color.fromARGB(255, 253, 244, 244),
  surface: Colors.white,
  background: Colors.white,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onSurface: Colors.black,
  onBackground: Colors.black,
  onError: Colors.white,
  brightness: Brightness.light,
);

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool flagConnect = true;
  var email = "";
  var uid = "";
  User? user;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Connectivity _connectivity;
  @override
  void initState() {
    super.initState();
    getUserEmail();
    getUserDetails();
    _connectivity = Connectivity();
    _checkInternetConnection();
    // checkLoggedInUser();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      flagConnect = false;
    } else {
      // Internet connection is present
      flagConnect = true;
    }
  }

  Future<String?> getUserEmail() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('user_email')!;
    print(email);
    return prefs.getString('user_email');
  }

  Future<void> getUserDetails() async {
    // Obtain shared preferences.
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString('user_email')!;
    String pass = prefs.getString('user_password')!;
    print(pass);
    UserCredential userCredential;
    userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: pass,
    );

    user = userCredential.user;
  }

  @override
  Widget build(BuildContext context) {
    MaterialColor myPrimarySwatch = MaterialColor(
      const Color.fromARGB(255, 185, 152, 241).value,
      <int, Color>{
        50: myColorScheme.primary.withOpacity(0.1),
        100: myColorScheme.primary.withOpacity(0.2),
        200: myColorScheme.primary.withOpacity(0.3),
        300: myColorScheme.primary.withOpacity(0.4),
        400: myColorScheme.primary.withOpacity(0.5),
        500: myColorScheme.primary.withOpacity(0.6),
        600: myColorScheme.primary.withOpacity(0.7),
        700: myColorScheme.primary.withOpacity(0.8),
        800: myColorScheme.primary.withOpacity(0.9),
        900: myColorScheme.primary,
      },
    );

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData(
            colorScheme: myColorScheme,
            useMaterial3: true,
            primarySwatch: myPrimarySwatch,
            fontFamily: 'Roboto',
            textTheme: const TextTheme(
              headline1: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              bodyText1: TextStyle(
                fontSize: 16.0,
              ),
              button: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
          ),
          home: child,
        );
      },

      //child: RegisterPage(),

      child: (email.isNotEmpty && flagConnect == true)
          ? UserDetailsPage(user: user)
          : ConnectionCheckPage(),
    );
  }
}
