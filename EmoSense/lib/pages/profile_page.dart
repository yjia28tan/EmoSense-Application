import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/profile_button_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/edit_genres_preferences.dart';
import 'package:emosense/pages/get_starter_page.dart';
import 'package:emosense/pages/privacy_policy.dart';
import 'package:emosense/pages/signin_page.dart';
import 'package:emosense/pages/terms_conditions.dart';
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
  String? gender;
  String? birthday;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Sign out function
  Future<bool> signOut(BuildContext context) async {
    // Show a dialog asking if the user is sure they want to log out
    final bool? shouldSignout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to prevent back action
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Sign out the user from Firebase Authentication
                await FirebaseAuth.instance.signOut();

                // Clear the user's FCM token in Firestore
                if (globalUID != null) {
                  final userRef = FirebaseFirestore.instance.collection('users').doc(globalUID);
                  await userRef.update({'fcmToken': ""});
                }

                // Navigate to SigninPage and clear the navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => GetStartedPage()),
                      (route) => false,
                ); // Return true to allow back action
              },
              child: Text('Sign Out'),
            ),
          ],
        );
      },
    );

    return shouldSignout ?? false; // Default to false if null
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
          gender = userData['gender'];
          birthday = userData['birthdate'];
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
    // Retrieve screen height and width using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.075),
        child: Center(
          child: Column(
            children: [
              // Profile Picture
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 100,  // Set the width for the square shape
                    height: 100, // Set the height for the square shape
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.textColorBlack, width: 2),
                      image: DecorationImage(
                        image: AssetImage('assets/logo 3d profile photo.png'),
                        fit: BoxFit.cover, // Ensures the image fits the container
                      ),
                    ),
                  ),
                ),
              ),

              // Username
              Text(
                '$username!',
                style: inkwellText.copyWith(fontWeight: FontWeight.bold, fontSize: 25),
              ),

              // Profile Text
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                      'Profile',
                      style: greySmallText.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              // Elevated Buttons
              // edit profile
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: profile_Button(
                  'Username',
                  '$username',
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: profile_Button(
                  'Email',
                  '$email',
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: profile_Button(
                  'Gender',
                  '$gender',
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
              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                child: profile_Button(
                  'Birthdate',
                  '$birthday',
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
              ),
              // set reminder button
              // SetReminder(),

              // Security Text
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                      'Security',
                      style: greySmallText.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: profile_Button(
                  'Change Password',
                  '',
                  Icons.arrow_forward_ios,
                      () async {
                    // final result = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => EditPreferencesPage()),
                    // );
                  },
                ),
              ),

              // Prefrences Text
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                      'Preferences',
                      style: greySmallText.copyWith(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      )
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: profile_Button(
                  'Edit Preferences',
                  '',
                  Icons.arrow_forward_ios,
                      () async {
                    // final result = await Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => EditPreferencesPage()),
                    // );
                  },
                ),
              ),

              // 'More' text
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 18.0),
                  child: Text(
                    'More',
                    style: greySmallText.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                ),
              ),
              // privacy policy
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: profile_Button(
                  'Privacy Policy',
                  '',
                  Icons.arrow_forward_ios,
                      () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
              ),
              // t&c
              Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: profile_Button(
                  'Terms and Conditions',
                  '',
                  Icons.arrow_forward_ios,
                      () async {
                        await Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => TermsNConditionsPage()
                            )
                        );
                      },
                ),
              ),
              SizedBox(height: 20),
              // sign out button
              Container(
                width: double.infinity,  // Takes the full width of the screen
                height: screenHeight * 0.07,
                child: signout_Button(
                  'Sign Out',
                      () async {
                    // Call the signOut function
                    await signOut(context);
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
