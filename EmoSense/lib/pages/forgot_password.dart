import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmpasswordTextController = TextEditingController();

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
                            'Forgot Password',
                            style: titleBlack,
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
                        icon: Icon(Icons.check, color: Color(0xFFF2F2F2)),
                        label: Text('Send Code', style: whiteText),
                      ),
                    ),

                  ],
                ),

              ],
            ),
          ),
        ),
      ],
    );
  }
}
