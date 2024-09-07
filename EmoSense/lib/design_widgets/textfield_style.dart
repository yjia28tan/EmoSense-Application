import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';

TextField forTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
  return TextField(
    controller: controller,
    obscureText: isPasswordType,
    cursorColor: Colors.black12,
    style: TextStyle(
      fontSize: 14.0,
        color: AppColors.textColorBlack
    ),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        size: 17.0,
        color: AppColors.textColorGrey,
      ),
      hintText: text,
      labelStyle: TextStyle(color: AppColors.textColorGrey),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: AppColors.textFieldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 13.0, horizontal: 15.0),
    ),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}


TextField forReadTextField(String text, IconData icon, bool isPasswordType,
    bool isWriteType, String detail) {
  return TextField(
    readOnly: isWriteType,
    obscureText: isPasswordType,
    cursorColor: Colors.black12,
    style: TextStyle(color: Color(0xFFA6A6A6)),
    decoration: InputDecoration(
      prefixIcon: Icon(
        icon,
        color: Colors.black26,
      ),
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
      filled: true,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      fillColor: Color(0xFFF2F2F2).withOpacity(0.7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.0),
        borderSide: const BorderSide(width: 0, style: BorderStyle.none),
      ),
    ),
    controller: TextEditingController(text: detail),
    keyboardType: isPasswordType
        ? TextInputType.visiblePassword
        : TextInputType.emailAddress,
  );
}