import 'package:flutter/material.dart';
import 'package:emosense/pages/add_emotion_page.dart';
import 'package:emosense/pages/calendar_page.dart';
import 'package:emosense/pages/discover_page.dart';
import 'package:emosense/pages/profile_page.dart';
import 'package:emosense/pages/home_content_page.dart';
import 'package:emosense/design_widgets/navigation_bar.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomePage extends StatefulWidget {
  // final Interpreter interpreter; // Add the interpreter here
  //
  // HomePage(this.interpreter); // Update constructor

  static String routeName = '/HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages to display
  final List<Widget> _pages = <Widget>[
    HomeContentPage(),
    CalendarPage(),
    EmotionDetectionPage(),
    DiscoverPage(),
    ProfilePage(),
  ];

  // Method to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Future<bool> _onWillPop() async {
  //   // Show a dialog asking if the user is sure they want to log out
  //   final bool? shouldSignout = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Sign Out'),
  //         content: Text('Are you sure you want to sign out?'),
  //         actions: <Widget>[
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(false); // Return false to prevent back action
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () async {
  //               // Sign out the user from Firebase Authentication
  //               await FirebaseAuth.instance.signOut();
  //
  //               // Clear the user's FCM token in Firestore
  //               if (globalUID != null) {
  //                 final userRef = FirebaseFirestore.instance.collection('users').doc(globalUID);
  //                 await userRef.update({'fcmToken': ""});
  //               }
  //
  //               // Navigate to SigninPage and clear the navigation stack
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 MaterialPageRoute(builder: (context) => GetStartedPage()),
  //                     (route) => false,
  //               ); // Return true to allow back action
  //             },
  //             child: Text('Sign Out'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //
  //   return shouldSignout ?? false; // Default to false if null
  // }

  Future<bool> _onWillPop() async {
    // Instead of logging out, we allow the back button to close the app
    return true; // Returning true will close the app on back button press
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigation(
          selectedIndex: _selectedIndex,
          onClicked: _onItemTapped,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: _selectedIndex != 2
            ? FloatingActionButton(
              heroTag: null, // Prevent hero animation conflict
              onPressed: () {
                setState(() {
                  _selectedIndex = 2; // Go to Add Emotion page
                });
              },
              backgroundColor: Color(0xFFC9A4D7),
              child: Icon(Icons.add, color: Color(0xFF453276)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100)),
            )
            : null, // Do not display FAB for other pages
      ),
    );
  }

}
