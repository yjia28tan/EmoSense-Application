import 'package:cloud_firestore/cloud_firestore.dart';
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
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF453276)),
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
                        icon: Icon(Icons.login, color: Color(0xFFF2F2F2)),
                        label: Text('Sign In', style: homeSubHeaderText),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      height: 45,
                      width: 250,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.app_registration, color: Color(0xFFF2F2F2)),
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF453276)),
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
                      color: Color(0xFF453276),
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
