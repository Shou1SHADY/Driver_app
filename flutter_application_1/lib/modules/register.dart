import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/driver.user.dart';
import 'package:flutter_application_1/modules/user_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;
  final _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _usernamerealController = TextEditingController();
  bool _isLoading = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  Future<void> _registerUser() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    _showMessage('');

    if (username.isNotEmpty && password.isNotEmpty) {
      try {
        setState(() {
          _isLoading = true;
        });

        // Registration successful, create a new user with a default image URL
        User? user = await DriverUser.registerWithFirebase(
          username: username.toLowerCase(),
          password: password,
          image:
              "https://images.unsplash.com/photo-1575936123452-b67c3203c357?q=80&w=1000&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aW1hZ2V8ZW58MHx8MHx8fDA%3D",
        );

        if (user != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailsPage(user: user),
            ),
          );
        } else {
          _showMessage('User registration failed.');
        }
      } catch (e) {
        _showMessage('Error: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showMessage('Please fill in all fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(70.0),
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
              bottomLeft: Radius.circular(20.r),
              bottomRight: Radius.circular(20.r),
            ),
          ),
          title: Center(
            child: Text(
              'Register',
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
          padding: EdgeInsets.all(40.0.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Create an Account',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              SizedBox(height: 40.h),
              TextFormField(
                controller: _usernamerealController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_3_rounded),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!value.contains('@') ||
                      !value.endsWith('.eng.asu.edu.eg')) {
                    return 'Please enter a valid email address ending with .eng.asu.edu.eg';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock), // Use lock icon
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      // Toggle the visibility of the password
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                obscureText: _obscureText, // Set the obscureText property
                validator: (value) {
                  // Password validation
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  // Password must include alphabets and numbers and be at least 8 characters long
                  RegExp regex = RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$');
                  if (!regex.hasMatch(value)) {
                    return 'Password must include alphabets and numbers, and be at least 8 characters long';
                  }
                  return null; // Return null if validation succeeds
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Confirm Password',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 32),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 50.0.w, vertical: 30.h),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _registerUser,
                  child: _isLoading
                      ? CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : Text(
                          'Register',
                          style: TextStyle(color: Colors.teal),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
