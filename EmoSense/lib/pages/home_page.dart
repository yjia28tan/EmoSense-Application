import 'package:flutter/material.dart';
import 'package:emosense/pages/add_emotion_page.dart';
import 'package:emosense/pages/calendar_page.dart';
import 'package:emosense/pages/discover_page.dart';
import 'package:emosense/pages/profile_page.dart';
import 'package:emosense/pages/home_content_page.dart';
import 'package:emosense/design_widgets/navigation_bar.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  final int selectedIndex;

  HomePage({this.selectedIndex = 0}); // Default to index 0 if not provided

  static String routeName = '/HomePage';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Use the passed index
  }

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

  Future<bool> _onWillPop() async {
    // Close the app instead of popping to another page
    SystemNavigator.pop();
    return false; // Return false to indicate that the pop has been handled
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
