import 'package:emosense/design_widgets/navigation_bar.dart';
import 'package:emosense/pages/add_emotion_page.dart';
import 'package:emosense/pages/discover_page.dart';
import 'package:emosense/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:emosense/pages/home_content_page.dart';
import 'package:emosense/pages/calendar_page.dart';

class HomePage extends StatefulWidget {
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
    AddEmotionRecordPage(),
    DiscoverPage(),
    ProfilePage(),
  ];

  // Method to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onClicked: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        child: FloatingActionButton(
          onPressed: () {
            setState(() {
              _selectedIndex = 2; // Go to the Add Emotion page when FAB is clicked
            });
          },
          backgroundColor: Color(0xFFC9A4D7),
          child: Icon(Icons.add, color: Color(0xFF453276)),
          // make the floating button round
          shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(100)
          ),
        ),
      ),
    );
  }
}
