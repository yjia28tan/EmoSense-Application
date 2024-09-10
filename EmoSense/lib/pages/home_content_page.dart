import 'package:emosense/design_widgets/app_color.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  String _selectedView = 'Daily';

  // Example data for today mood
  String todayEmotion = "Happy";
  Icon todayEmotionIcon = Icon(Icons.sentiment_satisfied_alt, size: 40, color: Colors.deepPurple);

  // Example data for mood count
  Map<String, int> weeklyMoodCount = {
    "sad": 2,
    "happy": 5,
    "neutral": 1,
    "angry": 1,
    "fear": 0,
    "disgust": 0,
  };

  Map<String, int> monthlyMoodCount = {
    "sad": 8,
    "happy": 12,
    "neutral": 4,
    "angry": 3,
    "fear": 2,
    "disgust": 1,
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday(); // Set the initial date and view
    });
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view
    });
  }

  void _updateFormattedDate() {
    if (_selectedView == 'Daily') {
      formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
    } else if (_selectedView == 'Weekly') {
      formattedDate = _getWeeklyDateRange();
    } else if (_selectedView == 'Monthly') {
      formattedDate = DateFormat('MMMM yyyy').format(_selectedDate);
    }
  }

  String _getWeeklyDateRange() {
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final endOfWeek = _selectedDate.add(Duration(days: DateTime.daysPerWeek - _selectedDate.weekday));
    final startFormatted = DateFormat('d MMM').format(startOfWeek);
    final endFormatted = DateFormat('d MMM').format(endOfWeek);
    return '$startFormatted - $endFormatted';
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

  void _showPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7));
      _updateFormattedDate();
    });
  }

  void _showNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7));
      _updateFormattedDate();
    });
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

    Map<String, int> moodData;
    if (_selectedView == 'Weekly') {
      moodData = weeklyMoodCount;
    } else if (_selectedView == 'Monthly') {
      moodData = monthlyMoodCount;
    } else {
      moodData = {
        todayEmotion.toLowerCase(): 1, // Example data for daily mood
      };
    }

    return Scaffold(
      backgroundColor: AppColors.downBackgroundColor,
      body: Stack(
        children: [
          Container(
            child: Column(
              children: [
                Container(
                  height: screenHeight * 0.325,
                  decoration: BoxDecoration(
                    color: AppColors.upBackgroundColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
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

                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Button to go to the previous day/week/month
                            IconButton(
                              iconSize: screenHeight * 0.02, // Adjusting icon size based on screen height
                              icon: Icon(Icons.arrow_back_ios_outlined),
                              onPressed: () {
                                if (_selectedView == 'Daily') {
                                  _showPreviousDay();
                                } else if (_selectedView == 'Weekly') {
                                  _showPreviousWeek();
                                } else if (_selectedView == 'Monthly') {
                                  _showPreviousMonth();
                                }
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
                                if (_selectedView == 'Daily' && !_isToday()) {
                                  _showNextDay();
                                } else if (_selectedView == 'Weekly' && !_isToday()) {
                                  _showNextWeek();
                                } else if (_selectedView == 'Monthly' && !_isToday()) {
                                  _showNextMonth();
                                }
                              },
                              color: _isToday() ? AppColors.textFieldColor : null, // Grey out the icon if disabled
                            ),
                          ],
                        ),
                      ),

                      _buildMoodBarChart(moodData),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton(String view) {
    final bool isSelected = _selectedView == view;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8),
        child: TextButton(
          onPressed: () {
            setState(() {
              _selectedView = view;
              _resetToToday(); // Reset to today's date when switching views
            });
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: isSelected ? Colors.white : AppColors.textColorGrey,
            backgroundColor: isSelected ? AppColors.darkPurpleColor : AppColors.lightBackgroundColor, // Text color
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

  Widget _buildMoodBarChart(Map<String, int> moodData) {
    return Container(
      height: 200,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 10,
          ),
        ],
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
          barGroups: moodData.entries.map((entry) {
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
