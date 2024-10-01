import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emosense/design_widgets/alert_dialog_widget.dart';
import 'package:emosense/design_widgets/app_color.dart';
import 'package:emosense/design_widgets/emotion_data_model.dart';
import 'package:emosense/design_widgets/emotion_model.dart';
import 'package:emosense/design_widgets/stress_level_chart.dart';
import 'package:emosense/design_widgets/stress_model.dart';
import 'package:emosense/main.dart';
import 'package:fl_chart/fl_chart.dart';
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
  double _averageStressLevel = 0.0;
  StressModel _currentStressLevel = stressModels.last;

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
    _resetToToday();
    setState(() {
      _fetchDataForSelectedDate(); // Fetch data on initialization
    });
  }

  Future<void> _fetchDataForSelectedDate() async {
    try {
      print('Fetching data for $_selectedDate');

      final uid = globalUID;

      // Convert formattedDate to DateTime for filtering
      DateTime dateTime = DateFormat('E, d MMM, yyyy').parse(formattedDate);

      final startOfDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
      final endOfDay = startOfDay.add(const Duration(hours: 23, minutes: 59, seconds: 59));

      final emotionSnapshot = await FirebaseFirestore.instance
          .collection('emotionRecords')
          .where('uid', isEqualTo: uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThan: endOfDay)
          .get();

      List<Map<String, dynamic>> emotions = [];

      print(emotionSnapshot.docs);

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
      // Calculate stress level counts
      stressCounts = _calculateStressLevelCounts(emotions);

      print("Stress Counts: $stressCounts");

      setState(() {
        _emotionForToday = emotions;
      });
    } catch (error) {
      showAlert(context, 'Error', 'Error fetching data: $error');
    }
  }

  void _calculateAverageStressLevel(List<Map<String, dynamic>> emotions) {
    if (emotions.isNotEmpty) {
      double totalStress = 0.0;
      for (var emotion in emotions) {
        // Convert stressLevel to double, handling potential conversion errors
        try {
          totalStress += double.parse(emotion['stressLevel'] as String);
        } catch (e) {
          print('Error converting stress level to double: $e');
        }
      }
      print('Total Stress Level: $totalStress');
      _averageStressLevel = totalStress / emotions.length;
      print('Average Stress Level: $_averageStressLevel');

      // Get the current stress level based on the average stress level
      _currentStressLevel = getStressLevel(_averageStressLevel);

    } else {
      _averageStressLevel = 0.0; // No emotions recorded for the day
      _currentStressLevel = stressModels.last; // Set to Low or default level
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

    for (var emotion in emotions) {
      // Fetch stress level as dynamic and handle potential type issues
      var stressLevelValue = emotion['stressLevel'];

      // Ensure stressLevelValue is a double
      double stressLevelAsDouble;
      if (stressLevelValue is String) {
        // Convert String to double
        stressLevelAsDouble = double.tryParse(stressLevelValue) ?? 2.0; // Default to 2.0 if conversion fails
      } else if (stressLevelValue is double) {
        stressLevelAsDouble = stressLevelValue;
      } else {
        print('Warning: Unrecognized stress level type: ${stressLevelValue.runtimeType}');
        continue; // Skip this iteration if the type is not recognized
      }

      String stressLevel = getStressLevelAsString(stressLevelAsDouble); // Map it to a string

      if (stressCounts.containsKey(stressLevel)) {
        stressCounts[stressLevel] = (stressCounts[stressLevel] ?? 0) + 1;
      } else {
        // Error handling for unrecognized stress levels
        print('Warning: Unrecognized stress level: $stressLevelAsDouble');
      }
    }

    print('Stress Counts: $stressCounts'); // Debug output to verify the counts
    return stressCounts;
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

  void _resetToToday() {
    setState(() {
      _selectedDate = DateTime.now(); // Reset to today's date
      _updateFormattedDate(); // Update the date display based on the selected view
      _fetchDataForSelectedDate(); // Fetch the data for today
    });
  }

  void _updateFormattedDate() {
    formattedDate = DateFormat('E, d MMM, yyyy').format(_selectedDate);
  }

  void _showPreviousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(Duration(days: 1));
      _updateFormattedDate();
      _fetchDataForSelectedDate(); // Fetch data for the new date
    });
  }

  void _showNextDay() {
    if (!_isToday()) {
      setState(() {
        _selectedDate = _selectedDate.add(Duration(days: 1));
        _updateFormattedDate();
        _fetchDataForSelectedDate(); // Fetch data for the new date
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

    // Get the latest emotion for display
    Map<String, dynamic>? latestEmotion;
    if (_emotionForToday.isNotEmpty) {
      latestEmotion = _emotionForToday.last;
    }

    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: screenHeight * 0.02,
                icon: Icon(Icons.arrow_back_ios_outlined),
                onPressed: _showPreviousDay,
              ),
              Text(
                formattedDate,
                style: titleBlack.copyWith(fontSize: screenHeight * 0.02),
              ),
              IconButton(
                iconSize: screenHeight * 0.02,
                icon: Icon(Icons.arrow_forward_ios_outlined),
                onPressed: _showNextDay,
                color: _isToday() ? AppColors.textFieldColor : null,
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
                // Today's Emotion
                _buildEmotionContainer(
                    latestEmotion != null ? _getEmotionIcon(latestEmotion['emotion'], screenHeight * 0.4)
                        : _getDefaultIcon(screenHeight * 0.08)),
                // Stress Level
                _buildStressLevelContainer(),
              ],
            ),
          ),
        ),
        _buildEmotionCountChart(context),
        SizedBox(height: 25),
      ],
    );
  }

  Widget _buildEmotionContainer(Widget icon) {
    return Container(
      height: 185,
      width: 157,
      padding: EdgeInsets.all(10),
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
            padding: const EdgeInsets.only(left: 4, right: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                  'Today\'s Emotion',
                style: titleBlack.copyWith(fontSize: 14),
              ),
            ),
          ),
          Center(child: icon), // Display the latest emotion icon and resize the icon to 180
        ],
      ),
    );
  }

  Widget _buildStressLevelContainer() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        Container(
        height: 185,
        width: 158,
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
                  style: titleBlack.copyWith(fontSize: 14),
                ),
              ),
            ),
            // Add the half pie chart for stress levels here if needed
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
                  color: _currentStressLevel.containerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${_currentStressLevel.level}', // Show the current stress level
                    style: titleBlack.copyWith(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
        Positioned(
          top: 5,
          right: 5,
          child: Tooltip(
            message: "This chart shows the distribution of stress levels throughout the day. "
                "The stress level displayed below is the average stress throughout the day.",
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
              color: Colors.grey,
              size: 19,
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
    for (var emotion in _emotionForToday) {
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
    return Container(
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
    );
  }

  Widget _getDefaultIcon(double iconSize) {
    return Image.asset(
      'assets/logo.png',
      width: 120,
    );
  }
}

