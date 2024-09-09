import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/textfield_style.dart';
import 'package:emosense/pages/signup_page.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:emosense/pages/genre_selection_page.dart';

class SigninPage extends StatefulWidget {
  static String routeName = '/SigninPage';

  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

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
                SizedBox(height: screenHeight * 0.08),// Spacing from the top
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
                    Text('Sign in', style: titleBlack),
                    SizedBox(height: screenHeight * 0.02),
                    forTextField("Email", Icons.email, false, _emailTextController),
                    SizedBox(height: screenHeight * 0.02),
                    forTextField("Password", Icons.lock, true, _passwordTextController),
                    SizedBox(height: screenHeight * 0.025),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () async {
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                          );
              
                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _emailTextController.text,
                            );
              
                            Navigator.pop(context);
              
                            final snackbar = SnackBar(
                              content: Text("Password reset email sent. Please check your email."),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          } catch (error) {
                            Navigator.pop(context);
              
                            final snackbar = SnackBar(
                              content: Text("Failed to send password reset email."),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          }
                        },
                        child: Text(
                          "Forgot password?",
                          style: inkwellText,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.16),
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
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CircularProgressIndicator()),
                          );
              
                          try {
                            // Sign in with email and password
                            final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text,
                            );
              
                            // Check if email is verified
                            if (userCredential.user!.emailVerified) {
                              globalUID = userCredential.user!.uid;
                              final docSnapshot = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(globalUID)
                                  .get();
              
                              final data = docSnapshot.data();
                              if (data != null) {
                                final firstLogin = data['firstLogin'] ?? true;
                                final hasCompletedSurvey = data['surveyCompleted'];
              
                                if (firstLogin) {
                                  // Update user document to mark first login as false
                                  await FirebaseFirestore.instance.collection(
                                      'users').doc(globalUID).update({'firstLogin': false});
              
                                  // Navigate to the preferences survey page
                                  Future.delayed(Duration(milliseconds: 300), () {
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) => GenreSelectionPage()
                                        )
                                    );
                                  });
                                } else {
                                  // Navigate to the home page
                                  Future.delayed(Duration(milliseconds: 300), () {
                                    Navigator.push(context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()
                                        )
                                    );
                                  });
                                }
                              } else {
                                final snackbar = SnackBar(
                                  content: Text("Failed to fetch user data."),
                                  action: SnackBarAction(
                                    label: 'OK',
                                    onPressed: () {},
                                  ),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(snackbar);
                              }
                            }  else {
                              // Email is not verified
                              final snackbar = SnackBar(
                                content: Text("Please verify your email before logging in."),
                                action: SnackBarAction(
                                  label: 'OK',
                                  onPressed: () {},
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(snackbar);
                            }
                          } catch (error) {
                            // Handle sign-in errors
                            final snackbar = SnackBar(
                              content: Text("Invalid Email or Password."),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          } finally {
                            Navigator.of(context).pop(); // Hide progress indicator
                          }
                        },
                        child: Text('Sign in', style: whiteText),
                      ),
                    ),
                    // SizedBox(height: screenHeight * 0.01),
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
