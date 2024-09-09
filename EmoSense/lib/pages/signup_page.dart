import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/textfield_style.dart';
import 'package:emosense/pages/signin_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _usernameTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmTextController = TextEditingController();

  bool passwordConfirmed() {
    return _passwordTextController.text.trim() == _confirmTextController.text.trim();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve screen height and width using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background color and emoji/logo
          Container(
            color: AppColors.upBackgroundColor, // Background color matching the design
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.08), // Spacing from the top
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.08),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.darkLogoColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Form container with rounded top corners
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Container(
                height: screenHeight * 0.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Let’s sign you up', style: titleBlack),
                    SizedBox(height: screenHeight * 0.02),
                    forTextField("Username", Icons.person, false, _usernameTextController),
                    SizedBox(height: screenHeight * 0.02),
                    forTextField("Email", Icons.email, false, _emailTextController),
                    SizedBox(height: screenHeight * 0.02),
                    forTextField("Password", Icons.lock, true, _passwordTextController),
                    SizedBox(height: screenHeight * 0.02),
                    forTextField("Confirm Password", Icons.lock, true, _confirmTextController),
                    SizedBox(height: screenHeight * 0.04),
                    Container(
                      width: double.infinity,  // Takes the full width of the screen
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPurpleColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),  // Add rounded corners if needed
                          ),
                        ),
                        onPressed: () async {
                          String username = _usernameTextController.text.trim();
                          String email = _emailTextController.text.trim();
                          String password = _passwordTextController.text.trim();

                          if (username.isEmpty || email.isEmpty || password.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Registration Failed'),
                                content: const Text('Please fill in all details.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return; // Stop further execution
                          } else if (!passwordConfirmed()) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Ensure your password'),
                                content: const Text(
                                    'Please make sure the password and confirm password are the same.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                          );

                          try {
                            // Register new user with email and password
                            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                            );

                            // Save user data in Firestore
                            await FirebaseFirestore.instance.collection('users').doc(userCredential.user?.uid).set({
                              'username': username,
                              'email': email,
                              'firstLogin': true,
                              'gender': null,
                              'birthdate': null,
                              'dailyReminder': false,
                              'reminderTime': null,
                            });

                            // Send email verification
                            await userCredential.user!.sendEmailVerification();

                            // Notify the user that the account has been created
                            final snackbar = SnackBar(
                              content: Text(
                                  "Account Created!\n Check your email to verify your account before signing in."),
                              action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {}
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);

                            // Navigate to the sign-in page
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const SigninPage()));
                          } catch (error) {
                            String errorMessage = '';

                            if (error is FirebaseAuthException) {
                              if (error.code == 'email-already-in-use') {
                                errorMessage = 'Email is already registered. Please use a different email.';
                              } else if (error.code == 'weak-password') {
                                errorMessage = 'Password is too weak. Please use a different password.';
                              } else if (error.code == 'invalid-email') {
                                errorMessage = 'Please use a valid email.';
                              } else {
                                errorMessage = 'An error occurred\nError: ${error.message}';
                              }
                            } else {
                              errorMessage = 'An unknown error occurred.';
                            }

                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Registration Failed"),
                                  content: Text(errorMessage),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                ));
                          } finally {
                            Navigator.of(context).pop(); // Hide progress indicator
                          }
                        },
                        child: Text('Sign Up', style: whiteText),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.011),
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SigninPage())
                        );
                      },
                      child: Text(
                        "Already have an account? Sign in here",
                        style: inkwellText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
