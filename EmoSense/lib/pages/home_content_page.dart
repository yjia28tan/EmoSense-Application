import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/design_widgets/font_style.dart';

class HomeContentPage extends StatefulWidget {
  @override
  _HomeContentPageState createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  // String? todayEmotion;
  // Icon? todayEmotionIcon;
  String? emotionID;

  @override
  void initState() {
    super.initState();
    formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
  }

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


  void _showPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
      formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
    });
  }

  void _showNextDay() {
    if (!_isToday()) {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(days: 1));
        formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
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

    return Scaffold(
      body: SingleChildScrollView( // Make the screen scrollable
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.05
          ),
          child: Column(
            children: [
              Container(
                height: screenHeight * 0.1, // Adjusting height based on screen size
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Button to go to the previous day
                    IconButton(
                      iconSize: screenHeight * 0.025, // Adjusting icon size based on screen height
                      icon: Icon(Icons.arrow_back_ios_outlined),
                      onPressed: _showPreviousDay,
                    ),
                    Text(
                      formattedDate,
                      style: titleBlack.copyWith(fontSize: screenHeight * 0.025), // Adjust font size
                    ),
                    IconButton(
                      iconSize: screenHeight * 0.025, // Adjusting icon size based on screen height
                      icon: Icon(Icons.arrow_forward_ios_outlined),
                      onPressed: _isToday() ? null : _showNextDay,
                      color: _isToday() ? Colors.grey : null, // Grey out the icon if disabled
                    ),
                  ],
                ),
              ),

              // SizedBox(height: screenHeight * 0.001), // Adjusting space between date and content
              Align(
                alignment: Alignment.centerLeft, // Align the 'Today' text to the left
                child: Text(
                  "Today",
                  style: homepageText.copyWith(fontSize: screenHeight * 0.03),
                ),
              ),
              SizedBox(height: screenHeight * 0.001), // Adjusting space between title and content
              // Display today's emotion
              Container(
                height: screenHeight * 0.1,
                width: screenWidth * 0.9,
                decoration: BoxDecoration(
                  color: Color(0xFFF2F2F2).withOpacity(0.3),
                  // border: Border.all(
                  //   color: Color(0xFFC9A4D7),
                  //   width: 2.0,
                  // ),
                  // borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        todayEmotionIcon ??
                            Icon(Icons.sentiment_neutral, size: screenHeight * 0.04),
                        SizedBox(width: screenWidth * 0.02), // Add spacing between icon and text
                        Text(
                          todayEmotion ?? 'No emotion recorded',
                          style: homepageText.copyWith(fontSize: screenHeight * 0.03), // Adjust font size
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Activity",
                  style: homepageText.copyWith(fontSize: screenHeight * 0.03),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),

              // Mood Count Graph - Weekly
              Text(
                "Mood Count - Last 7 Days",
                style: homepageText.copyWith(fontSize: screenHeight * 0.025),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildMoodBarChart(weeklyMoodCount),

              SizedBox(height: screenHeight * 0.02),

              // Mood Count Graph - Monthly
              Text(
                "Mood Count - Last 30 Days",
                style: homepageText.copyWith(fontSize: screenHeight * 0.025),
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildMoodBarChart(monthlyMoodCount),



              // Add other widgets or content that here
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildMoodBarChart(Map<String, int> moodData) {
  return Container(
    height: 200,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        ),
      ],
    ),
    child: BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: moodData.entries.map((entry) {
          return BarChartGroupData(
            x: entry.key.hashCode,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Colors.purple,
                width: 15,
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                String mood = moodData.keys.firstWhere(
                      (key) => key.hashCode == value.toInt(),
                  orElse: () => '',
                );
                return Text(
                  mood,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black,
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // Increase reserved size to prevent overlap
              interval: 2, // Define an interval for the Y-axis labels
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0), // Add padding to prevent overlap
                  child: Text(
                    value.toInt().toString(),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    ),
  );
}


