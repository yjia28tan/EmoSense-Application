import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/font_style.dart';

class PrivacyPolicyPage extends StatelessWidget {
  static const routeName = '/privacy_policy';

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF2F2F2),
        appBar: AppBar(
          title: Text("Privacy Policy", style: ProfileTitleText),
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
            // Text("Privacy Policy for EmoSense", style: ProfileTitleText),
            // SizedBox(height: 10),
            Text("Effective Date: 11/09/2014", style: ProfileContentText),
            SizedBox(height: 20),
            Text("1. Information We Collect", style: ProfileContentBold),
            SizedBox(height: 10),
            Text("• \t\tFacial Emotion Data: ", style: ProfileContentBold),
            Text(
              "EmoSense analyzes your facial expressions in real-time using an emotion detection model. However, we do not store or save any facial image data in our database. All analysis is performed locally on your device.",
              style: ProfileContentText),
            Text("\n• \t\tMusic Preferences: ", style: ProfileContentBold,),
            Text("We collect your music preferences (e.g., favorite genres, artists) to provide personalized music recommendations based on your detected emotional state.",
              style: ProfileContentText),
            Text("\n• \t\tEmotion Tracking Data: ", style: ProfileContentBold),
            Text(
                  "We store data about your detected emotional states to help you track your mood over time. This data is stored securely in our cloud database.",
              style: ProfileContentText),
            Text("\n• \t\tUser Account Information:", style: ProfileContentBold),
            Text(
                  "When you create an account, we collect information such as your email address, username, and password to facilitate login and account management.",
              style: ProfileContentText),
            SizedBox(height: 20),
            Text("2. How We Use Your Information", style: ProfileContentBold),
            SizedBox(height: 10),
            Text(
              "We use the data collected to analyze your emotional state in real-time, offer personalized music recommendations, and track your emotional well-being over time. Your data is also used to improve the accuracy of our emotion detection model.",
              style: ProfileContentText,
            ),
            // Add more sections here
            SizedBox(height: 20),
            Text("3. Contact Us", style: ProfileContentBold),
            SizedBox(height: 10),
            Text(
              "If you have any questions or concerns about our privacy practices, please contact us at yijia@emosense.com.",
              style: ProfileContentText,
            ),
          ],
        ),
      ),
    );
  }
}