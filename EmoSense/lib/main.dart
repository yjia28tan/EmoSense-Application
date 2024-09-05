import 'package:emosense/pages/genre_selection_page.dart';
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

  @override
  void initState() {
    super.initState();
    // Check if the user is already logged in
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      globalUID = user!.uid;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EmoSense',
      theme: ThemeData(
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFFF2F2F2),
          selectedItemColor: Color(0xFF453276),
          unselectedItemColor: Color(0xFFA6A6A6),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFC9A4D7)),
      ),
      // Use a ternary operator to decide which screen to show based on login status
      home: user != null ? HomePage() : const SigninPage(),
      routes: {
        SigninPage.routeName: (context) => const SigninPage(),
        HomePage.routeName: (context) => HomePage(),
        GenreSelectionPage.routeName: (context) => GenreSelectionPage(),
        AddEmotionRecordPage.routeName: (context) => AddEmotionRecordPage(),
      },
    );
  }
}
