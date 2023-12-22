import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/local/db.dart';
import 'package:flutter_application_1/models/driver.user.dart';
import 'package:flutter_application_1/modules/myHomePage.dart';

class ConnectionCheckPage extends StatefulWidget {
  @override
  _ConnectionCheckPageState createState() => _ConnectionCheckPageState();
}

class _ConnectionCheckPageState extends State<ConnectionCheckPage> {
  late Connectivity _connectivity;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // No internet connection
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NoInternetPage()),
      );
    } else {
      // Internet connection is present
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class NoInternetPage extends StatefulWidget {
  const NoInternetPage({super.key});

  @override
  State<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  late DbHelper _dbHelper;
  late DriverUser userDriver;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _dbHelper = DbHelper();
    _dbHelper.initDatabase();
    getUserData();
  }

  getUserData() async {
    userDriver = (await _dbHelper.getAllDriverUsers()) as DriverUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundImage: userDriver.image.isNotEmpty
                  ? NetworkImage(userDriver.image)
                  : null,
            ),
            SizedBox(height: 16),
            Text(
              'User ID: ${userDriver.id}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
