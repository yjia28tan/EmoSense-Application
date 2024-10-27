import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:emosense/design_widgets/font_style.dart';
import 'package:emosense/design_widgets/textfield_style.dart';
import 'package:emosense/pages/signin_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  static String routeName = '/ForgotPasswordPage';

  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.24),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, top: 80, bottom: 10),
                    child: Center(
                      child: Text(
                        'Forgot Password',
                        style: titleBlack,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 30),
                    child: Center(
                      child: Text(
                        'Please enter your email address to reset your password.',
                        style: greySmallText.copyWith(fontSize: 15),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                    child: forTextField("Email", Icons.email, false, _emailTextController),
                  ),
                  SizedBox(height: screenHeight * 0.2),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF453276)),
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (context) => Center(child: CustomLoadingIndicator()),
                          );

                          try {
                            await FirebaseAuth.instance.sendPasswordResetEmail(
                              email: _emailTextController.text,
                            );

                            Navigator.pop(context);

                            final snackbar = SnackBar(
                              content: Text("Password reset email sent. Please check your email.\n"
                                  "You can reset your password using the link in the email and sign in again."),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);

                            // clear the email field
                            _emailTextController.clear();
                            // Navigate back to the sign in page
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (context) => SigninPage()
                                )
                            );

                          } catch (error) {
                            Navigator.pop(context);

                            final snackbar = SnackBar(
                              content: Text("Failed to send password reset email. Please enter a valid email address."),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          }
                        },
                        child: Text('Send Email', style: whiteText),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
