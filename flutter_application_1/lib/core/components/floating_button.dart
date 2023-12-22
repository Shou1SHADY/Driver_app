import 'package:flutter/material.dart';

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;

  CustomFloatingActionButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(40.0), // Adjust the border radius as needed
        onTap: onPressed,
        child: Container(
          width: 80.0, // Adjust the width as needed
          height: 80.0, // Adjust the height as needed
          decoration: BoxDecoration(
            color: Colors.blue, // Change the color as needed
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car, color: Colors.white),
                SizedBox(height: 5.0),
                Text(
                  'Start Trip',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
