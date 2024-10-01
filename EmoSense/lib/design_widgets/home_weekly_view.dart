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

class WeeklyViewHome extends StatefulWidget {
  @override
  _WeeklyViewHomeState createState() => _WeeklyViewHomeState();
}

class _WeeklyViewHomeState extends State<WeeklyViewHome> {
  DateTime _selectedDate = DateTime.now();
  late String formattedDate;
  late String startFormatted;
  late String endFormatted;
  List<Map<String, dynamic>> _emotionForThisWeek = [];
  double _averageStressLevel = 0.0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday();
      _fetchDataForSelectedWeek(); // Fetch data on initialization
    });
  }

  Future<void> _fetchDataForSelectedWeek() async {
    try {
      print('Fetching data for week starting $_selectedDate');

      final uid = globalUID;

      // Calculate the start and end of the selected week
      // Start from Monday at 00:00:00
      final startOfWeek = _selectedDate.subtract(
        Duration(days: _selectedDate.weekday - 1), // Move to Monday
      ).copyWith(hour: 0, minute: 0, second: 0);

      // End on Sunday at 23:59:59
      final endOfWeek = startOfWeek.add(
        const Duration(days: 6, hours: 23, minutes: 59, seconds: 59),
      );

      // Log the start and end dates for debugging
      print('Week range in fetching data: $startOfWeek - $endOfWeek');

      // Fetch emotion records for the selected week
      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .where('uid', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfWeek)
          .where('timestamp', isLessThanOrEqualTo: endOfWeek)
          .get();

      List<Map<String, dynamic>> emotions = [];

      if (emotionSnapshot.docs.isNotEmpty) {
        for (var doc in emotionSnapshot.docs) {
          emotions.add({
            'docId': doc.id,
            'emotion': doc['emotion'],
            'timestamp': doc['timestamp'],
            'stressLevel': doc['stressLevel'],
            'description': doc['description'],
          });
        }
      }

      // Update state with the emotions fetched for the week
      setState(() {
        _emotionForThisWeek = emotions;
      });

      print('Fetched weekly emotions: ${_emotionForThisWeek.length}');
      print('Emotions: $_emotionForThisWeek');

    } catch (error) {
      showAlert(context, 'Error', 'Error fetching weekly data: $error');
    }
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view

    });
  }

  void _updateFormattedDate() {
    formattedDate = _getWeeklyDateRange();
    startFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate.subtract(Duration(days: _selectedDate.weekday - 1)));
    endFormatted = DateFormat('yyyy-MM-dd').format(_selectedDate.add(Duration(days: DateTime.daysPerWeek - _selectedDate.weekday)));
    print('Formatted date: $formattedDate');
    print('Start formatted: $startFormatted');
    print('End formatted: $endFormatted');
  }

  String _getWeeklyDateRange() {
    // Calculate the start and end of the selected week from Monday to Sunday
    final startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final endOfWeek = _selectedDate.add(Duration(days: DateTime.daysPerWeek - _selectedDate.weekday));
    final startFormatted = DateFormat('d MMM').format(startOfWeek);
    final endFormatted = DateFormat('d MMM').format(endOfWeek);
    print('Week range _getWeeklyDateRange: $startFormatted - $endFormatted');
    formattedDate = '$startFormatted - $endFormatted';
    return formattedDate;
  }


  void _showPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 7));
      _updateFormattedDate();
      _fetchDataForSelectedWeek(); // Refetch the data for the new week
    });
  }

  void _showNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: 7));
      _updateFormattedDate();
      _fetchDataForSelectedWeek(); // Refetch the data for the new week
    });
  }

  bool _isThisWeek() {
    final now = DateTime.now();

    // Get the start and end of the current week (from Monday to Sunday)
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final endOfWeek = now.add(Duration(days: DateTime.daysPerWeek - now.weekday)); // Sunday

    // Check if the selected date is within the current week range
    return _selectedDate.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
        _selectedDate.isBefore(endOfWeek.add(const Duration(seconds: 1)));
  }

  Color _getBarColorForEmotion(String emotion) {
    // Customize color based on the emotion
    switch (emotion) {
      case 'Happy':
        return AppColors.happy;
      case 'Sad':
        return AppColors.sad;
      case 'Neutral':
        return AppColors.neutral;
      case 'Angry':
        return AppColors.angry;
      case 'Fear':
        return AppColors.fear;
      case 'Disgust':
        return AppColors.disgust;
      default:
        return AppColors.lightLogoColor; // Default color if emotion doesn't match
    }
  }

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
                  _showPreviousWeek();
                },
              ),
              Text(
                formattedDate,
                style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
              ),
              IconButton(
                iconSize: screenHeight * 0.02,
                icon: Icon(Icons.arrow_forward_ios_outlined),
                onPressed: _isThisWeek() ? null : _showNextWeek, // Disable button if in current week
                color: _isThisWeek() ? AppColors.textFieldColor : null, // Grey out the icon if disabled
              ),

            ],
          ),
        ),

        // Display the emotion count chart
        _buildEmotionCountChart(context),

        // Display the stress level chart
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

        // Display the emotion trends chart
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

        SizedBox(height: 25),


      ],

    );
  }

  Widget _buildEmotionCountChart(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // Define all possible emotions
    List<String> allEmotions = ["Angry", "Neutral", "Happy", "Disgust", "Sad", "Fear"];

    // Prepare data for the chart, including emotions with 0 occurrences
    Map<String, int> emotionData = {
      for (var emotion in allEmotions) emotion: 0
    };

    // Update the emotion counts from the fetched data
    for (var emotion in _emotionForThisWeek) {
      String emotionName = emotion['emotion'];
      emotionData[emotionName] = (emotionData[emotionName] ?? 0) + 1;
    }

    // Create a list of BarChartGroupData from the emotionData
    List<BarChartGroupData> barChartGroups = [];
    int index = 0;
    emotionData.forEach((emotion, count) {
      barChartGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: count.toDouble(),
              color: _getBarColorForEmotion(emotion), // Customize bar color based on the emotion
              borderRadius: BorderRadius.circular(15),
              width: 30, // Set a fixed width for bars
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: 5, // Fixed height for the background bar for visual consistency
                color: Colors.transparent,
              ),
            ),
          ],
          showingTooltipIndicators: [0],
        ),
      );
      index++;
    });

    // Return the bar chart widget
    return Padding(
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
                  'Emotion Count',
                  style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
                ),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.3,
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
              ),
              child: BarChart(
                BarChartData(
                  borderData: FlBorderData(show: false), // Remove the border around the chart
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // Remove Y-axis labels
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // No Y-axis labels
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false), // No Y-axis on the right
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          String emotion = allEmotions[value.toInt()]; // Get emotion based on value

                          return Column(
                            // mainAxisSize: MainAxisSize.min,
                            children: [
                              _getEmotionIcon(emotion, 45),
                              Text(
                                emotion, // Display the emotion name below the icon
                                style: TextStyle(
                                  color: AppColors.textColorBlack,
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  ),
                  barGroups: barChartGroups,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBorder: BorderSide.none,
                      tooltipPadding: EdgeInsets.all(5), // Remove any padding
                      tooltipMargin: 0, // Remove the margin
                      // Customize the tooltip appearance
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        return BarTooltipItem(
                          '${rod.toY.toInt()}', // Show the emotion count on top of the bar
                          greySmallText.copyWith(
                            fontSize: 12,
                            color: AppColors.textColorBlack,
                            backgroundColor: Colors.transparent, // Remove background color
                          ),
                        );
                      },
                      getTooltipColor: (group) {
                        return Colors.transparent;
                      },

                    ),
                  ),

                  gridData: FlGridData(show: false), // Disable grid lines
                  alignment: BarChartAlignment.spaceAround, // Space the bars evenly
                  maxY: 5, // Maximum Y value (assuming 5 for visual consistency)
                ),
              ),
            ),
            SizedBox(height: 10),

          ],
        ),
      ),
    );
  }

}