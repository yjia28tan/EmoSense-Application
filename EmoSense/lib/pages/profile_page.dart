import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/profile_button_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/signin_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? email;
  bool? dailyReminder;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Sign out function
  Future<void> signOut(BuildContext context) async {
    // Sign out the user from Firebase Authentication
    await _auth.signOut();

    // Clear the user's FCM token in Firestore
    if (globalUID != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(globalUID);
      await userRef.update({'fcmToken': ""});
    }

    // Navigate to SigninPage and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => SigninPage()),
          (route) => false,
    );
  }

  // Fetch user data from Firestore
  void fetchUserData() {
    final uid = globalUID;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((userData) {
        setState(() {
          username = userData['username'];
          email = userData['email'];
          dailyReminder = userData['dailyReminder'];
        });
      }).catchError((error) {
        showAlert(context, 'Error', 'Error fetching user data: $error');
      });
    } else {
      showAlert(context, 'Error', 'globalUID is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            children: [
              // Profile Picture
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Welcome,',
                    style: signinTitle,
                  ),
                ),
              ),
              // Username
              Text(
                '$username!',
                style: userName_display,
              ),
              SizedBox(height: 20),
              // set reminder button
              // SetReminder(),
              SizedBox(height: 15),
              // Elevated Buttons
              // edit profile
              profile_Button(
                'Edit Profile',
                Icons.arrow_forward_ios,
                    () async {
                  // final result = await Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => EditProfilePage()),
                  // );
                  // if (result == true) {
                  //   // Refresh the user data
                  //   fetchUserData();
                  // }
                },
              ),
              SizedBox(height: 20),
              // 'More' text
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'More',
                    style: homepageText,
                  ),
                ),
              ),
              SizedBox(height: 15),
              // privacy policy
              profile_Button(
                'Privacy Policy',
                Icons.arrow_forward_ios,
                    () {},
              ),
              SizedBox(height: 15),
              // t&c
              profile_Button(
                'Terms and Conditions',
                Icons.arrow_forward_ios,
                    () {},
              ),
              SizedBox(height: 20),
              // sign out button
              Container(
                height: 45,
                width: 250,
                child: signout_Button(
                  'Sign Out',
                  Icons.logout,
                      () {
                    signOut(context); // Pass the context here
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
