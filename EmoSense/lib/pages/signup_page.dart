import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/custom_loading_button.dart';
import 'package:emosense/pages/privacy_policy.dart';
import 'package:emosense/pages/terms_conditions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
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

  // New variable to track agreement with terms and conditions
  bool _isAgreedToTerms = false;
  bool _isPasswordVisible = false; // Password visibility toggle

  bool passwordConfirmed() {
    return _passwordTextController.text.trim() == _confirmTextController.text.trim();
  }

  bool isValidPassword(String password) {
    // At least 6 characters, one uppercase, one lowercase, one number, and one special character
    RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*])[A-Za-z\d!@#$%^&*]{6,}$');
    return passwordRegex.hasMatch(password);
  }

  bool isValidEmail(String email) {
    // Basic email validation
    RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve screen height and width using MediaQuery
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background color
          Container(
            color: AppColors.upBackgroundColor,
          ),
          // Image asset positioned in the stack
          Positioned(
            top: screenHeight * 0.00015,
            right: screenWidth * 0,
            child: CircleAvatar(
              radius: 200,
              backgroundColor: AppColors.upBackgroundColor,
              backgroundImage: AssetImage('assets/hi.png'), // Use your image asset here
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
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Let’s sign you up', style: titleBlack),
                    SizedBox(height: screenHeight * 0.015),
                    forTextField("Username", Icons.person, false, _usernameTextController),
                    SizedBox(height: screenHeight * 0.015),
                    forTextField("Email", Icons.email, false, _emailTextController),
                    SizedBox(height: screenHeight * 0.015),
                    forPasswordTextField(
                        "Password",
                        Icons.lock,
                        true,
                        _passwordTextController,
                        _isPasswordVisible,
                            () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                          });
                        }
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    forPasswordTextField(
                        "Confirm Password",
                        Icons.lock,
                        true,
                        _confirmTextController,
                        _isPasswordVisible,
                            () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible; // Toggle password visibility
                          });
                        }
                        ),

                    // Checkbox for terms and conditions
                    CheckboxListTile(
                      value: _isAgreedToTerms,
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(text: "I agree to the ", style: inkwellText.copyWith(color: Colors.black)),
                            TextSpan(
                              text: "Terms & Conditions",
                              style: inkwellText, // Customize color as needed
                              recognizer: TapGestureRecognizer()..onTap = () {
                                // Navigate to Terms & Conditions page
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TermsNConditionsPage()));
                              },
                            ),
                            TextSpan(text: " and ", style: inkwellText.copyWith(color: Colors.black)),
                            TextSpan(
                              text: "Privacy Policy",
                              style: inkwellText, // Customize color as needed
                              recognizer: TapGestureRecognizer()..onTap = () {
                                // Navigate to Privacy Policy page
                                Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyPage()));
                              },
                            ),
                          ],
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _isAgreedToTerms = value!;
                        });
                      },
                      // Adjust the content padding to create space between the checkbox and text
                      contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 8), // Customize vertical padding as needed
                      controlAffinity: ListTileControlAffinity.leading, // Positions the checkbox on the left
                    ),

                    Container(
                      width: double.infinity,
                      height: screenHeight * 0.07,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkPurpleColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                        onPressed: () async {
                          String username = _usernameTextController.text.trim();
                          String email = _emailTextController.text.trim();
                          String password = _passwordTextController.text.trim();

                          if (username.isEmpty) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Registration Failed'),
                                content: const Text('Please enter your username.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          } else if (!isValidEmail(email)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Invalid Email'),
                                content: const Text('Please enter a valid email address.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          } else if (!isValidPassword(password)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Weak Password'),
                                content: const Text('Password must be at least 6 characters long and include at least one uppercase letter, one number, and one special character.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          } else if (!passwordConfirmed()) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Ensure your password'),
                                content: const Text('Please make sure the password and confirm password are the same.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          } else if (!_isAgreedToTerms) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Agreement Required'),
                                content: const Text('Please agree to the Terms & Conditions and Privacy Policy.'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                            return;
                          }

                          // Show custom loading indicator
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => Center(child: CustomLoadingIndicator()),
                          );

                          try {
                            final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                              email: email,
                              password: password,
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

                            await userCredential.user!.sendEmailVerification();

                            final snackbar = SnackBar(
                              content: Text("Account Created! Check your email to verify your account before signing in."),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );

                            _usernameTextController.clear();
                            _emailTextController.clear();
                            _passwordTextController.clear();
                            _confirmTextController.clear();

                            setState(() {
                              _isAgreedToTerms = false;
                            });

                            try {
                              Navigator.pop(context);
                            } catch (e) {}

                            ScaffoldMessenger.of(context).showSnackBar(snackbar);

                            Navigator.push(context, MaterialPageRoute(builder: (context) => const SigninPage()));

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

                            Navigator.pop(context);

                            final snackbar = SnackBar(
                              content: Text(errorMessage),
                              action: SnackBarAction(
                                label: 'OK',
                                onPressed: () {},
                              ),
                            );

                            ScaffoldMessenger.of(context).showSnackBar(snackbar);
                          }
                        },
                        child: Text('Sign Up', style: whiteText),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SigninPage()));
                      },
                      child: Text('Already have an account? Sign in', style: inkwellText),
                    ),
                    SizedBox(height: screenHeight * 0.01),
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
