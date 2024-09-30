import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class DailyViewHome extends StatefulWidget {
  @override
  _DailyViewHomeState createState() => _DailyViewHomeState();
}

class _DailyViewHomeState extends State<DailyViewHome> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  List<Map<String, dynamic>> _emotionForToday = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday();

    });
  }

  Future<void> _fetchDataForSelectedDate() async {
    final uid = globalUID;
    final startOfDay = DateTime(formattedDate.year, formattedDate.month, formattedDate.day);
    final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

    final emotionSnapshot = await FirebaseFirestore.instance
        .collection('emotionRecords')
        .where('uid', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .where('timestamp', isLessThan: endOfDay)
        .get();

    List<Map<String, dynamic>> emotions = [];

    if (emotionSnapshot.docs.isNotEmpty) {
      for (var doc in emotionSnapshot.docs) {
        // Add the emotions
        emotions.add({
          'docId': doc.id,
          'emotion': doc['emotion'],
          'timestamp': doc['timestamp'],
          'stressLevel': doc['stressLevel'],
          'description': doc['description'],
        });
      }
    }
    print(emotions);

    // Update the state with both emotions and tracks for the selected day
    setState(() {
      _emotionForToday = emotions;
    });
  }

  /// Adjusted this function to make the emoji size dynamic based on screen height
  Widget _getEmotionIcon(String mood, double iconSize) {
    final emotion = Emotion.emotions.firstWhere(
          (e) => e.name == mood,
      orElse: () => Emotion(
        name: 'Unknown',
        assetPath: 'assets/logo.png',
        color: Colors.transparent,
        containerColor: Colors.transparent,
      ),
    );

    return Image.asset(
      emotion.assetPath,
      width: iconSize,  // Set the size dynamically
    );
  }

  /// Default icon with adjustable size if no emotion is found
  Widget _getDefaultIcon(double iconSize) {
    return Image.asset(
      'assets/logo.png',
      width: iconSize,
    );
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view
    });
  }

  void _updateFormattedDate() {
      formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
  }

  void _showPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
      _updateFormattedDate();
    });
  }

  void _showNextDay() {
    if (!_isToday()) {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(days: 1));
        _updateFormattedDate();
      });
    }
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
                      _showPreviousDay();
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
                      _showNextDay();
                  },
                  color: _isToday() ? AppColors.textFieldColor : null, // Grey out the icon if disabled
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: screenHeight * 0.15,
                    width: screenWidth * 0.43,
                    padding: EdgeInsets.all(8),
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
                              'Today\'s Emotion',
                              style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                            ),
                          ),
                        ),
                        // Display the latest emotion of the day
                      ],
                    ),
                  ),
                  Container(
                    height: screenHeight * 0.15,
                    width: screenWidth * 0.43,
                    padding: EdgeInsets.all(8),
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
                        // Calculate the average stress level for the day and display the graph

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(

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
              )),
        ],

    );
  }

  Widget _buildEmotionCountChart(context, Map<String, int> emotionData) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      width: MediaQuery.of(context).size.width * 0.9,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,

            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  List<String> emotions = ["Sad", "Happy", "Neutral", "Angry", "Fear", "Disgust"];
                  return Text(
                    emotions[value.toInt()],
                    style: TextStyle(
                      color: AppColors.textColorBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          barGroups: emotionData.entries.map((entry) {
            return BarChartGroupData(
              x: ["sad", "happy", "neutral", "angry", "fear", "disgust"].indexOf(entry.key),
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: AppColors.darkLogoColor,
                  width: 16,
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
