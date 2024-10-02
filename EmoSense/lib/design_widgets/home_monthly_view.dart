import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/design_widgets/stress_level_chart.dart';
import 'package:emosense/design_widgets/stress_model.dart';
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
  late String startFormatted;
  late String endFormatted;
  List<Map<String, dynamic>> _emotionForThisMonth = [];
  StressModel _currentStressLevel = stressModels.last;
  int counter = 0;

  Map<String, int> stressCounts = {
    "Extreme": 0,
    "High": 0,
    "Optimal": 0,
    "Moderate": 0,
    "Low": 0,
  };

  @override
  void initState() {
    super.initState();
    setState(() {
      _resetToToday();
      _fetchDataForSelectedMonth();
    });
  }

  Future<void> _fetchDataForSelectedMonth() async {
    try {
      final uid = globalUID;

      // Calculate the start and end of the selected month
      // Start from the 1st of the month at 00:00:00
      final startOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1, 0, 0, 0);

      // End on the last day of the month at 23:59:59
      final endOfMonth = DateTime(
        _selectedDate.year,
        _selectedDate.month + 1, // Go to the next month
        0, // This gets the last day of the current month
        23, 59, 59,
      );

      // Fetch emotion records for the selected month
      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .where('uid', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
          .where('timestamp', isLessThanOrEqualTo: endOfMonth)
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

      // Calculate the average stress level and update the state
      _calculateAverageStressLevel(emotions);

      // Calculate stress level counts and update the counter
      stressCounts = _calculateStressLevelCounts(emotions);
      counter = emotions.length;

      // Update state with the emotions fetched for the month
      setState(() {
        _emotionForThisMonth = emotions; // Use a separate variable for monthly emotions
      });
    } catch (error) {
      showAlert(context, 'Error', 'Error fetching monthly data: $error');
    }
  }

  void _calculateAverageStressLevel(List<Map<String, dynamic>> emotions) {
    if (emotions.isNotEmpty) {
      double totalStress = emotions.fold(0.0, (sum, emotion) {
        try {
          return sum + double.parse(emotion['stressLevel'] as String);
        } catch (e) {
          print('Error converting stress level to double: $e');
          return sum;
        }
      });

      double averageStressLevel = totalStress / emotions.length;
      print('Average Stress Level: $averageStressLevel');

      _currentStressLevel = getStressLevel(averageStressLevel);
    } else {
      _currentStressLevel = stressModels.last;
    }
  }

  Map<String, int> _calculateStressLevelCounts(List<Map<String, dynamic>> emotions) {
    Map<String, int> stressCounts = {
      "Low": 0,
      "Moderate": 0,
      "Optimal": 0,
      "High": 0,
      "Extreme": 0,
    };

    emotions.forEach((emotion) {
      double stressLevelAsDouble = _parseStressLevel(emotion['stressLevel']);
      String stressLevel = getStressLevelAsString(stressLevelAsDouble);

      if (stressCounts.containsKey(stressLevel)) {
        stressCounts[stressLevel] = (stressCounts[stressLevel] ?? 0) + 1;
      }
    });

    return stressCounts;
  }

  double _parseStressLevel(dynamic stressLevelValue) {
    if (stressLevelValue is String) {
      return double.tryParse(stressLevelValue) ?? 2.0;
    } else if (stressLevelValue is double) {
      return stressLevelValue;
    } else {
      print('Warning: Unrecognized stress level type: ${stressLevelValue.runtimeType}');
      return 2.0; // Default if type unrecognized
    }
  }

  static String getStressLevelAsString(double level) {
    switch (level) {
      case 4.0:
        return "Extreme";
      case 3.0:
        return "High";
      case 2.0:
        return "Optimal";
      case 1.0:
        return "Moderate";
      case 0.0:
        return "Low";
      default:
        return "Unknown"; // Handle cases that don't match
    }
  }

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate();
      _fetchDataForSelectedMonth();
    });
  }

  void _updateFormattedDate() {
    formattedDate = DateFormat('MMMM yyyy').format(_selectedDate);
  }

  void _showPreviousMonth() {
    setState(() {
      // Move to the last day of the previous month if necessary
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, 0);
      _updateFormattedDate();
      _fetchDataForSelectedMonth();
    });
  }

  void _showNextMonth() {
    setState(() {
      // Move to the last day of the next month if necessary
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 2, 0);
      _updateFormattedDate();
      _fetchDataForSelectedMonth();
    });
  }

  bool _isThisMonth() {
    final now = DateTime.now();
    return _selectedDate.year == now.year && _selectedDate.month == now.month;
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
        valence: 0,
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
                onPressed: _isThisMonth() ? null : _showNextMonth, // Disable button if in current month
                color: _isThisMonth() ? AppColors.textFieldColor : null, // Grey out the icon if disabled
              ),
            ],
          ),
        ),

        // Display the emotion count chart
        _buildEmotionCountChart(context),

        // Display the stress level chart
        _buildStressLevelContainer(),

        // Display the emotion trends
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
    for (var emotion in _emotionForThisMonth) {
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

  Widget _buildStressLevelContainer() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Stack(
        children: [
          Column(
            children: [
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
                    // Add the half pie chart for stress levels here if needed
                    if (counter == 0)
                      SizedBox(
                        height: 110,
                        width: 150,
                      ),
                    if (counter > 0)
                      SizedBox(
                        height: 110,
                        width: 150,
                        child: HalfDonutChart(stressCounts: stressCounts),
                      ),

                    // Display the current stress level that was calculated
                    Center(
                      child: Container(
                        height: 32,
                        width: screenWidth * 0.25,
                        decoration: BoxDecoration(
                          color: counter == 0 ? AppColors.textFieldColor : _currentStressLevel.containerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            counter == 0 ? "None" : _currentStressLevel.level, // Show the current stress level
                            style: titleBlack.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 5,
            right: 5,
            child: Tooltip(
              message: "This chart shows the distribution of stress levels throughout the month.\n"
                  "Color Indicator: \nRed - Extreme, \nOrange - High, \nYellow - Optimal, \nGreen - Moderate, \nBlue - Low.\n\n"
                  "The stress level displayed below is the average stress throughout the month.",
              padding: EdgeInsets.all(8.0),  // Control the padding inside the tooltip box
              verticalOffset: 15,  // Adjust how far the tooltip is from the target widget
              preferBelow: false,  // Show the tooltip above the widget
              margin: EdgeInsets.only(left: 85, right: 10),  // Adjust the margin between the tooltip and the widget
              textStyle: TextStyle(
                fontSize: 14.0,  // Set the text size
                color: Colors.white,
              ),
              decoration: BoxDecoration(
                color: AppColors.textColorGrey,  // Background color of the tooltip
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.info_outline,
                color: AppColors.textColorGrey,
                size: 19,
              ),
            ),
          ),
        ],
      ),
    );
  }


}