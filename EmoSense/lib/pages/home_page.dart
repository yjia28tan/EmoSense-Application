import 'package:emosense/design_widgets/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:emosense/pages/home_content_page.dart';

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
    // CalendarContentPage(),
    // AddContentPage(),
    // DiscoverContentPage(),
    // ProfileContentPage(),
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
      appBar: AppBar(title: Text('Home')),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onClicked: _onItemTapped,
      )
    );
  }
}
