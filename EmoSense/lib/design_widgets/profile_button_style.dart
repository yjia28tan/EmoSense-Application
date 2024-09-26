import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:flutter/material.dart';

ElevatedButton profile_Button(String text, String data, IconData icon, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFFF2F2F2).withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    onPressed: onPressed,
    child: Row(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            style: textBlackNormal.copyWith(fontSize: 15, fontWeight: FontWeight.normal),
          ),
        ),
        Spacer(),
        // Email Text that might be too long
        Expanded(
          flex: 3, // Adjust the flex value for the email part
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              data,
              style: greySmallText.copyWith(fontSize: 13, fontWeight: FontWeight.normal),
              maxLines: 1, // Limit to 1 line
              overflow: TextOverflow.ellipsis, // Add ellipsis (...) for overflow
              softWrap: false, // Disable wrapping
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Icon(
            icon,
            color: AppColors.darkPurpleColor,
          ),
        ),
      ],
    ),
  );
}

ElevatedButton signout_Button(String text, VoidCallback onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      // foregroundColor: Color(0xFF366021),
      backgroundColor: AppColors.darkPurpleColor,
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
        Text(
          text,
          style: whiteText,
        ),
      ],
    ),
  );
}

