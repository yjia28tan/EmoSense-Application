import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/home_daily_view.dart';
import 'package:emosense/design_widgets/home_monthly_view.dart';
import 'package:emosense/design_widgets/home_weekly_view.dart';
import 'package:emosense/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  String? username;
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  String _selectedView = 'Daily';

  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday(); // Set the initial date and view
      fetchUserData();
      DailyViewHome();
      WeeklyViewHome();
      MonthlyViewHome();
    });
  }

  void fetchUserData() {
    final uid = globalUID;
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .then((userData) {
        setState(() {
          username = userData['username'];
        });
      }).catchError((error) {
        showAlert(context, 'Error', 'Error fetching user data: $error');
      });
    } else {
      showAlert(context, 'Error', 'globalUID is null');
    }
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _selectedView = 'Daily';
    });
  }


  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        height: screenHeight * 0.325,
                        width: screenWidth,
                        decoration: BoxDecoration(
                          color: AppColors.upBackgroundColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Stack(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: screenHeight * 0.05,
                                  left: screenWidth * 0.05
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hey, $username :)',
                                    style: HomeWelcomeTitle.copyWith(
                                      fontSize: screenHeight * 0.035,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Have a great day!',
                                    style: HomeWelcomeTitle.copyWith(
                                      fontSize: screenHeight * 0.026,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: -35,
                              right: -25,
                              child: Image.asset(
                                'assets/hi.png',
                                width: 225,
                                height: 225,
                                fit: BoxFit.cover, // Ensures the image fits properly
                              ),
                            ),
                          ],
                        ),
                      ),


                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05,
                            vertical: screenHeight * 0.01
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                              child: Container(
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Mood Stats',
                                    style: titleBlack.copyWith(fontSize: screenHeight * 0.025),
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildViewButton('Daily'),
                                _buildViewButton('Weekly'),
                                _buildViewButton('Monthly'),
                              ],
                            ),
                            // Display the selected view widget
                            _getSelectedViewWidget(),

                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _getSelectedViewWidget() {
    switch (_selectedView) {
      case 'Daily':
        return DailyViewHome();
      case 'Weekly':
        return WeeklyViewHome();
      case 'Monthly':
        return MonthlyViewHome();
      default:
        return Container(); // Default case if needed
    }
  }

  Widget _buildViewButton(String view) {
    final bool isSelected = _selectedView == view;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedDate = DateTime.now();
              _resetToToday();
              _selectedView = view;
              if (view == 'Daily') {
                // Display the daily view

              } else if (view == 'Weekly') {
                // Display the weekly view
              } else if (view == 'Monthly') {
                // Display the monthly view
              }
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : AppColors.textColorGrey,
            backgroundColor: isSelected ? AppColors.darkPurpleColor : AppColors.downBackgroundColor, // Text color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              // no border
            ),
            padding: EdgeInsets.symmetric(vertical: 5.0), // Padding for size
          ),
          child: Text(view,
              style: GoogleFonts.leagueSpartan(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}