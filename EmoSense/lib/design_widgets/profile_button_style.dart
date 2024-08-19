import 'package:flutter/material.dart';

ElevatedButton profile_Button(String text, IconData icon, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFF366021),
      backgroundColor: Color(0xFFE5FFD0).withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      minimumSize: Size(double.infinity, 50), // set the minimum size to match the text field
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(color: Color(0xFF366021)),
        ),
        Icon(
          icon,
          color: Color(0xFF366021),
        ),
      ],
    ),
  );
}

ElevatedButton signout_Button(String text, IconData icon, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      // foregroundColor: Color(0xFF366021),
      backgroundColor: Color(0xFF366021).withOpacity(1.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      minimumSize: Size(double.infinity, 50), // set the minimum size to match the text field
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Color(0xFFE5FFD0),
        ),
        Text(
          text,
          style: TextStyle(color: Color(0xFFE5FFD0)),
        ),
      ],
    ),
  );
}

