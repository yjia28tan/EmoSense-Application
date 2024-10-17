import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/profile_button_style.dart';
import 'package:emosense/main.dart';
import 'package:emosense/pages/edit_genres_preferences.dart';
import 'package:emosense/pages/get_starter_page.dart';
import 'package:emosense/pages/privacy_policy.dart';
import 'package:emosense/pages/terms_conditions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    setState(() {
      fetchUserData();
    });
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
          // Check the type of the birthdate field
          var birthdateData = userData['birthdate'];
          if (birthdateData is Timestamp) {
            DateTime birthDate = birthdateData.toDate();
            birthday = DateFormat('yyyy-MM-dd').format(birthDate);
          } else if (birthdateData is String) {
            // If it's a string, parse it directly
            birthday = birthdateData; // Assuming it's already in 'yyyy-MM-dd' format
          } else {
            birthday = null; // Handle cases where it's null or an unexpected type
          }


          dailyReminder = userData['dailyReminder'];
        });
      }).catchError((error) {
        print("Error: $error");
        showAlert(context, 'Error', 'Error fetching user data: $error');
      });
    } else {
      showAlert(context, 'Error', 'globalUID is null');
    }
  }

  void _showEditDialog(String title, String currentValue, Function(String?)? onSave, {bool readOnly = false}) {
    TextEditingController _editController = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        // For gender selection
        if (title == 'Gender') {
          String? selectedGender = currentValue.isEmpty ? null : currentValue; // Allow null selection

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  "Select Gender",
                  style: titleBlack,
                ),
                content: DropdownButton<String?>(
                  value: selectedGender,
                  items: [
                    DropdownMenuItem(
                      child: Text('None', style: greySmallText),
                      value: null,
                    ),
                    DropdownMenuItem(
                      child: Text('Male', style: greySmallText),
                      value: 'Male',
                    ),
                    DropdownMenuItem(
                      child: Text('Female', style: greySmallText),
                      value: 'Female',
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedGender = value;
                    });
                  },
                  hint: Text('Select gender'),
                  isExpanded: true,
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close without saving
                    },
                    child: Text("Close"),
                  ),
                  TextButton(
                    onPressed: () {
                      onSave!(selectedGender); // Save the selected gender
                      Navigator.pop(context);
                    },
                    child: Text("Save"),
                  ),
                ],
              );
            },
          );
        }

        if (title == 'Birthdate') {
          DateTime? selectedDate = currentValue.isNotEmpty ? DateTime.parse(currentValue) : null;

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(
                  "Select Birthdate",
                  style: titleBlack,
                ),
                content: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            : 'No date selected',
                        style: greySmallText.copyWith(fontWeight: FontWeight.normal),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate; // Store the picked date directly
                          });
                        }
                      },
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close without saving
                    },
                    child: Text("Close"),
                  ),
                  TextButton(
                    onPressed: () {
                      String? dateString = selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : null;
                      onSave!(dateString);
                      Navigator.pop(context);
                    },
                    child: Text("Save"),
                  ),
                  TextButton(
                    onPressed: () {
                      onSave!(null); // Clear the date (set to null)
                      Navigator.pop(context);
                    },
                    child: Text("Clear"),
                  ),
                ],
              );
            },
          );
        }

        return AlertDialog(
          title: Text(
            readOnly ? "$title" : "Edit $title",
            style: titleBlack,
          ),
          content: TextField(
            controller: _editController,
            readOnly: readOnly, // Disable editing if it's a view-only field
            style: greySmallText.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold
            ), // Text style
            decoration: InputDecoration(
              labelText: readOnly ? '' : 'Enter new $title',
              labelStyle: titleBlack.copyWith(fontWeight: FontWeight.normal), // Label style
              border: OutlineInputBorder(),
              hintStyle: greySmallText, // Hint style
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: Text("Close"),
            ),
            if (!readOnly) // Only show Save button if field is editable
              TextButton(
                onPressed: () {
                  if (_editController.text.isNotEmpty) {
                    onSave!(_editController.text); // Save the new value
                    Navigator.pop(context); // Close the dialog
                  }
                },
                child: Text("Save"),
              ),
          ],
        );
      },
    );
  }

  // Function to show the change password dialog
  Future<void> showChangePasswordDialog(BuildContext context) async {
    String currentPassword = '';
    String newPassword = '';
    String confirmPassword = '';

    User? user = FirebaseAuth.instance.currentUser;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Change Password",
            style: titleBlack,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      currentPassword = value;
                    },
                    decoration: InputDecoration(
                      labelText: "Current Password",
                      labelStyle: titleBlack.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    style: greySmallText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      newPassword = value;
                    },
                    decoration: InputDecoration(
                      labelText: "New Password",
                      labelStyle: titleBlack.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                    style: greySmallText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextField(
                    obscureText: true,
                    onChanged: (value) {
                      confirmPassword = value;
                    },
                    decoration: InputDecoration(
                      labelText: "Confirm New Password",
                      labelStyle: titleBlack.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                    style: greySmallText.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                if (newPassword != confirmPassword) {
                  // Show an error message if passwords do not match
                  showAlert(context, 'Error', 'New passwords do not match.');
                  return;
                }

                // Enforce password validation: At least 6 characters, a number, an uppercase letter, and a special character
                RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[0-9])(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$');

                if (!passwordRegex.hasMatch(newPassword)) {
                  // Show an error message if the password doesn't meet the requirements
                  showAlert(context, 'Error', 'Password must be at least 6 characters long, contain at least one number, one uppercase letter, and one special character.');
                  return;
                }

                try {
                  // Re-authenticate the user before changing the password
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: currentPassword,
                  );

                  // Re-authenticate the user
                  await user.reauthenticateWithCredential(credential);

                  // If re-authentication is successful, update the password
                  await user.updatePassword(newPassword);

                  Navigator.pop(context); // Close the dialog
                  showAlert(context, 'Success', 'Password changed successfully.');
                } catch (e) {
                  // Check for specific error messages
                  if (e is FirebaseAuthException) {
                    if (e.code == 'wrong-password') {
                      showAlert(context, 'Error', 'Current password is incorrect.');
                    } else if (e.code == 'weak-password') {
                      showAlert(context, 'Error', 'The new password is too weak.');
                    } else {
                      showAlert(context, 'Error', 'Failed to change password: ${e.message}');
                    }
                  } else {
                    // General error handling
                    showAlert(context, 'Error', 'Failed to change password: $e');
                  }
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
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
                '$username',
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
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: profile_Button(
                        'Username',
                        '$username',
                        Icons.arrow_forward_ios,
                            () {
                          _showEditDialog('Username', username!, (newValue) async {
                            // Update in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(globalUID)
                                .update({'username': newValue});

                            // Fetch updated data
                            fetchUserData();
                          });
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
                              _showEditDialog('Email', email!, null, readOnly: true); // View-only, no save action
                            },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: profile_Button(
                        'Gender',
                        gender ?? 'Not set', // Use 'Not set' if gender is null
                        Icons.arrow_forward_ios,
                            () {
                          _showEditDialog('Gender', gender ?? '', (newValue) async {
                            // Update in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(globalUID)
                                .update({'gender': newValue});

                            // Fetch updated data
                            fetchUserData();
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                      child: profile_Button(
                        'Birthdate',
                        birthday ?? 'Not set', // Use 'Not set' if birthdate is null
                        Icons.arrow_forward_ios,
                            () {
                          _showEditDialog('Birthdate', birthday ?? '', (newValue) async {
                            // Update in Firestore
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(globalUID)
                                .update({'birthdate': newValue});

                            // Fetch updated data
                            fetchUserData();
                          });
                        },
                      ),
                    ),

                    // set reminder button
                    // SetReminder(),

                  ],
                ),
              ),

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
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                  child: profile_Button(
                    'Change Password',
                    '',
                    Icons.arrow_forward_ios,
                        () async {
                      await showChangePasswordDialog(context);
                    },
                  ),
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
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
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
              Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
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
                  ],
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
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
