import 'package:emosense/design_widgets/app_color.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/font_style.dart';

class TermsNConditionsPage extends StatelessWidget {
  static const routeName = '/terms-n-conditions';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text("Terms and Conditions", style: ProfileTitleText),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: AppColors.darkLogoColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 30, bottom: 20, left: 16.0, right: 16.0),
        children: [
          Text("Effective Date: 11/09/2024", style: ProfileContentText),
          SizedBox(height: 20),
          Text("1. Acceptance of Terms", style: ProfileContentBold),
          SizedBox(height: 10),
          Text(
            "By accessing and using the EmoSense app, you agree to be bound by these terms and conditions. If you do not agree to these terms, you may not use the app.",
            style: ProfileContentText,
          ),
          SizedBox(height: 20),
          Text("2. Use of the App", style: ProfileContentBold),
          SizedBox(height: 10),
          Text(
            "• \t\t EmoSense is designed to help users track their emotional well-being and receive personalized music recommendations."
                "\n• \t\t You are responsible for maintaining the confidentiality of your account information and for any activities that occur under your account."
                "\n• \t\t You agree not to use the app for any unlawful or unauthorized purpose.",
            style: ProfileContentText,
          ),
          SizedBox(height: 20),
          Text("3. Contact Us", style: ProfileContentBold),
          SizedBox(height: 10),
          Text(
            "For any questions regarding these terms and conditions, please contact us at yijia@emosense.com.",
            style: ProfileContentText,
          ),
        ],
      ),
    );
  }
}