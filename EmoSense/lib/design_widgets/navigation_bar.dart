import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  final selectedIndex;
  ValueChanged<int> onClicked;
  BottomNavigation({Key? key, required this.selectedIndex, required this.onClicked}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: "Calendar"),
        BottomNavigationBarItem(icon: Icon(Icons.add_reaction), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Discover"),
        BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: "Profile"),
      ],
      currentIndex: selectedIndex,
      onTap: onClicked,
    );
  }
}