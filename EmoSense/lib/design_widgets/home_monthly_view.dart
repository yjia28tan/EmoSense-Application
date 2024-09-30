import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class MonthlyViewHome extends StatefulWidget {
  @override
  _MonthlyViewHomeState createState() => _MonthlyViewHomeState();
}

class _MonthlyViewHomeState extends State<MonthlyViewHome> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday();
    });
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view
    });
  }

  void _updateFormattedDate() {
    formattedDate = DateFormat('MMMM yyyy').format(_selectedDate);
  }

  void _showPreviousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, _selectedDate.day);
      _updateFormattedDate();
    });
  }

  void _showNextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, _selectedDate.day);
      _updateFormattedDate();
    });
  }


  bool _isToday() {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Button to go to the previous day/week/month
              IconButton(
                iconSize: screenHeight * 0.02, // Adjusting icon size based on screen height
                icon: Icon(Icons.arrow_back_ios_outlined),
                onPressed: () {
                  _showPreviousMonth();
                },
              ),
              Text(
                formattedDate,
                style: titleBlack.copyWith(fontSize: screenHeight * 0.02), // Adjust font size
              ),
              IconButton(
                iconSize: screenHeight * 0.02, // Adjusting icon size based on screen height
                icon: Icon(Icons.arrow_forward_ios_outlined),
                onPressed: () {
                  _showNextMonth();
                },
                color: _isToday() ? AppColors.textFieldColor : null, // Grey out the icon if disabled
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Stress Level',
                      style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                    ),
                  ),
                ),
                // Calculate the average stress level for the week and display the graph

              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                  ),
                ],
              ),
              child:
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Emotion Count',
                        style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                      ),
                    ),
                  ),
                  // _buildEmotionCountChart(context, emotionData),
                ],
              )
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.whiteColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 5, left: 4, right: 5),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Emotion Trends',
                      style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                    ),
                  ),
                ),
                // Calculate the average stress level for the week and display the graph

              ],
            ),
          ),
        ),

      ],

    );
  }
}