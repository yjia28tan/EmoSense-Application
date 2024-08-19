import 'package:emosense/pages/preferences_survey.dart';
import 'package:emosense/pages/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:emosense/pages/home_page.dart';
import 'package:emosense/pages/signin_page.dart';
import 'package:emosense/pages/add_emotion_page.dart';

String? globalUID;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCpcP0utp2YRC9s3a41WXu-hVzJDo4bKdA',
      appId: '1:436217855383:android:14b5a678dd39aefc0f58d2',
      messagingSenderId: '436217855383',
      projectId: 'emosense-d13d2',
    ),
  );
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? user;

  refresh() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in
    User? user = FirebaseAuth.instance.currentUser;

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmoSense',
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFE5FFD0),
          selectedItemColor: Color(0xFFFF366021),
          unselectedItemColor: Color(0xFF34A853),
        ),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF366021)),
      ),
      home: user != null ? HomePage() : const SigninPage(),
      routes: {
        SigninPage.routeName: (context) => const SigninPage(),
        '/homepage': (context) => HomePage(),
        '/preferencesSurveyPage': (context) => const PreferencesSurveyPage(),
        // SignUpPage.routeName: (context) => const SignUpPage(),
      },
    );
  }
}
