import 'package:flutter/material.dart';

ElevatedButton profile_Button(String text, IconData icon, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFFA6A6A6),
      backgroundColor: Color(0xFFF2F2F2).withOpacity(0.7),
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
          style: TextStyle(color: Color(0xFF453276)),
        ),
        Icon(
          icon,
          color: Color(0xFF453276),
        ),
      ],
    ),
  );
}

ElevatedButton signout_Button(String text, IconData icon, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      // foregroundColor: Color(0xFF366021),
      backgroundColor: Color(0xFF453176).withOpacity(1.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      minimumSize: Size(double.infinity, 50), // set the minimum size to match the text field
    ),
    onPressed: onPressed,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: Color(0xFFF2F2F2),
        ),
        Text(
          text,
          style: TextStyle(color: Color(0xFFF2F2F2)),
        ),
      ],
    ),
  );
}

