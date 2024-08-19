import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/textfield_style.dart';
import 'package:emosense/pages/signup_page.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:emosense/pages/preferences_survey.dart';

class SigninPage extends StatefulWidget {
  static String routeName = '/LoginPage';

  const SigninPage({Key? key}) : super(key: key);

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _passwordTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        child: Center(
                          // Logo or App Name
                        ),
                      ),
                      Container(
                        height: 100,
                        child: Center(
                          child: Text(
                            'EmoSense',
                            style: signinTitle,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      forTextField("Email", Icons.email, false, _emailTextController),
                      SizedBox(height: 15),
                      forTextField("Password", Icons.lock, true, _passwordTextController),
                      SizedBox(height: 80),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Container(
                      height: 45,
                      width: 250,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE5FFD0)),
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

                            // Check if the email is verified
                            if (userCredential.user!.emailVerified) {
                              globalUID = userCredential.user!.uid;
                              final docSnapshot = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(globalUID)
                                  .get();

                              if (docSnapshot.exists) {
                                final data = docSnapshot.data();
                                if (data != null) {
                                  final hasCompletedSurvey = data['surveyCompleted'];
                                  if (hasCompletedSurvey != null) {
                                    print(hasCompletedSurvey);
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                                    // if (hasCompletedSurvey == true) {
                                    //   print('Home Page Content');
                                    //   // Navigate to the home page
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(builder: (context) => HomePage()),
                                    //   );
                                    //   print('Navigation to Home Page initiated');
                                    // } else {
                                    //   print('Survey Page Content');
                                    //   // Navigator.pushNamed(context, 'preferencesSurveyPage');
                                    //   // Navigate to the preferences survey page
                                    //   Navigator.push(
                                    //     context,
                                    //     MaterialPageRoute(
                                    //         builder: (context) => PreferencesSurveyPage()
                                    //     ),
                                    //   );
                                    //   print('Navigation to Survey Page initiated');
                                    // }
                                  } else {
                                    print('hasCompletedSurvey field is not present in the document');
                                  }
                                } else {
                                  print('Document data is null');
                                }
                              } else {
                                print('Document does not exist');
                              }
                            } else {
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
                        icon: Icon(Icons.login, color: Color(0xFF366021)),
                        label: Text('Sign In', style: homeSubHeaderText),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      width: 250,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.app_registration, color: Color(0xFF366021)),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFE5FFD0)),
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                        },
                        label: Text('Sign Up', style: homeSubHeaderText),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InkWell(
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
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Color(0xFF366021),
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
